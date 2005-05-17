From: jaegert <jaegert@us.ibm.com>
Subject: [PATCH 2/2] Resend: LSM-IPSec Networking Hooks
Date: Tue, 17 May 2005 16:27:51 -0400
Message-ID: <1116361671.5560.125.camel@dyn9002018177.watson.ibm.com>
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


This patch series implements per packet access control via the
extension of the Linux Security Modules (LSM) interface by hooks in
the XFRM and pfkey subsystems that leverage IPSec security
associations to label packets.  Extensions to the SELinux LSM are
included that leverage the patch for this purpose.

This patch implements the changes necessary to the SELinux LSM to
create, deallocate, and use security contexts for policies
(xfrm_policy) and security associations (xfrm_state) that enable
control of a socket's ability to send and receive packets.

Patch purpose:

The patch is designed to enable the SELinux LSM to implement access
control on individual packets based on the strongly authenticated
IPSec security association.  Such access controls augment the existing
ones in SELinux based on network interface and IP address.  The former
are very coarse-grained, and the latter can be spoofed.  By using
IPSec, the SELinux can control access to remote hosts based on
cryptographic keys generated using the IPSec mechanism.  This enables
access control on a per-machine basis or per-application if the remote
machine is running the same mechanism and trusted to enforce the
access control policy.

Patch design approach:

The patch's main function is to authorize a socket's access to a IPSec
policy based on their security contexts.  Since the communication is
implemented by a security association, the patch ensures that the
security association's negotiated and used have the same security
context.  The patch enables allocation and deallocation of such
security contexts for policies and security associations.  It also
enables copying of the security context when policies are cloned.
Lastly, the patch ensures that packets that are sent without using a
IPSec security assocation with a security context are allowed to be
sent in that manner.  

A presentation available at
www.selinux-symposium.org/2005/presentations/session2/2-3-jaeger.pdf
from the SELinux symposium describes the overall approach.

Patch implementation details: 

The function which authorizes a socket to perform a requested
operation (send/receive) on a IPSec policy (xfrm_policy) is
selinux_xfrm_policy_lookup.  The Netfilter and rcv_skb hooks ensure
that if a IPSec SA with a securit y association has not been used,
then the socket is allowed to send or receive the packet,
respectively.

The patch implements SELinux function for allocating security contexts
when policies (xfrm_policy) are created via the pfkey or xfrm_user
interfaces via selinux_xfrm_policy_alloc.  When a security association
is built, SELinux allocates the security context designated by the
XFRM subsystem which is based on that of the authorized policy via
selinux_xfrm_state_alloc.

When a xfrm_policy is cloned, the security context of that policy, if
any, is copied to the clone via selinux_xfrm_policy_clone.

When a xfrm_policy or xfrm_state is freed, its security context, if
any is also freed at selinux_xfrm_policy_free or
selinux_xfrm_state_free.

Testing:

The SELinux authorization function is tested using ipsec-tools.  We
created policies and security associations with particular security
contexts and added SELinux access control policy entries to verify the
authorization decision.  We also made sure that packets for which no
security context was supplied (which either did or did not use
security associations) were authorized using an unlabelled context.


---

 security/selinux/Makefile           |    2 
 security/selinux/hooks.c            |   20 +
 security/selinux/include/nethooks.h |    8 
 security/selinux/nethooks.c         |  428 ++++++++++++++++++++++++++++++++++++
 4 files changed, 457 insertions(+), 1 deletion(-)

diff -puN security/selinux/hooks.c~lsm-selinux-nethooks security/selinux/hooks.c
--- linux-2.6.12-rc4-nethooks/security/selinux/hooks.c~lsm-selinux-nethooks	2005-05-13 13:15:47.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/security/selinux/hooks.c	2005-05-13 13:15:47.000000000 -0400
@@ -72,6 +72,7 @@
 #include "avc.h"
 #include "objsec.h"
 #include "netif.h"
+#include "nethooks.h"
 
 #define XATTR_SELINUX_SUFFIX "selinux"
 #define XATTR_NAME_SELINUX XATTR_SECURITY_PREFIX XATTR_SELINUX_SUFFIX
@@ -3350,6 +3351,10 @@ static int selinux_socket_sock_rcv_skb(s
 		err = avc_has_perm(sock_sid, port_sid,
 				   sock_class, recv_perm, &ad);
 	}
