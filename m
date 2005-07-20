From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2/*] nfnetlink layer
Date: Wed, 20 Jul 2005 09:30:07 -0400
Message-ID: <20050720133007.GC4077@rama>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="B8ONY/mu/bqBak9m"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--B8ONY/mu/bqBak9m
Content-Type: multipart/mixed; boundary="hUH5gZbnpyIv7Mn4"
Content-Disposition: inline


--hUH5gZbnpyIv7Mn4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,=20

here comes the nfnetlink layer.  Its first user (ctnetlink) is waiting
for some last review and will follow tomorrow.

Please apply to your 2.6.14 tree, thanks!


--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--hUH5gZbnpyIv7Mn4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="02-nfnetlink.patch"
Content-Transfer-Encoding: quoted-printable

Introduce "nfnetlink" (netfilter netlink) layer.  This layer is used as
transport layer for all userspace communication of the new upcoming
netfilter subsystems, such as ctnetlink, nfnetlink_queue and some day even
the mythical pkttables ;)

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 41a00086e4c896f92c8a29f8e2e5f6d893118e77
tree db282fb2ed082b8a1b70b0c5bdf87928da6c594f
parent 212c12f0005581d2625a1bd0add59cd8ac5725d0
author laforge <laforge@netfilter.org> Mi, 20 Jul 2005 09:02:40 -0400
committer laforge <laforge@netfilter.org> Mi, 20 Jul 2005 09:02:40 -0400

 include/linux/netfilter/nfnetlink.h |  145 +++++++++++++++
 net/Kconfig                         |    2=20
 net/Makefile                        |    1=20
 net/netfilter/Kconfig               |    5 +
 net/netfilter/Makefile              |    1=20
 net/netfilter/nfnetlink.c           |  343 +++++++++++++++++++++++++++++++=
++++
 6 files changed, 497 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/=
nfnetlink.h
new file mode 100644
--- /dev/null
+++ b/include/linux/netfilter/nfnetlink.h
@@ -0,0 +1,145 @@
+#ifndef _NFNETLINK_H
+#define _NFNETLINK_H
+#include <linux/types.h>
+
+/* nfnetlink groups: Up to 32 maximum */
+#define NF_NETLINK_CONNTRACK_NEW 		0x00000001
+#define NF_NETLINK_CONNTRACK_UPDATE		0x00000002
+#define NF_NETLINK_CONNTRACK_DESTROY		0x00000004
+#define NF_NETLINK_CONNTRACK_EXP_NEW		0x00000008
+#define NF_NETLINK_CONNTRACK_EXP_UPDATE		0x00000010
+#define NF_NETLINK_CONNTRACK_EXP_DESTROY	0x00000020
+
+/* Generic structure for encapsulation optional netfilter information.
+ * It is reminiscent of sockaddr, but with sa_family replaced
+ * with attribute type.=20
+ * ! This should someday be put somewhere generic as now rtnetlink and
+ * ! nfnetlink use the same attributes methods. - J. Schulist.
+ */
+
+struct nfattr
+{
+	u_int16_t nfa_len;
+	u_int16_t nfa_type;
+} __attribute__ ((packed));
+
+/* FIXME: Shamelessly copy and pasted from rtnetlink.h, it's time
+ * 	  to put this in a generic file */
+
+#define NFA_ALIGNTO     4
+#define NFA_ALIGN(len)	(((len) + NFA_ALIGNTO - 1) & ~(NFA_ALIGNTO - 1))
+#define NFA_OK(nfa,len)	((len) > 0 && (nfa)->nfa_len >=3D sizeof(struct nf=
attr) \
+	&& (nfa)->nfa_len <=3D (len))
+#define NFA_NEXT(nfa,attrlen)	((attrlen) -=3D NFA_ALIGN((nfa)->nfa_len), \
+	(struct nfattr *)(((char *)(nfa)) + NFA_ALIGN((nfa)->nfa_len)))
+#define NFA_LENGTH(len)	(NFA_ALIGN(sizeof(struct nfattr)) + (len))
+#define NFA_SPACE(len)	NFA_ALIGN(NFA_LENGTH(len))
+#define NFA_DATA(nfa)   ((void *)(((char *)(nfa)) + NFA_LENGTH(0)))
+#define NFA_PAYLOAD(nfa) ((int)((nfa)->nfa_len) - NFA_LENGTH(0))
+#define NFA_NEST(skb, type) \
+({	struct nfattr *__start =3D (struct nfattr *) (skb)->tail; \
+	NFA_PUT(skb, type, 0, NULL); \
+	__start;  })
+#define NFA_NEST_END(skb, start) \
+({      (start)->nfa_len =3D ((skb)->tail - (unsigned char *) (start)); \
+        (skb)->len; })
+#define NFA_NEST_CANCEL(skb, start) \
+({      if (start) \
+                skb_trim(skb, (unsigned char *) (start) - (skb)->data); \
+        -1; })
+
+/* General form of address family dependent message.
+ */
+struct nfgenmsg {
+	u_int8_t  nfgen_family;		/* AF_xxx */
+	u_int8_t  version;		/* nfnetlink version */
+	u_int16_t res_id;		/* resource id */
+} __attribute__ ((packed));
+
+#define NFNETLINK_V1	1
+
+#define NFM_NFA(n)      ((struct nfattr *)(((char *)(n)) \
+        + NLMSG_ALIGN(sizeof(struct nfgenmsg))))
+#define NFM_PAYLOAD(n)  NLMSG_PAYLOAD(n, sizeof(struct nfgenmsg))
+
+/* netfilter netlink message types are split in two pieces:
+ * 8 bit subsystem, 8bit operation.
+ */
+
+#define NFNL_SUBSYS_ID(x)	((x & 0xff00) >> 8)
+#define NFNL_MSG_TYPE(x)	(x & 0x00ff)
+
+enum nfnl_subsys_id {
+	NFNL_SUBSYS_NONE =3D 0,
+	NFNL_SUBSYS_CTNETLINK,
+	NFNL_SUBSYS_CTNETLINK_EXP,
+	NFNL_SUBSYS_IPTNETLINK,
+	NFNL_SUBSYS_QUEUE,
+	NFNL_SUBSYS_ULOG,
+	NFNL_SUBSYS_COUNT,
+};
+
+#ifdef __KERNEL__
+
+#include <linux/capability.h>
+
+struct nfnl_callback
+{
+	kernel_cap_t cap_required; /* capabilities required for this msg */
+	int (*call)(struct sock *nl, struct sk_buff *skb,=20
+		struct nlmsghdr *nlh, struct nfattr *cda[], int *errp);
+};
+
+struct nfnetlink_subsystem
+{
+	const char *name;
+	__u8 subsys_id;		/* nfnetlink subsystem ID */
+	__u8 cb_count;		/* number of callbacks */
+	u_int32_t attr_count;	/* number of nfattr's */
+	struct nfnl_callback *cb; /* callback for individual types */
+};
+
+extern void __nfa_fill(struct sk_buff *skb, int attrtype,
+        int attrlen, const void *data);
+#define NFA_PUT(skb, attrtype, attrlen, data) \
+({ if (skb_tailroom(skb) < (int)NFA_SPACE(attrlen)) goto nfattr_failure; \
+   __nfa_fill(skb, attrtype, attrlen, data); })
+
+extern struct semaphore nfnl_sem;
+
+#define nfnl_shlock()		down(&nfnl_sem)
+#define nfnl_shlock_nowait()	down_trylock(&nfnl_sem)
+
+#define nfnl_shunlock()		do { up(&nfnl_sem); \
+				     if(nfnl && nfnl->sk_receive_queue.qlen) \
+					    nfnl->sk_data_ready(nfnl, 0); \
+                        	} while(0)
+
+extern void nfnl_lock(void);
+extern void nfnl_unlock(void);
+
+extern int nfnetlink_subsys_register(struct nfnetlink_subsystem *n);
+extern int nfnetlink_subsys_unregister(struct nfnetlink_subsystem *n);
+
+extern int nfattr_parse(struct nfattr *tb[], int maxattr,=20
+			struct nfattr *nfa, int len);
+
+#define nfattr_parse_nested(tb, max, nfa) \
+	nfattr_parse((tb), (max), NFA_DATA((nfa)), NFA_PAYLOAD((nfa)))
+
+#define nfattr_bad_size(tb, max, cta_min)				\
+({	int __i, __res =3D 0;						\
+ 	for (__i=3D0; __i<max; __i++) 					\
+ 		if (tb[__i] && NFA_PAYLOAD(tb[__i]) < cta_min[__i]){	\
+ 			__res =3D 1;					\
+ 			break;						\
+ 		}							\
+ 	__res;								\
+})
+
+extern int nfnetlink_send(struct sk_buff *skb, u32 pid, unsigned group,=20
+			  int echo);
+extern int nfnetlink_unicast(struct sk_buff *skb, u_int32_t pid, int flags=
);
+
+#endif	/* __KERNEL__ */
+#endif	/* _NFNETLINK_H */
diff --git a/net/Kconfig b/net/Kconfig
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -205,6 +205,8 @@ config NET_PKTGEN
 	  To compile this code as a module, choose M here: the
 	  module will be called pktgen.
