From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 07/31: xtables: remove xt_conntrack v0
Date: Thu, 10 Sep 2009 18:11:55 +0200 (MEST)
Message-ID: <20090910161151.31179.41974.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64640 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbZIJQLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:11:53 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9e05ec4b1804a1ba51f61fe169aef9b86edcd3f7
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 12 18:56:14 2009 +0200

    netfilter: xtables: remove xt_conntrack v0
    
    Superseded by xt_conntrack v1 (v2.6.24-2921-g64eb12f).
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 54f9357..6746473 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -238,9 +238,6 @@ What (Why):
 	- "forwarding" header files like ipt_mac.h in
 	  include/linux/netfilter_ipv4/ and include/linux/netfilter_ipv6/
 
-	- xt_conntrack match revision 0
-	  (superseded by xt_conntrack match revision 1)
-
 	- xt_iprange match revision 0,
 	  include/linux/netfilter_ipv4/ipt_iprange.h
 	  (superseded by xt_iprange match revision 1)
diff --git a/include/linux/netfilter/xt_conntrack.h b/include/linux/netfilter/xt_conntrack.h
index 7ae0533..54f47a2 100644
--- a/include/linux/netfilter/xt_conntrack.h
+++ b/include/linux/netfilter/xt_conntrack.h
@@ -32,42 +32,6 @@ enum {
 	XT_CONNTRACK_DIRECTION    = 1 << 12,
 };
 
-/* This is exposed to userspace, so remains frozen in time. */
-struct ip_conntrack_old_tuple
-{
-	struct {
-		__be32 ip;
-		union {
-			__u16 all;
-		} u;
-	} src;
-
-	struct {
-		__be32 ip;
-		union {
-			__u16 all;
-		} u;
-
-		/* The protocol. */
-		__u16 protonum;
-	} dst;
-};
-
-struct xt_conntrack_info
-{
-	unsigned int statemask, statusmask;
-
-	struct ip_conntrack_old_tuple tuple[IP_CT_DIR_MAX];
-	struct in_addr sipmsk[IP_CT_DIR_MAX], dipmsk[IP_CT_DIR_MAX];
-
-	unsigned long expires_min, expires_max;
-
-	/* Flags word */
-	__u8 flags;
-	/* Inverse flags */
-	__u8 invflags;
-};
-
 struct xt_conntrack_mtinfo1 {
 	union nf_inet_addr origsrc_addr, origsrc_mask;
 	union nf_inet_addr origdst_addr, origdst_mask;
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index fc58180..6dc4652 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -19,101 +19,12 @@
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Marc Boucher <marc@mbsi.ca>");
-MODULE_AUTHOR("Jan Engelhardt <jengelh@computergmbh.de>");
+MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
 MODULE_DESCRIPTION("Xtables: connection tracking state match");
 MODULE_ALIAS("ipt_conntrack");
 MODULE_ALIAS("ip6t_conntrack");
 
 static bool
-conntrack_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
-{
-	const struct xt_conntrack_info *sinfo = par->matchinfo;
-	const struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-	unsigned int statebit;
-
-	ct = nf_ct_get(skb, &ctinfo);
-
-#define FWINV(bool, invflg) ((bool) ^ !!(sinfo->invflags & (invflg)))
-
-	if (ct == &nf_conntrack_untracked)
-		statebit = XT_CONNTRACK_STATE_UNTRACKED;
-	else if (ct)
-		statebit = XT_CONNTRACK_STATE_BIT(ctinfo);
-	else
-		statebit = XT_CONNTRACK_STATE_INVALID;
-
-	if (sinfo->flags & XT_CONNTRACK_STATE) {
-		if (ct) {
-			if (test_bit(IPS_SRC_NAT_BIT, &ct->status))
-				statebit |= XT_CONNTRACK_STATE_SNAT;
-			if (test_bit(IPS_DST_NAT_BIT, &ct->status))
-				statebit |= XT_CONNTRACK_STATE_DNAT;
-		}
-		if (FWINV((statebit & sinfo->statemask) == 0,
-			  XT_CONNTRACK_STATE))
-			return false;
-	}
-
-	if (ct == NULL) {
-		if (sinfo->flags & ~XT_CONNTRACK_STATE)
-			return false;
-		return true;
-	}
-
-	if (sinfo->flags & XT_CONNTRACK_PROTO &&
-	    FWINV(nf_ct_protonum(ct) !=
-		  sinfo->tuple[IP_CT_DIR_ORIGINAL].dst.protonum,
-		  XT_CONNTRACK_PROTO))
-		return false;
-
-	if (sinfo->flags & XT_CONNTRACK_ORIGSRC &&
-	    FWINV((ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip &
-		   sinfo->sipmsk[IP_CT_DIR_ORIGINAL].s_addr) !=
-		  sinfo->tuple[IP_CT_DIR_ORIGINAL].src.ip,
-		  XT_CONNTRACK_ORIGSRC))
-		return false;
-
-	if (sinfo->flags & XT_CONNTRACK_ORIGDST &&
-	    FWINV((ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3.ip &
-		   sinfo->dipmsk[IP_CT_DIR_ORIGINAL].s_addr) !=
-		  sinfo->tuple[IP_CT_DIR_ORIGINAL].dst.ip,
-		  XT_CONNTRACK_ORIGDST))
-		return false;
-
-	if (sinfo->flags & XT_CONNTRACK_REPLSRC &&
-	    FWINV((ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip &
-		   sinfo->sipmsk[IP_CT_DIR_REPLY].s_addr) !=
-		  sinfo->tuple[IP_CT_DIR_REPLY].src.ip,
-		  XT_CONNTRACK_REPLSRC))
-		return false;
-
-	if (sinfo->flags & XT_CONNTRACK_REPLDST &&
-	    FWINV((ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip &
-		   sinfo->dipmsk[IP_CT_DIR_REPLY].s_addr) !=
-		  sinfo->tuple[IP_CT_DIR_REPLY].dst.ip,
-		  XT_CONNTRACK_REPLDST))
-		return false;
-
-	if (sinfo->flags & XT_CONNTRACK_STATUS &&
-	    FWINV((ct->status & sinfo->statusmask) == 0,
-		  XT_CONNTRACK_STATUS))
-		return false;
-
-	if(sinfo->flags & XT_CONNTRACK_EXPIRES) {
-		unsigned long expires = timer_pending(&ct->timeout) ?
-					(ct->timeout.expires - jiffies)/HZ : 0;
-
-		if (FWINV(!(expires >= sinfo->expires_min &&
-			    expires <= sinfo->expires_max),
-			  XT_CONNTRACK_EXPIRES))
-			return false;
-	}
-	return true;
-#undef FWINV
-}
-
-static bool
 conntrack_addrcmp(const union nf_inet_addr *kaddr,
                   const union nf_inet_addr *uaddr,
                   const union nf_inet_addr *umask, unsigned int l3proto)
@@ -337,73 +248,9 @@ static void conntrack_mt_destroy_v1(const struct xt_mtdtor_param *par)
 	conntrack_mt_destroy(par);
 }
 
