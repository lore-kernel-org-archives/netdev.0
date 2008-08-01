From: "Adam Langley" <agl@imperialviolet.org>
Subject: [PATCH] MD5: Fix MD5 signatures on certain ACK packets
Date: Thu, 31 Jul 2008 19:56:31 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069050@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:33555 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbYHAC6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 22:58:15 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1144480wfd.4
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2008 19:58:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed, looking at tcpdumps, that timewait ACKs were getting sent with an
incorrect MD5 signature when signatures were enabled.

I broke this in 49a72dfb8814c2d65bd9f8c9c6daf6395a1ec58d. I didn't take into
account that the skb passed to tcp_*_send_ack was the inbound packet, thus the
source and dest addresses need to be swapped when calculating the MD5
pseudoheader.

Signed-off-by: Adam Langley <agl@imperialviolet.org>
---

 net/ipv4/tcp_ipv4.c |    4 ++--
 net/ipv6/tcp_ipv6.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b3875c0..91a8cfd 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -655,8 +655,8 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 		rep.th.doff = arg.iov[0].iov_len/4;
 
 		tcp_v4_md5_hash_hdr((__u8 *) &rep.opt[offset],
-				    key, ip_hdr(skb)->daddr,
-				    ip_hdr(skb)->saddr, &rep.th);
+				    key, ip_hdr(skb)->saddr,
+				    ip_hdr(skb)->daddr, &rep.th);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1db4521..1bcdcbc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1094,8 +1094,8 @@ static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32
 		*topt++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
 				(TCPOPT_MD5SIG << 8) | TCPOLEN_MD5SIG);
 		tcp_v6_md5_hash_hdr((__u8 *)topt, key,
-				    &ipv6_hdr(skb)->daddr,
-				    &ipv6_hdr(skb)->saddr, t1);
+				    &ipv6_hdr(skb)->saddr,
+				    &ipv6_hdr(skb)->daddr, t1);
 	}
 #endif
 
