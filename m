From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/04: xtables: conntrack match revision 2
Date: Mon, 29 Jun 2009 16:20:18 +0200 (MEST)
Message-ID: <20090629142012.5728.4525.sendpatchset@x2.localnet>
References: <20090629142007.5728.63458.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090629142007.5728.63458.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit d6d3f08b0fd998b647a05540cedd11a067b72867
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Jun 29 14:31:46 2009 +0200

    netfilter: xtables: conntrack match revision 2
    
    As reported by Philip, the UNTRACKED state bit does not fit within
    the 8-bit state_mask member. Enlarge state_mask and give status_mask
    a few more bits too.
    
    Reported-by: Philip Craig <philipc@snapgear.com>
    References: http://markmail.org/thread/b7eg6aovfh4agyz7
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/xt_conntrack.h b/include/linux/netfilter/xt_conntrack.h
index 3430c77..7ae0533 100644
--- a/include/linux/netfilter/xt_conntrack.h
+++ b/include/linux/netfilter/xt_conntrack.h
@@ -81,4 +81,17 @@ struct xt_conntrack_mtinfo1 {
 	__u8 state_mask, status_mask;
 };
 
+struct xt_conntrack_mtinfo2 {
+	union nf_inet_addr origsrc_addr, origsrc_mask;
+	union nf_inet_addr origdst_addr, origdst_mask;
+	union nf_inet_addr replsrc_addr, replsrc_mask;
+	union nf_inet_addr repldst_addr, repldst_mask;
+	__u32 expires_min, expires_max;
+	__u16 l4proto;
+	__be16 origsrc_port, origdst_port;
+	__be16 replsrc_port, repldst_port;
+	__u16 match_flags, invert_flags;
+	__u16 state_mask, status_mask;
+};
+
 #endif /*_XT_CONNTRACK_H*/
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 0b7139f..fc58180 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -129,7 +129,7 @@ conntrack_addrcmp(const union nf_inet_addr *kaddr,
 
 static inline bool
 conntrack_mt_origsrc(const struct nf_conn *ct,
-                     const struct xt_conntrack_mtinfo1 *info,
+                     const struct xt_conntrack_mtinfo2 *info,
 		     u_int8_t family)
 {
 	return conntrack_addrcmp(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3,
@@ -138,7 +138,7 @@ conntrack_mt_origsrc(const struct nf_conn *ct,
 
 static inline bool
 conntrack_mt_origdst(const struct nf_conn *ct,
-                     const struct xt_conntrack_mtinfo1 *info,
+                     const struct xt_conntrack_mtinfo2 *info,
 		     u_int8_t family)
 {
 	return conntrack_addrcmp(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3,
@@ -147,7 +147,7 @@ conntrack_mt_origdst(const struct nf_conn *ct,
 
 static inline bool
 conntrack_mt_replsrc(const struct nf_conn *ct,
-                     const struct xt_conntrack_mtinfo1 *info,
+                     const struct xt_conntrack_mtinfo2 *info,
 		     u_int8_t family)
 {
 	return conntrack_addrcmp(&ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3,
@@ -156,7 +156,7 @@ conntrack_mt_replsrc(const struct nf_conn *ct,
 
 static inline bool
 conntrack_mt_repldst(const struct nf_conn *ct,
-                     const struct xt_conntrack_mtinfo1 *info,
+                     const struct xt_conntrack_mtinfo2 *info,
 		     u_int8_t family)
 {
 	return conntrack_addrcmp(&ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3,
@@ -164,7 +164,7 @@ conntrack_mt_repldst(const struct nf_conn *ct,
 }
 
 static inline bool
-ct_proto_port_check(const struct xt_conntrack_mtinfo1 *info,
+ct_proto_port_check(const struct xt_conntrack_mtinfo2 *info,
                     const struct nf_conn *ct)
 {
 	const struct nf_conntrack_tuple *tuple;
@@ -204,7 +204,7 @@ ct_proto_port_check(const struct xt_conntrack_mtinfo1 *info,
 static bool
 conntrack_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
-	const struct xt_conntrack_mtinfo1 *info = par->matchinfo;
+	const struct xt_conntrack_mtinfo2 *info = par->matchinfo;
 	enum ip_conntrack_info ctinfo;
 	const struct nf_conn *ct;
 	unsigned int statebit;
@@ -278,6 +278,16 @@ conntrack_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
+static bool
+conntrack_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
+{
+	const struct xt_conntrack_mtinfo2 *const *info = par->matchinfo;
+	struct xt_match_param newpar = *par;
+
+	newpar.matchinfo = *info;
+	return conntrack_mt(skb, &newpar);
+}
+
 static bool conntrack_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
@@ -288,11 +298,45 @@ static bool conntrack_mt_check(const struct xt_mtchk_param *par)
 	return true;
 }
 
+static bool conntrack_mt_check_v1(const struct xt_mtchk_param *par)
+{
+	struct xt_conntrack_mtinfo1 *info = par->matchinfo;
+	struct xt_conntrack_mtinfo2 *up;
+	int ret = conntrack_mt_check(par);
+
+	if (ret < 0)
+		return ret;
+
+	up = kmalloc(sizeof(*up), GFP_KERNEL);
+	if (up == NULL) {
+		nf_ct_l3proto_module_put(par->family);
+		return -ENOMEM;
+	}
+
+	/*
+	 * The strategy here is to minimize the overhead of v1 matching,
+	 * by prebuilding a v2 struct and putting the pointer into the
+	 * v1 dataspace.
+	 */
+	memcpy(up, info, offsetof(typeof(*info), state_mask));
+	up->state_mask  = info->state_mask;
+	up->status_mask = info->status_mask;
+	*(void **)info  = up;
+	return true;
+}
+
 static void conntrack_mt_destroy(const struct xt_mtdtor_param *par)
 {
 	nf_ct_l3proto_module_put(par->family);
 }
 
+static void conntrack_mt_destroy_v1(const struct xt_mtdtor_param *par)
+{
+	struct xt_conntrack_mtinfo2 **info = par->matchinfo;
+	kfree(*info);
+	conntrack_mt_destroy(par);
+}
+
 #ifdef CONFIG_COMPAT
 struct compat_xt_conntrack_info
 {
@@ -363,6 +407,16 @@ static struct xt_match conntrack_mt_reg[] __read_mostly = {
 		.revision   = 1,
 		.family     = NFPROTO_UNSPEC,
 		.matchsize  = sizeof(struct xt_conntrack_mtinfo1),
+		.match      = conntrack_mt_v1,
+		.checkentry = conntrack_mt_check_v1,
+		.destroy    = conntrack_mt_destroy_v1,
+		.me         = THIS_MODULE,
+	},
+	{
+		.name       = "conntrack",
+		.revision   = 2,
+		.family     = NFPROTO_UNSPEC,
+		.matchsize  = sizeof(struct xt_conntrack_mtinfo2),
 		.match      = conntrack_mt,
 		.checkentry = conntrack_mt_check,
 		.destroy    = conntrack_mt_destroy,