-#ifdef CONFIG_COMPAT
-struct compat_xt_conntrack_info
-{
-	compat_uint_t			statemask;
-	compat_uint_t			statusmask;
-	struct ip_conntrack_old_tuple	tuple[IP_CT_DIR_MAX];
-	struct in_addr			sipmsk[IP_CT_DIR_MAX];
-	struct in_addr			dipmsk[IP_CT_DIR_MAX];
-	compat_ulong_t			expires_min;
-	compat_ulong_t			expires_max;
-	u_int8_t			flags;
-	u_int8_t			invflags;
-};
-
-static void conntrack_mt_compat_from_user_v0(void *dst, void *src)
-{
-	const struct compat_xt_conntrack_info *cm = src;
-	struct xt_conntrack_info m = {
-		.statemask	= cm->statemask,
-		.statusmask	= cm->statusmask,
-		.expires_min	= cm->expires_min,
-		.expires_max	= cm->expires_max,
-		.flags		= cm->flags,
-		.invflags	= cm->invflags,
-	};
-	memcpy(m.tuple, cm->tuple, sizeof(m.tuple));
-	memcpy(m.sipmsk, cm->sipmsk, sizeof(m.sipmsk));
-	memcpy(m.dipmsk, cm->dipmsk, sizeof(m.dipmsk));
-	memcpy(dst, &m, sizeof(m));
-}
-
-static int conntrack_mt_compat_to_user_v0(void __user *dst, void *src)
-{
-	const struct xt_conntrack_info *m = src;
-	struct compat_xt_conntrack_info cm = {
-		.statemask	= m->statemask,
-		.statusmask	= m->statusmask,
-		.expires_min	= m->expires_min,
-		.expires_max	= m->expires_max,
-		.flags		= m->flags,
-		.invflags	= m->invflags,
-	};
-	memcpy(cm.tuple, m->tuple, sizeof(cm.tuple));
-	memcpy(cm.sipmsk, m->sipmsk, sizeof(cm.sipmsk));
-	memcpy(cm.dipmsk, m->dipmsk, sizeof(cm.dipmsk));
-	return copy_to_user(dst, &cm, sizeof(cm)) ? -EFAULT : 0;
-}
-#endif
-
 static struct xt_match conntrack_mt_reg[] __read_mostly = {
 	{
 		.name       = "conntrack",
-		.revision   = 0,
-		.family     = NFPROTO_IPV4,
-		.match      = conntrack_mt_v0,
-		.checkentry = conntrack_mt_check,
-		.destroy    = conntrack_mt_destroy,
-		.matchsize  = sizeof(struct xt_conntrack_info),
-		.me         = THIS_MODULE,
-#ifdef CONFIG_COMPAT
-		.compatsize       = sizeof(struct compat_xt_conntrack_info),
-		.compat_from_user = conntrack_mt_compat_from_user_v0,
-		.compat_to_user   = conntrack_mt_compat_to_user_v0,
-#endif
-	},
-	{
-		.name       = "conntrack",
 		.revision   = 1,
 		.family     = NFPROTO_UNSPEC,
 		.matchsize  = sizeof(struct xt_conntrack_mtinfo1),
