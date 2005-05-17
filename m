From: jaegert <jaegert@us.ibm.com>
Subject: [PATCH 1/2] Resend: LSM-IPSec Networking Hooks
Date: Tue, 17 May 2005 16:25:11 -0400
Message-ID: <1116361510.5560.121.camel@dyn9002018177.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Cc: jaegert@us.ibm.com, serue@us.ibm.com, latten@austin.ibm.com,
        sds@tycho.nsa.gov, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, chrisw@osdl.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I am resending these patches because of format errors in the original 
mails.  I apologize for that inconvenience. 

Regards,
Trent.
-----------------------------------
Trent Jaeger
IBM T.J. Watson Research Center
19 Skyline Drive, Hawthorne, NY 10532
(914) 784-7225, (FAX) (914) 784-6209


This patch series implements per packet access control via the
extension of the Linux Security Modules (LSM) interface by hooks in
the XFRM and pfkey subsystems that leverage IPSec security
associations to label packets.  Extensions to the SELinux LSM are
included that leverage the patch for this purpose.

This patch implements the changes necessary to the XFRM subsystem,
pfkey interface, ipv4/ipv6, and xfrm_user interface to restrict a
socket to use only authorized security associations (or no security
association) to send/receive network packets.

Patch purpose:

The patch is designed to enable access control per packets based on
the strongly authenticated IPSec security association.  Such access
controls augment the existing ones based on network interface and IP
address.  The former are very coarse-grained, and the latter can be
spoofed.  By using IPSec, the system can control access to remote
hosts based on cryptographic keys generated using the IPSec mechanism.
This enables access control on a per-machine basis or per-application
if the remote machine is running the same mechanism and trusted to
enforce the access control policy.

Patch design approach:

The overall approach is that policy (xfrm_policy) entries set by
user-level programs (e.g., setkey for ipsec-tools) are extended with a
security context that is used at policy selection time in the XFRM
subsystem to restrict the sockets that can send/receive packets via
security associations (xfrm_states) that are built from those
policies.  

A presentation available at
www.selinux-symposium.org/2005/presentations/session2/2-3-jaeger.pdf
from the SELinux symposium describes the overall approach.

Patch implementation details: 

On output, the policy retrieved (via xfrm_policy_lookup or
xfrm_sk_policy_lookup) must be authorized for the security context of
the socket and the same security context is required for resultant
security association (retrieved or negotiated via racoon in
ipsec-tools).  This is enforced in xfrm_state_find.

On input, the policy retrieved must also be authorized for the socket
(at __xfrm_policy_check), and the security context of the policy must
also match the security association being used.

The patch has virtually no impact on packets that do not use IPSec.
The existing Netfilter (outgoing) and LSM rcv_skb hooks are used as
before.

Also, if IPSec is used without security contexts, the impact is
minimal.  The LSM must allow such policies to be selected for the
combination of socket and remote machine, but subsequent IPSec
processing proceeds as in the original case.

Testing:

The pfkey interface is tested using the ipsec-tools.  ipsec-tools have
been modified (a separate ipsec-tools patch is available for version
0.5) that supports assignment of xfrm_policy entries and security
associations with security contexts via setkey and the negotiation
using the security contexts via racoon.

The xfrm_user interface is tested via ad hoc programs that set
security contexts.  These programs are also available from me, and
contain programs for setting, getting, and deleting policy for testing
this interface.  Testing of sa functions was done by tracing kernel
behavior.

---

 include/linux/pfkeyv2.h  |   13 +++
 include/linux/security.h |  119 +++++++++++++++++++++++++++++++++++
 include/linux/xfrm.h     |   36 ++++++++++
 include/net/flow.h       |    5 -
 include/net/xfrm.h       |   21 ++++++
 net/core/flow.c          |    4 -
 net/ipv4/xfrm4_policy.c  |    2 
 net/ipv6/xfrm6_policy.c  |    2 
 net/key/af_key.c         |  119 +++++++++++++++++++++++++++++++++--
 net/xfrm/xfrm_policy.c   |   64 +++++++++++-------
 net/xfrm/xfrm_state.c    |   14 +++-
 net/xfrm/xfrm_user.c     |  159 +++++++++++++++++++++++++++++++++++++++++++++--
 security/Kconfig         |   13 +++
 security/dummy.c         |   37 ++++++++++
 14 files changed, 568 insertions(+), 40 deletions(-)

diff -puN include/linux/pfkeyv2.h~lsm-xfrm-nethooks include/linux/pfkeyv2.h
--- linux-2.6.12-rc4-nethooks/include/linux/pfkeyv2.h~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/include/linux/pfkeyv2.h	2005-05-10 16:19:20.000000000 -0400
@@ -216,6 +216,16 @@ struct sadb_x_nat_t_port {
 } __attribute__((packed));
 /* sizeof(struct sadb_x_nat_t_port) == 8 */
 
+/* Generic LSM security context */
+struct sadb_x_sec_ctx {
+	uint16_t	sadb_x_sec_len;
+	uint16_t	sadb_x_sec_exttype;
+	uint8_t		sadb_x_ctx_alg;  /* LSMs: e.g., selinux == 1 */
+	uint8_t		sadb_x_ctx_doi;
+	uint16_t	sadb_x_ctx_len;
+} __attribute__((packed));
+/* sizeof(struct sadb_sec_ctx) = 8 */
+
 /* Message types */
 #define SADB_RESERVED		0
 #define SADB_GETSPI		1
