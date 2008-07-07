From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 5/7] MIB: add struct net to ICMP_INC_STATS_BH
Date: Mon, 07 Jul 2008 14:52:19 +0400
Message-ID: <4871F563.4050800@openvz.org>
References: <4871F2D8.8030502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54604 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752724AbYGGKyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 06:54:54 -0400
In-Reply-To: <4871F2D8.8030502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/icmp.h  |    2 +-
 net/dccp/ipv4.c     |    4 ++--
 net/ipv4/icmp.c     |   10 +++++-----
 net/ipv4/tcp_ipv4.c |    4 ++--
 net/ipv4/udp.c      |    2 +-
 net/sctp/input.c    |    5 +++--
 6 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index c86fef8..e2ae640 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -32,7 +32,7 @@ extern struct icmp_err icmp_err_convert[];
 DECLARE_SNMP_STAT(struct icmp_mib, icmp_statistics);
 DECLARE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
 #define ICMP_INC_STATS(net, field)	SNMP_INC_STATS(icmp_statistics, field)
-#define ICMP_INC_STATS_BH(field)	SNMP_INC_STATS_BH(icmp_statistics, field)
+#define ICMP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH(icmp_statistics, field)
 #define ICMPMSGOUT_INC_STATS(field)	SNMP_INC_STATS(icmpmsg_statistics, field+256)
 #define ICMPMSGIN_INC_STATS_BH(field)	SNMP_INC_STATS_BH(icmpmsg_statistics, field)
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index cc4f334..2b03c47 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -208,7 +208,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	struct net *net = dev_net(skb->dev);
 
 	if (skb->len < (iph->ihl << 2) + 8) {
-		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
 
@@ -216,7 +216,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 			iph->daddr, dh->dccph_dport,
 			iph->saddr, dh->dccph_sport, inet_iif(skb));
 	if (sk == NULL) {
-		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index e94de41..56a7bbc 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -763,7 +763,7 @@ static void icmp_unreach(struct sk_buff *skb)
 out:
 	return;
 out_err:
-	ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+	ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 	goto out;
 }
 
@@ -803,7 +803,7 @@ static void icmp_redirect(struct sk_buff *skb)
 out:
 	return;
 out_err:
-	ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+	ICMP_INC_STATS_BH(dev_net(skb->dev), ICMP_MIB_INERRORS);
 	goto out;
 }
 
@@ -874,7 +874,7 @@ static void icmp_timestamp(struct sk_buff *skb)
 out:
 	return;
 out_err:
-	ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+	ICMP_INC_STATS_BH(dev_net(skb->dst->dev), ICMP_MIB_INERRORS);
 	goto out;
 }
 
@@ -994,7 +994,7 @@ int icmp_rcv(struct sk_buff *skb)
 		skb_set_network_header(skb, nh);
 	}
 
-	ICMP_INC_STATS_BH(ICMP_MIB_INMSGS);
+	ICMP_INC_STATS_BH(net, ICMP_MIB_INMSGS);
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
@@ -1053,7 +1053,7 @@ drop:
 	kfree_skb(skb);
 	return 0;
 error:
-	ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+	ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 	goto drop;
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ca41b77..0fefd44 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -346,14 +346,14 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 	struct net *net = dev_net(skb->dev);
 
 	if (skb->len < (iph->ihl << 2) + 8) {
-		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
 
 	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
 			iph->saddr, th->source, inet_iif(skb));
 	if (!sk) {
-		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;
 	}
 	if (sk->sk_state == TCP_TIME_WAIT) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9342cfd..fdd4faa 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -359,7 +359,7 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct hlist_head udptable[])
 	sk = __udp4_lib_lookup(net, iph->daddr, uh->dest,
 			iph->saddr, uh->source, skb->dev->ifindex, udptable);
 	if (sk == NULL) {
-		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;	/* No socket for error */
 	}
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index d354a23..ed8834e 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -61,6 +61,7 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 #include <net/sctp/checksum.h>
+#include <net/net_namespace.h>
 
 /* Forward declarations for internal helpers. */
 static int sctp_rcv_ootb(struct sk_buff *);
@@ -534,7 +535,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	int err;
 
 	if (skb->len < ihlen + 8) {
-		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(&init_net, ICMP_MIB_INERRORS);
 		return;
 	}
 
@@ -548,7 +549,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	skb->network_header = saveip;
 	skb->transport_header = savesctp;
 	if (!sk) {
-		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(&init_net, ICMP_MIB_INERRORS);
 		return;
 	}
 	/* Warning:  The sock lock is held.  Remember to call
-- 
1.5.3.4

