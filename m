From: David Miller <davem@davemloft.net>
Subject: Re: a problem tcp_v4_err()
Date: Fri, 12 Nov 2010 11:22:24 -0800 (PST)
Message-ID: <20101112.112224.112610807.davem@davemloft.net>
References: <1289585578.3185.268.camel@edumazet-laptop>
	<20101112182959.GA20459@ms2.inr.ac.ru>
	<1289586803.3185.275.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, kaber@trash.net, equinox@diac24.net,
	eparis@redhat.com, hzhong@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, paul.moore@hp.com,
	damian@tvk.rwth-aachen.de
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289586803.3185.275.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Nov 2010 19:33:23 +0100

> I CC Damian Lukowski in my previous answer (and this one too)

Probably the safest fix is this:

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8f8527d..69ccbc1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -415,6 +415,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		    !icsk->icsk_backoff)
 			break;
 
+		if (sock_owned_by_user(sk))
+			break;
+
 		icsk->icsk_backoff--;
 		inet_csk(sk)->icsk_rto = __tcp_set_rto(tp) <<
 					 icsk->icsk_backoff;
@@ -429,11 +432,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		if (remaining) {
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 						  remaining, TCP_RTO_MAX);
-		} else if (sock_owned_by_user(sk)) {
-			/* RTO revert clocked out retransmission,
-			 * but socket is locked. Will defer. */
-			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-						  HZ/20, TCP_RTO_MAX);
 		} else {
 			/* RTO revert clocked out retransmission.
 			 * Will retransmit now */
