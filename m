From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/udp: slab-out-of-bounds Read in udp_recvmsg
Date: Wed, 15 Mar 2017 09:10:33 -0700
Message-ID: <1489594233.28631.152.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1D28E435-EDFC-4E01-A3CE-28C83FBD27F4@gmail.com>
         <CALRZ7UuGJMuEDfzF=J6ddQD9RZSvqWQZt5-Aer68Mde5SCG79w@mail.gmail.com>
         <CACT4Y+aKW-yNfdWBvAWck3xNFKKeKEf8BNOmtFg2EZZjN98BVg@mail.gmail.com>
         <1489593673.28631.150.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?Q?=EC=AA=BC=EB=A5=B4?= <zzoru007@gmail.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Cardwell <ncardwell@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489593673.28631.150.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-03-15 at 09:01 -0700, Eric Dumazet wrote:
> On Wed, 2017-03-15 at 16:41 +0100, Dmitry Vyukov wrote:
> > On Wed, Mar 15, 2017 at 4:25 PM, 쪼르 <zzoru007@gmail.com> wrote:
> > > It seems that attacker can leak kernel memory(slab) by this vulnerability.
> > > I make a PoC code, and it works well on
> > > ae50dfd61665086e617cc9e554a1285d52765670.
> > > but, I found that PoC wasn't work on Ubuntu16.04.02 4.4.0-64-generic
> > > #85-Ubuntu SMP.
> > 
> > 
> > Do you know why it is not working on Ubuntu16.04.02?
> > Is it because the source bug is not present there? Or maybe you need a
> > slightly different poc for that version?
> > 
> 
> Seems to be a side effect of a recent commit
> 
> ( 1c885808e45601b2b6f68b30ac1d999e10b6f606 )


Can you try this fix ?

diff --git a/net/socket.c b/net/socket.c
index e034fe4164beec7731c68ba2bc6920627741561b..9b9a8eca81efa4d310be4376eb07c12614f7b562 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -692,12 +692,17 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
 		empty = 0;
 	if (!empty) {
+		unsigned int hlen = skb_headlen(skb);
+
 		put_cmsg(msg, SOL_SOCKET,
 			 SCM_TIMESTAMPING, sizeof(tss), &tss);
 
-		if (skb->len && (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS))
+		if (hlen &&
+		    (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS) &&
+		    sk->sk_protocol == IPPROTO_TCP &&
+		    sk->sk_type == SOCK_STREAM)
 			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_OPT_STATS,
-				 skb->len, skb->data);
+				 hlen, skb->data);
 	}
 }
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