+
+	if (!err)
+		err = selinux_xfrm_sock_rcv_skb(sock_sid, skb);
+
 out:	
 	return err;
 }
@@ -3537,6 +3542,11 @@ static unsigned int selinux_ip_postroute
 		                   send_perm, &ad) ? NF_DROP : NF_ACCEPT;
 	}
 
+	if (err != NF_ACCEPT)
+		goto out;
+
+	err = selinux_xfrm_postroute_last(isec->sid, skb);
+
 out:
 	return err;
 }
@@ -4389,6 +4399,15 @@ static struct security_operations selinu
 	.sk_alloc_security =		selinux_sk_alloc_security,
 	.sk_free_security =		selinux_sk_free_security,
 #endif
+
+#ifdef CONFIG_SECURITY_NETWORK_XFRM
+	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
+	.xfrm_policy_clone_security =	selinux_xfrm_policy_clone,
+	.xfrm_policy_free_security =	selinux_xfrm_policy_free,
+	.xfrm_state_alloc_security =	selinux_xfrm_state_alloc,
+	.xfrm_state_free_security =	selinux_xfrm_state_free,
+	.xfrm_policy_lookup =	        selinux_xfrm_policy_lookup,
+#endif
 };
 
 static __init int selinux_init(void)
@@ -4499,6 +4518,7 @@ static int __init selinux_nf_ip_init(voi
 		panic("SELinux: nf_register_hook for IPv6: error %d\n", err);
 
 #endif	/* IPV6 */
+
 out:
 	return err;
 }
diff -puN /dev/null security/selinux/include/nethooks.h
--- /dev/null	2004-02-23 16:02:56.000000000 -0500
+++ linux-2.6.12-rc4-nethooks-root/security/selinux/include/nethooks.h	2005-05-13 13:15:47.000000000 -0400
@@ -0,0 +1,8 @@
+int selinux_xfrm_policy_alloc(struct xfrm_policy *xp, struct sadb_x_sec_ctx *sec_ctx);
+int selinux_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new);
+void selinux_xfrm_policy_free(struct xfrm_policy *xp);
+int selinux_xfrm_state_alloc(struct xfrm_state *x, struct sadb_x_sec_ctx *sec_ctx);
+void selinux_xfrm_state_free(struct xfrm_state *x);
+int selinux_xfrm_policy_lookup(struct sock *sk, struct xfrm_selector *sel, struct flowi *fl, u8 dir);
+int selinux_xfrm_sock_rcv_skb(u32 sid, struct sk_buff *skb);
+int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb);
diff -puN security/selinux/Makefile~lsm-selinux-nethooks security/selinux/Makefile
--- linux-2.6.12-rc4-nethooks/security/selinux/Makefile~lsm-selinux-nethooks	2005-05-13 13:15:47.000000000 -0400
+++ linux-2.6.12-rc4-nethooks-root/security/selinux/Makefile	2005-05-13 13:15:47.000000000 -0400
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_SECURITY_SELINUX) := selinux.o ss/
 
-selinux-y := avc.o hooks.o selinuxfs.o netlink.o nlmsgtab.o
+selinux-y := avc.o hooks.o selinuxfs.o netlink.o nlmsgtab.o nethooks.o
 
 selinux-$(CONFIG_SECURITY_NETWORK) += netif.o
 
