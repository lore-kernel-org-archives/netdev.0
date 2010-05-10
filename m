From: kaber@trash.net
Subject: [PATCH 43/84] netfilter: xtables: change xt_target.checkentry return type
Date: Mon, 10 May 2010 22:18:14 +0200
Message-ID: <1273522735-24672-44-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Restore function signatures from bool to int so that we can report
memory allocation failures or similar using -ENOMEM rather than
always having to pass -EINVAL back.

// <smpl>
@@
type bool;
identifier check, par;
@@
-bool check
+int check
 (struct xt_tgchk_param *par) { ... }
// </smpl>

Minus the change it does to xt_ct_find_proto.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h  |    4 ++--
 net/bridge/netfilter/ebt_arpreply.c |    2 +-
 net/bridge/netfilter/ebt_dnat.c     |    2 +-
 net/bridge/netfilter/ebt_log.c      |    2 +-
 net/bridge/netfilter/ebt_mark.c     |    2 +-
 net/bridge/netfilter/ebt_nflog.c    |    2 +-
 net/bridge/netfilter/ebt_redirect.c |    2 +-
 net/bridge/netfilter/ebt_snat.c     |    2 +-
 net/bridge/netfilter/ebt_ulog.c     |    2 +-
 net/ipv4/netfilter/arpt_mangle.c    |    2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c  |    2 +-
 net/ipv4/netfilter/ipt_ECN.c        |    2 +-
 net/ipv4/netfilter/ipt_LOG.c        |    2 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c |    2 +-
 net/ipv4/netfilter/ipt_NETMAP.c     |    2 +-
 net/ipv4/netfilter/ipt_REDIRECT.c   |    2 +-
 net/ipv4/netfilter/ipt_REJECT.c     |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c       |    2 +-
 net/ipv4/netfilter/nf_nat_rule.c    |    4 ++--
 net/ipv6/netfilter/ip6t_LOG.c       |    2 +-
 net/ipv6/netfilter/ip6t_REJECT.c    |    2 +-
 net/netfilter/xt_CONNSECMARK.c      |    2 +-
 net/netfilter/xt_CT.c               |    2 +-
 net/netfilter/xt_DSCP.c             |    2 +-
 net/netfilter/xt_HL.c               |    4 ++--
 net/netfilter/xt_LED.c              |    2 +-
 net/netfilter/xt_NFLOG.c            |    2 +-
 net/netfilter/xt_NFQUEUE.c          |    2 +-
 net/netfilter/xt_RATEEST.c          |    2 +-
 net/netfilter/xt_SECMARK.c          |    2 +-
 net/netfilter/xt_TCPMSS.c           |    4 ++--
 net/netfilter/xt_TPROXY.c           |    2 +-
 net/netfilter/xt_connmark.c         |    2 +-
 33 files changed, 37 insertions(+), 37 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 33c1a62..1a65d45 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -342,8 +342,8 @@ struct xt_target {
 	/* Called when user tries to insert an entry of this type:
            hook_mask is a bitmask of hooks from which it can be
            called. */
-	/* Should return true or false. */
-	bool (*checkentry)(const struct xt_tgchk_param *);
+	/* Should return true or false, or an error code (-Exxxx). */
+	int (*checkentry)(const struct xt_tgchk_param *);
 
 	/* Called when entry of this type deleted. */
 	void (*destroy)(const struct xt_tgdtor_param *);
diff --git a/net/bridge/netfilter/ebt_arpreply.c b/net/bridge/netfilter/ebt_arpreply.c
index f392e9d..2491564 100644
--- a/net/bridge/netfilter/ebt_arpreply.c
+++ b/net/bridge/netfilter/ebt_arpreply.c
@@ -57,7 +57,7 @@ ebt_arpreply_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return info->target;
 }
 
-static bool ebt_arpreply_tg_check(const struct xt_tgchk_param *par)
+static int ebt_arpreply_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ebt_arpreply_info *info = par->targinfo;
 	const struct ebt_entry *e = par->entryinfo;
diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index 2bb40d7..5fddebe 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -26,7 +26,7 @@ ebt_dnat_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return info->target;
 }
 
