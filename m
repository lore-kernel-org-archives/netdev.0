From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 03/17] net: rename ICMP_INC_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:29 -0700
Message-ID: <1461800683-25034-4-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:32915 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbcD0Xo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:44:59 -0400
Received: by mail-pf0-f174.google.com with SMTP id 206so26374070pfu.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:44:58 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename ICMP_INC_STATS_BH() to __ICMP_INC_STATS()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/icmp.h  |  2 +-
 net/dccp/ipv4.c     |  4 ++--
 net/ipv4/icmp.c     | 16 ++++++++--------
 net/ipv4/tcp_ipv4.c |  2 +-
 net/ipv4/udp.c      |  2 +-
 net/sctp/input.c    |  2 +-
 6 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index 970028e13382..5a60ce819078 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -30,7 +30,7 @@ struct icmp_err {
 
 extern const struct icmp_err icmp_err_convert[];
 #define ICMP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmp_statistics, field)
-#define ICMP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.icmp_statistics, field)
+#define __ICMP_INC_STATS(net, field)	SNMP_INC_STATS_BH((net)->mib.icmp_statistics, field)
 #define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field+256)
 #define ICMPMSGIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field)
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 4b78067669d6..14e30584e59d 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -247,7 +247,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 
 	if (skb->len < offset + sizeof(*dh) ||
 	    skb->len < offset + __dccp_basic_hdr_len(dh)) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;
 	}
 
@@ -256,7 +256,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 				       iph->saddr, ntohs(dh->dccph_sport),
 				       inet_iif(skb));
 	if (!sk) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;
 	}
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 6333489771ed..995fef9c5099 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -363,7 +363,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 			   icmp_param->data_len+icmp_param->head_len,
 			   icmp_param->head_len,
 			   ipc, rt, MSG_DONTWAIT) < 0) {
-		ICMP_INC_STATS_BH(sock_net(sk), ICMP_MIB_OUTERRORS);
+		__ICMP_INC_STATS(sock_net(sk), ICMP_MIB_OUTERRORS);
 		ip_flush_pending_frames(sk);
 	} else if ((skb = skb_peek(&sk->sk_write_queue)) != NULL) {
 		struct icmphdr *icmph = icmp_hdr(skb);
@@ -744,7 +744,7 @@ static void icmp_socket_deliver(struct sk_buff *skb, u32 info)
 	 * avoid additional coding at protocol handlers.
 	 */
 	if (!pskb_may_pull(skb, iph->ihl * 4 + 8)) {
-		ICMP_INC_STATS_BH(dev_net(skb->dev), ICMP_MIB_INERRORS);
+		__ICMP_INC_STATS(dev_net(skb->dev), ICMP_MIB_INERRORS);
 		return;
 	}
 
@@ -865,7 +865,7 @@ static bool icmp_unreach(struct sk_buff *skb)
 out:
 	return true;
 out_err:
-	ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+	__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 	return false;
 }
 
@@ -877,7 +877,7 @@ out_err:
 static bool icmp_redirect(struct sk_buff *skb)
 {
 	if (skb->len < sizeof(struct iphdr)) {
-		ICMP_INC_STATS_BH(dev_net(skb->dev), ICMP_MIB_INERRORS);
+		__ICMP_INC_STATS(dev_net(skb->dev), ICMP_MIB_INERRORS);
 		return false;
 	}
 
@@ -956,7 +956,7 @@ static bool icmp_timestamp(struct sk_buff *skb)
 	return true;
 
 out_err:
-	ICMP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ICMP_MIB_INERRORS);
+	__ICMP_INC_STATS(dev_net(skb_dst(skb)->dev), ICMP_MIB_INERRORS);
 	return false;
 }
 
@@ -996,7 +996,7 @@ int icmp_rcv(struct sk_buff *skb)
 		skb_set_network_header(skb, nh);
 	}
 
-	ICMP_INC_STATS_BH(net, ICMP_MIB_INMSGS);
+	__ICMP_INC_STATS(net, ICMP_MIB_INMSGS);
 
 	if (skb_checksum_simple_validate(skb))
 		goto csum_error;
@@ -1052,9 +1052,9 @@ drop:
 	kfree_skb(skb);
 	return 0;
 csum_error:
-	ICMP_INC_STATS_BH(net, ICMP_MIB_CSUMERRORS);
+	__ICMP_INC_STATS(net, ICMP_MIB_CSUMERRORS);
 error:
-	ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+	__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 	goto drop;
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d2a5763e5abc..ebd8f3b9e61b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -372,7 +372,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 				       th->dest, iph->saddr, ntohs(th->source),
 				       inet_iif(icmp_skb));
 	if (!sk) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;
 	}
 	if (sk->sk_state == TCP_TIME_WAIT) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 00f5de9a155e..6b004b838966 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -688,7 +688,7 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 			iph->saddr, uh->source, skb->dev->ifindex, udptable,
 			NULL);
 	if (!sk) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;	/* No socket for error */
 	}
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 00b8445364e3..f8eca792dbcf 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -589,7 +589,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	skb->network_header = saveip;
 	skb->transport_header = savesctp;
 	if (!sk) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
 		return;
 	}
 	/* Warning:  The sock lock is held.  Remember to call
-- 
2.8.0.rc3.226.g39d4020
