From: kaber@trash.net
Subject: [PATCH 24/84] netfilter: xtables: remove almost-unused xt_match_param.data member
Date: Mon, 10 May 2010 22:17:55 +0200
Message-ID: <1273522735-24672-25-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

This member is taking up a "long" per match, yet is only used by one
module out of the roughly 90 modules, ip6t_hbh. ip6t_hbh can be
restructured a little to accomodate for the lack of the .data member.
This variant uses checking the par->match address, which should avoid
having to add two extra functions, including calls, i.e.

(hbh_mt6: call hbhdst_mt6(skb, par, NEXTHDR_OPT),
dst_mt6: call hbhdst_mt6(skb, par, NEXTHDR_DEST))

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h |    3 ---
 net/ipv6/netfilter/ip6t_hbh.c      |    9 ++++++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index c68ff82..cf91473 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -315,9 +315,6 @@ struct xt_match {
 	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
 	struct module *me;
 
-	/* Free to use by each match */
-	unsigned long data;
-
 	const char *table;
 	unsigned int matchsize;
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index cbe8dec..82593c8 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -41,6 +41,8 @@ MODULE_ALIAS("ip6t_dst");
  *	5	-> RTALERT 2 x x
  */
 
+static struct xt_match hbh_mt6_reg[] __read_mostly;
+
 static bool
 hbh_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 {
@@ -58,7 +60,9 @@ hbh_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 	unsigned int optlen;
 	int err;
 
-	err = ipv6_find_hdr(skb, &ptr, par->match->data, NULL);
+	err = ipv6_find_hdr(skb, &ptr,
+			    (par->match == &hbh_mt6_reg[0]) ?
+			    NEXTHDR_HOP : NEXTHDR_DEST, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
 			*par->hotdrop = true;
@@ -179,13 +183,13 @@ static bool hbh_mt6_check(const struct xt_mtchk_param *par)
 
 static struct xt_match hbh_mt6_reg[] __read_mostly = {
 	{
+		/* Note, hbh_mt6 relies on the order of hbh_mt6_reg */
 		.name		= "hbh",
 		.family		= NFPROTO_IPV6,
 		.match		= hbh_mt6,
 		.matchsize	= sizeof(struct ip6t_opts),
 		.checkentry	= hbh_mt6_check,
 		.me		= THIS_MODULE,
-		.data		= NEXTHDR_HOP,
 	},
 	{
 		.name		= "dst",
@@ -194,7 +198,6 @@ static struct xt_match hbh_mt6_reg[] __read_mostly = {
 		.matchsize	= sizeof(struct ip6t_opts),
 		.checkentry	= hbh_mt6_check,
 		.me		= THIS_MODULE,
-		.data		= NEXTHDR_DEST,
 	},
 };
 
-- 
1.7.0.4

