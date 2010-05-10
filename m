From: kaber@trash.net
Subject: [PATCH 45/84] netfilter: xtables: change targets to return error code
Date: Mon, 10 May 2010 22:18:16 +0200
Message-ID: <1273522735-24672-46-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Part of the transition of done by this semantic patch:
// <smpl>
@ rule1 @
struct xt_target ops;
identifier check;
@@
 ops.checkentry = check;

@@
identifier rule1.check;
@@
 check(...) { <...
-return true;
+return 0;
 ...> }

@@
identifier rule1.check;
@@
 check(...) { <...
-return false;
+return -EINVAL;
 ...> }
// </smpl>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/bridge/netfilter/ebt_arpreply.c |    6 +++---
 net/bridge/netfilter/ebt_dnat.c     |    8 ++++----
 net/bridge/netfilter/ebt_log.c      |    6 +++---
 net/bridge/netfilter/ebt_mark.c     |    8 ++++----
 net/bridge/netfilter/ebt_nflog.c    |    4 ++--
 net/bridge/netfilter/ebt_redirect.c |    8 ++++----
 net/bridge/netfilter/ebt_snat.c     |    8 ++++----
 net/bridge/netfilter/ebt_ulog.c     |    4 ++--
 net/ipv4/netfilter/ipt_CLUSTERIP.c  |   16 ++++++++--------
 net/ipv4/netfilter/ipt_ECN.c        |    8 ++++----
 net/ipv4/netfilter/ipt_LOG.c        |    6 +++---
 net/ipv4/netfilter/ipt_MASQUERADE.c |    6 +++---
 net/ipv4/netfilter/ipt_NETMAP.c     |    6 +++---
 net/ipv4/netfilter/ipt_REDIRECT.c   |    6 +++---
 net/ipv4/netfilter/ipt_REJECT.c     |    6 +++---
 net/ipv4/netfilter/ipt_ULOG.c       |    6 +++---
 net/ipv4/netfilter/nf_nat_rule.c    |    8 ++++----
 net/ipv6/netfilter/ip6t_LOG.c       |    6 +++---
 net/ipv6/netfilter/ip6t_REJECT.c    |    6 +++---
 net/netfilter/x_tables.c            |   12 ++++++++++--
 net/netfilter/xt_CONNSECMARK.c      |    6 +++---
 net/netfilter/xt_CT.c               |    6 +++---
 net/netfilter/xt_DSCP.c             |    4 ++--
 net/netfilter/xt_HL.c               |   10 +++++-----
 net/netfilter/xt_LED.c              |   10 ++++------
 net/netfilter/xt_NFLOG.c            |    6 +++---
 net/netfilter/xt_NFQUEUE.c          |    6 +++---
 net/netfilter/xt_RATEEST.c          |    9 ++++-----
 net/netfilter/xt_SECMARK.c          |   10 +++++-----
 net/netfilter/xt_TCPMSS.c           |   12 ++++++------
 net/netfilter/xt_TPROXY.c           |    4 ++--
 31 files changed, 116 insertions(+), 111 deletions(-)

diff --git a/net/bridge/netfilter/ebt_arpreply.c b/net/bridge/netfilter/ebt_arpreply.c
index 2491564..4581adb 100644
--- a/net/bridge/netfilter/ebt_arpreply.c
+++ b/net/bridge/netfilter/ebt_arpreply.c
@@ -63,11 +63,11 @@ static int ebt_arpreply_tg_check(const struct xt_tgchk_param *par)
 	const struct ebt_entry *e = par->entryinfo;
 
 	if (BASE_CHAIN && info->target == EBT_RETURN)
-		return false;
+		return -EINVAL;
 	if (e->ethproto != htons(ETH_P_ARP) ||
 	    e->invflags & EBT_IPROTO)
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static struct xt_target ebt_arpreply_tg_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index 5fddebe..59d5b7c 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -32,7 +32,7 @@ static int ebt_dnat_tg_check(const struct xt_tgchk_param *par)
 	unsigned int hook_mask;
 
 	if (BASE_CHAIN && info->target == EBT_RETURN)
-		return false;
+		return -EINVAL;
 
 	hook_mask = par->hook_mask & ~(1 << NF_BR_NUMHOOKS);
 	if ((strcmp(par->table, "nat") != 0 ||
@@ -40,10 +40,10 @@ static int ebt_dnat_tg_check(const struct xt_tgchk_param *par)
 	    (1 << NF_BR_LOCAL_OUT)))) &&
 	    (strcmp(par->table, "broute") != 0 ||
 	    hook_mask & ~(1 << NF_BR_BROUTING)))