diff -puN /dev/null security/selinux/nethooks.c
--- /dev/null	2004-02-23 16:02:56.000000000 -0500
+++ linux-2.6.12-rc4-nethooks-root/security/selinux/nethooks.c	2005-05-16 14:28:25.000000000 -0400
@@ -0,0 +1,428 @@
+/*
+ * USAGE:
+ * NOTES:
+ *   1. Make sure to enable the following options in your kernel config:
+ *	CONFIG_SECURITY=y
+ *	CONFIG_SECURITY_NETWORK=y
+ *	CONFIG_SECURITY_NETWORK_XFRM=y
+ *	CONFIG_SECURITY_SELINUX=m/y
+ * ISSUES:
+ *   1. Caching packets, so they are not dropped during negotiation
+ *   2. Emulating a reasonable SO_PEERSEC across machines
+ *   3. Testing sk_policy setting with context
+ */
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/security.h>
+#include <linux/types.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/skbuff.h>
+#include <linux/xfrm.h>
+#include <net/xfrm.h>
+#include <net/checksum.h>
+#include <net/udp.h>
+#include <asm/semaphore.h>
+
+#include "nethooks.h"
+#include "avc.h"
+#include "objsec.h"
+
+/**************************************************************
+ *
+ * defines
+ *
+ **************************************************************/
+
+#define DEBUG 0
+
+/**************************************************************
+ *
+ * structures
+ *
+ **************************************************************/
+
+/**************************************************************
+ *
+ * globals
+ *
+ **************************************************************/
+
+/**************************************************************
+ *
+ * macros/inlines
+ *
+ **************************************************************/
+
+#define nethooks_debug(fmt, args...) {if (DEBUG) printk(KERN_NOTICE fmt,## args);}
+
+/*
+ * Extract the security blob from the sock (it's actually on the socket)
+ */
+static inline struct inode_security_struct *get_sock_isec(struct sock *sk)
+{
+	if (!sk->sk_socket) {
+		nethooks_debug("%s: no socket on this sock (!?)\n",
+			       __FUNCTION__);
+		return (struct inode_security_struct *) NULL;
+	}
+
+	return SOCK_INODE(sk->sk_socket)->i_security;
+}
+
+/*
+ * Returns true if the xfrm contains a security blob for SELinux
+ */
+static inline int selinux_authorizable_xfrm(struct xfrm_state *x)
+{
+	struct xfrm_sec_ctx *xfrm_ctx = xfrm_state_security(x);
+
+	return (xfrm_ctx &&
+		(xfrm_ctx->ctx_doi == XFRM_SC_DOI_LSM) &&
+		(xfrm_ctx->ctx_alg == XFRM_SC_ALG_SELINUX));
+}
+
+/**************************************************************
+ *
+ * LSM
+ *
+ **************************************************************/
+#ifdef CONFIG_SECURITY_NETWORK_XFRM
+/*
+ * LSM hook implementation that authorizes that a socket can be used
+ * with the corresponding xfrm_policy selector and direction.
+ */
+
+int selinux_xfrm_policy_lookup(struct sock *sk, struct xfrm_selector *sel, struct flowi *fl, u8 dir)
+{
+	int rc = 0;
+	struct inode_security_struct *isec = NULL;
+	u32 sock_sid, sel_sid = SECINITSID_UNLABELED;
+
+	nethooks_debug("%s: authorize\n", __FUNCTION__);
+
+	if (!sk) {
+                /* no sock to send -- e.g., icmp reply */
+		/* authorize as kernel packet */
+		if (fl && fl->proto == IPPROTO_ICMP) {
+			nethooks_debug("%s: ICMP case\n",
+				       __FUNCTION__);
+			sock_sid = SECINITSID_KERNEL;
+			goto authorize;
+		}
+		/*
+		 * hooks.c accepts packets with no socket unconditionally
+		 */
+		nethooks_debug("%s: no sock on this skbuff: non-ICMP\n",
+			       __FUNCTION__);
+		goto out;
+	}
+
+	read_lock_bh(&sk->sk_callback_lock);
+	isec = get_sock_isec(sk);
+
+	/* No isec: allow if any sock can read target */
+	if (!isec) {
+		nethooks_debug("%s: no isec from sock\n", __FUNCTION__);
+		sock_sid = SECINITSID_ANY_SOCKET;
+	}
+	else {
+		sock_sid = isec->sid;
+	}
+	read_unlock_bh(&sk->sk_callback_lock);
+
+
+authorize:
+	/* Selector sid is either set to label or ANY_ASSOC */
+	if (sel->security) {
+		sel_sid = sel->security->ctx_sid;
+		nethooks_debug("%s: %s for context %.50s; sid: %d; sock: %d\n",
+			       __FUNCTION__,
+			       ((dir == FLOW_DIR_IN) ? "input" :
+				((dir == FLOW_DIR_OUT) ? "output" : "forward")),
+			       sel->security->ctx_str,
+			       sel_sid,
+			       sock_sid);
+	}
+
+	rc = avc_has_perm(sock_sid, sel_sid, SECCLASS_ASSOCIATION,
+			  ((dir == FLOW_DIR_IN) ? ASSOCIATION__RECVFROM :
+			   ((dir == FLOW_DIR_OUT) ?  ASSOCIATION__SENDTO :
+			    (ASSOCIATION__SENDTO | ASSOCIATION__RECVFROM))),
+			  NULL);
+
+out:
+	return rc;
+}
+
+/*
+ * Security blob allocation for xfrm_policy and xfrm_state
+ *  -- both attached to selectors
+ */
+static inline int selinux_xfrm_selector_alloc(struct xfrm_selector *sel, struct sadb_x_sec_ctx *sec_ctx)
+{
+	int rc = 0;
+
+	if (!sec_ctx)
+		return -EINVAL;
+
+	nethooks_debug(KERN_NOTICE "%s: got a sec_ctx for policy\n",
+		       __FUNCTION__);
+
+	if (sec_ctx->sadb_x_ctx_len >= PAGE_SIZE)
+		return -ENOMEM;
+
+	sel->security = kmalloc(sizeof(*sel->security) +
+				sec_ctx->sadb_x_ctx_len + 1,
+				GFP_KERNEL);
+
+	if (!sel->security)
+		return -ENOMEM;
+
+	sel->security->ctx_doi = sec_ctx->sadb_x_ctx_doi;
+	sel->security->ctx_len = sec_ctx->sadb_x_ctx_len;
+	sel->security->ctx_alg = sec_ctx->sadb_x_ctx_alg;
+
+	nethooks_debug(KERN_NOTICE "%s: doi %u len %u alg %u\n",
+		       __FUNCTION__,
+		       sel->security->ctx_doi,
+		       sel->security->ctx_len,
+		       sel->security->ctx_alg);
+
+	memcpy(sel->security->ctx_str,
+	       sec_ctx+1,
+	       sel->security->ctx_len);
+	rc = security_context_to_sid(sel->security->ctx_str,
+				     sel->security->ctx_len,
+				     &sel->security->ctx_sid);
+	sel->security->ctx_str[sel->security->ctx_len] = 0;
+
+	nethooks_debug(KERN_NOTICE "%s: context was %s with sid %d\n",
+		       __FUNCTION__,
+		       sel->security->ctx_str,
+		       sel->security->ctx_sid);
+
+	if (rc)
+		kfree(sel->security);
+
+	return rc;
+}
+
+/*
+ * LSM hook implementation that allocs and transfers sec_ctx spec to
+ * xfrm_policy.
+ */
+int selinux_xfrm_policy_alloc(struct xfrm_policy *xp, struct sadb_x_sec_ctx *sec_ctx)
+{
+	int rc = 0;
+
+	if (!xp)
+		return -EINVAL;
+
+	nethooks_debug(KERN_NOTICE "%s: start alloc\n", __FUNCTION__);
+
+	rc = selinux_xfrm_selector_alloc(&xp->selector, sec_ctx);
+
+	return rc;
+}
+
+
+/*
+ * LSM hook implementation that copies security data structure from old to
+ * new for policy cloning.
+ */
+int selinux_xfrm_policy_clone(struct xfrm_policy *old, struct xfrm_policy *new)
+{
+	struct xfrm_sec_ctx *old_ctx, *new_ctx;
+
+	old_ctx = xfrm_policy_security(old);
+
+	if (old_ctx) {
+		new_ctx = new->selector.security =
+			kmalloc(sizeof(*new_ctx) +
+				old_ctx->ctx_len + 1,
+				GFP_KERNEL);
+
+		if (!new_ctx)
+			return -ENOMEM;
+
+		memcpy(new_ctx, old_ctx, sizeof(*new_ctx));
+		memcpy(new_ctx->ctx_str, old_ctx->ctx_str, new_ctx->ctx_len);
+	}
+	return 0;
+}
+
+/*
+ * LSM hook implementation that frees xfrm_policy security information.
+ */
+void selinux_xfrm_policy_free(struct xfrm_policy *xp)
+{
+	struct xfrm_sec_ctx *xfrm_ctx = xfrm_policy_security(xp);
+
+	if (xfrm_ctx)
+		kfree(xfrm_ctx);
+}
+
+/*
+ * LSM hook implementation that allocs and transfers sec_ctx spec to
+ * xfrm_state.
+ */
+int selinux_xfrm_state_alloc(struct xfrm_state *x, struct sadb_x_sec_ctx *sec_ctx)
+{
+	int rc = 0;
+
+	if (!x)
+		return -EINVAL;
+
+	nethooks_debug(KERN_NOTICE "%s: start alloc\n", __FUNCTION__);
+
+	rc = selinux_xfrm_selector_alloc(&x->sel, sec_ctx);
+
+	return rc;
+}
+
+/*
+ * LSM hook implementation that frees xfrm_state security information.
+ */
+void selinux_xfrm_state_free(struct xfrm_state *x)
+{
+	struct xfrm_sec_ctx *xfrm_ctx = xfrm_state_security(x);
+
+	if (xfrm_ctx)
+		kfree(xfrm_ctx);
+}
+
+/*
+ * LSM hook that controls access to unlabelled packets.  If
+ * a xfrm_state is authorizable (defined by macro) then it was
+ * already authorized by selector matching process.  If not, then
+ * we need to check for unlabelled access since this may not have
+ * gone thru the selector process.
+ */
+int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb)
+{
+	int i, rc = 0;
+	struct sec_path *sp;
+	struct sock *sk;
+
+	nethooks_debug("%s: starting\n", __FUNCTION__);
+
+	/* regular check for socket with isec */
+	sp = skb->sp;
+	sk = skb->sk;
+
+	if (sp) {
+		nethooks_debug("%s: sp (0x%x) on skb with length %d\n",
+			       __FUNCTION__,
+			       (unsigned) sp, sp->len);
+
+		/*
+		 * __xfrm_policy_check does not approve unless xfrm_policy_ok
+		 * says that spi's match for policy and the socket.
+		 *
+		 *  Only need to verify the existence of an authorizable sp.
+		 */
+		for (i = 0; i < sp->len; i++) {
+			struct xfrm_state *x = sp->x[i].xvec;
+
+			nethooks_debug("%s: sa: 0x%x\n",
+				       __FUNCTION__,
+				       (unsigned) x);
+
+			if (selinux_authorizable_xfrm(x)) {
+				nethooks_debug("%s: sa 0x%x found\n",
+					       __FUNCTION__,
+					       (unsigned) x);
+				goto accept;
+			}
+		}
+	}
+
+	/* check SELinux sock for unlabelled access */
+	nethooks_debug("%s: before unlabelled sa auth: isec_sid = 0x%x\n",
+		       __FUNCTION__,
+		       (unsigned) isec_sid);
+	rc = avc_has_perm(isec_sid, SECINITSID_UNLABELED, SECCLASS_ASSOCIATION,
+			  ASSOCIATION__RECVFROM, NULL);
+	nethooks_debug("%s: after unlabelled sa auth rc: %d\n",
+		       __FUNCTION__,
+		       rc);
+
+	if (rc)
+		goto drop;
+
+accept:
+	nethooks_debug("%s: accept\n", __FUNCTION__);
+	return 0;
+
+drop:
+	nethooks_debug("%s: drop\n", __FUNCTION__);
+	return rc;
+}
+
+/*
+ * POSTROUTE_LAST hook's XFRM processing:
+ * If we have no security association, then we need to determine
+ * whether the socket is allowed to send to an unlabelled destination.
+ * If we do have a authorizable security association, then it has already been
+ * checked in xfrm_policy_lookup hook.
+ */
+int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb)
+{
+	struct dst_entry *dst;
+	int rc = 0;
+
+	dst = skb->dst;
+
+	if (dst) {
+		struct dst_entry *dst_test;
+
+		for (dst_test = dst; dst_test != 0;
+		     dst_test = dst_test->child) {
+			struct xfrm_state *x = dst_test->xfrm;
+
+			if (selinux_authorizable_xfrm(x)) {
+				nethooks_debug("%s: sa 0x%x found\n",
+					       __FUNCTION__,
+					       (unsigned) x);
+				goto accept;
+			}
+		}
+	}
+
+	nethooks_debug("%s: before unlabelled sa auth: isec_sid = 0x%x\n",
+		       __FUNCTION__,
+		       (unsigned) isec_sid);
+	rc = avc_has_perm(isec_sid, SECINITSID_UNLABELED, SECCLASS_ASSOCIATION,
+			  ASSOCIATION__SENDTO, NULL);
+	nethooks_debug("%s: after unlabelled sa auth rc: %d\n", __FUNCTION__, rc);
+
+	if (rc)
+		goto drop;
+
+accept:
+	nethooks_debug("%s: accept\n", __FUNCTION__);
+	return NF_ACCEPT;
+
+drop:
+	nethooks_debug("%s: drop\n", __FUNCTION__);
+	return NF_DROP;
+}
+
+#else  /* CONFIG_SECURITY_NETWORK_XFRM */
+
+int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb)
+{
+	return 0;
+}
+
+int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb)
+{
+	return 0;
+}
+#endif /* CONFIG_SECURITY_NETWORK_XFRM */
_