=20
+source "net/netfilter/Kconfig"
+
 endmenu
=20
 endmenu
diff --git a/net/Makefile b/net/Makefile
--- a/net/Makefile
+++ b/net/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_NET)		+=3D $(tmp-y)
 obj-$(CONFIG_LLC)		+=3D llc/
 obj-$(CONFIG_NET)		+=3D ethernet/ 802/ sched/ netlink/
 obj-$(CONFIG_INET)		+=3D ipv4/
+obj-$(CONFIG_NETFILTER)		+=3D netfilter/
 obj-$(CONFIG_XFRM)		+=3D xfrm/
 obj-$(CONFIG_UNIX)		+=3D unix/
 ifneq ($(CONFIG_IPV6),)
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
new file mode 100644
--- /dev/null
+++ b/net/netfilter/Kconfig
@@ -0,0 +1,5 @@
+config NETFILTER_NETLINK
+       tristate "Netfilter netlink interface"
+       help
+         If this option is enabled, the kernel will include support
+         for the new netfilter netlink interface.
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
new file mode 100644
--- /dev/null
+++ b/net/netfilter/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_NETFILTER_NETLINK) +=3D nfnetlink.o
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
new file mode 100644
--- /dev/null
+++ b/net/netfilter/nfnetlink.c
@@ -0,0 +1,343 @@
+/* Netfilter messages via netlink socket. Allows for user space
+ * protocol helpers and general trouble making from userspace.
+ *
+ * (C) 2001 by Jay Schulist <jschlst@samba.org>,
+ * (C) 2002-2005 by Harald Welte <laforge@gnumonks.org>
+ * (C) 2005 by Pablo Neira Ayuso <pablo@eurodev.net>
+ *
+ * Initial netfilter messages via netlink development funded and
+ * generally made possible by Network Robots, Inc. (www.networkrobots.com)
+ *
+ * Further development of this code funded by Astaro AG (http://www.astaro=
=2Ecom)
+ *
+ * This software may be used and distributed according to the terms
+ * of the GNU General Public License, incorporated herein by reference.
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/kernel.h>
+#include <linux/major.h>
+#include <linux/sched.h>
+#include <linux/timer.h>
+#include <linux/string.h>
+#include <linux/sockios.h>
+#include <linux/net.h>
+#include <linux/fcntl.h>
+#include <linux/skbuff.h>
+#include <asm/uaccess.h>
+#include <asm/system.h>
+#include <net/sock.h>
+#include <linux/init.h>
+#include <linux/spinlock.h>
+
+#include <linux/netfilter.h>
+#include <linux/netlink.h>
+#include <linux/netfilter/nfnetlink.h>
+
+MODULE_LICENSE("GPL");
+
+static char __initdata nfversion[] =3D "0.30";
+
+#if 0
+#define DEBUGP printk
+#else
+#define DEBUGP(format, args...)
+#endif
+
+static struct sock *nfnl =3D NULL;
+static struct nfnetlink_subsystem *subsys_table[NFNL_SUBSYS_COUNT];
+DECLARE_MUTEX(nfnl_sem);
+
+void nfnl_lock(void)
+{
+	nfnl_shlock();
+}
+
+void nfnl_unlock(void)
+{
+	nfnl_shunlock();
+}
+
+int nfnetlink_subsys_register(struct nfnetlink_subsystem *n)
+{
+	DEBUGP("registering subsystem ID %u\n", n->subsys_id);
+
+	/* If the netlink socket wasn't created, then fail */
+	if (!nfnl)
+		return -1;
+
+	nfnl_lock();
+	subsys_table[n->subsys_id] =3D n;
+	nfnl_unlock();
+
+	return 0;
+}
+
+int nfnetlink_subsys_unregister(struct nfnetlink_subsystem *n)
+{
+	DEBUGP("unregistering subsystem ID %u\n", n->subsys_id);
+
+	nfnl_lock();
+	subsys_table[n->subsys_id] =3D NULL;
+	nfnl_unlock();
+
+	return 0;
+}
+
+static inline struct nfnetlink_subsystem *nfnetlink_get_subsys(u_int16_t t=
ype)
+{
+	u_int8_t subsys_id =3D NFNL_SUBSYS_ID(type);
+
+	if (subsys_id >=3D NFNL_SUBSYS_COUNT
+	    || subsys_table[subsys_id] =3D=3D NULL)
+		return NULL;
+
+	return subsys_table[subsys_id];
+}
+
+static inline struct nfnl_callback *
+nfnetlink_find_client(u_int16_t type, struct nfnetlink_subsystem *ss)
+{
+	u_int8_t cb_id =3D NFNL_MSG_TYPE(type);
+=09
+	if (cb_id >=3D ss->cb_count) {
+		DEBUGP("msgtype %u >=3D %u, returning\n", type, ss->cb_count);
+		return NULL;
+	}
+
+	return &ss->cb[cb_id];
+}
+
+void __nfa_fill(struct sk_buff *skb, int attrtype, int attrlen,
+		const void *data)
+{
+	struct nfattr *nfa;
+	int size =3D NFA_LENGTH(attrlen);
+
+	nfa =3D (struct nfattr *)skb_put(skb, NFA_ALIGN(size));
+	nfa->nfa_type =3D attrtype;
+	nfa->nfa_len  =3D size;
+	memcpy(NFA_DATA(nfa), data, attrlen);
+}
+
+int nfattr_parse(struct nfattr *tb[], int maxattr, struct nfattr *nfa, int=
 len)