@@ -324,7 +334,8 @@ struct sadb_x_nat_t_port {
 #define SADB_X_EXT_NAT_T_SPORT		21
 #define SADB_X_EXT_NAT_T_DPORT		22
 #define SADB_X_EXT_NAT_T_OA		23
-#define SADB_EXT_MAX			23
+#define SADB_X_EXT_SEC_CTX		24
+#define SADB_EXT_MAX			24
 
 /* Identity Extension values */
 #define SADB_IDENTTYPE_RESERVED	0
diff -puN include/linux/security.h~lsm-xfrm-nethooks include/linux/security.h
--- linux-2.6.12-rc4-nethooks/include/linux/security.h~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/include/linux/security.h	2005-05-16 16:12:29.000000000 -0400
@@ -58,6 +58,12 @@ struct sk_buff;
 struct sock;
 struct sockaddr;
 struct socket;
+struct flowi;
+struct dst_entry;
+struct xfrm_selector;
+struct xfrm_policy;
+struct xfrm_state;
+struct sadb_x_sec_ctx;
 
 extern int cap_netlink_send(struct sock *sk, struct sk_buff *skb);
 extern int cap_netlink_recv(struct sk_buff *skb);
@@ -802,6 +808,50 @@ struct swap_info_struct;
  * @sk_free_security:
  *	Deallocate security structure.
  *
+ * Security hooks for XFRM operations.
+ *
+ * @xfrm_policy_alloc_security:
+ *	@xp contains the xfrm_policy being added to Security Policy Database
+ *      used by the XFRM system.
+ *      @sec_ctx contains the security context information being provided by
+ *      the user-level policy update program (e.g., setkey).
+ *      Allocate a security structure to the xp->selector.security field.
+ *      The security field is initialized to NULL when the xfrm_policy is
+ *      allocated.
+ *	Return 0 if operation was successful (memory to allocate, legal context)
+ * @xfrm_policy_clone_security:
+ *      @old contains an existing xfrm_policy in the SPD.
+ *      @new contains a new xfrm_policy being cloned from old.
+ *      Allocate a security structure to the new->selector.security field
+ *      that contains the information from the old->selector.security field.
+ *	Return 0 if operation was successful (memory to allocate).
+ * @xfrm_policy_free_security:
+ *      @xp contains the xfrm_policy
+ *      Deallocate xp->selector.security.
+ * @xfrm_state_alloc_security:
+ *      @x contains the xfrm_state being added to the Security Association
+ *      Database by the XFRM system.
+ *      @sec_ctx contains the security context information being provided by
+ *      the user-level SA generation program (e.g., setkey or racoon).
+ *      Allocate a security structure to the x->sel.security field.  The
+ *      security field is initialized to NULL when the xfrm_state is
+ *      allocated.
+ *	Return 0 if operation was successful (memory to allocate, legal context).
+ * @xfrm_state_free_security:
+ *      @x contains the xfrm_state.
+ *      Deallocate x>sel.security.
+ * @xfrm_policy_lookup:
+ *      @sk contains the sock that is requesting to either send or receive a
+ *      network communication.
+ *      @sel contains the selector that matches the communication end points of
+ *      the network communication (source, destination, and ports).
+ *      @fl contains the flowi that indicates the communication protocol.
+ *      @dir contains the direction of the flow (input or output).
+ *	Check permission when a sock selects a xfrm_policy for processing
+ *      XFRMs on a packet.  The hook is called when selecting either a
+ *      per-socket policy or a generic xfrm policy.
+ *	Return 0 if permission is granted.
+ *
  * Security hooks affecting all System V IPC operations.
  *
  * @ipc_permission:
@@ -1243,6 +1293,15 @@ struct security_operations {
 	int (*sk_alloc_security) (struct sock *sk, int family, int priority);
 	void (*sk_free_security) (struct sock *sk);
 #endif	/* CONFIG_SECURITY_NETWORK */
+
+#ifdef CONFIG_SECURITY_NETWORK_XFRM
+	int (*xfrm_policy_alloc_security) (struct xfrm_policy *xp, struct sadb_x_sec_ctx *sec_ctx);
+	int (*xfrm_policy_clone_security) (struct xfrm_policy *old, struct xfrm_policy *new);
+	void (*xfrm_policy_free_security) (struct xfrm_policy *xp);
+	int (*xfrm_state_alloc_security) (struct xfrm_state *x, struct sadb_x_sec_ctx *sec_ctx);
+	void (*xfrm_state_free_security) (struct xfrm_state *x);
+	int (*xfrm_policy_lookup)(struct sock *sk, struct xfrm_selector *sel, struct flowi *fl, u8 dir);
+#endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 };
 
 /* global variables */
@@ -2854,5 +2913,65 @@ static inline void security_sk_free(stru
 }
 #endif	/* CONFIG_SECURITY_NETWORK */
 
+#ifdef CONFIG_SECURITY_NETWORK_XFRM
+static inline int security_xfrm_policy_alloc(struct xfrm_policy *xp, struct sadb_x_sec_ctx *sec_ctx)
+{
+        return security_ops->xfrm_policy_alloc_security(xp, sec_ctx);
+}
+
+static inline int security_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
+{
+        return security_ops->xfrm_policy_clone_security(old, new);
+}
+
+static inline void security_xfrm_policy_free(struct xfrm_policy *xp)
+{
+        security_ops->xfrm_policy_free_security(xp);
+}
+
+static inline int security_xfrm_state_alloc(struct xfrm_state *x, struct sadb_x_sec_ctx *sec_ctx)
+{
+        return security_ops->xfrm_state_alloc_security(x, sec_ctx);
+}
+
+static inline void security_xfrm_state_free(struct xfrm_state *x)
+{
+        security_ops->xfrm_state_free_security(x);
+}
+
+static inline int security_xfrm_policy_lookup(struct sock *sk, struct xfrm_selector *sel, struct flowi *fl, u8 dir)
+{
+        return security_ops->xfrm_policy_lookup(sk, sel, fl, dir);
+}
+#else	/* CONFIG_SECURITY_NETWORK_XFRM */
+static inline int security_xfrm_policy_alloc(struct xfrm_policy *xp, struct sadb_x_sec_ctx *sec_ctx)
+{
+        return 0;
+}
+
+static inline int security_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
+{
+        return 0;
+}
+
+static inline void security_xfrm_policy_free(struct xfrm_policy *xp)
+{
+}
+
+static inline int security_xfrm_state_alloc(struct xfrm_state *x, struct sadb_x_sec_ctx *sec_ctx)
+{
+        return 0;
+}
+
+static inline void security_xfrm_state_free(struct xfrm_state *x)
+{
+}
+
+static inline int security_xfrm_policy_lookup(struct sock *sk, struct xfrm_selector *sel, struct flowi *fl, u8 dir)
+{
+        return 0;
+}
+#endif	/* CONFIG_SECURITY_NETWORK_XFRM */
+
 #endif /* ! __LINUX_SECURITY_H */
 
diff -puN include/linux/xfrm.h~lsm-xfrm-nethooks include/linux/xfrm.h
--- linux-2.6.12-rc4-nethooks/include/linux/xfrm.h~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/include/linux/xfrm.h	2005-05-10 16:22:40.000000000 -0400
@@ -27,6 +27,22 @@ struct xfrm_id
 	__u8		proto;
 };
 
+struct xfrm_sec_ctx {
+	__u8	ctx_doi;
+	__u8	ctx_alg;
+	__u16	ctx_len;
+	__u32	ctx_sid;
+	char	ctx_str[0];
+};
+
+/* Security Context Domains of Interpretation */
+#define XFRM_SC_DOI_RESERVED 0
+#define XFRM_SC_DOI_LSM 1
+
+/* Security Context Algorithms */
+#define XFRM_SC_ALG_RESERVED 0
+#define XFRM_SC_ALG_SELINUX 1
+
 /* Selector, used as selector both on policy rules (SPD) and SAs. */
 
 struct xfrm_selector
@@ -43,8 +59,15 @@ struct xfrm_selector
 	__u8	proto;
 	int	ifindex;
 	uid_t	user;
+	struct xfrm_sec_ctx *security;
 };
 
