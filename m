From: kaber@trash.net
Subject: [PATCH 8/9] netfilter: ipt_LOG/ip6t_LOG: add option to print decoded MAC header
Date: Fri,  2 Jul 2010 11:52:21 +0200
Message-ID: <1278064342-19059-9-git-send-email-kaber@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1278064342-19059-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The LOG targets print the entire MAC header as one long string, which is not
readable very well:

IN=eth0 OUT= MAC=00:15:f2:24:91:f8:00:1b:24:dc:61:e6:08:00 ...

Add an option to decode known header formats (currently just ARPHRD_ETHER devices)
in their individual fields:

IN=eth0 OUT= MACSRC=00:1b:24:dc:61:e6 MACDST=00:15:f2:24:91:f8 MACPROTO=0800 ...
IN=eth0 OUT= MACSRC=00:1b:24:dc:61:e6 MACDST=00:15:f2:24:91:f8 MACPROTO=86dd ...

The option needs to be explicitly enabled by userspace to avoid breaking
existing parsers.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter_ipv4/ipt_LOG.h  |    3 +-
 include/linux/netfilter_ipv6/ip6t_LOG.h |    3 +-
 net/ipv4/netfilter/ipt_LOG.c            |   54 +++++++++++++++-----
 net/ipv6/netfilter/ip6t_LOG.c           |   81 ++++++++++++++++++++-----------
 4 files changed, 97 insertions(+), 44 deletions(-)

diff --git a/include/linux/netfilter_ipv4/ipt_LOG.h b/include/linux/netfilter_ipv4/ipt_LOG.h
index 90fa652..dcdbadf 100644
--- a/include/linux/netfilter_ipv4/ipt_LOG.h
+++ b/include/linux/netfilter_ipv4/ipt_LOG.h
@@ -7,7 +7,8 @@
 #define IPT_LOG_IPOPT		0x04	/* Log IP options */
 #define IPT_LOG_UID		0x08	/* Log UID owning local socket */
 #define IPT_LOG_NFLOG		0x10	/* Unsupported, don't reuse */