-static bool ebt_dnat_tg_check(const struct xt_tgchk_param *par)
+static int ebt_dnat_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ebt_nat_info *info = par->targinfo;
 	unsigned int hook_mask;
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index e873924..a0aeac6 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -24,7 +24,7 @@
 
 static DEFINE_SPINLOCK(ebt_log_lock);
 
-static bool ebt_log_tg_check(const struct xt_tgchk_param *par)
+static int ebt_log_tg_check(const struct xt_tgchk_param *par)
 {
 	struct ebt_log_info *info = par->targinfo;
 
diff --git a/net/bridge/netfilter/ebt_mark.c b/net/bridge/netfilter/ebt_mark.c
index 2b5ce53..dd94daf 100644
--- a/net/bridge/netfilter/ebt_mark.c
+++ b/net/bridge/netfilter/ebt_mark.c
@@ -36,7 +36,7 @@ ebt_mark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return info->target | ~EBT_VERDICT_BITS;
 }
 
-static bool ebt_mark_tg_check(const struct xt_tgchk_param *par)
+static int ebt_mark_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ebt_mark_t_info *info = par->targinfo;
 	int tmp;
diff --git a/net/bridge/netfilter/ebt_nflog.c b/net/bridge/netfilter/ebt_nflog.c
index 40dbd24..1f2b7bb 100644
--- a/net/bridge/netfilter/ebt_nflog.c
+++ b/net/bridge/netfilter/ebt_nflog.c
@@ -35,7 +35,7 @@ ebt_nflog_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return EBT_CONTINUE;
 }
 
-static bool ebt_nflog_tg_check(const struct xt_tgchk_param *par)
+static int ebt_nflog_tg_check(const struct xt_tgchk_param *par)
 {
 	struct ebt_nflog_info *info = par->targinfo;
 
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index 9be8fbc..73c4d3a 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -32,7 +32,7 @@ ebt_redirect_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return info->target;
 }
 
-static bool ebt_redirect_tg_check(const struct xt_tgchk_param *par)
+static int ebt_redirect_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ebt_redirect_info *info = par->targinfo;
 	unsigned int hook_mask;
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index 9c7b520..94bcecd 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -42,7 +42,7 @@ out:
 	return info->target | ~EBT_VERDICT_BITS;
 }
 
-static bool ebt_snat_tg_check(const struct xt_tgchk_param *par)
+static int ebt_snat_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ebt_nat_info *info = par->targinfo;
 	int tmp;
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 789ea36..f554bc2 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -249,7 +249,7 @@ ebt_ulog_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return EBT_CONTINUE;
 }
 
-static bool ebt_ulog_tg_check(const struct xt_tgchk_param *par)
+static int ebt_ulog_tg_check(const struct xt_tgchk_param *par)
 {
 	struct ebt_ulog_info *uloginfo = par->targinfo;
 
diff --git a/net/ipv4/netfilter/arpt_mangle.c b/net/ipv4/netfilter/arpt_mangle.c
index b0d5b1d..4b51a02 100644
--- a/net/ipv4/netfilter/arpt_mangle.c
+++ b/net/ipv4/netfilter/arpt_mangle.c
@@ -54,7 +54,7 @@ target(struct sk_buff *skb, const struct xt_target_param *par)
 	return mangle->target;
 }
 
