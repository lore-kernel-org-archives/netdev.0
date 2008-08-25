From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH][RESEND] XFRM: MIGRATE enhancements
Date: Mon, 25 Aug 2008 08:40:06 +0200
Message-ID: <87iqtpk37d.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, Shinta Sugimoto <shinta@sfc.wide.ad.jp>,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:41130 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622AbYHYGms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 02:42:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is a resend, the patch is now against today's net-next-2.6; I also 
added Herbert in Cc.

I start with the context, patch-related information follow.

XFRM supports a feature called MIGRATE, used by MIPv6 for the purpose of
IPsec SP/SA updates upon movement. It was integrated some time ago by
people of USAGI (Masahide Nakamura, Shinta Sugimoto and possibly
others). Sugimoto-san and Nakamura-san (in CC) also published a document
(IETF draft, see [1]) which specifies the original PF_KEY MIGRATE
mechanism.

Because MIGRATE was not sufficient for bootstrapping IKE negotiation in
MIPv6 context, an additional PF_KEY extension was also defined in the 
draft (SADB_X_EXT_PACKET): simply put, its main goal was to carry a
verbatim copy of the triggering packet in the ACQUIRE so that the key
manager be able to deduce some information on the addresses to use for
the negotiation. A limited version of this feature implemented for Linux
Kernel proved to be a pain to maintain and there was also additional
drawbacks. This is why I never pushed associated patches.

This convinced me to propose some *simple* improvements to MIGRATE
authors: removing SADB_X_EXT_PACKET and replacing it by something more
efficient which also solves other lacks. It is defined in a continuation
work [2] of MIGRATE mechanim ([1] is expired). The proposed changes
have been validated by Sugimoto-san and I have implemented and
maintained patches for UMIP (Usagi MIPv6 userland implementation for
Linux), racoon (IKE daemon) and Linux kernel (XFRM and PF_KEY) since
2.6.23-rc7 or so. I use it on a daily basis on my main laptop.

Simply put, the feature allows a MIPv6 Mobile Node to negotiate IPsec
using IKE (bootstrapping) and then perform movements without the need
for rekeying (migration of in-kernel SP/SA (done by current kernel code)
*and* passing of required info for update of IKE-maintained
structures). Take a look at [3] for more information.

The patch attached to this email provides the missing bits between
current MIGRATE implementation and what is specified in [2]. It is
against today's net-next-2.6.

If you have questions, do not hesitate.

Cheers,

a+

[1]: http://tools.ietf.org/html/draft-sugimoto-mip6-pfkey-migrate-04
[2]: http://tools.ietf.org/html/draft-ebalard-mext-pfkey-enhanced-migrate-00 
[3]: http://natisbad.org/MIPv6/


From: Arnaud Ebalard <arno@natisbad.org>
Date: Mon, 25 Aug 2008 08:18:12 +0200
Subject: [PATCH] XFRM: MIGRATE enhancements (draft-ebalard-mext-pfkey-enhanced-migrate)

Provides implementation of the enhancements of XFRM/PF_KEY MIGRATE mechanism
specified in draft-ebalard-mext-pfkey-enhanced-migrate-00. Defines associated
PF_KEY SADB_X_EXT_KMADDRESS extension XFMR/netlink XFRMA_KMADDRESS attribute.

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 include/linux/pfkeyv2.h |   13 +++++++-
 include/linux/xfrm.h    |   10 +++++
 include/net/xfrm.h      |   15 +++++++--
 net/key/af_key.c        |   85 +++++++++++++++++++++++++++++++++++++---------
 net/xfrm/xfrm_policy.c  |    5 ++-
 net/xfrm/xfrm_state.c   |    5 ++-
 net/xfrm/xfrm_user.c    |   45 ++++++++++++++++++++----
 7 files changed, 145 insertions(+), 33 deletions(-)