-#define IPT_LOG_MASK		0x1f
+#define IPT_LOG_MACDECODE	0x20	/* Decode MAC header */
+#define IPT_LOG_MASK		0x2f
 
 struct ipt_log_info {
 	unsigned char level;
diff --git a/include/linux/netfilter_ipv6/ip6t_LOG.h b/include/linux/netfilter_ipv6/ip6t_LOG.h
index 0d0119b..9dd5579 100644
--- a/include/linux/netfilter_ipv6/ip6t_LOG.h
+++ b/include/linux/netfilter_ipv6/ip6t_LOG.h
@@ -7,7 +7,8 @@
 #define IP6T_LOG_IPOPT		0x04	/* Log IP options */
 #define IP6T_LOG_UID		0x08	/* Log UID owning local socket */
 #define IP6T_LOG_NFLOG		0x10	/* Unsupported, don't use */
-#define IP6T_LOG_MASK		0x1f
+#define IP6T_LOG_MACDECODE	0x20	/* Decode MAC header */
+#define IP6T_LOG_MASK		0x2f
 
 struct ip6t_log_info {
 	unsigned char level;
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 0a452a5..915fc17 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -13,6 +13,7 @@
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/skbuff.h>
+#include <linux/if_arp.h>
 #include <linux/ip.h>
 #include <net/icmp.h>
 #include <net/udp.h>
@@ -363,6 +364,42 @@ static void dump_packet(const struct nf_loginfo *info,
 	/* maxlen = 230+   91  + 230 + 252 = 803 */
 }
 
+static void dump_mac_header(const struct nf_loginfo *info,
+			    const struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	unsigned int logflags = 0;
+
+	if (info->type == NF_LOG_TYPE_LOG)
+		logflags = info->u.log.logflags;
+
+	if (!(logflags & IPT_LOG_MACDECODE))
+		goto fallback;
+
+	switch (dev->type) {
+	case ARPHRD_ETHER:
+		printk("MACSRC=%pM MACDST=%pM MACPROTO=%04x ",
+		       eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
+		       ntohs(eth_hdr(skb)->h_proto));
+		return;
+	default:
+		break;
+	}
+
+fallback:
+	printk("MAC=");
+	if (dev->hard_header_len &&
+	    skb->mac_header != skb->network_header) {
+		const unsigned char *p = skb_mac_header(skb);
+		unsigned int i;
+
+		printk("%02x", *p++);
+		for (i = 1; i < dev->hard_header_len; i++, p++)
+			printk(":%02x", *p);
+	}
+	printk(" ");
+}
+
 static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
@@ -404,20 +441,9 @@ ipt_log_packet(u_int8_t pf,
 	}
 #endif
 
-	if (in && !out) {
-		/* MAC logging for input chain only. */
-		printk("MAC=");
-		if (skb->dev && skb->dev->hard_header_len &&
-		    skb->mac_header != skb->network_header) {
-			int i;
-			const unsigned char *p = skb_mac_header(skb);
-
-			printk("%02x", *p++);
-			for (i = 1; i < skb->dev->hard_header_len; i++, p++)
-				printk(":%02x", *p);
-		}
-		printk(" ");
-	}
+	/* MAC logging for input path only. */
+	if (in && !out)
+		dump_mac_header(loginfo, skb);
 
 	dump_packet(loginfo, skb, 0);
 	printk("\n");
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 4c7ddac..0a07ae7 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -373,6 +373,56 @@ static void dump_packet(const struct nf_loginfo *info,
 		printk("MARK=0x%x ", skb->mark);
 }
 
+static void dump_mac_header(const struct nf_loginfo *info,
+			    const struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	unsigned int logflags = 0;
+
+	if (info->type == NF_LOG_TYPE_LOG)
+		logflags = info->u.log.logflags;
+
+	if (!(logflags & IP6T_LOG_MACDECODE))
+		goto fallback;
+
+	switch (dev->type) {
+	case ARPHRD_ETHER:
+		printk("MACSRC=%pM MACDST=%pM MACPROTO=%04x ",
+		       eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
+		       ntohs(eth_hdr(skb)->h_proto));
+		return;
+	default:
+		break;
+	}
+
+fallback:
+	printk("MAC=");
+	if (dev->hard_header_len &&
+	    skb->mac_header != skb->network_header) {
+		const unsigned char *p = skb_mac_header(skb);
+		unsigned int len = dev->hard_header_len;
+		unsigned int i;
+
+		if (dev->type == ARPHRD_SIT &&
+		    (p -= ETH_HLEN) < skb->head)
+			p = NULL;
+
+		if (p != NULL) {
+			printk("%02x", *p++);
+			for (i = 1; i < len; i++)
+				printk(":%02x", p[i]);
+		}
+		printk(" ");
+
+		if (dev->type == ARPHRD_SIT) {
+			const struct iphdr *iph =
+				(struct iphdr *)skb_mac_header(skb);
+			printk("TUNNEL=%pI4->%pI4 ", &iph->saddr, &iph->daddr);
+		}
+	} else
+		printk(" ");
+}
+
 static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
@@ -400,35 +450,10 @@ ip6t_log_packet(u_int8_t pf,
 		prefix,
 		in ? in->name : "",
 		out ? out->name : "");
-	if (in && !out) {
-		unsigned int len;
-		/* MAC logging for input chain only. */
-		printk("MAC=");
-		if (skb->dev && (len = skb->dev->hard_header_len) &&
-		    skb->mac_header != skb->network_header) {
-			const unsigned char *p = skb_mac_header(skb);
-			int i;
-
-			if (skb->dev->type == ARPHRD_SIT &&
-			    (p -= ETH_HLEN) < skb->head)
-				p = NULL;
-
-			if (p != NULL) {
-				printk("%02x", *p++);
-				for (i = 1; i < len; i++)
-					printk(":%02x", p[i]);
-			}
-			printk(" ");
 
-			if (skb->dev->type == ARPHRD_SIT) {
-				const struct iphdr *iph =
-					(struct iphdr *)skb_mac_header(skb);
-				printk("TUNNEL=%pI4->%pI4 ",
-				       &iph->saddr, &iph->daddr);
-			}
-		} else
-			printk(" ");
-	}
+	/* MAC logging for input path only. */
+	if (in && !out)
+		dump_mac_header(loginfo, skb);
 
 	dump_packet(loginfo, skb, skb_network_offset(skb), 1);
 	printk("\n");
-- 
1.7.0.4