-		return false;
+		return -EINVAL;
 	if (INVALID_TARGET)
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static struct xt_target ebt_dnat_tg_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index a0aeac6..c460241 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -29,11 +29,11 @@ static int ebt_log_tg_check(const struct xt_tgchk_param *par)
 	struct ebt_log_info *info = par->targinfo;
 
 	if (info->bitmask & ~EBT_LOG_MASK)
-		return false;
+		return -EINVAL;
 	if (info->loglevel >= 8)
-		return false;
+		return -EINVAL;
 	info->prefix[EBT_LOG_PREFIX_SIZE - 1] = '\0';
-	return true;
+	return 0;
 }
 
 struct tcpudphdr
diff --git a/net/bridge/netfilter/ebt_mark.c b/net/bridge/netfilter/ebt_mark.c
index dd94daf..126e536 100644
--- a/net/bridge/netfilter/ebt_mark.c
+++ b/net/bridge/netfilter/ebt_mark.c
@@ -43,14 +43,14 @@ static int ebt_mark_tg_check(const struct xt_tgchk_param *par)
 
 	tmp = info->target | ~EBT_VERDICT_BITS;
 	if (BASE_CHAIN && tmp == EBT_RETURN)
-		return false;
+		return -EINVAL;
 	if (tmp < -NUM_STANDARD_TARGETS || tmp >= 0)
-		return false;
+		return -EINVAL;
 	tmp = info->target & ~EBT_VERDICT_BITS;
 	if (tmp != MARK_SET_VALUE && tmp != MARK_OR_VALUE &&
 	    tmp != MARK_AND_VALUE && tmp != MARK_XOR_VALUE)
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 #ifdef CONFIG_COMPAT
 struct compat_ebt_mark_t_info {
diff --git a/net/bridge/netfilter/ebt_nflog.c b/net/bridge/netfilter/ebt_nflog.c
index 1f2b7bb..22e2ad5 100644
--- a/net/bridge/netfilter/ebt_nflog.c
+++ b/net/bridge/netfilter/ebt_nflog.c
@@ -40,9 +40,9 @@ static int ebt_nflog_tg_check(const struct xt_tgchk_param *par)
 	struct ebt_nflog_info *info = par->targinfo;
 
 	if (info->flags & ~EBT_NFLOG_MASK)
-		return false;
+		return -EINVAL;
 	info->prefix[EBT_NFLOG_PREFIX_SIZE - 1] = '\0';
-	return true;
+	return 0;
 }
 
 static struct xt_target ebt_nflog_tg_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index 73c4d3a..a6044a6 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -38,17 +38,17 @@ static int ebt_redirect_tg_check(const struct xt_tgchk_param *par)
 	unsigned int hook_mask;
 
 	if (BASE_CHAIN && info->target == EBT_RETURN)
-		return false;
+		return -EINVAL;
 
 	hook_mask = par->hook_mask & ~(1 << NF_BR_NUMHOOKS);
 	if ((strcmp(par->table, "nat") != 0 ||
 	    hook_mask & ~(1 << NF_BR_PRE_ROUTING)) &&
 	    (strcmp(par->table, "broute") != 0 ||
 	    hook_mask & ~(1 << NF_BR_BROUTING)))
-		return false;
+		return -EINVAL;
 	if (INVALID_TARGET)
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static struct xt_target ebt_redirect_tg_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index 94bcecd..79caca3 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -49,14 +49,14 @@ static int ebt_snat_tg_check(const struct xt_tgchk_param *par)
 
 	tmp = info->target | ~EBT_VERDICT_BITS;
 	if (BASE_CHAIN && tmp == EBT_RETURN)
-		return false;
+		return -EINVAL;
 
 	if (tmp < -NUM_STANDARD_TARGETS || tmp >= 0)
-		return false;
+		return -EINVAL;
 	tmp = info->target | EBT_VERDICT_BITS;
 	if ((tmp & ~NAT_ARP_BIT) != ~NAT_ARP_BIT)
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static struct xt_target ebt_snat_tg_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index f554bc2..f77b42d 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -254,14 +254,14 @@ static int ebt_ulog_tg_check(const struct xt_tgchk_param *par)
 	struct ebt_ulog_info *uloginfo = par->targinfo;
 
 	if (uloginfo->nlgroup > 31)
