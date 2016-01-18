From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: hang in ip_finish_output
Date: Mon, 18 Jan 2016 08:21:52 -0800
Message-ID: <1453134112.1223.221.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+bdpCR_rmiDAUi8ge3iecBOpaAat6S3o_GDjt-p2c53BA@mail.gmail.com>
	 <CAEfhGixTRfTviSiaiqYHPDxxz2af4Xbm198WuM1dR6BQKojPxQ@mail.gmail.com>
	 <1452929396.1223.202.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1453086734.1223.215.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453086734.1223.215.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-01-17 at 19:12 -0800, Eric Dumazet wrote:
> On Fri, 2016-01-15 at 23:29 -0800, Eric Dumazet wrote:
> > On Fri, 2016-01-15 at 19:20 -0500, Craig Gallek wrote:
> > 
> > > I wasn't able to reproduce this exact stack trace, but I was able to
> > > cause soft lockup messages with a fork bomb of your test program.  It
> > > is certainly related to my recent SO_REUSEPORT change (reverting it
> > > seems to fix the problem).  I haven't completely figured out the exact
> > > cause yet, though.  Could you please post your configuration and
> > > exactly how you are running this 'parallel loop'?
> > 
> > There is a problem in the lookup functions (udp4_lib_lookup2() &
> > __udp4_lib_lookup())
> > 
> > Because of RCU SLAB_DESTROY_BY_RCU semantics (check
> > Documentation/RCU/rculist_nulls.txt for some details), you should not
> > call reuseport_select_sock(sk, ...) without taking a stable reference on
> > the sk socket. (and checking the lookup keys again)
> > 
> > This is because sk could be freed, re-used by a totally different UDP
> > socket on a different port, and the incoming frame(s) could be delivered
> > on the wrong socket/channel/application :(
> > 
> > Note that we discussed some time ago to remove SLAB_DESTROY_BY_RCU for
> > UDP sockets (and freeing them after rcu grace period instead), so make
> > UDP rx path faster, as we would no longer need to increment/decrement
> > the socket refcount. This also would remove the added false sharing on
> > sk_refcnt for the case the UDP socket serves as a tunnel (up->encap_rcv
> > being non NULL)
> 
> Hmm... not it looks you do the lookup , refcnt change, re-lookup just
> fine.
> 
> The problem here is that UDP connected sockets update the
> sk->sk_incoming_cpu from __udp_queue_rcv_skb()
> 
> This means that we can find the first socket in hash table with a
> matching incoming cpu, and badness == high_score + 1
> 
> Then, the reuseport_select_sock() can selects another socket from the
> array (using bpf or the hash )
> 
> We do the atomic_inc_not_zero_hint() to update sk_refcnt on the new
> socket, then compute_score2() returns high_score (< badness)
> 
> So we loop back to the beginning of udp4_lib_lookup2(), and we loop
> forever (as long as the first socket in hash table has still this match
> about incoming cpu)
> 
> In short, the recent SO_REUSE_PORT changes are not compatible with the
> SO_INCOMING_CPU ones, if connected UDP sockets are used.
> 
> A fix could be to not check sk_incoming_cpu on connected sockets (this
> makes really little sense, as this option was meant to spread traffic on
> UDP _servers_ ). Also it collides with SO_REUSEPORT notion of a group of
> sockets having the same score.
> 
> Dmitry, could you test it ? I could not get the trace you reported.

BTW, it could be the bug is hard to trigger because of IP early demux :

When connected UDP sockets are used, __udp4_lib_demux_lookup() returns
first socket found in the hash chain, so all incoming messages should be
delivered on this socket. (The normal reuseport hash/bpf spread does not
happen)

So to trigger the bug more easily we can disable early demux :

echo 0 >/proc/sys/net/ipv4/ip_early_demux

We also should disallow ip early demux on SO_REUSEPORT UDP sockets.

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index dc45b538e237..55954094ab17 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2026,7 +2026,8 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 	result = NULL;
 	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
 		if (INET_MATCH(sk, net, acookie,
-			       rmt_addr, loc_addr, ports, dif))
+			       rmt_addr, loc_addr, ports, dif) &&
+		    !sk->sk_reuseport)
 			result = sk;
 		/* Only check first socket in chain */
 		break;