diff --git a/include/linux/pfkeyv2.h b/include/linux/pfkeyv2.h
index 700725d..01b2629 100644
--- a/include/linux/pfkeyv2.h
+++ b/include/linux/pfkeyv2.h
@@ -226,6 +226,15 @@ struct sadb_x_sec_ctx {
 } __attribute__((packed));
 /* sizeof(struct sadb_sec_ctx) = 8 */
 
+/* Used by MIGRATE to pass addresses IKE will use to perform
+ * negotiation with the peer */
+struct sadb_x_kmaddress {
+	uint16_t	sadb_x_kmaddress_len;
+	uint16_t	sadb_x_kmaddress_exttype;
+	uint32_t	sadb_x_kmaddress_reserved;
+} __attribute__((packed));
+/* sizeof(struct sadb_x_kmaddress) == 8 */
+
 /* Message types */
 #define SADB_RESERVED		0
 #define SADB_GETSPI		1
@@ -346,7 +355,9 @@ struct sadb_x_sec_ctx {
 #define SADB_X_EXT_NAT_T_DPORT		22
 #define SADB_X_EXT_NAT_T_OA		23
 #define SADB_X_EXT_SEC_CTX		24
-#define SADB_EXT_MAX			24
+/* Used with MIGRATE to pass @ to IKE for negotiation */
+#define SADB_X_EXT_KMADDRESS		25
+#define SADB_EXT_MAX			25
 
 /* Identity Extension values */
 #define SADB_IDENTTYPE_RESERVED	0
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index fb0c215..4bc1e6b 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -279,6 +279,7 @@ enum xfrm_attr_type_t {
 	XFRMA_POLICY_TYPE,	/* struct xfrm_userpolicy_type */
 	XFRMA_MIGRATE,
 	XFRMA_ALG_AEAD,		/* struct xfrm_algo_aead */
+	XFRMA_KMADDRESS,        /* struct xfrm_user_kmaddress */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -415,6 +416,15 @@ struct xfrm_user_report {
 	struct xfrm_selector		sel;
 };
 
+/* Used by MIGRATE to pass addresses IKE should use to perform
+ * SA negotiation with the peer */
+struct xfrm_user_kmaddress {
+	xfrm_address_t                  local;
+	xfrm_address_t                  remote;
+	__u32				reserved;
+	__u16				family;
+};
+
 struct xfrm_user_migrate {
 	xfrm_address_t			old_daddr;
 	xfrm_address_t			old_saddr;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 2933d74..ea93d89 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -476,6 +476,13 @@ struct xfrm_policy
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
 };
 
+struct xfrm_kmaddress {
+	xfrm_address_t          local;
+	xfrm_address_t          remote;
+	u32			reserved;
+	u16			family;
+};
+
 struct xfrm_migrate {
 	xfrm_address_t		old_daddr;
 	xfrm_address_t		old_saddr;
@@ -515,7 +522,7 @@ struct xfrm_mgr
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, struct km_event *c);
 	int			(*report)(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
-	int			(*migrate)(struct xfrm_selector *sel, u8 dir, u8 type, struct xfrm_migrate *m, int num_bundles);
+	int			(*migrate)(struct xfrm_selector *sel, u8 dir, u8 type, struct xfrm_migrate *m, int num_bundles, struct xfrm_kmaddress *k);
 };
 
 extern int xfrm_register_km(struct xfrm_mgr *km);
@@ -1455,12 +1462,14 @@ extern int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
 
 #ifdef CONFIG_XFRM_MIGRATE
 extern int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-		      struct xfrm_migrate *m, int num_bundles);
+		      struct xfrm_migrate *m, int num_bundles,
+		      struct xfrm_kmaddress *k);
 extern struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m);
 extern struct xfrm_state * xfrm_state_migrate(struct xfrm_state *x,
 					      struct xfrm_migrate *m);
 extern int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-			struct xfrm_migrate *m, int num_bundles);