-		return false;
+		return -EINVAL;
 
 	uloginfo->prefix[EBT_ULOG_PREFIX_LEN - 1] = '\0';
 
 	if (uloginfo->qthreshold > EBT_ULOG_MAX_QLEN)
 		uloginfo->qthreshold = EBT_ULOG_MAX_QLEN;
 
-	return true;
+	return 0;
 }
 
 static struct xt_target ebt_ulog_tg_reg __read_mostly = {
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 290a7b9..1302de2 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -358,13 +358,13 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 	    cipinfo->hash_mode != CLUSTERIP_HASHMODE_SIP_SPT &&
 	    cipinfo->hash_mode != CLUSTERIP_HASHMODE_SIP_SPT_DPT) {
 		pr_info("unknown mode %u\n", cipinfo->hash_mode);
-		return false;
+		return -EINVAL;
 
 	}
 	if (e->ip.dmsk.s_addr != htonl(0xffffffff) ||
 	    e->ip.dst.s_addr == 0) {
 		pr_info("Please specify destination IP\n");
-		return false;
+		return -EINVAL;
 	}
 
 	/* FIXME: further sanity checks */
@@ -374,20 +374,20 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 		if (!(cipinfo->flags & CLUSTERIP_FLAG_NEW)) {
 			pr_info("no config found for %pI4, need 'new'\n",
 				&e->ip.dst.s_addr);
-			return false;
+			return -EINVAL;
 		} else {
 			struct net_device *dev;
 
 			if (e->ip.iniface[0] == '\0') {
 				pr_info("Please specify an interface name\n");
-				return false;
+				return -EINVAL;
 			}
 
 			dev = dev_get_by_name(&init_net, e->ip.iniface);
 			if (!dev) {
 				pr_info("no such interface %s\n",
 					e->ip.iniface);
-				return false;
+				return -EINVAL;
 			}
 
 			config = clusterip_config_init(cipinfo,
@@ -395,7 +395,7 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 			if (!config) {
 				pr_info("cannot allocate config\n");
 				dev_put(dev);
-				return false;
+				return -EINVAL;
 			}
 			dev_mc_add(config->dev,config->clustermac, ETH_ALEN, 0);
 		}
@@ -405,10 +405,10 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return false;
+		return -EINVAL;
 	}
 
