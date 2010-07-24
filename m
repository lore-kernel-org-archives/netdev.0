From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] xt_length: support ipv6 jumbo frames
Date: Sat, 24 Jul 2010 11:32:34 +0800
Message-ID: <1279942354-23961-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to support ipv6 jumbo frames, the type of min and max in xt_length_info
is changed to __u32. Since the structure xt_length_info is updated, the revision
is updated to 1 from 0, and the old revision is still reserved to keep binary
compatible with the older version of iptables.

skb->len is used to keep consistency.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netfilter/xt_length.h |    2 +-
 net/netfilter/xt_length.c           |   36 +++++++++++++++++++++++++++---------
 2 files changed, 28 insertions(+), 10 deletions(-)
diff --git a/include/linux/netfilter/xt_length.h b/include/linux/netfilter/xt_length.h
index b82ed7c..a12785c 100644
--- a/include/linux/netfilter/xt_length.h
+++ b/include/linux/netfilter/xt_length.h
@@ -4,7 +4,7 @@
 #include <linux/types.h>
 
 struct xt_length_info {
-    __u16	min, max;
+    __u32	min, max;
     __u8	invert;
 };
 
diff --git a/net/netfilter/xt_length.c b/net/netfilter/xt_length.c
index 176e557..579f340 100644
--- a/net/netfilter/xt_length.c
+++ b/net/netfilter/xt_length.c
@@ -20,21 +20,23 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_length");
 MODULE_ALIAS("ip6t_length");
 
-static bool
-length_mt(const struct sk_buff *skb, struct xt_action_param *par)
+struct xt_length_info_v0 {
+    __u16	min, max;
+    __u8	invert;
+};
+
+static bool length_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	const struct xt_length_info *info = par->matchinfo;
-	u_int16_t pktlen = ntohs(ip_hdr(skb)->tot_len);
+	const struct xt_length_info_v0 *info = par->matchinfo;
+	u_int16_t pktlen = skb->len;
 
 	return (pktlen >= info->min && pktlen <= info->max) ^ info->invert;
 }
 
-static bool
-length_mt6(const struct sk_buff *skb, struct xt_action_param *par)
+static bool length_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_length_info *info = par->matchinfo;
-	const u_int16_t pktlen = ntohs(ipv6_hdr(skb)->payload_len) +
-				 sizeof(struct ipv6hdr);
+	u_int32_t pktlen = skb->len;
 
 	return (pktlen >= info->min && pktlen <= info->max) ^ info->invert;
 }
@@ -43,16 +45,32 @@ static struct xt_match length_mt_reg[] __read_mostly = {
 	{
 		.name		= "length",
 		.family		= NFPROTO_IPV4,
+		.match		= length_mt_v0,
+		.matchsize	= sizeof(struct xt_length_info_v0),
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "length",
+		.family		= NFPROTO_IPV6,
+		.match		= length_mt_v0,
+		.matchsize	= sizeof(struct xt_length_info_v0),
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "length",
+		.family		= NFPROTO_IPV4,
 		.match		= length_mt,
 		.matchsize	= sizeof(struct xt_length_info),
 		.me		= THIS_MODULE,
+		.revision	= 1,
 	},
 	{
 		.name		= "length",
 		.family		= NFPROTO_IPV6,
-		.match		= length_mt6,
+		.match		= length_mt,
 		.matchsize	= sizeof(struct xt_length_info),
 		.me		= THIS_MODULE,
+		.revision	= 1,
 	},
 };
 