-static bool checkentry(const struct xt_tgchk_param *par)
+static int checkentry(const struct xt_tgchk_param *par)
 {
 	const struct arpt_mangle *mangle = par->targinfo;
 
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index fcaa0dc..290a7b9 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -347,7 +347,7 @@ clusterip_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool clusterip_tg_check(const struct xt_tgchk_param *par)
+static int clusterip_tg_check(const struct xt_tgchk_param *par)
 {
 	struct ipt_clusterip_tgt_info *cipinfo = par->targinfo;
 	const struct ipt_entry *e = par->entryinfo;
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 0198875..9d96500 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -93,7 +93,7 @@ ecn_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool ecn_tg_check(const struct xt_tgchk_param *par)
+static int ecn_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ipt_ECN_info *einfo = par->targinfo;
 	const struct ipt_entry *e = par->entryinfo;
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index b3bf623..c9ee5c4 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -439,7 +439,7 @@ log_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool log_tg_check(const struct xt_tgchk_param *par)
+static int log_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ipt_log_info *loginfo = par->targinfo;
 
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 5063dda..5a182f6 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -28,7 +28,7 @@ MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("Xtables: automatic-address SNAT");
 
 /* FIXME: Multiple targets. --RR */
-static bool masquerade_tg_check(const struct xt_tgchk_param *par)
+static int masquerade_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct nf_nat_multi_range_compat *mr = par->targinfo;
 
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMAP.c
index 51ab01a..cbfe5f7 100644
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ b/net/ipv4/netfilter/ipt_NETMAP.c
@@ -22,7 +22,7 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Svenning Soerensen <svenning@post5.tele.dk>");
 MODULE_DESCRIPTION("Xtables: 1:1 NAT mapping of IPv4 subnets");
 
-static bool netmap_tg_check(const struct xt_tgchk_param *par)
+static int netmap_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct nf_nat_multi_range_compat *mr = par->targinfo;
 
diff --git a/net/ipv4/netfilter/ipt_REDIRECT.c b/net/ipv4/netfilter/ipt_REDIRECT.c
index 74f1f55..f8daec2 100644
--- a/net/ipv4/netfilter/ipt_REDIRECT.c
+++ b/net/ipv4/netfilter/ipt_REDIRECT.c
@@ -26,7 +26,7 @@ MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("Xtables: Connection redirection to localhost");
 
 /* FIXME: Take multiple ranges --RR */
-static bool redirect_tg_check(const struct xt_tgchk_param *par)
+static int redirect_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct nf_nat_multi_range_compat *mr = par->targinfo;
 
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index ff32252..cf76f1b 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -174,7 +174,7 @@ reject_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return NF_DROP;
 }
 
-static bool reject_tg_check(const struct xt_tgchk_param *par)
+static int reject_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ipt_reject_info *rejinfo = par->targinfo;
 	const struct ipt_entry *e = par->entryinfo;
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index d926201..7f73bbe 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -307,7 +307,7 @@ static void ipt_logfn(u_int8_t pf,
 	ipt_ulog_packet(hooknum, skb, in, out, &loginfo, prefix);
 }
 
-static bool ulog_tg_check(const struct xt_tgchk_param *par)
+static int ulog_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ipt_ulog_info *loginfo = par->targinfo;
 
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 7d6345e..1172267 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -74,7 +74,7 @@ ipt_dnat_target(struct sk_buff *skb, const struct xt_target_param *par)
 	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_DST);
 }
 
-static bool ipt_snat_checkentry(const struct xt_tgchk_param *par)
+static int ipt_snat_checkentry(const struct xt_tgchk_param *par)
 {
 	const struct nf_nat_multi_range_compat *mr = par->targinfo;
 
@@ -86,7 +86,7 @@ static bool ipt_snat_checkentry(const struct xt_tgchk_param *par)
 	return true;
 }
 
-static bool ipt_dnat_checkentry(const struct xt_tgchk_param *par)
+static int ipt_dnat_checkentry(const struct xt_tgchk_param *par)
 {
 	const struct nf_nat_multi_range_compat *mr = par->targinfo;
 
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 5a79883..bcc3fc1 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -451,7 +451,7 @@ log_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 }
 
 
-static bool log_tg6_check(const struct xt_tgchk_param *par)
+static int log_tg6_check(const struct xt_tgchk_param *par)
 {
 	const struct ip6t_log_info *loginfo = par->targinfo;
 
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 45efb9f..8d5141e 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -213,7 +213,7 @@ reject_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 	return NF_DROP;
 }
 
-static bool reject_tg6_check(const struct xt_tgchk_param *par)
+static int reject_tg6_check(const struct xt_tgchk_param *par)
 {
 	const struct ip6t_reject_info *rejinfo = par->targinfo;
 	const struct ip6t_entry *e = par->entryinfo;
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index 6812865..3f9d0f4 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -84,7 +84,7 @@ connsecmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool connsecmark_tg_check(const struct xt_tgchk_param *par)
+static int connsecmark_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_connsecmark_target_info *info = par->targinfo;
 
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 6509e03..c1553bf 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -53,7 +53,7 @@ static u8 xt_ct_find_proto(const struct xt_tgchk_param *par)
 		return 0;
 }
 