-	return true;
+	return 0;
 }
 
 /* drop reference count of cluster config when rule is deleted */
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 9d96500..563049f 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -100,18 +100,18 @@ static int ecn_tg_check(const struct xt_tgchk_param *par)
 
 	if (einfo->operation & IPT_ECN_OP_MASK) {
 		pr_info("unsupported ECN operation %x\n", einfo->operation);
-		return false;
+		return -EINVAL;
 	}
 	if (einfo->ip_ect & ~IPT_ECN_IP_MASK) {
 		pr_info("new ECT codepoint %x out of mask\n", einfo->ip_ect);
-		return false;
+		return -EINVAL;
 	}
 	if ((einfo->operation & (IPT_ECN_OP_SET_ECE|IPT_ECN_OP_SET_CWR)) &&
 	    (e->ip.proto != IPPROTO_TCP || (e->ip.invflags & XT_INV_PROTO))) {
 		pr_info("cannot use TCP operations on a non-tcp rule\n");
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_target ecn_tg_reg __read_mostly = {
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index c9ee5c4..a6a454b 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -445,13 +445,13 @@ static int log_tg_check(const struct xt_tgchk_param *par)
 
 	if (loginfo->level >= 8) {
 		pr_debug("level %u >= 8\n", loginfo->level);
-		return false;
+		return -EINVAL;
 	}
 	if (loginfo->prefix[sizeof(loginfo->prefix)-1] != '\0') {
 		pr_debug("prefix is not null-terminated\n");
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_target log_tg_reg __read_mostly = {
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 5a182f6..02b1bc4 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -34,13 +34,13 @@ static int masquerade_tg_check(const struct xt_tgchk_param *par)
 
 	if (mr->range[0].flags & IP_NAT_RANGE_MAP_IPS) {
 		pr_debug("bad MAP_IPS.\n");
-		return false;
+		return -EINVAL;
 	}
 	if (mr->rangesize != 1) {
 		pr_debug("bad rangesize %u\n", mr->rangesize);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static unsigned int
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMAP.c
index cbfe5f7..708c7f8 100644
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ b/net/ipv4/netfilter/ipt_NETMAP.c
@@ -28,13 +28,13 @@ static int netmap_tg_check(const struct xt_tgchk_param *par)
 
 	if (!(mr->range[0].flags & IP_NAT_RANGE_MAP_IPS)) {
 		pr_debug("bad MAP_IPS.\n");
-		return false;
+		return -EINVAL;
 	}
 	if (mr->rangesize != 1) {
 		pr_debug("bad rangesize %u.\n", mr->rangesize);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static unsigned int
diff --git a/net/ipv4/netfilter/ipt_REDIRECT.c b/net/ipv4/netfilter/ipt_REDIRECT.c
index f8daec2..3cf1019 100644
--- a/net/ipv4/netfilter/ipt_REDIRECT.c
+++ b/net/ipv4/netfilter/ipt_REDIRECT.c
@@ -32,13 +32,13 @@ static int redirect_tg_check(const struct xt_tgchk_param *par)
 
 	if (mr->range[0].flags & IP_NAT_RANGE_MAP_IPS) {
 		pr_debug("bad MAP_IPS.\n");
-		return false;
+		return -EINVAL;
 	}
 	if (mr->rangesize != 1) {
 		pr_debug("bad rangesize %u.\n", mr->rangesize);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static unsigned int
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index cf76f1b..b026014 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -181,16 +181,16 @@ static int reject_tg_check(const struct xt_tgchk_param *par)
 
 	if (rejinfo->with == IPT_ICMP_ECHOREPLY) {
 		pr_info("ECHOREPLY no longer supported.\n");
-		return false;
+		return -EINVAL;
 	} else if (rejinfo->with == IPT_TCP_RESET) {
 		/* Must specify that it's a TCP packet */
 		if (e->ip.proto != IPPROTO_TCP ||
 		    (e->ip.invflags & XT_INV_PROTO)) {
 			pr_info("TCP_RESET invalid for non-tcp\n");
-			return false;
+			return -EINVAL;
 		}
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_target reject_tg_reg __read_mostly = {
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 7f73bbe..04c86dc 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -313,14 +313,14 @@ static int ulog_tg_check(const struct xt_tgchk_param *par)
 
 	if (loginfo->prefix[sizeof(loginfo->prefix) - 1] != '\0') {
 		pr_debug("prefix not null-terminated\n");
-		return false;
+		return -EINVAL;
 	}
 	if (loginfo->qthreshold > ULOG_MAX_QLEN) {
 		pr_debug("queue threshold %Zu > MAX_QLEN\n",
 			 loginfo->qthreshold);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 1172267..b66137c 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -81,9 +81,9 @@ static int ipt_snat_checkentry(const struct xt_tgchk_param *par)
 	/* Must be a valid range */
 	if (mr->rangesize != 1) {
 		pr_info("SNAT: multiple ranges no longer supported\n");
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static int ipt_dnat_checkentry(const struct xt_tgchk_param *par)
@@ -93,9 +93,9 @@ static int ipt_dnat_checkentry(const struct xt_tgchk_param *par)
 	/* Must be a valid range */
 	if (mr->rangesize != 1) {
 		pr_info("DNAT: multiple ranges no longer supported\n");
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 unsigned int
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index bcc3fc1..439eded 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -457,13 +457,13 @@ static int log_tg6_check(const struct xt_tgchk_param *par)
 
 	if (loginfo->level >= 8) {
 		pr_debug("level %u >= 8\n", loginfo->level);
-		return false;
+		return -EINVAL;
 	}
 	if (loginfo->prefix[sizeof(loginfo->prefix)-1] != '\0') {
 		pr_debug("prefix not null-terminated\n");
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_target log_tg6_reg __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 8d5141e..55b9b2d 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -220,16 +220,16 @@ static int reject_tg6_check(const struct xt_tgchk_param *par)
 
 	if (rejinfo->with == IP6T_ICMP6_ECHOREPLY) {
 		pr_info("ECHOREPLY is not supported.\n");
-		return false;
+		return -EINVAL;
 	} else if (rejinfo->with == IP6T_TCP_RESET) {
 		/* Must specify that it's a TCP packet */
 		if (e->ipv6.proto != IPPROTO_TCP ||
 		    (e->ipv6.invflags & XT_INV_PROTO)) {
 			pr_info("TCP_RESET illegal for non-tcp\n");
-			return false;
+			return -EINVAL;
 		}
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_target reject_tg6_reg __read_mostly = {
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 7ee1777..8e23d8f 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -528,6 +528,8 @@ EXPORT_SYMBOL_GPL(xt_compat_match_to_user);
 int xt_check_target(struct xt_tgchk_param *par,
 		    unsigned int size, u_int8_t proto, bool inv_proto)
 {
+	int ret;
+
 	if (XT_ALIGN(par->target->targetsize) != size) {
 		pr_err("%s_tables: %s.%u target: invalid size "
 		       "%u (kernel) != (user) %u\n",
@@ -559,8 +561,14 @@ int xt_check_target(struct xt_tgchk_param *par,
 		       par->target->proto);
 		return -EINVAL;
 	}
-	if (par->target->checkentry != NULL && !par->target->checkentry(par))
-		return -EINVAL;
+	if (par->target->checkentry != NULL) {
+		ret = par->target->checkentry(par);
+		if (ret < 0)
+			return ret;
+		else if (ret > 0)
+			/* Flag up potential errors. */
+			return -EIO;
+	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xt_check_target);
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index 3f9d0f4..2287a82 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -92,7 +92,7 @@ static int connsecmark_tg_check(const struct xt_tgchk_param *par)
 	    strcmp(par->table, "security") != 0) {
 		pr_info("target only valid in the \'mangle\' "
 			"or \'security\' tables, not \'%s\'.\n", par->table);
-		return false;
+		return -EINVAL;
 	}
 
 	switch (info->mode) {
@@ -108,9 +108,9 @@ static int connsecmark_tg_check(const struct xt_tgchk_param *par)
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static void connsecmark_tg_destroy(const struct xt_tgdtor_param *par)
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index c1553bf..ee566e2 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -62,7 +62,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par)
 	u8 proto;
 
 	if (info->flags & ~XT_CT_NOTRACK)
-		return false;
+		return -EINVAL;
 
 	if (info->flags & XT_CT_NOTRACK) {
 		ct = &nf_conntrack_untracked;
@@ -108,14 +108,14 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par)
 	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
 out:
 	info->ct = ct;
-	return true;
+	return 0;
 
 err3:
 	nf_conntrack_free(ct);
 err2:
 	nf_ct_l3proto_module_put(par->family);
 err1:
-	return false;
+	return -EINVAL;
 }
 
 static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par)
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index 1fa7b67..aa263b8 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -66,9 +66,9 @@ static int dscp_tg_check(const struct xt_tgchk_param *par)
 
 	if (info->dscp > XT_DSCP_MAX) {
 		pr_info("dscp %x out of range\n", info->dscp);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static unsigned int
diff --git a/net/netfilter/xt_HL.c b/net/netfilter/xt_HL.c
index 15ba161..7a47383 100644
--- a/net/netfilter/xt_HL.c
+++ b/net/netfilter/xt_HL.c
@@ -110,8 +110,8 @@ static int ttl_tg_check(const struct xt_tgchk_param *par)
 		return false;
 	}
 	if (info->mode != IPT_TTL_SET && info->ttl == 0)
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static int hl_tg6_check(const struct xt_tgchk_param *par)
@@ -120,14 +120,14 @@ static int hl_tg6_check(const struct xt_tgchk_param *par)
 
 	if (info->mode > IP6T_HL_MAXMODE) {
 		pr_info("invalid or unknown mode %u\n", info->mode);
-		return false;
+		return -EINVAL;
 	}
 	if (info->mode != IP6T_HL_SET && info->hop_limit == 0) {
 		pr_info("increment/decrement does not "
 			"make sense with value 0\n");
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_target hl_tg_reg[] __read_mostly = {
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index 1a3e3dd..22b5b70 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -88,12 +88,12 @@ static int led_tg_check(const struct xt_tgchk_param *par)
 
 	if (ledinfo->id[0] == '\0') {
 		pr_info("No 'id' parameter given.\n");
-		return false;
+		return -EINVAL;
 	}
 
 	ledinternal = kzalloc(sizeof(struct xt_led_info_internal), GFP_KERNEL);
 	if (!ledinternal)
-		return false;
+		return -EINVAL;
 
 	ledinternal->netfilter_led_trigger.name = ledinfo->id;
 
@@ -111,13 +111,11 @@ static int led_tg_check(const struct xt_tgchk_param *par)
 			    (unsigned long)ledinfo);
 
 	ledinfo->internal_data = ledinternal;
-
-	return true;
+	return 0;
 
 exit_alloc:
 	kfree(ledinternal);
-
-	return false;
+	return -EINVAL;
 }
 
 static void led_tg_destroy(const struct xt_tgdtor_param *par)
diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index 13e6c00..42dd874 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -42,10 +42,10 @@ static int nflog_tg_check(const struct xt_tgchk_param *par)
 	const struct xt_nflog_info *info = par->targinfo;
 
 	if (info->flags & ~XT_NFLOG_MASK)
-		return false;
+		return -EINVAL;
 	if (info->prefix[sizeof(info->prefix) - 1] != '\0')
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static struct xt_target nflog_tg_reg __read_mostly = {
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index d435579..add1789 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -92,15 +92,15 @@ static int nfqueue_tg_v1_check(const struct xt_tgchk_param *par)
 	}
 	if (info->queues_total == 0) {
 		pr_err("NFQUEUE: number of total queues is 0\n");
-		return false;
+		return -EINVAL;
 	}
 	maxid = info->queues_total - 1 + info->queuenum;
 	if (maxid > 0xffff) {
 		pr_err("NFQUEUE: number of queues (%u) out of range (got %u)\n",
 		       info->queues_total, maxid);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_target nfqueue_tg_reg[] __read_mostly = {
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 9743e50..7af5fba 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -109,10 +109,10 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 		    (info->interval != est->params.interval ||
 		     info->ewma_log != est->params.ewma_log)) {
 			xt_rateest_put(est);
-			return false;
+			return -EINVAL;
 		}
 		info->est = est;
-		return true;
+		return 0;
 	}
 
 	est = kzalloc(sizeof(*est), GFP_KERNEL);
@@ -136,13 +136,12 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 
 	info->est = est;
 	xt_rateest_hash_insert(est);
-
-	return true;
+	return 0;
 
 err2:
 	kfree(est);
 err1:
-	return false;
+	return -EINVAL;
 }
 
 static void xt_rateest_tg_destroy(const struct xt_tgdtor_param *par)
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index 48f8e4f..39098fc 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -88,29 +88,29 @@ static int secmark_tg_check(const struct xt_tgchk_param *par)
 	    strcmp(par->table, "security") != 0) {
 		pr_info("target only valid in the \'mangle\' "
 			"or \'security\' tables, not \'%s\'.\n", par->table);
-		return false;
+		return -EINVAL;
 	}
 
 	if (mode && mode != info->mode) {
 		pr_info("mode already set to %hu cannot mix with "
 			"rules for mode %hu\n", mode, info->mode);
-		return false;
+		return -EINVAL;
 	}
 
 	switch (info->mode) {
 	case SECMARK_MODE_SEL:
 		if (!checkentry_selinux(info))
-			return false;
+			return -EINVAL;
 		break;
 
 	default:
 		pr_info("invalid mode: %hu\n", info->mode);
-		return false;
+		return -EINVAL;
 	}
 
 	if (!mode)
 		mode = info->mode;
-	return true;
+	return 0;
 }
 
 static void secmark_tg_destroy(const struct xt_tgdtor_param *par)
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 70288dc..385677b 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -246,13 +246,13 @@ static int tcpmss_tg4_check(const struct xt_tgchk_param *par)
 			   (1 << NF_INET_POST_ROUTING))) != 0) {
 		pr_info("path-MTU clamping only supported in "
 			"FORWARD, OUTPUT and POSTROUTING hooks\n");
-		return false;
+		return -EINVAL;
 	}
 	xt_ematch_foreach(ematch, e)
 		if (find_syn_match(ematch))
-			return true;
+			return 0;
 	pr_info("Only works on TCP SYN packets\n");
-	return false;
+	return -EINVAL;
 }
 
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
@@ -268,13 +268,13 @@ static int tcpmss_tg6_check(const struct xt_tgchk_param *par)
 			   (1 << NF_INET_POST_ROUTING))) != 0) {
 		pr_info("path-MTU clamping only supported in "
 			"FORWARD, OUTPUT and POSTROUTING hooks\n");
-		return false;
+		return -EINVAL;
 	}
 	xt_ematch_foreach(ematch, e)
 		if (find_syn_match(ematch))
-			return true;
+			return 0;
 	pr_info("Only works on TCP SYN packets\n");
-	return false;
+	return -EINVAL;
 }
 #endif
 
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 189df9a..4f246dd 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -65,11 +65,11 @@ static int tproxy_tg_check(const struct xt_tgchk_param *par)
 
 	if ((i->proto == IPPROTO_TCP || i->proto == IPPROTO_UDP)
 	    && !(i->invflags & IPT_INV_PROTO))
-		return true;
+		return 0;
 
 	pr_info("Can be used only in combination with "
 		"either -p tcp or -p udp\n");
-	return false;
+	return -EINVAL;
 }
 
 static struct xt_target tproxy_tg_reg __read_mostly = {
-- 
1.7.0.4

