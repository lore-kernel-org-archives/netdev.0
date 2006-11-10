From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: optimize echo reply checksum calculation
Date: Fri, 10 Nov 2006 11:25:53 -0500
Message-ID: <4554A811.5060402@hp.com>
References: <20061108221332.GI29920@ftp.linux.org.uk>	<45536622.90708@hp.com> <20061109.151402.15590179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090104080204050707070704"
Cc: viro@ftp.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:57569 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1946761AbWKJQZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 11:25:55 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061109.151402.15590179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090104080204050707070704
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Since the only difference between echo requests and echo replies is the 
ICMPv6 type value (which is a difference of 1), just subtracting one 
from the request checksum will result in the correct checksum for the reply.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------090104080204050707070704
Content-Type: text/x-patch;
 name="no.cksum.echo.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="no.cksum.echo.diff"

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index dbb9b1f..ee04610 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -212,7 +212,7 @@ static __inline__ int opt_unrec(struct s
 	return (*op & 0xC0) == 0x80;
 }
 
-static int icmpv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct icmp6hdr *thdr, int len)
+static int icmpv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct icmp6hdr *thdr, int len, int cksum_needed)
 {
 	struct sk_buff *skb;
 	struct icmp6hdr *icmp6h;
@@ -223,7 +223,9 @@ static int icmpv6_push_pending_frames(st
 
 	icmp6h = (struct icmp6hdr*) skb->h.raw;
 	memcpy(icmp6h, thdr, sizeof(struct icmp6hdr));
-	icmp6h->icmp6_cksum = 0;
+
+	if (!cksum_needed)
+		goto sendit;
 
 	if (skb_queue_len(&sk->sk_write_queue) == 1) {
 		skb->csum = csum_partial((char *)icmp6h,
@@ -246,6 +248,7 @@ static int icmpv6_push_pending_frames(st
 					   len, fl->proto, tmp_csum);
 		icmp6h->icmp6_cksum = tmp_csum;
 	}
+sendit:
 	ip6_push_pending_frames(sk);
 out:
 	return err;
@@ -451,7 +454,7 @@ void icmpv6_send(struct sk_buff *skb, in
 		ip6_flush_pending_frames(sk);
 		goto out_put;
 	}
-	err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, len + sizeof(struct icmp6hdr));
+	err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, len + sizeof(struct icmp6hdr), 1);
 
 	if (type >= ICMPV6_DEST_UNREACH && type <= ICMPV6_PARAMPROB)
 		ICMP6_INC_STATS_OFFSET_BH(idev, ICMP6_MIB_OUTDESTUNREACHS, type - ICMPV6_DEST_UNREACH);
@@ -489,6 +492,14 @@ static void icmpv6_echo_reply(struct sk_
 	memcpy(&tmp_hdr, icmph, sizeof(tmp_hdr));
 	tmp_hdr.icmp6_type = ICMPV6_ECHO_REPLY;
 
+	/*
+	 * The only difference between echo requests and echo replies is the
+	 * ICMPv6 type value (which is a difference of 1).  So if we subtract
+	 * one from the request checksum, it will result in the correct
+	 * checksum for the reply.
+	 */
+	tmp_hdr.icmp6_cksum--;
+
 	memset(&fl, 0, sizeof(fl));
 	fl.proto = IPPROTO_ICMPV6;
 	ipv6_addr_copy(&fl.fl6_dst, &skb->nh.ipv6h->saddr);
@@ -540,7 +551,7 @@ static void icmpv6_echo_reply(struct sk_
 		ip6_flush_pending_frames(sk);
 		goto out_put;
 	}
-	err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, skb->len + sizeof(struct icmp6hdr));
+	err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, skb->len + sizeof(struct icmp6hdr), 0);
 
         ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTECHOREPLIES);
         ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);

--------------090104080204050707070704--