-static bool xt_ct_tg_check(const struct xt_tgchk_param *par)
+static int xt_ct_tg_check(const struct xt_tgchk_param *par)
 {
 	struct xt_ct_target_info *info = par->targinfo;
 	struct nf_conntrack_tuple t;
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index bbf08a9..1fa7b67 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -60,7 +60,7 @@ dscp_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool dscp_tg_check(const struct xt_tgchk_param *par)
+static int dscp_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_DSCP_info *info = par->targinfo;
 
diff --git a/net/netfilter/xt_HL.c b/net/netfilter/xt_HL.c
index 7004ed2..15ba161 100644
--- a/net/netfilter/xt_HL.c
+++ b/net/netfilter/xt_HL.c
@@ -101,7 +101,7 @@ hl_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool ttl_tg_check(const struct xt_tgchk_param *par)
+static int ttl_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ipt_TTL_info *info = par->targinfo;
 
@@ -114,7 +114,7 @@ static bool ttl_tg_check(const struct xt_tgchk_param *par)
 	return true;
 }
 
-static bool hl_tg6_check(const struct xt_tgchk_param *par)
+static int hl_tg6_check(const struct xt_tgchk_param *par)
 {
 	const struct ip6t_HL_info *info = par->targinfo;
 
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index f511bea..1a3e3dd 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -80,7 +80,7 @@ static void led_timeout_callback(unsigned long data)
 	led_trigger_event(&ledinternal->netfilter_led_trigger, LED_OFF);
 }
 
-static bool led_tg_check(const struct xt_tgchk_param *par)
+static int led_tg_check(const struct xt_tgchk_param *par)
 {
 	struct xt_led_info *ledinfo = par->targinfo;
 	struct xt_led_info_internal *ledinternal;
diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index a57c5cf..13e6c00 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -37,7 +37,7 @@ nflog_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool nflog_tg_check(const struct xt_tgchk_param *par)
+static int nflog_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_nflog_info *info = par->targinfo;
 
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 7cc0de6..d435579 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -81,7 +81,7 @@ nfqueue_tg_v1(struct sk_buff *skb, const struct xt_target_param *par)
 	return NF_QUEUE_NR(queue);
 }
 
-static bool nfqueue_tg_v1_check(const struct xt_tgchk_param *par)
+static int nfqueue_tg_v1_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_NFQ_info_v1 *info = par->targinfo;
 	u32 maxid;
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 87ae97e..9743e50 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -85,7 +85,7 @@ xt_rateest_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
+static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 {
 	struct xt_rateest_target_info *info = par->targinfo;
 	struct xt_rateest *est;
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index 4855fd9..48f8e4f 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -80,7 +80,7 @@ static bool checkentry_selinux(struct xt_secmark_target_info *info)
 	return true;
 }
 
-static bool secmark_tg_check(const struct xt_tgchk_param *par)
+static int secmark_tg_check(const struct xt_tgchk_param *par)
 {
 	struct xt_secmark_target_info *info = par->targinfo;
 
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 45161d9..70288dc 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -234,7 +234,7 @@ static inline bool find_syn_match(const struct xt_entry_match *m)
 	return false;
 }
 
-static bool tcpmss_tg4_check(const struct xt_tgchk_param *par)
+static int tcpmss_tg4_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_tcpmss_info *info = par->targinfo;
 	const struct ipt_entry *e = par->entryinfo;
@@ -256,7 +256,7 @@ static bool tcpmss_tg4_check(const struct xt_tgchk_param *par)
 }
 
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
-static bool tcpmss_tg6_check(const struct xt_tgchk_param *par)
+static int tcpmss_tg6_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_tcpmss_info *info = par->targinfo;
 	const struct ip6t_entry *e = par->entryinfo;
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index e9244fd..189df9a 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -59,7 +59,7 @@ tproxy_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return NF_DROP;
 }
 
-static bool tproxy_tg_check(const struct xt_tgchk_param *par)
+static int tproxy_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct ipt_ip *i = par->entryinfo;
 
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index df7eaff..0e69427 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -74,7 +74,7 @@ connmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return XT_CONTINUE;
 }
 
-static bool connmark_tg_check(const struct xt_tgchk_param *par)
+static int connmark_tg_check(const struct xt_tgchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
-- 
1.7.0.4

