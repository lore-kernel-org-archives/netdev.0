From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/21] netfilter: x_tables: add context to know if extension runs from nft_compat
Date: Mon, 18 May 2015 18:25:23 +0200
Message-ID: <1431966324-4494-21-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, we have four xtables extensions that cannot be used from the
xt over nft compat layer. The problem is that they need real access to
the full blown xt_entry to validate that the rule comes with the right
dependencies. This check was introduced to overcome the lack of
sufficient userspace dependency validation in iptables.

To resolve this problem, this patch introduces a new field to the
xt_tgchk_param structure that tell us if the extension is run from
nft_compat context.

The three affected extensions are:

1) CLUSTERIP, this target has been superseded by xt_cluster. So just
   bail out by returning -EINVAL.

2) TCPMSS. Relax the checking when used from nft_compat. If used with
   the wrong configuration, it will corrupt !syn packets by adding TCP
   MSS option.

3) ebt_stp. Relax the check to make sure it uses the reserved
   destination MAC address for STP.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Tested-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
---
 include/linux/netfilter/x_tables.h |    2 ++
 net/bridge/netfilter/ebt_stp.c     |    6 ++++--
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    5 +++++
 net/netfilter/nft_compat.c         |    2 ++
 net/netfilter/xt_TCPMSS.c          |    6 ++++++
 5 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index a3e215b..09f3820 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -62,6 +62,7 @@ struct xt_mtchk_param {
 	void *matchinfo;
 	unsigned int hook_mask;
 	u_int8_t family;
+	bool nft_compat;
 };
 
 /**
@@ -92,6 +93,7 @@ struct xt_tgchk_param {
 	void *targinfo;
 	unsigned int hook_mask;
 	u_int8_t family;
+	bool nft_compat;
 };
 
 /* Target destructor parameters */
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 071d872..0c40570 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -164,8 +164,10 @@ static int ebt_stp_mt_check(const struct xt_mtchk_param *par)
 	    !(info->bitmask & EBT_STP_MASK))
 		return -EINVAL;
 	/* Make sure the match only receives stp frames */
-	if (!ether_addr_equal(e->destmac, bridge_ula) ||
-	    !ether_addr_equal(e->destmsk, msk) || !(e->bitmask & EBT_DESTMAC))
+	if (!par->nft_compat &&
+	    (!ether_addr_equal(e->destmac, bridge_ula) ||
+	     !ether_addr_equal(e->destmsk, msk) ||
+	     !(e->bitmask & EBT_DESTMAC)))
 		return -EINVAL;
 
 	return 0;
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 771ab3d..45cb16a 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -367,6 +367,11 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 	struct clusterip_config *config;
 	int ret;
 
+	if (par->nft_compat) {
+		pr_err("cannot use CLUSTERIP target from nftables compat\n");
+		return -EOPNOTSUPP;
+	}
+
 	if (cipinfo->hash_mode != CLUSTERIP_HASHMODE_SIP &&
 	    cipinfo->hash_mode != CLUSTERIP_HASHMODE_SIP_SPT &&
 	    cipinfo->hash_mode != CLUSTERIP_HASHMODE_SIP_SPT_DPT) {
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 7f29cfc..66def31 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -161,6 +161,7 @@ nft_target_set_tgchk_param(struct xt_tgchk_param *par,
 		par->hook_mask = 0;
 	}
 	par->family	= ctx->afi->family;
+	par->nft_compat = true;
 }
 
 static void target_compat_from_user(struct xt_target *t, void *in, void *out)
@@ -377,6 +378,7 @@ nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
 		par->hook_mask = 0;
 	}
 	par->family	= ctx->afi->family;
+	par->nft_compat = true;
 }
 
 static void match_compat_from_user(struct xt_match *m, void *in, void *out)
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index e762de5..8c3190e 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -277,6 +277,9 @@ static int tcpmss_tg4_check(const struct xt_tgchk_param *par)
 			"FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return -EINVAL;
 	}
+	if (par->nft_compat)
+		return 0;
+
 	xt_ematch_foreach(ematch, e)
 		if (find_syn_match(ematch))
 			return 0;
@@ -299,6 +302,9 @@ static int tcpmss_tg6_check(const struct xt_tgchk_param *par)
 			"FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return -EINVAL;
 	}
+	if (par->nft_compat)
+		return 0;
+
 	xt_ematch_foreach(ematch, e)
 		if (find_syn_match(ematch))
 			return 0;
-- 
1.7.10.4