+/* All but the security field */
+static inline int xfrm_selector_base_size(void)
+{
+	return sizeof(struct xfrm_selector) - sizeof(struct xfrm_sec_ctx *);
+}
+
 #define XFRM_INF (~(__u64)0)
 
 struct xfrm_lifetime_cfg
@@ -146,6 +169,18 @@ enum {
 
 #define XFRM_NR_MSGTYPES (XFRM_MSG_MAX + 1 - XFRM_MSG_BASE)
 
+/*
+ * Generic LSM security context for comunicating to user space
+ * NOTE: Same format as sadb_x_sec_ctx
+ */
+struct xfrm_user_sec_ctx {
+	__u16			len;
+	__u16			exttype;
+	__u8			ctx_alg;  /* LSMs: e.g., selinux == 1 */
+	__u8			ctx_doi;
+	__u16			ctx_len;
+};
+
 struct xfrm_user_tmpl {
 	struct xfrm_id		id;
 	__u16			family;
@@ -173,6 +208,7 @@ enum xfrm_attr_type_t {
 	XFRMA_ALG_CRYPT,	/* struct xfrm_algo */
 	XFRMA_ALG_COMP,		/* struct xfrm_algo */
 	XFRMA_ENCAP,		/* struct xfrm_algo + struct xfrm_encap_tmpl */
+	XFRMA_SEC_CTX,          /* struct xfrm_sec_ctx */
 	XFRMA_TMPL,		/* 1 or more struct xfrm_user_tmpl */
 	__XFRMA_MAX
 
diff -puN include/net/flow.h~lsm-xfrm-nethooks include/net/flow.h
--- linux-2.6.12-rc4-nethooks/include/net/flow.h~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/include/net/flow.h	2005-05-10 15:04:25.000000000 -0400
@@ -84,10 +84,11 @@ struct flowi {
 #define FLOW_DIR_OUT	1
 #define FLOW_DIR_FWD	2
 
-typedef void (*flow_resolve_t)(struct flowi *key, u16 family, u8 dir,
+struct sock;
+typedef void (*flow_resolve_t)(struct flowi *key, struct sock *sk, u16 family, u8 dir,
 			       void **objp, atomic_t **obj_refp);
 
-extern void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
+extern void *flow_cache_lookup(struct flowi *key, struct sock *sk, u16 family, u8 dir,
 			       flow_resolve_t resolver);
 extern void flow_cache_flush(void);
 extern atomic_t flow_cache_genid;
diff -puN include/net/xfrm.h~lsm-xfrm-nethooks include/net/xfrm.h
--- linux-2.6.12-rc4-nethooks/include/net/xfrm.h~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/include/net/xfrm.h	2005-05-12 15:38:22.000000000 -0400
@@ -493,6 +493,27 @@ xfrm_selector_match(struct xfrm_selector
 	return 0;
 }
 
+/* If neither has a context --> match
+   Otherwise, both must have a context and the sids, doi, alg must match */
+static inline int xfrm_sec_ctx_match(struct xfrm_sec_ctx *s1, struct xfrm_sec_ctx *s2)
+{
+	return ((!s1 && !s2) ||
+		(s1 && s2 &&
+		 (s1->ctx_sid == s2->ctx_sid) &&
+		 (s1->ctx_doi == s2->ctx_doi) &&
+		 (s1->ctx_alg == s2->ctx_alg)));
+}
+
+static inline struct xfrm_sec_ctx *xfrm_policy_security(struct xfrm_policy *xp)
+{
+	return (xp ? xp->selector.security : NULL);
+}
+
+static inline struct xfrm_sec_ctx *xfrm_state_security(struct xfrm_state *x)
+{
+	return (x ? x->sel.security : NULL);
+}
+
 /* A struct encoding bundle of transformations to apply to some set of flow.
  *
  * dst->child points to the next element of bundle.
diff -puN net/core/flow.c~lsm-xfrm-nethooks net/core/flow.c
--- linux-2.6.12-rc4-nethooks/net/core/flow.c~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/net/core/flow.c	2005-05-10 15:04:25.000000000 -0400
@@ -162,7 +162,7 @@ static int flow_key_compare(struct flowi
 	return 0;
 }
 
-void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
+void *flow_cache_lookup(struct flowi *key, struct sock *sk, u16 family, u8 dir,
 			flow_resolve_t resolver)
 {
 	struct flow_cache_entry *fle, **head;
@@ -221,7 +221,7 @@ nocache:
 		void *obj;
 		atomic_t *obj_ref;
 
-		resolver(key, family, dir, &obj, &obj_ref);
+		resolver(key, sk, family, dir, &obj, &obj_ref);
 
 		if (fle) {
 			fle->genid = atomic_read(&flow_cache_genid);
diff -puN net/ipv4/xfrm4_policy.c~lsm-xfrm-nethooks net/ipv4/xfrm4_policy.c
--- linux-2.6.12-rc4-nethooks/net/ipv4/xfrm4_policy.c~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/net/ipv4/xfrm4_policy.c	2005-05-16 13:33:47.000000000 -0400
@@ -36,6 +36,8 @@ __xfrm4_find_bundle(struct flowi *fl, st
 		if (xdst->u.rt.fl.oif == fl->oif &&	/*XXX*/
 		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
 	    	    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
+ 		    xfrm_sec_ctx_match(xfrm_policy_security(policy),
+				       xfrm_state_security(dst->xfrm)) &&
 		    xfrm_bundle_ok(xdst, fl, AF_INET)) {
 			dst_clone(dst);
 			break;
diff -puN net/ipv6/xfrm6_policy.c~lsm-xfrm-nethooks net/ipv6/xfrm6_policy.c
--- linux-2.6.12-rc4-nethooks/net/ipv6/xfrm6_policy.c~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/net/ipv6/xfrm6_policy.c	2005-05-10 15:13:49.000000000 -0400
@@ -54,6 +54,8 @@ __xfrm6_find_bundle(struct flowi *fl, st
 				 xdst->u.rt6.rt6i_src.plen);
 		if (ipv6_addr_equal(&xdst->u.rt6.rt6i_dst.addr, &fl_dst_prefix) &&
 		    ipv6_addr_equal(&xdst->u.rt6.rt6i_src.addr, &fl_src_prefix) &&
+ 		    xfrm_sec_ctx_match(xfrm_policy_security(policy),
+ 				       xfrm_state_security(dst->xfrm)) &&
 		    xfrm_bundle_ok(xdst, fl, AF_INET6)) {
 			dst_clone(dst);
 			break;
diff -puN net/key/af_key.c~lsm-xfrm-nethooks net/key/af_key.c
--- linux-2.6.12-rc4-nethooks/net/key/af_key.c~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/net/key/af_key.c	2005-05-16 16:13:56.000000000 -0400
@@ -336,6 +336,7 @@ static u8 sadb_ext_min_len[] = {
 	[SADB_X_EXT_NAT_T_SPORT]	= (u8) sizeof(struct sadb_x_nat_t_port),
 	[SADB_X_EXT_NAT_T_DPORT]	= (u8) sizeof(struct sadb_x_nat_t_port),
 	[SADB_X_EXT_NAT_T_OA]		= (u8) sizeof(struct sadb_address),
+        [SADB_X_EXT_SEC_CTX]            = (u8) sizeof(struct sadb_x_sec_ctx),
 };
 
 /* Verify sadb_address_{len,prefixlen} against sa_family.  */
@@ -383,6 +384,22 @@ static int verify_address_len(void *p)
 	return 0;
 }
 
+static inline int verify_sec_ctx_len(void *p)
+{
+	struct sadb_x_sec_ctx *sec_ctx = (struct sadb_x_sec_ctx *)p;
+	int len = 0;
+
+	len += sizeof(struct sadb_x_sec_ctx);
+	len += sec_ctx->sadb_x_ctx_len;
+	len += sizeof(uint64_t) - 1;
+	len /= sizeof(uint64_t);
+
+	if (sec_ctx->sadb_x_sec_len != len)
+		return -EINVAL;
+
+	return 0;
+}
+
 static int present_and_same_family(struct sadb_address *src,
 				   struct sadb_address *dst)
 {
@@ -438,6 +455,10 @@ static int parse_exthdrs(struct sk_buff 
 				if (verify_address_len(p))
 					return -EINVAL;
 			}				
+			if (ext_type == SADB_X_EXT_SEC_CTX) {
+				if (verify_sec_ctx_len(p))
+					return -EINVAL;
+			}
 			ext_hdrs[ext_type-1] = p;
 		}
 		p   += ext_len;
@@ -586,6 +607,9 @@ static struct sk_buff * pfkey_xfrm_state
 	struct sadb_key *key;
 	struct sadb_x_sa2 *sa2;
 	struct sockaddr_in *sin;
+	struct sadb_x_sec_ctx *sec_ctx;
+	struct xfrm_sec_ctx *xfrm_ctx;
+	int ctx_size = 0;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct sockaddr_in6 *sin6;
 #endif
@@ -609,6 +633,12 @@ static struct sk_buff * pfkey_xfrm_state
 			sizeof(struct sadb_address)*2 + 
 				sockaddr_size*2 +
 					sizeof(struct sadb_x_sa2);
+
+	if ((xfrm_ctx = xfrm_state_security(x))) {
+		ctx_size = PFKEY_ALIGN8(xfrm_ctx->ctx_len);
+		size += sizeof(struct sadb_x_sec_ctx) + ctx_size;
+        }
+
 	/* identity & sensitivity */
 
 	if ((x->props.family == AF_INET &&
@@ -892,6 +922,20 @@ static struct sk_buff * pfkey_xfrm_state
 		n_port->sadb_x_nat_t_port_reserved = 0;
 	}
 
+	/* security context */
+        if (xfrm_ctx) {
+		sec_ctx = (struct sadb_x_sec_ctx *) skb_put(skb,
+				sizeof(struct sadb_x_sec_ctx) + ctx_size);
+		sec_ctx->sadb_x_sec_len =
+		  (sizeof(struct sadb_x_sec_ctx) + ctx_size) / sizeof(uint64_t);
+		sec_ctx->sadb_x_sec_exttype = SADB_X_EXT_SEC_CTX;
+		sec_ctx->sadb_x_ctx_doi = xfrm_ctx->ctx_doi;
+		sec_ctx->sadb_x_ctx_alg = xfrm_ctx->ctx_alg;
+		sec_ctx->sadb_x_ctx_len = xfrm_ctx->ctx_len;
+		memcpy(sec_ctx + 1, xfrm_ctx->ctx_str,
+		       xfrm_ctx->ctx_len);
+	}
+
 	return skb;
 }
 
@@ -902,6 +946,7 @@ static struct xfrm_state * pfkey_msg2xfr
 	struct sadb_lifetime *lifetime;
 	struct sadb_sa *sa;
 	struct sadb_key *key;
+	struct sadb_x_sec_ctx *sec_ctx;
 	uint16_t proto;
 	int err;
 	
@@ -984,6 +1029,13 @@ static struct xfrm_state * pfkey_msg2xfr
 		x->lft.soft_add_expires_seconds = lifetime->sadb_lifetime_addtime;
 		x->lft.soft_use_expires_seconds = lifetime->sadb_lifetime_usetime;
 	}
+
+	sec_ctx = (struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];
+	if (sec_ctx != NULL) {
+		if (security_xfrm_state_alloc(x, sec_ctx))
+			goto out;
+	}
+
 	key = (struct sadb_key*) ext_hdrs[SADB_EXT_KEY_AUTH-1];
 	if (sa->sadb_sa_auth) {
 		int keysize = 0;
@@ -1634,6 +1686,18 @@ parse_ipsecrequests(struct xfrm_policy *
 	return 0;
 }
 
+static inline int pfkey_xfrm_policy2sec_ctx_size(struct xfrm_policy *xp)
+{
+	struct xfrm_sec_ctx *xfrm_ctx = xfrm_policy_security(xp);
+
+	if (xfrm_ctx) {
+		int len = sizeof(struct sadb_x_sec_ctx);
+		len += xfrm_ctx->ctx_len;
+		return PFKEY_ALIGN8(len);
+	}
+	return 0;
+}
+
 static int pfkey_xfrm_policy2msg_size(struct xfrm_policy *xp)
 {
 	int sockaddr_size = pfkey_sockaddr_size(xp->family);
@@ -1647,7 +1711,8 @@ static int pfkey_xfrm_policy2msg_size(st
 		(sockaddr_size * 2) +
 		sizeof(struct sadb_x_policy) +
 		(xp->xfrm_nr * (sizeof(struct sadb_x_ipsecrequest) +
-				(socklen * 2)));
+				(socklen * 2))) +
+		pfkey_xfrm_policy2sec_ctx_size(xp);
 }
 
 static struct sk_buff * pfkey_xfrm_policy2msg_prep(struct xfrm_policy *xp)
@@ -1671,6 +1736,8 @@ static void pfkey_xfrm_policy2msg(struct
 	struct sadb_lifetime *lifetime;
 	struct sadb_x_policy *pol;
 	struct sockaddr_in   *sin;
+	struct sadb_x_sec_ctx *sec_ctx;
+	struct xfrm_sec_ctx *xfrm_ctx;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct sockaddr_in6  *sin6;
 #endif
@@ -1855,19 +1922,35 @@ static void pfkey_xfrm_policy2msg(struct
 			}
 		}
 	}
+
+	/* security context */
+        if ((xfrm_ctx = xfrm_policy_security(xp))) {
+		int ctx_size = pfkey_xfrm_policy2sec_ctx_size(xp);
+
+		sec_ctx = (struct sadb_x_sec_ctx *) skb_put(skb, ctx_size);
+		sec_ctx->sadb_x_sec_len = ctx_size / sizeof(uint64_t);
+		sec_ctx->sadb_x_sec_exttype = SADB_X_EXT_SEC_CTX;
+		sec_ctx->sadb_x_ctx_doi = xfrm_ctx->ctx_doi;
+		sec_ctx->sadb_x_ctx_alg = xfrm_ctx->ctx_alg;
+		sec_ctx->sadb_x_ctx_len = xfrm_ctx->ctx_len;
+		memcpy(sec_ctx + 1, xfrm_ctx->ctx_str,
+		       xfrm_ctx->ctx_len);
+	}
+
 	hdr->sadb_msg_len = size / sizeof(uint64_t);
 	hdr->sadb_msg_reserved = atomic_read(&xp->refcnt);
 }
 
 static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
-	int err;
+	int err = 0;
 	struct sadb_lifetime *lifetime;
 	struct sadb_address *sa;
 	struct sadb_x_policy *pol;
 	struct xfrm_policy *xp;
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
+	struct sadb_x_sec_ctx *sec_ctx;
 
 	if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
 				     ext_hdrs[SADB_EXT_ADDRESS_DST-1]) ||
@@ -1914,6 +1997,12 @@ static int pfkey_spdadd(struct sock *sk,
 	if (xp->selector.dport)
 		xp->selector.dport_mask = ~0;
 
+	sec_ctx = (struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];
+	if (sec_ctx != NULL) {
+		if (security_xfrm_policy_alloc(xp, sec_ctx))
+			goto out;
+	}
+
 	xp->lft.soft_byte_limit = XFRM_INF;
 	xp->lft.hard_byte_limit = XFRM_INF;
 	xp->lft.soft_packet_limit = XFRM_INF;
@@ -1963,6 +2052,7 @@ static int pfkey_spdadd(struct sock *sk,
 	return 0;
 
 out:
+	security_xfrm_policy_free(xp);
 	kfree(xp);
 	return err;
 }
@@ -1972,10 +2062,11 @@ static int pfkey_spddelete(struct sock *
 	int err;
 	struct sadb_address *sa;
 	struct sadb_x_policy *pol;
-	struct xfrm_policy *xp;
+	struct xfrm_policy *xp, tmp;
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
 	struct xfrm_selector sel;
+	struct sadb_x_sec_ctx *sec_ctx;
 
 	if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
 				     ext_hdrs[SADB_EXT_ADDRESS_DST-1]) ||
@@ -2004,7 +2095,15 @@ static int pfkey_spddelete(struct sock *
 	if (sel.dport)
 		sel.dport_mask = ~0;
 
-	xp = xfrm_policy_bysel(pol->sadb_x_policy_dir-1, &sel, 1);
+	sec_ctx = (struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];
+	memcpy(&tmp.selector, &sel, sizeof(struct xfrm_selector));
+	if (sec_ctx != NULL) {
+		if (security_xfrm_policy_alloc(&tmp, sec_ctx))
+			goto out;
+	}
+
+	xp = xfrm_policy_bysel(pol->sadb_x_policy_dir-1, &tmp.selector, 1);
+	security_xfrm_policy_free(&tmp);
 	if (xp == NULL)
 		return -ENOENT;
 
@@ -2482,6 +2581,7 @@ static struct xfrm_policy *pfkey_compile
 {
 	struct xfrm_policy *xp;
 	struct sadb_x_policy *pol = (struct sadb_x_policy*)data;
+	struct sadb_x_sec_ctx *sec_ctx;
 
 	switch (family) {
 	case AF_INET:
@@ -2531,10 +2631,21 @@ static struct xfrm_policy *pfkey_compile
 	    (*dir = parse_ipsecrequests(xp, pol)) < 0)
 		goto out;
 
+	/* security context too */
+	if (len >= (pol->sadb_x_policy_len*8 +
+		    sizeof(struct sadb_x_sec_ctx))) {
+		char *p = (char *) pol;
+		p += pol->sadb_x_policy_len*8;
+		sec_ctx = (struct sadb_x_sec_ctx *) p;
+		if (security_xfrm_policy_alloc(xp, sec_ctx))
+			goto out;
+	}
+
 	*dir = pol->sadb_x_policy_dir-1;
 	return xp;
 
 out:
+	security_xfrm_policy_free(xp);
 	kfree(xp);
 	return NULL;
 }
diff -puN net/xfrm/xfrm_policy.c~lsm-xfrm-nethooks net/xfrm/xfrm_policy.c
--- linux-2.6.12-rc4-nethooks/net/xfrm/xfrm_policy.c~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/net/xfrm/xfrm_policy.c	2005-05-16 16:16:54.000000000 -0400
@@ -257,6 +257,7 @@ void __xfrm_policy_destroy(struct xfrm_p
 	if (del_timer(&policy->timer))
 		BUG();
 
+	security_xfrm_policy_free(policy);
 	kfree(policy);
 }
 EXPORT_SYMBOL(__xfrm_policy_destroy);
@@ -396,7 +397,8 @@ struct xfrm_policy *xfrm_policy_bysel(in
 
 	write_lock_bh(&xfrm_policy_lock);
 	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL; p = &pol->next) {
-		if (memcmp(sel, &pol->selector, sizeof(*sel)) == 0) {
+		if ((memcmp(sel, &pol->selector, xfrm_selector_base_size()) == 0) &&
+		    (xfrm_sec_ctx_match(sel->security, xfrm_policy_security(pol)))) {
 			xfrm_pol_hold(pol);
 			if (delete)
 				*p = pol->next;
@@ -492,7 +494,7 @@ EXPORT_SYMBOL(xfrm_policy_walk);
 
 /* Find policy to apply to this flow. */
 
-static void xfrm_policy_lookup(struct flowi *fl, u16 family, u8 dir,
+static void xfrm_policy_lookup(struct flowi *fl, struct sock *sk, u16 family, u8 dir,
 			       void **objp, atomic_t **obj_refp)
 {
 	struct xfrm_policy *pol;
@@ -506,9 +508,12 @@ static void xfrm_policy_lookup(struct fl
 			continue;
 
 		match = xfrm_selector_match(sel, fl, family);
+
 		if (match) {
-			xfrm_pol_hold(pol);
-			break;
+ 			if (!security_xfrm_policy_lookup(sk, sel, fl, dir)) {
+				xfrm_pol_hold(pol);
+				break;
+			}
 		}
 	}
 	read_unlock_bh(&xfrm_policy_lock);
@@ -516,15 +521,38 @@ static void xfrm_policy_lookup(struct fl
 		*obj_refp = &pol->refcnt;
 }
 
+static inline int policy_to_flow_dir(int dir)
+{
+	if (XFRM_POLICY_IN == FLOW_DIR_IN &&
+ 	    XFRM_POLICY_OUT == FLOW_DIR_OUT &&
+ 	    XFRM_POLICY_FWD == FLOW_DIR_FWD)
+ 		return dir;
+ 	switch (dir) {
+ 	default:
+ 	case XFRM_POLICY_IN:
+ 		return FLOW_DIR_IN;
+ 	case XFRM_POLICY_OUT:
+ 		return FLOW_DIR_OUT;
+ 	case XFRM_POLICY_FWD:
+ 		return FLOW_DIR_FWD;
+	};
+}
+
 static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struct flowi *fl)
 {
 	struct xfrm_policy *pol;
 
 	read_lock_bh(&xfrm_policy_lock);
 	if ((pol = sk->sk_policy[dir]) != NULL) {
-		int match = xfrm_selector_match(&pol->selector, fl,
+ 		struct xfrm_selector *sel = &pol->selector;
+ 		int match = xfrm_selector_match(sel, fl,
 						sk->sk_family);
+ 		int err = 0;
+
 		if (match)
+ 			err = security_xfrm_policy_lookup(sk, sel, fl, policy_to_flow_dir(dir));
+
+ 		if (match && !err)
 			xfrm_pol_hold(pol);
 		else
 			pol = NULL;
@@ -595,6 +623,10 @@ static struct xfrm_policy *clone_policy(
 
 	if (newp) {
 		newp->selector = old->selector;
+		if (security_xfrm_policy_clone(old, newp)) {
+			kfree(newp);
+			return (struct xfrm_policy *)NULL;  /* ENOMEM */
+		}
 		newp->lft = old->lft;
 		newp->curlft = old->curlft;
 		newp->action = old->action;
@@ -706,22 +738,6 @@ xfrm_bundle_create(struct xfrm_policy *p
 	return err;
 }
 
-static inline int policy_to_flow_dir(int dir)
-{
-	if (XFRM_POLICY_IN == FLOW_DIR_IN &&
-	    XFRM_POLICY_OUT == FLOW_DIR_OUT &&
-	    XFRM_POLICY_FWD == FLOW_DIR_FWD)
-		return dir;
-	switch (dir) {
-	default:
-	case XFRM_POLICY_IN:
-		return FLOW_DIR_IN;
-	case XFRM_POLICY_OUT:
-		return FLOW_DIR_OUT;
-	case XFRM_POLICY_FWD:
-		return FLOW_DIR_FWD;
-	};
-}
 
 static int stale_bundle(struct dst_entry *dst);
 
@@ -751,7 +767,7 @@ restart:
 		if ((dst_orig->flags & DST_NOXFRM) || !xfrm_policy_list[XFRM_POLICY_OUT])
 			return 0;
 
-		policy = flow_cache_lookup(fl, family,
+		policy = flow_cache_lookup(fl, sk, family,
 					   policy_to_flow_dir(XFRM_POLICY_OUT),
 					   xfrm_policy_lookup);
 	}
@@ -942,7 +958,7 @@ int __xfrm_policy_check(struct sock *sk,
 		int i;
 
 		for (i=skb->sp->len-1; i>=0; i--) {
-		  struct sec_decap_state *xvec = &(skb->sp->x[i]);
+			struct sec_decap_state *xvec = &(skb->sp->x[i]);
 			if (!xfrm_selector_match(&xvec->xvec->sel, &fl, family))
 				return 0;
 
@@ -960,7 +976,7 @@ int __xfrm_policy_check(struct sock *sk,
 		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
 
 	if (!pol)
-		pol = flow_cache_lookup(&fl, family,
+		pol = flow_cache_lookup(&fl, sk, family,
 					policy_to_flow_dir(dir),
 					xfrm_policy_lookup);
 
diff -puN net/xfrm/xfrm_state.c~lsm-xfrm-nethooks net/xfrm/xfrm_state.c
--- linux-2.6.12-rc4-nethooks/net/xfrm/xfrm_state.c~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/net/xfrm/xfrm_state.c	2005-05-16 15:49:41.000000000 -0400
@@ -74,6 +74,7 @@ static void xfrm_state_gc_destroy(struct
 		x->type->destructor(x);
 		xfrm_put_type(x->type);
 	}
+	security_xfrm_state_free(x);
 	kfree(x);
 }
 
@@ -338,7 +339,8 @@ xfrm_state_find(xfrm_address_t *daddr, x
 			      selector.
 			 */
 			if (x->km.state == XFRM_STATE_VALID) {
-				if (!xfrm_selector_match(&x->sel, fl, family))
+				if (!xfrm_selector_match(&x->sel, fl, family) ||
+				    !xfrm_sec_ctx_match(xfrm_policy_security(pol), xfrm_state_security(x)))
 					continue;
 				if (!best ||
 				    best->km.dying > x->km.dying ||
@@ -349,7 +351,8 @@ xfrm_state_find(xfrm_address_t *daddr, x
 				acquire_in_progress = 1;
 			} else if (x->km.state == XFRM_STATE_ERROR ||
 				   x->km.state == XFRM_STATE_EXPIRED) {
-				if (xfrm_selector_match(&x->sel, fl, family))
+ 				if (xfrm_selector_match(&x->sel, fl, family) &&
+				    xfrm_sec_ctx_match(xfrm_policy_security(pol), xfrm_state_security(x)))
 					error = -ESRCH;
 			}
 		}
@@ -374,6 +377,13 @@ xfrm_state_find(xfrm_address_t *daddr, x
 		xfrm_init_tempsel(x, fl, tmpl, daddr, saddr, family);
 
 		if (km_query(x, tmpl, pol) == 0) {
+			if (!xfrm_sec_ctx_match(xfrm_policy_security(pol), xfrm_state_security(x))) {
+				x->km.state = XFRM_STATE_DEAD;
+				xfrm_state_put(x);
+				x = NULL;
+				error = 1;
+				goto out;
+			}
 			x->km.state = XFRM_STATE_ACQ;
 			list_add_tail(&x->bydst, xfrm_state_bydst+h);
 			xfrm_state_hold(x);
diff -puN net/xfrm/xfrm_user.c~lsm-xfrm-nethooks net/xfrm/xfrm_user.c
--- linux-2.6.12-rc4-nethooks/net/xfrm/xfrm_user.c~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/net/xfrm/xfrm_user.c	2005-05-16 16:20:27.000000000 -0400
@@ -200,6 +200,32 @@ static int attach_encap_tmpl(struct xfrm
 	return 0;
 }
 
+
+static inline int xfrm_user_sec_ctx_size(struct xfrm_policy *xp)
+{
+	struct xfrm_sec_ctx *xfrm_ctx = xfrm_policy_security(xp);
+	int len;
+
+	if (xfrm_ctx) {
+		len = sizeof(struct xfrm_user_sec_ctx);
+		len += xfrm_ctx->ctx_len;
+		return len;
+	}
+	return 0;
+}
+
+static int attach_sec_ctx(struct xfrm_state *x, struct rtattr *u_arg)
+{
+	struct xfrm_user_sec_ctx *uxsc = RTA_DATA(u_arg);
+
+	if (uxsc) {
+		security_xfrm_state_free(x);
+		return security_xfrm_state_alloc(x, uxsc);
+	}
+
+	return 0;
+}
+
 static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *p)
 {
 	memcpy(&x->id, &p->id, sizeof(x->id));
@@ -249,6 +275,9 @@ static struct xfrm_state *xfrm_state_con
 	if (err)
 		goto error;
 
+	if ((err = attach_sec_ctx(x, xfrma[XFRMA_SEC_CTX-1])))
+		goto error;
+
 	x->curlft.add_time = (unsigned long) xtime.tv_sec;
 	x->km.state = XFRM_STATE_VALID;
 	x->km.seq = p->seq;
@@ -335,6 +364,27 @@ struct xfrm_dump_info {
 	int this_idx;
 };
 
+static int dump_one_sec_ctx(struct xfrm_sec_ctx *ctx, struct xfrm_user_sec_ctx *uctx, struct sk_buff *skb, int ctx_size)
+{
+	if (!ctx)
+		return -1;
+
+	uctx->exttype = XFRMA_SEC_CTX;
+	uctx->len = ctx_size;
+	uctx->ctx_doi = ctx->ctx_doi;
+	uctx->ctx_alg = ctx->ctx_alg;
+	uctx->ctx_len = ctx->ctx_len;
+
+	memcpy(uctx + 1, ctx->ctx_str, ctx->ctx_len);
+
+	RTA_PUT(skb, XFRMA_SEC_CTX, ctx_size, uctx);
+
+	return 0;
+
+rtattr_failure:
+	return -1;
+}
+
 static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
 {
 	struct xfrm_dump_info *sp = ptr;
@@ -343,6 +393,7 @@ static int dump_one_state(struct xfrm_st
 	struct xfrm_usersa_info *p;
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb->tail;
+	struct xfrm_sec_ctx *xfrm_ctx;
 
 	if (sp->this_idx < sp->start_idx)
 		goto out;
@@ -367,6 +418,18 @@ static int dump_one_state(struct xfrm_st
 	if (x->encap)
 		RTA_PUT(skb, XFRMA_ENCAP, sizeof(*x->encap), x->encap);
 
+	if ((xfrm_ctx = xfrm_state_security(x))) {
+		int ctx_size = sizeof(struct xfrm_user_sec_ctx) +
+			xfrm_ctx->ctx_len + 1;
+		struct xfrm_user_sec_ctx *uctx = kmalloc(ctx_size, GFP_KERNEL);
+		int err;
+
+	        err = dump_one_sec_ctx(xfrm_ctx, uctx, skb, ctx_size);
+		kfree(uctx);
+
+		if (err < 0)
+			goto rtattr_failure;
+	}
 	nlh->nlmsg_len = skb->tail - b;
 out:
 	sp->this_idx++;
@@ -580,6 +643,27 @@ static int verify_newpolicy_info(struct 
 	return verify_policy_dir(p->dir);
 }
 
+static int copy_sec_ctx(struct xfrm_policy *pol, struct xfrm_user_sec_ctx *uctx)
+{
+	int err = 0;
+
+	security_xfrm_policy_free(pol);
+	err = security_xfrm_policy_alloc(pol, uctx);
+	return err;
+}
+
+static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct rtattr **xfrma)
+{
+	struct rtattr *rt = xfrma[XFRMA_SEC_CTX-1];
+	struct xfrm_user_sec_ctx *uctx = RTA_DATA(rt);
+
+	if (uctx) {
+		copy_sec_ctx(pol, uctx);
+	}
+
+	return 0;
+}
+
 static void copy_templates(struct xfrm_policy *xp, struct xfrm_user_tmpl *ut,
 			   int nr)
 {
@@ -658,7 +742,10 @@ static struct xfrm_policy *xfrm_policy_c
 	}
 
 	copy_from_user_policy(xp, p);
-	err = copy_from_user_tmpl(xp, xfrma);
+
+	if (!(err = copy_from_user_tmpl(xp, xfrma)))
+		err = copy_from_user_sec_ctx(xp, xfrma);
+
 	if (err) {
 		*errp = err;
 		kfree(xp);
@@ -728,6 +815,27 @@ rtattr_failure:
 	return -1;
 }
 
+static int copy_to_user_sec_ctx(struct xfrm_policy *xp, struct sk_buff *skb, int src)
+{
+	int err = 0;
+	struct xfrm_sec_ctx *xfrm_ctx = xfrm_policy_security(xp);
+
+	if (xfrm_ctx) {
+		int ctx_size = sizeof(struct xfrm_user_sec_ctx) +
+			xfrm_ctx->ctx_len;
+		struct xfrm_user_sec_ctx *uctx = kmalloc(ctx_size, GFP_KERNEL);
+
+		if (!uctx)
+			return -ENOMEM;
+
+	        err = dump_one_sec_ctx(xfrm_ctx, uctx, skb,
+				       ctx_size);
+		kfree(uctx);
+	}
+
+	return err;
+}
+
 static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr)
 {
 	struct xfrm_dump_info *sp = ptr;
@@ -749,6 +857,8 @@ static int dump_one_policy(struct xfrm_p
 	copy_to_user_policy(xp, p, dir);
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
+	if (copy_to_user_sec_ctx(xp, skb, 0) < 0)
+		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb->tail - b;
 out:
@@ -804,7 +914,7 @@ static struct sk_buff *xfrm_policy_netli
 
 static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
 {
-	struct xfrm_policy *xp;
+	struct xfrm_policy *xp, tmp;
 	struct xfrm_userpolicy_id *p;
 	int err;
 	int delete;
@@ -818,8 +928,20 @@ static int xfrm_get_policy(struct sk_buf
 
 	if (p->index)
 		xp = xfrm_policy_byid(p->dir, p->index, delete);
-	else
-		xp = xfrm_policy_bysel(p->dir, &p->sel, delete);
+	else {
+		struct rtattr **rtattrs = (struct rtattr **) xfrma;
+		struct rtattr *rt = rtattrs[XFRMA_SEC_CTX-1];
+
+		memcpy(&tmp.selector, &p->sel, sizeof(struct xfrm_selector));
+		if (rt) {
+			struct xfrm_user_sec_ctx *uxsc = RTA_DATA(rt);
+
+			if ((err = security_xfrm_policy_alloc(&tmp, uxsc)))
+				return err;
+		}
+		xp = xfrm_policy_bysel(p->dir, &tmp.selector, delete);
+		security_xfrm_policy_free(&tmp);
+	}
 	if (xp == NULL)
 		return -ENOENT;
 
@@ -1101,6 +1223,8 @@ static int build_acquire(struct sk_buff 
 
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
+	if (copy_to_user_sec_ctx(xp, skb, 1) < 0)
+		goto nlmsg_failure;
 
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
@@ -1114,10 +1238,12 @@ static int xfrm_send_acquire(struct xfrm
 			     struct xfrm_policy *xp, int dir)
 {
 	struct sk_buff *skb;
+	struct xfrm_sec_ctx *ctx;
 	size_t len;
 
 	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	len += NLMSG_SPACE(sizeof(struct xfrm_user_acquire));
+	len += xfrm_user_sec_ctx_size(xp);
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
@@ -1138,8 +1264,9 @@ static struct xfrm_policy *xfrm_compile_
 {
 	struct xfrm_userpolicy_info *p = (struct xfrm_userpolicy_info *)data;
 	struct xfrm_user_tmpl *ut = (struct xfrm_user_tmpl *) (p + 1);
+	struct xfrm_user_sec_ctx *uctx;
 	struct xfrm_policy *xp;
-	int nr;
+	int nr = 0;
 
 	switch (family) {
 	case AF_INET:
@@ -1167,9 +1294,26 @@ static struct xfrm_policy *xfrm_compile_
 	    verify_newpolicy_info(p))
 		return NULL;
 
+ 	if (len > (sizeof(*p) + (XFRM_MAX_DEPTH *
+				 sizeof(struct xfrm_user_tmpl)))) {
+ 		struct xfrm_user_tmpl *tmpl;
+ 		uctx = (struct xfrm_user_sec_ctx *) (ut + XFRM_MAX_DEPTH);
+
+ 		if (len != sizeof(*p) +
+		    (XFRM_MAX_DEPTH * sizeof(struct xfrm_user_tmpl)) +
+		    uctx->len)
+ 			return NULL;
+
+                 /* spi must be zero'd unless real tmpl */
+ 		for (tmpl = ut; tmpl->id.spi != 0; tmpl = tmpl + 1)
+ 			nr++;
+ 	}
+ 	else {
+ 		uctx = (struct xfrm_user_sec_ctx *) NULL;
 	nr = ((len - sizeof(*p)) / sizeof(*ut));
 	if (nr > XFRM_MAX_DEPTH)
 		return NULL;
+ 	}
 
 	xp = xfrm_policy_alloc(GFP_KERNEL);
 	if (xp == NULL) {
@@ -1179,6 +1323,8 @@ static struct xfrm_policy *xfrm_compile_
 
 	copy_from_user_policy(xp, p);
 	copy_templates(xp, ut, nr);
+	if (uctx)
+		copy_sec_ctx(xp, uctx);
 
 	*dir = p->dir;
 
@@ -1199,6 +1345,8 @@ static int build_polexpire(struct sk_buf
 	copy_to_user_policy(xp, &upe->pol, dir);
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
+	if (copy_to_user_sec_ctx(xp, skb, 2) < 0)
+		goto nlmsg_failure;
 	upe->hard = !!hard;
 
 	nlh->nlmsg_len = skb->tail - b;
@@ -1216,6 +1364,7 @@ static int xfrm_send_policy_notify(struc
 
 	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	len += NLMSG_SPACE(sizeof(struct xfrm_user_polexpire));
+	len += xfrm_user_sec_ctx_size(xp);
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
diff -puN security/dummy.c~lsm-xfrm-nethooks security/dummy.c
--- linux-2.6.12-rc4-nethooks/security/dummy.c~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/security/dummy.c	2005-05-10 15:40:22.000000000 -0400
@@ -811,6 +811,35 @@ static inline void dummy_sk_free_securit
 }
 #endif	/* CONFIG_SECURITY_NETWORK */
 
+#ifdef CONFIG_SECURITY_NETWORK_XFRM
+static int dummy_xfrm_policy_alloc_security(struct xfrm_policy *xp, struct sadb_x_sec_ctx *sec_ctx)
+{
+        return 0;
+}
+
+static inline int dummy_xfrm_policy_clone_security(struct xfrm_policy *old, struct xfrm_policy *new)
+{
+        return 0;
+}
+
+static void dummy_xfrm_policy_free_security(struct xfrm_policy *xp)
+{
+}
+
+static int dummy_xfrm_state_alloc_security(struct xfrm_state *x, struct sadb_x_sec_ctx *sec_ctx)
+{
+        return 0;
+}
+
+static void dummy_xfrm_state_free_security(struct xfrm_state *x)
+{
+}
+
+static int dummy_xfrm_policy_lookup(struct sock *sk, struct xfrm_selector *sel, struct flowi *fl, u8 dir)
+{
+        return 0;
+}
+#endif /* CONFIG_SECURITY_NETWORK_XFRM */
 static int dummy_register_security (const char *name, struct security_operations *ops)
 {
 	return -EINVAL;
@@ -992,5 +1021,13 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, sk_alloc_security);
 	set_to_dummy_if_null(ops, sk_free_security);
 #endif	/* CONFIG_SECURITY_NETWORK */
+#ifdef  CONFIG_SECURITY_NETWORK_XFRM
+	set_to_dummy_if_null(ops, xfrm_policy_alloc_security);
+	set_to_dummy_if_null(ops, xfrm_policy_clone_security);
+	set_to_dummy_if_null(ops, xfrm_policy_free_security);
+	set_to_dummy_if_null(ops, xfrm_state_alloc_security);
+	set_to_dummy_if_null(ops, xfrm_state_free_security);
+	set_to_dummy_if_null(ops, xfrm_policy_lookup);
+#endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 }
 
diff -puN security/Kconfig~lsm-xfrm-nethooks security/Kconfig
--- linux-2.6.12-rc4-nethooks/security/Kconfig~lsm-xfrm-nethooks	2005-05-10 15:04:25.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/security/Kconfig	2005-05-10 15:28:44.000000000 -0400
@@ -53,6 +53,19 @@ config SECURITY_NETWORK
 	  implement socket and networking access controls.
 	  If you are unsure how to answer this question, answer N.
 
+config SECURITY_NETWORK_XFRM
+	bool "XFRM (IPSec) Networking Security Hooks"
+	depends on XFRM && SECURITY_NETWORK
+	help
+	  This enables the XFRM (IPSec) networking security hooks.
+	  If enabled, a security module can use these hooks to
+	  implement per-packet access controls based on labels
+	  derived from IPSec policy.  Non-IPSec communications are
+	  designated as unlabelled, and only sockets authorized
+	  to communicate unlabelled data can send without using
+	  IPSec.
+	  If you are unsure how to answer this question, answer N.
+
 config SECURITY_CAPABILITIES
 	tristate "Default Linux Capabilities"
 	depends on SECURITY
_