+			struct xfrm_migrate *m, int num_bundles,
+			struct xfrm_kmaddress *k);
 #endif
 
 extern wait_queue_head_t km_waitq;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index d628df9..a311109 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -372,6 +372,7 @@ static u8 sadb_ext_min_len[] = {
 	[SADB_X_EXT_NAT_T_DPORT]	= (u8) sizeof(struct sadb_x_nat_t_port),
 	[SADB_X_EXT_NAT_T_OA]		= (u8) sizeof(struct sadb_address),
 	[SADB_X_EXT_SEC_CTX]		= (u8) sizeof(struct sadb_x_sec_ctx),
+	[SADB_X_EXT_KMADDRESS]		= (u8) sizeof(struct sadb_x_kmaddress),
 };
 
 /* Verify sadb_address_{len,prefixlen} against sa_family.  */
@@ -2353,24 +2354,21 @@ static int pfkey_sockaddr_pair_size(sa_family_t family)
 	return PFKEY_ALIGN8(pfkey_sockaddr_len(family) * 2);
 }
 
-static int parse_sockaddr_pair(struct sadb_x_ipsecrequest *rq,
+static int parse_sockaddr_pair(struct sockaddr *sa, int ext_len,
 			       xfrm_address_t *saddr, xfrm_address_t *daddr,
 			       u16 *family)
 {
-	u8 *sa = (u8 *) (rq + 1);
 	int af, socklen;
 
-	if (rq->sadb_x_ipsecrequest_len <
-	    pfkey_sockaddr_pair_size(((struct sockaddr *)sa)->sa_family))
+	if (ext_len < pfkey_sockaddr_pair_size(sa->sa_family))
 		return -EINVAL;
 
-	af = pfkey_sockaddr_extract((struct sockaddr *) sa,
-				    saddr);
+	af = pfkey_sockaddr_extract(sa, saddr);
 	if (!af)
 		return -EINVAL;
 
 	socklen = pfkey_sockaddr_len(af);
-	if (pfkey_sockaddr_extract((struct sockaddr *) (sa + socklen),
+	if (pfkey_sockaddr_extract((struct sockaddr *) (((u8 *)sa) + socklen),
 				   daddr) != af)
 		return -EINVAL;
 
@@ -2390,7 +2388,9 @@ static int ipsecrequests_to_migrate(struct sadb_x_ipsecrequest *rq1, int len,
 		return -EINVAL;
 
 	/* old endoints */
-	err = parse_sockaddr_pair(rq1, &m->old_saddr, &m->old_daddr,
+	err = parse_sockaddr_pair((struct sockaddr *)(rq1 + 1),
+				  rq1->sadb_x_ipsecrequest_len,
+				  &m->old_saddr, &m->old_daddr,
 				  &m->old_family);
 	if (err)
 		return err;
@@ -2403,7 +2403,9 @@ static int ipsecrequests_to_migrate(struct sadb_x_ipsecrequest *rq1, int len,
 		return -EINVAL;
 
 	/* new endpoints */
-	err = parse_sockaddr_pair(rq2, &m->new_saddr, &m->new_daddr,
+	err = parse_sockaddr_pair((struct sockaddr *)(rq2 + 1),
+				  rq2->sadb_x_ipsecrequest_len,
+				  &m->new_saddr, &m->new_daddr,
 				  &m->new_family);
 	if (err)
 		return err;
@@ -2429,26 +2431,36 @@ static int pfkey_migrate(struct sock *sk, struct sk_buff *skb,
 	int i, len, ret, err = -EINVAL;
 	u8 dir;
 	struct sadb_address *sa;
+	struct sadb_x_kmaddress *kma;
 	struct sadb_x_policy *pol;
 	struct sadb_x_ipsecrequest *rq;
 	struct xfrm_selector sel;
 	struct xfrm_migrate m[XFRM_MAX_DEPTH];
+	struct xfrm_kmaddress k;
 
 	if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC - 1],
-	    ext_hdrs[SADB_EXT_ADDRESS_DST - 1]) ||
-	    !ext_hdrs[SADB_X_EXT_POLICY - 1]) {
+				     ext_hdrs[SADB_EXT_ADDRESS_DST - 1]) ||
+	    !ext_hdrs[SADB_X_EXT_POLICY - 1] ||
+	    !ext_hdrs[SADB_X_EXT_KMADDRESS - 1]) {
 		err = -EINVAL;
 		goto out;
 	}
 
+	kma = ext_hdrs[SADB_X_EXT_KMADDRESS - 1];
 	pol = ext_hdrs[SADB_X_EXT_POLICY - 1];
-	if (!pol) {
+
+	if (pol->sadb_x_policy_dir >= IPSEC_DIR_MAX) {
 		err = -EINVAL;
 		goto out;
 	}
 
-	if (pol->sadb_x_policy_dir >= IPSEC_DIR_MAX) {
-		err = -EINVAL;
+	/* convert sadb_x_kmaddress to xfrm_kmaddress */
+	k.reserved = kma->sadb_x_kmaddress_reserved;
+	ret = parse_sockaddr_pair((struct sockaddr *)(kma + 1),
+				  8*(kma->sadb_x_kmaddress_len) - sizeof(*kma),
+				  &k.local, &k.remote, &k.family);
+	if (ret < 0) {
+		err = ret;
 		goto out;
 	}
 
@@ -2496,7 +2508,7 @@ static int pfkey_migrate(struct sock *sk, struct sk_buff *skb,
 		goto out;
 	}
 
-	return xfrm_migrate(&sel, dir, XFRM_POLICY_TYPE_MAIN, m, i);
+	return xfrm_migrate(&sel, dir, XFRM_POLICY_TYPE_MAIN, m, i, &k);
 
  out:
 	return err;
@@ -3283,6 +3295,32 @@ static int set_sadb_address(struct sk_buff *skb, int sasize, int type,
 	return 0;
 }
 
+
+static int set_sadb_kmaddress(struct sk_buff *skb, struct xfrm_kmaddress *k)
+{
+	struct sadb_x_kmaddress *kma;
+	u8 *sa;
+	int family = k->family;
+	int socklen = pfkey_sockaddr_len(family);
+	int size_req;
+
+	size_req = (sizeof(struct sadb_x_kmaddress) +
+		    pfkey_sockaddr_pair_size(family));
+
+	kma = (struct sadb_x_kmaddress *)skb_put(skb, size_req);
+	memset(kma, 0, size_req);
+	kma->sadb_x_kmaddress_len = size_req / 8;
+	kma->sadb_x_kmaddress_exttype = SADB_X_EXT_KMADDRESS;
+	kma->sadb_x_kmaddress_reserved = k->reserved;
+
+	sa = (u8 *)(kma + 1);
+	if (!pfkey_sockaddr_fill(&k->local, 0, (struct sockaddr *)sa, family) ||
+	    !pfkey_sockaddr_fill(&k->remote, 0, (struct sockaddr *)(sa+socklen), family))
+		return -EINVAL;
+
+	return 0;
+}
+
 static int set_ipsecrequest(struct sk_buff *skb,
 			    uint8_t proto, uint8_t mode, int level,
 			    uint32_t reqid, uint8_t family,
@@ -3315,7 +3353,8 @@ static int set_ipsecrequest(struct sk_buff *skb,
 
 #ifdef CONFIG_NET_KEY_MIGRATE
 static int pfkey_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-			      struct xfrm_migrate *m, int num_bundles)
+			      struct xfrm_migrate *m, int num_bundles,
+			      struct xfrm_kmaddress *k)
 {
 	int i;
 	int sasize_sel;
@@ -3332,6 +3371,13 @@ static int pfkey_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 	if (num_bundles <= 0 || num_bundles > XFRM_MAX_DEPTH)
 		return -EINVAL;
 
+	if (!k)
+		return -EINVAL;
+
+	/* addresses for KM */
+	size += PFKEY_ALIGN8(sizeof(struct sadb_x_kmaddress) +
+			     pfkey_sockaddr_pair_size(k->family));
+
 	/* selector */
 	sasize_sel = pfkey_sockaddr_size(sel->family);
 	if (!sasize_sel)
@@ -3368,6 +3414,10 @@ static int pfkey_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 	hdr->sadb_msg_seq = 0;
 	hdr->sadb_msg_pid = 0;
 
+	/* Addresses to be used by KM for negotiation */
+	if (set_sadb_kmaddress(skb, k) < 0)
+		return -EINVAL;
+
 	/* selector src */
 	set_sadb_address(skb, sasize_sel, SADB_EXT_ADDRESS_SRC, sel);
 
@@ -3413,7 +3463,8 @@ err:
 }
 #else
 static int pfkey_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-			      struct xfrm_migrate *m, int num_bundles)
+			      struct xfrm_migrate *m, int num_bundles,
+			      struct xfrm_kmaddress *k)
 {
 	return -ENOPROTOOPT;
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 841b32a..e8f6aff 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2673,7 +2673,8 @@ static int xfrm_migrate_check(struct xfrm_migrate *m, int num_migrate)
 }
 
 int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-		 struct xfrm_migrate *m, int num_migrate)
+		 struct xfrm_migrate *m, int num_migrate,
+		 struct xfrm_kmaddress *k)
 {
 	int i, err, nx_cur = 0, nx_new = 0;
 	struct xfrm_policy *pol = NULL;
@@ -2717,7 +2718,7 @@ int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 	}
 
 	/* Stage 5 - announce */
-	km_migrate(sel, dir, type, m, num_migrate);
+	km_migrate(sel, dir, type, m, num_migrate, k);
 
 	xfrm_pol_put(pol);
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 4c6914e..51dc718 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1787,7 +1787,8 @@ EXPORT_SYMBOL(km_policy_expired);
 
 #ifdef CONFIG_XFRM_MIGRATE
 int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-	       struct xfrm_migrate *m, int num_migrate)
+	       struct xfrm_migrate *m, int num_migrate,
+	       struct xfrm_kmaddress *k)
 {
 	int err = -EINVAL;
 	int ret;
@@ -1796,7 +1797,7 @@ int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list) {
 		if (km->migrate) {
-			ret = km->migrate(sel, dir, type, m, num_migrate);
+			ret = km->migrate(sel, dir, type, m, num_migrate, k);
 			if (!ret)
 				err = ret;
 		}
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 04c4150..4591cd7 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1710,12 +1710,20 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 #ifdef CONFIG_XFRM_MIGRATE
 static int copy_from_user_migrate(struct xfrm_migrate *ma,
+				  struct xfrm_kmaddress *k,
 				  struct nlattr **attrs, int *num)
 {
 	struct nlattr *rt = attrs[XFRMA_MIGRATE];
 	struct xfrm_user_migrate *um;
+	struct xfrm_user_kmaddress *uk;
 	int i, num_migrate;
 
+	uk = nla_data(attrs[XFRMA_KMADDRESS]);
+	memcpy(&k->local, &uk->local, sizeof(k->local));
+	memcpy(&k->remote, &uk->remote, sizeof(k->remote));
+	k->family = uk->family;
+	k->reserved = uk->reserved;
+
 	um = nla_data(rt);
 	num_migrate = nla_len(rt) / sizeof(*um);
 
@@ -1745,18 +1753,19 @@ static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
 {
 	struct xfrm_userpolicy_id *pi = nlmsg_data(nlh);
 	struct xfrm_migrate m[XFRM_MAX_DEPTH];
+	struct xfrm_kmaddress km;
 	u8 type;
 	int err;
 	int n = 0;
 
-	if (attrs[XFRMA_MIGRATE] == NULL)
+	if (attrs[XFRMA_MIGRATE] == NULL || attrs[XFRMA_KMADDRESS] == NULL)
 		return -EINVAL;
 
 	err = copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
-	err = copy_from_user_migrate((struct xfrm_migrate *)m,
+	err = copy_from_user_migrate((struct xfrm_migrate *)m, &km,
 				     attrs, &n);
 	if (err)
 		return err;
@@ -1764,7 +1773,7 @@ static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!n)
 		return 0;
 
-	xfrm_migrate(&pi->sel, pi->dir, type, m, n);
+	xfrm_migrate(&pi->sel, pi->dir, type, m, n, &km);
 
 	return 0;
 }
@@ -1795,16 +1804,30 @@ static int copy_to_user_migrate(struct xfrm_migrate *m, struct sk_buff *skb)
 	return nla_put(skb, XFRMA_MIGRATE, sizeof(um), &um);
 }
 
+static int copy_to_user_kmaddress(struct xfrm_kmaddress *k, struct sk_buff *skb)
+{
+	struct xfrm_user_kmaddress uk;
+
+	memset(&uk, 0, sizeof(uk));
+	uk.family = k->family;
+	uk.reserved = k->reserved;
+	memcpy(&uk.local, &k->local, sizeof(uk.local));
+	memcpy(&uk.remote, &k->local, sizeof(uk.remote));
+
+	return nla_put(skb, XFRMA_KMADDRESS, sizeof(uk), &uk);
+}
+
 static inline size_t xfrm_migrate_msgsize(int num_migrate)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_userpolicy_id))
