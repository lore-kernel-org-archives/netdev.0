From: Richard Weinberger <rw@linutronix.de>
Subject: [PATCH 3/5] nf_log: Export dump_packet() and dump_mac_header() functions
Date: Wed, 18 Jan 2012 23:43:28 +0100
Message-ID: <1326926610-17830-4-git-send-email-rw@linutronix.de>
References: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, Richard Weinberger <richard@nod.at>
To: netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard@nod.at>


Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/net/netfilter/nf_log.h |   19 +++++++++++++++++++
 net/ipv4/netfilter/ipt_LOG.c   |   12 +++++++-----
 net/ipv6/netfilter/ip6t_LOG.c  |   12 +++++++-----
 3 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
index e991bd0..c0f2b27 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -61,5 +61,24 @@ void nf_log_packet(u_int8_t pf,
 		   const struct net_device *out,
 		   const struct nf_loginfo *li,
 		   const char *fmt, ...);
+struct sbuff;
+void ipt_dump_packet(struct sbuff *m,
+	const struct nf_loginfo *info,
+	const struct sk_buff *skb,
+	unsigned int iphoff);
+
+void ipt_dump_mac_header(struct sbuff *m,
+	const struct nf_loginfo *info,
+	const struct sk_buff *skb);
+
+void ip6t_dump_packet(struct sbuff *m,
+	const struct nf_loginfo *info,
+	const struct sk_buff *skb,
+	unsigned int iphoff,
+	int recurse);
+
+void ip6t_dump_mac_header(struct sbuff *m,
+	const struct nf_loginfo *info,
+	const struct sk_buff *skb);
 
 #endif /* _NF_LOG_H */
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index d76d6c9..8ec9d2b 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -31,7 +31,7 @@ MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("Xtables: IPv4 packet logging to syslog");
 
 /* One level of recursion won't kill us */
-static void dump_packet(struct sbuff *m,
+void ipt_dump_packet(struct sbuff *m,
 			const struct nf_loginfo *info,
 			const struct sk_buff *skb,
 			unsigned int iphoff)
@@ -270,7 +270,7 @@ static void dump_packet(struct sbuff *m,
 			/* Max length: 3+maxlen */
 			if (!iphoff) { /* Only recurse once. */
 				sb_add(m, "[");
-				dump_packet(m, info, skb,
+				ipt_dump_packet(m, info, skb,
 					    iphoff + ih->ihl*4+sizeof(_icmph));
 				sb_add(m, "] ");
 			}
@@ -362,8 +362,9 @@ static void dump_packet(struct sbuff *m,
 	/* maxlen =  IP + ICMP +  IP + max(TCP,UDP,ICMP,unknown) */
 	/* maxlen = 230+   91  + 230 + 252 = 803 */
 }
+EXPORT_SYMBOL_GPL(ipt_dump_packet);
 
-static void dump_mac_header(struct sbuff *m,
+void ipt_dump_mac_header(struct sbuff *m,
 			    const struct nf_loginfo *info,
 			    const struct sk_buff *skb)
 {
@@ -399,6 +400,7 @@ fallback:
 	}
 	sb_add(m, " ");
 }
+EXPORT_SYMBOL_GPL(ipt_dump_mac_header);
 
 static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
@@ -443,9 +445,9 @@ ipt_log_packet(u_int8_t pf,
 #endif
 
 	if (in != NULL)
-		dump_mac_header(m, loginfo, skb);
+		ipt_dump_mac_header(m, loginfo, skb);
 
-	dump_packet(m, loginfo, skb, 0);
+	ipt_dump_packet(m, loginfo, skb, 0);
 
 	sb_close(m);
 }
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index e6af8d7..c6abacb 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -34,7 +34,7 @@ struct in_device;
 #include <linux/netfilter_ipv6/ip6t_LOG.h>
 
 /* One level of recursion won't kill us */
-static void dump_packet(struct sbuff *m,
+void ip6t_dump_packet(struct sbuff *m,
 			const struct nf_loginfo *info,
 			const struct sk_buff *skb, unsigned int ip6hoff,
 			int recurse)
@@ -341,7 +341,7 @@ static void dump_packet(struct sbuff *m,
 			/* Max length: 3+maxlen */
 			if (recurse) {
 				sb_add(m, "[");
-				dump_packet(m, info, skb,
+				ip6t_dump_packet(m, info, skb,
 					    ptr + sizeof(_icmp6h), 0);
 				sb_add(m, "] ");
 			}
@@ -371,8 +371,9 @@ static void dump_packet(struct sbuff *m,
 	if (!recurse && skb->mark)
 		sb_add(m, "MARK=0x%x ", skb->mark);
 }
+EXPORT_SYMBOL(ip6t_dump_packet);
 
-static void dump_mac_header(struct sbuff *m,
+void ip6t_dump_mac_header(struct sbuff *m,
 			    const struct nf_loginfo *info,
 			    const struct sk_buff *skb)
 {
@@ -422,6 +423,7 @@ fallback:
 	} else
 		sb_add(m, " ");
 }
+EXPORT_SYMBOL(ip6t_dump_mac_header);
 
 static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
@@ -453,9 +455,9 @@ ip6t_log_packet(u_int8_t pf,
 	       out ? out->name : "");
 
 	if (in != NULL)
-		dump_mac_header(m, loginfo, skb);
+		ip6t_dump_mac_header(m, loginfo, skb);
 
-	dump_packet(m, loginfo, skb, skb_network_offset(skb), 1);
+	ip6t_dump_packet(m, loginfo, skb, skb_network_offset(skb), 1);
 
 	sb_close(m);
 }
-- 
1.7.7
