From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH] network: return errors if we know tcp_connect failed
Date: Thu, 11 Nov 2010 16:03:41 -0500
Message-ID: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

THIS PATCH IS VERY POSSIBLY WRONG!  But if it is I want some feedback.

Basically what I found was that if I added an iptables rule like so:

iptables -A OUTPUT -p tcp --dport 80 -j DROP

And then ran a web browser like links it would just hang on 'establishing
connection.'  I expected that the application would immediately, or at least
very quickly, get notified that the connect failed.   This waiting for timeout
would be expected if something else dropped the SYN or if we were dropping the
SYN/ACK packet coming back, but I figured if we knew we threw away the SYN we knew
right away that the connection was denied and we should be able to indicate
that to the application.  Yes, I realize this is little different than if the
SYN was dropped in the first network device, but it is different because we
know what happened!  We know that connect() call failed and that there isn't
anything coming back.

What I discovered was that we actually had 2 problems in making it possible.
For userspace to quickly realize the connect failed.  The first was a problem
in the netfilter code which wasn't passing errors back up the stack correctly,
due to what I believe to be a mistake in precedence rules.

http://marc.info/?l=netfilter-devel&m=128950262021804&w=2

And the second was that tcp_connect() was just ignoring the return value from
tcp_transmit_skb().  Maybe this was intentional but I really wish we could
find out that connect failed long before the minutes long timeout.  Once I
fixed both of those issues I find that links gets denied (with EPERM)
immediately when it calls connect().  Is this wrong?  Is this bad to tell
userspace more quickly what happened?  Does passing this error code back up
the stack here break something else?  Why do some functions seem to pay
attention to tcp_transmit_skb() return codes and some functions just ignore
it?  What do others think?

NOT-AT-ALL-SIGNED-OFF-BY
---

 net/ipv4/tcp_output.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e961522..67b8535 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2592,6 +2592,7 @@ int tcp_connect(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *buff;
+	int ret;
 
 	tcp_connect_init(sk);
 
@@ -2614,7 +2615,7 @@ int tcp_connect(struct sock *sk)
 	sk->sk_wmem_queued += buff->truesize;
 	sk_mem_charge(sk, buff->truesize);
 	tp->packets_out += tcp_skb_pcount(buff);
-	tcp_transmit_skb(sk, buff, 1, sk->sk_allocation);
+	ret = tcp_transmit_skb(sk, buff, 1, sk->sk_allocation);
 
 	/* We change tp->snd_nxt after the tcp_transmit_skb() call
 	 * in order to make this packet get counted in tcpOutSegs.
@@ -2626,7 +2627,7 @@ int tcp_connect(struct sock *sk)
 	/* Timer for repeating the SYN until an answer. */
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 				  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL(tcp_connect);
 