+	       + nla_total_size(sizeof(struct xfrm_kmaddress))
 	       + nla_total_size(sizeof(struct xfrm_user_migrate) * num_migrate)
 	       + userpolicy_type_attrsize();
 }
 
 static int build_migrate(struct sk_buff *skb, struct xfrm_migrate *m,
-			 int num_migrate, struct xfrm_selector *sel,
-			 u8 dir, u8 type)
+			 int num_migrate, struct xfrm_kmaddress *k,
+			 struct xfrm_selector *sel, u8 dir, u8 type)
 {
 	struct xfrm_migrate *mp;
 	struct xfrm_userpolicy_id *pol_id;
@@ -1821,6 +1844,9 @@ static int build_migrate(struct sk_buff *skb, struct xfrm_migrate *m,
 	memcpy(&pol_id->sel, sel, sizeof(pol_id->sel));
 	pol_id->dir = dir;
 
+	if (copy_to_user_kmaddress(k, skb) < 0)
+		goto nlmsg_failure;
+
 	if (copy_to_user_policy_type(type, skb) < 0)
 		goto nlmsg_failure;
 
@@ -1836,7 +1862,8 @@ nlmsg_failure:
 }
 
 static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-			     struct xfrm_migrate *m, int num_migrate)
+			     struct xfrm_migrate *m, int num_migrate,
+			     struct xfrm_kmaddress *k)
 {
 	struct sk_buff *skb;
 
@@ -1845,14 +1872,15 @@ static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 		return -ENOMEM;
 
 	/* build migrate */
-	if (build_migrate(skb, m, num_migrate, sel, dir, type) < 0)
+	if (build_migrate(skb, m, num_migrate, k, sel, dir, type) < 0)
 		BUG();
 
 	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_MIGRATE, GFP_ATOMIC);
 }
 #else
 static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
-			     struct xfrm_migrate *m, int num_migrate)
+			     struct xfrm_migrate *m, int num_migrate,
+			     struct xfrm_kmaddress *k)
 {
 	return -ENOPROTOOPT;
 }
@@ -1901,6 +1929,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_COADDR]		= { .len = sizeof(xfrm_address_t) },
 	[XFRMA_POLICY_TYPE]	= { .len = sizeof(struct xfrm_userpolicy_type)},
 	[XFRMA_MIGRATE]		= { .len = sizeof(struct xfrm_user_migrate) },
+	[XFRMA_KMADDRESS]	= { .len = sizeof(struct xfrm_user_kmaddress) },
 };
 
 static struct xfrm_link {
-- 
1.5.6.3