+{
+	memset(tb, 0, sizeof(struct nfattr *) * maxattr);
+
+	while (NFA_OK(nfa, len)) {
+		unsigned flavor =3D nfa->nfa_type;
+		if (flavor && flavor <=3D maxattr)
+			tb[flavor-1] =3D nfa;
+		nfa =3D NFA_NEXT(nfa, len);
+	}
+
+	return 0;
+}
+
+/**
+ * nfnetlink_check_attributes - check and parse nfnetlink attributes
+ *
+ * subsys: nfnl subsystem for which this message is to be parsed
+ * nlmsghdr: netlink message to be checked/parsed
+ * cda: array of pointers, needs to be at least subsys->attr_count big
+ *
+ */
+static int
+nfnetlink_check_attributes(struct nfnetlink_subsystem *subsys,
+			   struct nlmsghdr *nlh, struct nfattr *cda[])
+{
+	int min_len;
+
+	memset(cda, 0, sizeof(struct nfattr *) * subsys->attr_count);
+
+	/* check attribute lengths. */
+	min_len =3D NLMSG_ALIGN(sizeof(struct nfgenmsg));
+	if (nlh->nlmsg_len < min_len)
+		return -EINVAL;
+
+	if (nlh->nlmsg_len > min_len) {
+		struct nfattr *attr =3D NFM_NFA(NLMSG_DATA(nlh));
+		int attrlen =3D nlh->nlmsg_len - NLMSG_ALIGN(min_len);
+
+		while (NFA_OK(attr, attrlen)) {
+			unsigned flavor =3D attr->nfa_type;
+			if (flavor) {
+				if (flavor > subsys->attr_count)
+					return -EINVAL;
+				cda[flavor - 1] =3D attr;
+			}
+			attr =3D NFA_NEXT(attr, attrlen);
+		}
+	} else
+		return -EINVAL;
+
+        return 0;
+}
+
+int nfnetlink_send(struct sk_buff *skb, u32 pid, unsigned group, int echo)
+{
+	int allocation =3D in_interrupt() ? GFP_ATOMIC : GFP_KERNEL;
+	int err =3D 0;
+
+	NETLINK_CB(skb).dst_groups =3D group;
+	if (echo)
+		atomic_inc(&skb->users);
+	netlink_broadcast(nfnl, skb, pid, group, allocation);
+	if (echo)
+		err =3D netlink_unicast(nfnl, skb, pid, MSG_DONTWAIT);
+
+	return err;
+}
+
+int nfnetlink_unicast(struct sk_buff *skb, u_int32_t pid, int flags)
+{
+	return netlink_unicast(nfnl, skb, pid, flags);
+}
+
+/* Process one complete nfnetlink message. */
+static inline int nfnetlink_rcv_msg(struct sk_buff *skb,
+				    struct nlmsghdr *nlh, int *errp)
+{
+	struct nfnl_callback *nc;
+	struct nfnetlink_subsystem *ss;
+	int type, err =3D 0;
+
+	DEBUGP("entered; subsys=3D%u, msgtype=3D%u\n",
+		 NFNL_SUBSYS_ID(nlh->nlmsg_type),
+		 NFNL_MSG_TYPE(nlh->nlmsg_type));
+
+	/* Only requests are handled by kernel now. */
+	if (!(nlh->nlmsg_flags & NLM_F_REQUEST)) {
+		DEBUGP("received non-request message\n");
+		return 0;
+	}
+
+	/* All the messages must at least contain nfgenmsg */
+	if (nlh->nlmsg_len <=20
+			NLMSG_LENGTH(NLMSG_ALIGN(sizeof(struct nfgenmsg)))) {
+		DEBUGP("received message was too short\n");
+		return 0;
+	}
+
+	type =3D nlh->nlmsg_type;
+	ss =3D nfnetlink_get_subsys(type);
+	if (!ss)
+		goto err_inval;
+
+	nc =3D nfnetlink_find_client(type, ss);
+	if (!nc) {
+		DEBUGP("unable to find client for type %d\n", type);
+		goto err_inval;
+	}
+
+	if (nc->cap_required &&=20
+	    !cap_raised(NETLINK_CB(skb).eff_cap, nc->cap_required)) {
+		DEBUGP("permission denied for type %d\n", type);
+		*errp =3D -EPERM;
+		return -1;
+	}
+
+	{
+		struct nfattr *cda[ss->attr_count];
+
+		memset(cda, 0, ss->attr_count*sizeof(struct nfattr *));
+	=09
+		err =3D nfnetlink_check_attributes(ss, nlh, cda);
+		if (err < 0)
+			goto err_inval;
+
+		err =3D nc->call(nfnl, skb, nlh, cda, errp);
+		*errp =3D err;
+		return err;
+	}
+
+err_inval:
+	*errp =3D -EINVAL;
+	return -1;
+}
+
+/* Process one packet of messages. */
+static inline int nfnetlink_rcv_skb(struct sk_buff *skb)
+{
+	int err;
+	struct nlmsghdr *nlh;
+
+	while (skb->len >=3D NLMSG_SPACE(0)) {
+		u32 rlen;
+
+		nlh =3D (struct nlmsghdr *)skb->data;
+		if (nlh->nlmsg_len < sizeof(struct nlmsghdr)
+		    || skb->len < nlh->nlmsg_len)
+			return 0;
+		rlen =3D NLMSG_ALIGN(nlh->nlmsg_len);
+		if (rlen > skb->len)
+			rlen =3D skb->len;
+		if (nfnetlink_rcv_msg(skb, nlh, &err)) {
+			if (!err)
+				return -1;
+			netlink_ack(skb, nlh, err);
+		} else
+			if (nlh->nlmsg_flags & NLM_F_ACK)
+				netlink_ack(skb, nlh, 0);
+		skb_pull(skb, rlen);
+	}
+
+	return 0;
+}
+
+static void nfnetlink_rcv(struct sock *sk, int len)
+{
+	do {
+		struct sk_buff *skb;
+
+		if (nfnl_shlock_nowait())
+			return;
+
+		while ((skb =3D skb_dequeue(&sk->sk_receive_queue)) !=3D NULL) {
+			if (nfnetlink_rcv_skb(skb)) {
+				if (skb->len)
+					skb_queue_head(&sk->sk_receive_queue,
+						       skb);
+				else
+					kfree_skb(skb);
+				break;
+			}
+			kfree_skb(skb);
+		}
+
+		up(&nfnl_sem);
+	} while(nfnl && nfnl->sk_receive_queue.qlen);
+}
+
+void __exit nfnetlink_exit(void)
+{
+	printk("Removing netfilter NETLINK layer.\n");
+	sock_release(nfnl->sk_socket);
+	return;
+}
+
+int __init nfnetlink_init(void)
+{
+	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
+
+	nfnl =3D netlink_kernel_create(NETLINK_NETFILTER, nfnetlink_rcv);
+	if (!nfnl) {
+		printk(KERN_ERR "cannot initialize nfnetlink!\n");
+		return -1;
+	}
+
+	return 0;
+}
+
+module_init(nfnetlink_init);
+module_exit(nfnetlink_exit);
+
+EXPORT_SYMBOL_GPL(nfnetlink_subsys_register);
+EXPORT_SYMBOL_GPL(nfnetlink_subsys_unregister);
+EXPORT_SYMBOL_GPL(nfnetlink_send);
+EXPORT_SYMBOL_GPL(nfnetlink_unicast);
+EXPORT_SYMBOL_GPL(nfattr_parse);
+EXPORT_SYMBOL_GPL(__nfa_fill);

--hUH5gZbnpyIv7Mn4--

--B8ONY/mu/bqBak9m
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC3lHeXaXGVTD0i/8RAnWMAJ9Df5f5deBJflJaxDBwfGxtjKFsAACZAfSQ
5bL1gFknXQaUjCvx7z1zCQk=
=B/O+
-----END PGP SIGNATURE-----

--B8ONY/mu/bqBak9m--
