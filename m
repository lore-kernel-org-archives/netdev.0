From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] ctnetlink
Date: Fri, 22 Jul 2005 09:11:30 -0400
Message-ID: <20050722131130.GA26783@rama>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DKU6Jbt7q3WqK7+M"
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


--DKU6Jbt7q3WqK7+M
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Content-Disposition: inline


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

This is a patch for your net-2.6.14 tree (incremental to the
expect-double-free fix).  It adds the ctnetlink code, and all the
required core conntrack/nat changes that it needs.

Please apply, Thanks!

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="05-ctnetlink.patch"
Content-Transfer-Encoding: quoted-printable

Add ctnetlink subsystem for userspace-access to ip_conntrack table.
This allows reading and updating of existing entries, as well as
creating new ones (and new expect's) via nfnetlink.

Please noe the 'strange' byte order: nfattr (tag+length) are in host
byte order, while the payload is always guaranteed to be in network
byte order.  This allows a simple userspace process to encapsulate netlink
messages into arch-independent udp packets by just processing/swapping the
headers and not knowing anything about the actual payload.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 7a379b7c1a60b65fe735a87bd55d01e141a69014
tree 28afcc784ef8bfda0d4b9d17bb15f8618316f7c5
parent 3b9186c6b1ac5d33789b35f8fe29ff39cbbe0872
author laforge <laforge@netfilter.org> Fr, 22 Jul 2005 08:56:28 -0400
committer laforge <laforge@netfilter.org> Fr, 22 Jul 2005 08:56:28 -0400

 include/linux/netfilter/nfnetlink.h                |    3=20
 include/linux/netfilter/nfnetlink_conntrack.h      |  123 ++
 include/linux/netfilter_ipv4/ip_conntrack.h        |   46 +
 include/linux/netfilter_ipv4/ip_conntrack_core.h   |    5=20
 include/linux/netfilter_ipv4/ip_conntrack_helper.h |    2=20
 clude/linux/netfilter_ipv4/ip_conntrack_protocol.h |   24=20
 include/linux/netfilter_ipv4/ip_nat_protocol.h     |   25=20
 net/ipv4/netfilter/Kconfig                         |    7=20
 net/ipv4/netfilter/Makefile                        |    4=20
 net/ipv4/netfilter/ip_conntrack_core.c             |  278 +++-
 net/ipv4/netfilter/ip_conntrack_netlink.c          | 1588 ++++++++++++++++=
++++
 net/ipv4/netfilter/ip_conntrack_proto_icmp.c       |   58 +
 net/ipv4/netfilter/ip_conntrack_proto_sctp.c       |    4=20
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c        |   17=20
 net/ipv4/netfilter/ip_conntrack_proto_udp.c        |    2=20
 net/ipv4/netfilter/ip_conntrack_standalone.c       |   36=20
 net/ipv4/netfilter/ip_nat_core.c                   |   96 +
 net/ipv4/netfilter/ip_nat_proto_icmp.c             |    6=20
 net/ipv4/netfilter/ip_nat_proto_tcp.c              |    7=20
 net/ipv4/netfilter/ip_nat_proto_udp.c              |    6=20
 net/ipv4/netfilter/ip_nat_proto_unknown.c          |    2=20
 net/ipv4/netfilter/ip_nat_standalone.c             |    2=20
 22 files changed, 2241 insertions(+), 100 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/=
nfnetlink.h
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -56,7 +56,7 @@ struct nfgenmsg {
 	u_int16_t res_id;		/* resource id */
 } __attribute__ ((packed));
=20
-#define NFNETLINK_V1	1
+#define NFNETLINK_V0	0
=20
 #define NFM_NFA(n)      ((struct nfattr *)(((char *)(n)) \
         + NLMSG_ALIGN(sizeof(struct nfgenmsg))))
@@ -81,6 +81,7 @@ enum nfnl_subsys_id {
=20
 #ifdef __KERNEL__
=20
+#include <linux/netlink.h>
 #include <linux/capability.h>
=20
 struct nfnl_callback
diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/=
netfilter/nfnetlink_conntrack.h
new file mode 100644
--- /dev/null
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -0,0 +1,123 @@
+#ifndef _IPCONNTRACK_NETLINK_H
+#define _IPCONNTRACK_NETLINK_H
+#include <linux/netfilter/nfnetlink.h>
+
+enum cntl_msg_types {
+	IPCTNL_MSG_CT_NEW,
+	IPCTNL_MSG_CT_GET,
+	IPCTNL_MSG_CT_DELETE,
+	IPCTNL_MSG_CT_GET_CTRZERO,
+
+	IPCTNL_MSG_MAX
+};
+
+enum ctnl_exp_msg_types {
+	IPCTNL_MSG_EXP_NEW,
+	IPCTNL_MSG_EXP_GET,
+	IPCTNL_MSG_EXP_DELETE,
+
+	IPCTNL_MSG_EXP_MAX
+};
+
+
+enum ctattr_type {
+	CTA_UNSPEC,
+	CTA_TUPLE_ORIG,
+	CTA_TUPLE_REPLY,
+	CTA_STATUS,
+	CTA_PROTOINFO,
+	CTA_HELP,
+	CTA_NAT,
+	CTA_TIMEOUT,
+	CTA_MARK,
+	CTA_COUNTERS_ORIG,
+	CTA_COUNTERS_REPLY,
+	CTA_USE,
+	CTA_EXPECT,
+	CTA_ID,
+	__CTA_MAX
+};
+#define CTA_MAX (__CTA_MAX - 1)
+
+enum ctattr_tuple {
+	CTA_TUPLE_UNSPEC,
+	CTA_TUPLE_IP,
+	CTA_TUPLE_PROTO,
+	__CTA_TUPLE_MAX
+};
+#define CTA_TUPLE_MAX (__CTA_TUPLE_MAX - 1)
+
+enum ctattr_ip {
+	CTA_IP_UNSPEC,
+	CTA_IP_V4_SRC,
+	CTA_IP_V4_DST,
+	CTA_IP_V6_SRC,
+	CTA_IP_V6_DST,
+	__CTA_IP_MAX
+};
+#define CTA_IP_MAX (__CTA_IP_MAX - 1)
+
+enum ctattr_l4proto {
+	CTA_PROTO_UNSPEC,
+	CTA_PROTO_NUM,
+	CTA_PROTO_SRC_PORT,
+	CTA_PROTO_DST_PORT,
+	CTA_PROTO_ICMP_ID,
+	CTA_PROTO_ICMP_TYPE,
+	CTA_PROTO_ICMP_CODE,
+	__CTA_PROTO_MAX
+};
+#define CTA_PROTO_MAX (__CTA_PROTO_MAX - 1)
+
+enum ctattr_protoinfo {
+	CTA_PROTOINFO_UNSPEC,
+	CTA_PROTOINFO_TCP_STATE,
+	__CTA_PROTOINFO_MAX
+};
+#define CTA_PROTOINFO_MAX (__CTA_PROTOINFO_MAX - 1)
+
+enum ctattr_counters {
+	CTA_COUNTERS_UNSPEC,
+	CTA_COUNTERS_PACKETS,
+	CTA_COUNTERS_BYTES,
+	__CTA_COUNTERS_MAX
+};
+#define CTA_COUNTERS_MAX (__CTA_COUNTERS_MAX - 1)
+
+enum ctattr_nat {
+	CTA_NAT_UNSPEC,
+	CTA_NAT_MINIP,
+	CTA_NAT_MAXIP,
+	CTA_NAT_PROTO,
+	__CTA_NAT_MAX
+};
+#define CTA_NAT_MAX (__CTA_NAT_MAX - 1)
+
+enum ctattr_protonat {
+	CTA_PROTONAT_UNSPEC,
+	CTA_PROTONAT_PORT_MIN,
+	CTA_PROTONAT_PORT_MAX,
+	__CTA_PROTONAT_MAX
+};
+#define CTA_PROTONAT_MAX (__CTA_PROTONAT_MAX - 1)
+
+enum ctattr_expect {
+	CTA_EXPECT_UNSPEC,
+	CTA_EXPECT_TUPLE,
+	CTA_EXPECT_MASK,
+	CTA_EXPECT_TIMEOUT,
+	CTA_EXPECT_ID,
+	__CTA_EXPECT_MAX
+};
+#define CTA_EXPECT_MAX (__CTA_EXPECT_MAX - 1)
+
+enum ctattr_help {
+	CTA_HELP_UNSPEC,
+	CTA_HELP_NAME,
+	__CTA_HELP_MAX
+};
+#define CTA_HELP_MAX (__CTA_HELP_MAX - 1)
+
+#define CTA_HELP_MAXNAMESIZE	32
+
+#endif /* _IPCONNTRACK_NETLINK_H */
diff --git a/include/linux/netfilter_ipv4/ip_conntrack.h b/include/linux/ne=
tfilter_ipv4/ip_conntrack.h
--- a/include/linux/netfilter_ipv4/ip_conntrack.h
+++ b/include/linux/netfilter_ipv4/ip_conntrack.h
@@ -209,6 +209,9 @@ struct ip_conntrack
 	/* Current number of expected connections */
 	unsigned int expecting;
=20
+	/* Unique ID that identifies this conntrack*/
+	unsigned int id;
+
 	/* Helper, if any. */
 	struct ip_conntrack_helper *helper;
=20
@@ -257,6 +260,9 @@ struct ip_conntrack_expect
 	/* Usage count. */
 	atomic_t use;
=20
+	/* Unique ID */
+	unsigned int id;
+
 #ifdef CONFIG_IP_NF_NAT_NEEDED
 	/* This is the original per-proto part, used to map the
 	 * expected connection the way the recipient expects. */
@@ -296,7 +302,12 @@ ip_conntrack_get(const struct sk_buff *s
 }
=20
 /* decrement reference count on a conntrack */
-extern inline void ip_conntrack_put(struct ip_conntrack *ct);
+static inline void
+ip_conntrack_put(struct ip_conntrack *ct)
+{
+	IP_NF_ASSERT(ct);
+	nf_conntrack_put(&ct->ct_general);
+}
=20
 /* call to create an explicit dependency on ip_conntrack. */
 extern void need_ip_conntrack(void);
@@ -331,6 +342,39 @@ extern void
 ip_ct_iterate_cleanup(int (*iter)(struct ip_conntrack *i, void *data),
 		      void *data);
=20
+extern struct ip_conntrack_helper *
+__ip_conntrack_helper_find_byname(const char *);
+extern struct ip_conntrack_helper *
+ip_conntrack_helper_find_get(const struct ip_conntrack_tuple *tuple);
+extern void ip_conntrack_helper_put(struct ip_conntrack_helper *helper);
+
+extern struct ip_conntrack_protocol *
+__ip_conntrack_proto_find(u_int8_t protocol);
+extern struct ip_conntrack_protocol *
+ip_conntrack_proto_find_get(u_int8_t protocol);
+extern void ip_conntrack_proto_put(struct ip_conntrack_protocol *proto);
+
+extern void ip_ct_remove_expectations(struct ip_conntrack *ct);
+
+extern struct ip_conntrack *ip_conntrack_alloc(struct ip_conntrack_tuple *,
+					       struct ip_conntrack_tuple *);
+
+extern void ip_conntrack_free(struct ip_conntrack *ct);
+
+extern void ip_conntrack_hash_insert(struct ip_conntrack *ct);
+
+extern struct ip_conntrack_expect *
+__ip_conntrack_expect_find(const struct ip_conntrack_tuple *tuple);
+
+extern struct ip_conntrack_expect *
+ip_conntrack_expect_find_get(const struct ip_conntrack_tuple *tuple);
+
+extern struct ip_conntrack_tuple_hash *
+__ip_conntrack_find(const struct ip_conntrack_tuple *tuple,
+                    const struct ip_conntrack *ignored_conntrack);
+
+extern void ip_conntrack_flush(void);
+
 /* It's confirmed if it is, or has been in the hash table. */
 static inline int is_confirmed(struct ip_conntrack *ct)
 {
diff --git a/include/linux/netfilter_ipv4/ip_conntrack_core.h b/include/lin=
ux/netfilter_ipv4/ip_conntrack_core.h
--- a/include/linux/netfilter_ipv4/ip_conntrack_core.h
+++ b/include/linux/netfilter_ipv4/ip_conntrack_core.h
@@ -2,6 +2,9 @@
 #define _IP_CONNTRACK_CORE_H
 #include <linux/netfilter.h>
=20
+#define MAX_IP_CT_PROTO 256
+extern struct ip_conntrack_protocol *ip_ct_protos[MAX_IP_CT_PROTO];
+
 /* This header is used to share core functionality between the
    standalone connection tracking module, and the compatibility layer's use
    of connection tracking. */
@@ -53,6 +56,8 @@ struct ip_conntrack_ecache;
 extern void __ip_ct_deliver_cached_events(struct ip_conntrack_ecache *ec);
 #endif
=20
+extern void __ip_ct_expect_unlink_destroy(struct ip_conntrack_expect *exp);
+
 extern struct list_head *ip_conntrack_hash;
 extern struct list_head ip_conntrack_expect_list;
 extern rwlock_t ip_conntrack_lock;
diff --git a/include/linux/netfilter_ipv4/ip_conntrack_helper.h b/include/l=
inux/netfilter_ipv4/ip_conntrack_helper.h
--- a/include/linux/netfilter_ipv4/ip_conntrack_helper.h
+++ b/include/linux/netfilter_ipv4/ip_conntrack_helper.h
@@ -24,6 +24,8 @@ struct ip_conntrack_helper
 	int (*help)(struct sk_buff **pskb,
 		    struct ip_conntrack *ct,
 		    enum ip_conntrack_info conntrackinfo);
+
+	int (*to_nfattr)(struct sk_buff *skb, const struct ip_conntrack *ct);
 };
=20
 extern int ip_conntrack_helper_register(struct ip_conntrack_helper *);
diff --git a/include/linux/netfilter_ipv4/ip_conntrack_protocol.h b/include=
/linux/netfilter_ipv4/ip_conntrack_protocol.h
--- a/include/linux/netfilter_ipv4/ip_conntrack_protocol.h
+++ b/include/linux/netfilter_ipv4/ip_conntrack_protocol.h
@@ -2,6 +2,7 @@
 #ifndef _IP_CONNTRACK_PROTOCOL_H
 #define _IP_CONNTRACK_PROTOCOL_H
 #include <linux/netfilter_ipv4/ip_conntrack.h>
+#include <linux/netfilter/nfnetlink_conntrack.h>
=20
 struct seq_file;
=20
@@ -47,22 +48,22 @@ struct ip_conntrack_protocol
 	int (*error)(struct sk_buff *skb, enum ip_conntrack_info *ctinfo,
 		     unsigned int hooknum);
=20
+	/* convert protoinfo to nfnetink attributes */
+	int (*to_nfattr)(struct sk_buff *skb, struct nfattr *nfa,
+			 const struct ip_conntrack *ct);
+
+	int (*tuple_to_nfattr)(struct sk_buff *skb,
+			       const struct ip_conntrack_tuple *t);
+	int (*nfattr_to_tuple)(struct nfattr *tb[],
+			       struct ip_conntrack_tuple *t);
+
 	/* Module (if any) which this is connected to. */
 	struct module *me;
 };
=20
-#define MAX_IP_CT_PROTO 256
-extern struct ip_conntrack_protocol *ip_ct_protos[MAX_IP_CT_PROTO];
-
 /* Protocol registration. */
 extern int ip_conntrack_protocol_register(struct ip_conntrack_protocol *pr=
oto);
 extern void ip_conntrack_protocol_unregister(struct ip_conntrack_protocol =
*proto);
-
-static inline struct ip_conntrack_protocol *ip_ct_find_proto(u_int8_t prot=
ocol)
-{
-	return ip_ct_protos[protocol];
-}
-
 /* Existing built-in protocols */
 extern struct ip_conntrack_protocol ip_conntrack_protocol_tcp;
 extern struct ip_conntrack_protocol ip_conntrack_protocol_udp;
@@ -73,6 +74,11 @@ extern int ip_conntrack_protocol_tcp_ini
 /* Log invalid packets */
 extern unsigned int ip_ct_log_invalid;
=20
+extern int ip_ct_port_tuple_to_nfattr(struct sk_buff *,
+				      const struct ip_conntrack_tuple *);
+extern int ip_ct_port_nfattr_to_tuple(struct nfattr *tb[],
+				      struct ip_conntrack_tuple *);
+
 #ifdef CONFIG_SYSCTL
 #ifdef DEBUG_INVALID_PACKETS
 #define LOG_INVALID(proto) \
diff --git a/include/linux/netfilter_ipv4/ip_nat_protocol.h b/include/linux=
/netfilter_ipv4/ip_nat_protocol.h
--- a/include/linux/netfilter_ipv4/ip_nat_protocol.h
+++ b/include/linux/netfilter_ipv4/ip_nat_protocol.h
@@ -4,6 +4,9 @@
 #include <linux/init.h>
 #include <linux/list.h>
=20
+#include <linux/netfilter_ipv4/ip_nat.h>
+#include <linux/netfilter/nfnetlink_conntrack.h>
+
 struct iphdr;
 struct ip_nat_range;
=20
@@ -15,6 +18,8 @@ struct ip_nat_protocol
 	/* Protocol number. */
 	unsigned int protonum;
=20
+	struct module *me;
+
 	/* Translate a packet to the target according to manip type.
 	   Return true if succeeded. */
 	int (*manip_pkt)(struct sk_buff **pskb,
@@ -43,19 +48,20 @@ struct ip_nat_protocol
=20
 	unsigned int (*print_range)(char *buffer,
 				    const struct ip_nat_range *range);
-};
=20
-#define MAX_IP_NAT_PROTO 256
-extern struct ip_nat_protocol *ip_nat_protos[MAX_IP_NAT_PROTO];
+	int (*range_to_nfattr)(struct sk_buff *skb,
+			       const struct ip_nat_range *range);
+
+	int (*nfattr_to_range)(struct nfattr *tb[],
+			       struct ip_nat_range *range);
+};
=20
 /* Protocol registration. */
 extern int ip_nat_protocol_register(struct ip_nat_protocol *proto);
 extern void ip_nat_protocol_unregister(struct ip_nat_protocol *proto);
=20
-static inline struct ip_nat_protocol *ip_nat_find_proto(u_int8_t protocol)
-{
-	return ip_nat_protos[protocol];
-}
+extern struct ip_nat_protocol *ip_nat_proto_find_get(u_int8_t protocol);
+extern void ip_nat_proto_put(struct ip_nat_protocol *proto);
=20
 /* Built-in protocols. */
 extern struct ip_nat_protocol ip_nat_protocol_tcp;
@@ -67,4 +73,9 @@ extern int init_protocols(void) __init;
 extern void cleanup_protocols(void);
 extern struct ip_nat_protocol *find_nat_proto(u_int16_t protonum);
=20
+extern int ip_nat_port_range_to_nfattr(struct sk_buff *skb,
+				       const struct ip_nat_range *range);
+extern int ip_nat_port_nfattr_to_range(struct nfattr *tb[],
+				       struct ip_nat_range *range);
+
 #endif /*_IP_NAT_PROTO_H*/
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -702,5 +702,12 @@ config IP_NF_ARP_MANGLE
 	  Allows altering the ARP packet payload: source and destination
 	  hardware and network addresses.
=20
+config IP_NF_CONNTRACK_NETLINK
+        tristate 'Connection tracking netlink interface'
+        depends on IP_NF_CONNTRACK && NETFILTER_NETLINK
+        help
+          This option enables support for a netlink-based userspace interf=
ace
+
+
 endmenu
=20
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -9,6 +9,10 @@ iptable_nat-objs	:=3D ip_nat_standalone.o=20
 # connection tracking
 obj-$(CONFIG_IP_NF_CONNTRACK) +=3D ip_conntrack.o
=20
+# conntrack netlink interface
+obj-$(CONFIG_IP_NF_CONNTRACK_NETLINK) +=3D ip_conntrack_netlink.o
+
+
 # SCTP protocol connection tracking
 obj-$(CONFIG_IP_NF_CT_PROTO_SCTP) +=3D ip_conntrack_proto_sctp.o
=20
diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip=
_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -50,7 +50,7 @@
 #include <linux/netfilter_ipv4/ip_conntrack_core.h>
 #include <linux/netfilter_ipv4/listhelp.h>
=20
-#define IP_CONNTRACK_VERSION	"2.2"
+#define IP_CONNTRACK_VERSION	"2.3"
=20
 #if 0
 #define DEBUGP printk
@@ -77,6 +77,8 @@ unsigned int ip_ct_log_invalid;
 static LIST_HEAD(unconfirmed);
 static int ip_conntrack_vmalloc;
=20
+static unsigned int ip_conntrack_next_id =3D 1;
+static unsigned int ip_conntrack_expect_next_id =3D 1;
 #ifdef CONFIG_IP_NF_CONNTRACK_EVENTS
 struct notifier_block *ip_conntrack_chain;
 struct notifier_block *ip_conntrack_expect_chain;
@@ -154,13 +156,6 @@ void ip_conntrack_event_cache_init(const
=20
 DEFINE_PER_CPU(struct ip_conntrack_stat, ip_conntrack_stat);
=20
-void=20
-ip_conntrack_put(struct ip_conntrack *ct)
-{
-	IP_NF_ASSERT(ct);
-	nf_conntrack_put(&ct->ct_general);
-}
-
 static int ip_conntrack_hash_rnd_initted;
 static unsigned int ip_conntrack_hash_rnd;
=20
@@ -222,6 +217,12 @@ static void unlink_expect(struct ip_conn
 	exp->master->expecting--;
 }
=20
+void __ip_ct_expect_unlink_destroy(struct ip_conntrack_expect *exp)
+{
+	unlink_expect(exp);
+	ip_conntrack_expect_put(exp);
+}
+
 static void expectation_timed_out(unsigned long ul_expect)
 {
 	struct ip_conntrack_expect *exp =3D (void *)ul_expect;
@@ -232,6 +233,33 @@ static void expectation_timed_out(unsign
 	ip_conntrack_expect_put(exp);
 }
=20
+struct ip_conntrack_expect *
+__ip_conntrack_expect_find(const struct ip_conntrack_tuple *tuple)
+{
+	struct ip_conntrack_expect *i;
+=09
+	list_for_each_entry(i, &ip_conntrack_expect_list, list) {
+		if (ip_ct_tuple_mask_cmp(tuple, &i->tuple, &i->mask)) {
+			atomic_inc(&i->use);
+			return i;
+		}
+	}
+	return NULL;
+}
+
+/* Just find a expectation corresponding to a tuple. */
+struct ip_conntrack_expect *
+ip_conntrack_expect_find_get(const struct ip_conntrack_tuple *tuple)
+{
+	struct ip_conntrack_expect *i;
+=09
+	read_lock_bh(&ip_conntrack_lock);
+	i =3D __ip_conntrack_expect_find(tuple);
+	read_unlock_bh(&ip_conntrack_lock);
+
+	return i;
+}
+
 /* If an expectation for this connection is found, it gets delete from
  * global list then returned. */
 static struct ip_conntrack_expect *
@@ -256,7 +284,7 @@ find_expectation(const struct ip_conntra
 }
=20
 /* delete all expectations for this conntrack */
-static void remove_expectations(struct ip_conntrack *ct)
+void ip_ct_remove_expectations(struct ip_conntrack *ct)
 {
 	struct ip_conntrack_expect *i, *tmp;
=20
@@ -286,7 +314,7 @@ clean_from_lists(struct ip_conntrack *ct
 	LIST_DELETE(&ip_conntrack_hash[hr], &ct->tuplehash[IP_CT_DIR_REPLY]);
=20
 	/* Destroy all pending expectations */
-	remove_expectations(ct);
+	ip_ct_remove_expectations(ct);
 }
=20
 static void
@@ -304,7 +332,7 @@ destroy_conntrack(struct nf_conntrack *n
 	/* To make sure we don't get any weird locking issues here:
 	 * destroy_conntrack() MUST NOT be called with a write lock
 	 * to ip_conntrack_lock!!! -HW */
-	proto =3D ip_ct_find_proto(ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.proto=
num);
+	proto =3D __ip_conntrack_proto_find(ct->tuplehash[IP_CT_DIR_REPLY].tuple.=
dst.protonum);
 	if (proto && proto->destroy)
 		proto->destroy(ct);
=20
@@ -316,7 +344,7 @@ destroy_conntrack(struct nf_conntrack *n
 	 * except TFTP can create an expectation on the first packet,
 	 * before connection is in the list, so we need to clean here,
 	 * too. */
-	remove_expectations(ct);
+	ip_ct_remove_expectations(ct);
=20
 	/* We overload first tuple to link into unconfirmed list. */
 	if (!is_confirmed(ct)) {
@@ -331,8 +359,7 @@ destroy_conntrack(struct nf_conntrack *n
 		ip_conntrack_put(ct->master);
=20
 	DEBUGP("destroy_conntrack: returning ct=3D%p to slab\n", ct);
-	kmem_cache_free(ip_conntrack_cachep, ct);
-	atomic_dec(&ip_conntrack_count);
+	ip_conntrack_free(ct);
 }
=20
 static void death_by_timeout(unsigned long ul_conntrack)
@@ -359,7 +386,7 @@ conntrack_tuple_cmp(const struct ip_conn
 		&& ip_ct_tuple_equal(tuple, &i->tuple);
 }
=20
-static struct ip_conntrack_tuple_hash *
+struct ip_conntrack_tuple_hash *
 __ip_conntrack_find(const struct ip_conntrack_tuple *tuple,
 		    const struct ip_conntrack *ignored_conntrack)
 {
@@ -394,6 +421,29 @@ ip_conntrack_find_get(const struct ip_co
 	return h;
 }
=20
+static void __ip_conntrack_hash_insert(struct ip_conntrack *ct,
+					unsigned int hash,
+					unsigned int repl_hash)=20
+{
+	ct->id =3D ++ip_conntrack_next_id;
+	list_prepend(&ip_conntrack_hash[hash],
+		     &ct->tuplehash[IP_CT_DIR_ORIGINAL].list);
+	list_prepend(&ip_conntrack_hash[repl_hash],
+		     &ct->tuplehash[IP_CT_DIR_REPLY].list);
+}
+
+void ip_conntrack_hash_insert(struct ip_conntrack *ct)
+{
+	unsigned int hash, repl_hash;
+
+	hash =3D hash_conntrack(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+	repl_hash =3D hash_conntrack(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+
+	write_lock_bh(&ip_conntrack_lock);
+	__ip_conntrack_hash_insert(ct, hash, repl_hash);
+	write_unlock_bh(&ip_conntrack_lock);
+}
+
 /* Confirm a connection given skb; places it in hash table */
 int
 __ip_conntrack_confirm(struct sk_buff **pskb)
@@ -440,10 +490,7 @@ __ip_conntrack_confirm(struct sk_buff **
 		/* Remove from unconfirmed list */
 		list_del(&ct->tuplehash[IP_CT_DIR_ORIGINAL].list);
=20
-		list_prepend(&ip_conntrack_hash[hash],
-			     &ct->tuplehash[IP_CT_DIR_ORIGINAL]);
-		list_prepend(&ip_conntrack_hash[repl_hash],
-			     &ct->tuplehash[IP_CT_DIR_REPLY]);
+		__ip_conntrack_hash_insert(ct, hash, repl_hash);
 		/* Timer relative to confirmation time, not original
 		   setting time, otherwise we'd get timer wrap in
 		   weird delay cases. */
@@ -527,34 +574,84 @@ static inline int helper_cmp(const struc
 	return ip_ct_tuple_mask_cmp(rtuple, &i->tuple, &i->mask);
 }
=20
-static struct ip_conntrack_helper *ip_ct_find_helper(const struct ip_connt=
rack_tuple *tuple)
+static struct ip_conntrack_helper *
+__ip_conntrack_helper_find( const struct ip_conntrack_tuple *tuple)
 {
 	return LIST_FIND(&helpers, helper_cmp,
 			 struct ip_conntrack_helper *,
 			 tuple);
 }
=20
-/* Allocate a new conntrack: we return -ENOMEM if classification
-   failed due to stress.  Otherwise it really is unclassifiable. */
-static struct ip_conntrack_tuple_hash *
-init_conntrack(const struct ip_conntrack_tuple *tuple,
-	       struct ip_conntrack_protocol *protocol,
-	       struct sk_buff *skb)
+struct ip_conntrack_helper *
+ip_conntrack_helper_find_get( const struct ip_conntrack_tuple *tuple)
+{
+	struct ip_conntrack_helper *helper;
+
+	/* need ip_conntrack_lock to assure that helper exists until
+	 * try_module_get() is called */
+	read_lock_bh(&ip_conntrack_lock);
+
+	helper =3D __ip_conntrack_helper_find(tuple);
+	if (helper) {
+		/* need to increase module usage count to assure helper will
+		 * not go away while the caller is e.g. busy putting a
+		 * conntrack in the hash that uses the helper */
+		if (!try_module_get(helper->me))
+			helper =3D NULL;
+	}
+
+	read_unlock_bh(&ip_conntrack_lock);
+
+	return helper;
+}
+
+void ip_conntrack_helper_put(struct ip_conntrack_helper *helper)
+{
+	module_put(helper->me);
+}
+
+struct ip_conntrack_protocol *
+__ip_conntrack_proto_find(u_int8_t protocol)
+{
+	return ip_ct_protos[protocol];
+}
+
+/* this is guaranteed to always return a valid protocol helper, since
+ * it falls back to generic_protocol */
+struct ip_conntrack_protocol *
+ip_conntrack_proto_find_get(u_int8_t protocol)
+{
+	struct ip_conntrack_protocol *p;
+
+	preempt_disable();
+	p =3D __ip_conntrack_proto_find(protocol);
+	if (p) {
+		if (!try_module_get(p->me))
+			p =3D &ip_conntrack_generic_protocol;
+	}
+	preempt_enable();
+=09
+	return p;
+}
+
+void ip_conntrack_proto_put(struct ip_conntrack_protocol *p)
+{
+	module_put(p->me);
+}
+
+struct ip_conntrack *ip_conntrack_alloc(struct ip_conntrack_tuple *orig,
+					struct ip_conntrack_tuple *repl)
 {
 	struct ip_conntrack *conntrack;
-	struct ip_conntrack_tuple repl_tuple;
-	size_t hash;
-	struct ip_conntrack_expect *exp;
=20
 	if (!ip_conntrack_hash_rnd_initted) {
 		get_random_bytes(&ip_conntrack_hash_rnd, 4);
 		ip_conntrack_hash_rnd_initted =3D 1;
 	}
=20
-	hash =3D hash_conntrack(tuple);
-
 	if (ip_conntrack_max
 	    && atomic_read(&ip_conntrack_count) >=3D ip_conntrack_max) {
+		unsigned int hash =3D hash_conntrack(orig);
 		/* Try dropping from this hash chain. */
 		if (!early_drop(&ip_conntrack_hash[hash])) {
 			if (net_ratelimit())
@@ -565,31 +662,58 @@ init_conntrack(const struct ip_conntrack
 		}
 	}
=20
-	if (!ip_ct_invert_tuple(&repl_tuple, tuple, protocol)) {
-		DEBUGP("Can't invert tuple.\n");
-		return NULL;
-	}
-
 	conntrack =3D kmem_cache_alloc(ip_conntrack_cachep, GFP_ATOMIC);
 	if (!conntrack) {
 		DEBUGP("Can't allocate conntrack.\n");
-		return ERR_PTR(-ENOMEM);
+		return NULL;
 	}
=20
 	memset(conntrack, 0, sizeof(*conntrack));
 	atomic_set(&conntrack->ct_general.use, 1);
 	conntrack->ct_general.destroy =3D destroy_conntrack;
-	conntrack->tuplehash[IP_CT_DIR_ORIGINAL].tuple =3D *tuple;
-	conntrack->tuplehash[IP_CT_DIR_REPLY].tuple =3D repl_tuple;
-	if (!protocol->new(conntrack, skb)) {
-		kmem_cache_free(ip_conntrack_cachep, conntrack);
-		return NULL;
-	}
+	conntrack->tuplehash[IP_CT_DIR_ORIGINAL].tuple =3D *orig;
+	conntrack->tuplehash[IP_CT_DIR_REPLY].tuple =3D *repl;
 	/* Don't set timer yet: wait for confirmation */
 	init_timer(&conntrack->timeout);
 	conntrack->timeout.data =3D (unsigned long)conntrack;
 	conntrack->timeout.function =3D death_by_timeout;
=20
+	atomic_inc(&ip_conntrack_count);
+
+	return conntrack;
+}
+
+void
+ip_conntrack_free(struct ip_conntrack *conntrack)
+{
+	atomic_dec(&ip_conntrack_count);
+	kmem_cache_free(ip_conntrack_cachep, conntrack);
+}
+
+/* Allocate a new conntrack: we return -ENOMEM if classification
+ * failed due to stress.   Otherwise it really is unclassifiable */
+static struct ip_conntrack_tuple_hash *
+init_conntrack(struct ip_conntrack_tuple *tuple,
+	       struct ip_conntrack_protocol *protocol,
+	       struct sk_buff *skb)
+{
+	struct ip_conntrack *conntrack;
+	struct ip_conntrack_tuple repl_tuple;
+	struct ip_conntrack_expect *exp;
+
+	if (!ip_ct_invert_tuple(&repl_tuple, tuple, protocol)) {
+		DEBUGP("Can't invert tuple.\n");
+		return NULL;
+	}
+
+	if (!(conntrack =3D ip_conntrack_alloc(tuple, &repl_tuple)))
+		return NULL;
+
+	if (!protocol->new(conntrack, skb)) {
+		ip_conntrack_free(conntrack);
+		return NULL;
+	}
+
 	write_lock_bh(&ip_conntrack_lock);
 	exp =3D find_expectation(tuple);
=20
@@ -605,7 +729,7 @@ init_conntrack(const struct ip_conntrack
 		nf_conntrack_get(&conntrack->master->ct_general);
 		CONNTRACK_STAT_INC(expect_new);
 	} else {
-		conntrack->helper =3D ip_ct_find_helper(&repl_tuple);
+		conntrack->helper =3D __ip_conntrack_helper_find(&repl_tuple);
=20
 		CONNTRACK_STAT_INC(new);
 	}
@@ -613,7 +737,6 @@ init_conntrack(const struct ip_conntrack
 	/* Overload tuple linked list to put us in unconfirmed list. */
 	list_add(&conntrack->tuplehash[IP_CT_DIR_ORIGINAL].list, &unconfirmed);
=20
-	atomic_inc(&ip_conntrack_count);
 	write_unlock_bh(&ip_conntrack_lock);
=20
 	if (exp) {
@@ -724,7 +847,7 @@ unsigned int ip_conntrack_in(unsigned in
 	}
 #endif
=20
-	proto =3D ip_ct_find_proto((*pskb)->nh.iph->protocol);
+	proto =3D __ip_conntrack_proto_find((*pskb)->nh.iph->protocol);
=20
 	/* It may be an special packet, error, unclean...
 	 * inverse of the return code tells to the netfilter
@@ -772,7 +895,7 @@ int invert_tuplepr(struct ip_conntrack_t
 		   const struct ip_conntrack_tuple *orig)
 {
 	return ip_ct_invert_tuple(inverse, orig,=20
-				  ip_ct_find_proto(orig->dst.protonum));
+				  __ip_conntrack_proto_find(orig->dst.protonum));
 }
=20
 /* Would two expected things clash? */
@@ -852,6 +975,8 @@ static void ip_conntrack_expect_insert(s
 	exp->timeout.expires =3D jiffies + exp->master->helper->timeout * HZ;
 	add_timer(&exp->timeout);
=20
+	exp->id =3D ++ip_conntrack_expect_next_id;
+	atomic_inc(&exp->use);
 	CONNTRACK_STAT_INC(expect_create);
 }
=20
@@ -931,7 +1056,7 @@ void ip_conntrack_alter_reply(struct ip_
=20
 	conntrack->tuplehash[IP_CT_DIR_REPLY].tuple =3D *newreply;
 	if (!conntrack->master && conntrack->expecting =3D=3D 0)
-		conntrack->helper =3D ip_ct_find_helper(newreply);
+		conntrack->helper =3D __ip_conntrack_helper_find(newreply);
 	write_unlock_bh(&ip_conntrack_lock);
 }
=20
@@ -945,6 +1070,19 @@ int ip_conntrack_helper_register(struct=20
 	return 0;
 }
=20
+struct ip_conntrack_helper *
+__ip_conntrack_helper_find_byname(const char *name)
+{
+	struct ip_conntrack_helper *h;
+
+	list_for_each_entry(h, &helpers, list) {
+		if (!strcmp(h->name, name))
+			return h;
+	}
+
+	return NULL;
+}
+
 static inline int unhelp(struct ip_conntrack_tuple_hash *i,
 			 const struct ip_conntrack_helper *me)
 {
@@ -1020,6 +1158,36 @@ void ip_ct_refresh_acct(struct ip_conntr
 	}
 }
=20
+/* Generic function for tcp/udp/sctp/dccp and alike. This needs to be
+ * in ip_conntrack_core, since we don't want the protocols to autoload
+ * or depend on ctnetlink */
+int ip_ct_port_tuple_to_nfattr(struct sk_buff *skb,
+			       const struct ip_conntrack_tuple *tuple)
+{
+	NFA_PUT(skb, CTA_PROTO_SRC_PORT, sizeof(u_int16_t),
+		&tuple->src.u.tcp.port);
+	NFA_PUT(skb, CTA_PROTO_DST_PORT, sizeof(u_int16_t),
+		&tuple->dst.u.tcp.port);
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+int ip_ct_port_nfattr_to_tuple(struct nfattr *tb[],
+			       struct ip_conntrack_tuple *t)
+{
+	if (!tb[CTA_PROTO_SRC_PORT-1] || !tb[CTA_PROTO_DST_PORT-1])
+		return -EINVAL;
+
+	t->src.u.tcp.port =3D
+		*(u_int16_t *)NFA_DATA(tb[CTA_PROTO_SRC_PORT-1]);
+	t->dst.u.tcp.port =3D
+		*(u_int16_t *)NFA_DATA(tb[CTA_PROTO_DST_PORT-1]);
+
+	return 0;
+}
+
 /* Returns new sk_buff, or NULL */
 struct sk_buff *
 ip_ct_gather_frags(struct sk_buff *skb, u_int32_t user)
@@ -1198,23 +1366,27 @@ static void free_conntrack_hash(void)
 				     * ip_conntrack_htable_size));
 }
=20
-/* Mishearing the voices in his head, our hero wonders how he's
-   supposed to kill the mall. */
-void ip_conntrack_cleanup(void)
+void ip_conntrack_flush()
 {
-	ip_ct_attach =3D NULL;
 	/* This makes sure all current packets have passed through
            netfilter framework.  Roll on, two-stage module
            delete... */
 	synchronize_net();
-=20
+
  i_see_dead_people:
 	ip_ct_iterate_cleanup(kill_all, NULL);
 	if (atomic_read(&ip_conntrack_count) !=3D 0) {
 		schedule();
 		goto i_see_dead_people;
 	}
+}
=20
+/* Mishearing the voices in his head, our hero wonders how he's
+   supposed to kill the mall. */
+void ip_conntrack_cleanup(void)
+{
+	ip_ct_attach =3D NULL;
+	ip_conntrack_flush();
 	kmem_cache_destroy(ip_conntrack_cachep);
 	kmem_cache_destroy(ip_conntrack_expect_cachep);
 	free_conntrack_hash();
diff --git a/net/ipv4/netfilter/ip_conntrack_netlink.c b/net/ipv4/netfilter=
/ip_conntrack_netlink.c
new file mode 100644
--- /dev/null
+++ b/net/ipv4/netfilter/ip_conntrack_netlink.c
@@ -0,0 +1,1588 @@
+/* Connection tracking via netlink socket. Allows for user space
+ * protocol helpers and general trouble making from userspace.
+ *
+ * (C) 2001 by Jay Schulist <jschlst@samba.org>
+ * (C) 2002-2005 by Harald Welte <laforge@gnumonks.org>
+ * (C) 2003 by Patrick Mchardy <kaber@trash.net>
+ * (C) 2005 by Pablo Neira Ayuso <pablo@eurodev.net>
+ *
+ * I've reworked this stuff to use attributes instead of conntrack=20
+ * structures. 5.44 am. I need more tea. --pablo 05/07/11.
+ *
+ * Initial connection tracking via netlink development funded and=20
+ * generally made possible by Network Robots, Inc. (www.networkrobots.com)
+ *
+ * Further development of this code funded by Astaro AG (http://www.astaro=
=2Ecom)
+ *
+ * This software may be used and distributed according to the terms
+ * of the GNU General Public License, incorporated herein by reference.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/timer.h>
+#include <linux/skbuff.h>
+#include <linux/errno.h>
+#include <linux/netlink.h>
+#include <linux/spinlock.h>
+#include <linux/notifier.h>
+#include <linux/rtnetlink.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ip_conntrack.h>
+#include <linux/netfilter_ipv4/ip_conntrack_core.h>
+#include <linux/netfilter_ipv4/ip_conntrack_helper.h>
+#include <linux/netfilter_ipv4/ip_conntrack_protocol.h>
+#include <linux/netfilter_ipv4/ip_nat_protocol.h>
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_conntrack.h>
+
+MODULE_LICENSE("GPL");
+
+static char __initdata version[] =3D "0.90";
+
+#if 0
+#define DEBUGP printk
+#else
+#define DEBUGP(format, args...)
+#endif
+
+
+static inline int
+ctnetlink_dump_tuples_proto(struct sk_buff *skb,=20
+			    const struct ip_conntrack_tuple *tuple)
+{
+	struct ip_conntrack_protocol *proto;
+
+	NFA_PUT(skb, CTA_PROTO_NUM, sizeof(u_int8_t), &tuple->dst.protonum);
+
+	proto =3D ip_conntrack_proto_find_get(tuple->dst.protonum);
+	if (proto && proto->tuple_to_nfattr)
+		return proto->tuple_to_nfattr(skb, tuple);
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+static inline int
+ctnetlink_dump_tuples(struct sk_buff *skb,=20
+		      const struct ip_conntrack_tuple *tuple)
+{
+	struct nfattr *nest_parms;
+=09
+	nest_parms =3D NFA_NEST(skb, CTA_TUPLE_IP);
+	NFA_PUT(skb, CTA_IP_V4_SRC, sizeof(u_int32_t), &tuple->src.ip);
+	NFA_PUT(skb, CTA_IP_V4_DST, sizeof(u_int32_t), &tuple->dst.ip);
+	NFA_NEST_END(skb, nest_parms);
+
+	nest_parms =3D NFA_NEST(skb, CTA_TUPLE_PROTO);
+	ctnetlink_dump_tuples_proto(skb, tuple);
+	NFA_NEST_END(skb, nest_parms);
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+static inline int
+ctnetlink_dump_status(struct sk_buff *skb, const struct ip_conntrack *ct)
+{
+	u_int32_t status =3D htonl((u_int32_t) ct->status);
+	NFA_PUT(skb, CTA_STATUS, sizeof(status), &status);
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+static inline int
+ctnetlink_dump_timeout(struct sk_buff *skb, const struct ip_conntrack *ct)
+{
+	long timeout_l =3D ct->timeout.expires - jiffies;
+	u_int32_t timeout;
+
+	if (timeout_l < 0)
+		timeout =3D 0;
+	else
+		timeout =3D htonl(timeout_l / HZ);
+=09
+	NFA_PUT(skb, CTA_TIMEOUT, sizeof(timeout), &timeout);
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+static inline int
+ctnetlink_dump_protoinfo(struct sk_buff *skb, const struct ip_conntrack *c=
t)
+{
+	struct ip_conntrack_protocol *proto =3D ip_conntrack_proto_find_get(ct->t=
uplehash[IP_CT_DIR_ORIGINAL].tuple.dst.protonum);
+
+	struct nfattr *nest_proto;
+	int ret;
+=09
+	if (!proto || !proto->to_nfattr)
+		return 0;
+=09
+	nest_proto =3D NFA_NEST(skb, CTA_PROTOINFO);
+
+	ret =3D proto->to_nfattr(skb, nest_proto, ct);
+
+	ip_conntrack_proto_put(proto);
+
+	NFA_NEST_END(skb, nest_proto);
+
+	return ret;
+
+nfattr_failure:
+	return -1;
+}
+
+static inline int
+ctnetlink_dump_helpinfo(struct sk_buff *skb, const struct ip_conntrack *ct)
+{
+	struct nfattr *nest_helper;
+
+	if (!ct->helper)
+		return 0;
+	=09
+	nest_helper =3D NFA_NEST(skb, CTA_HELP);
+	NFA_PUT(skb, CTA_HELP_NAME, CTA_HELP_MAXNAMESIZE, &ct->helper->name);
+
+	if (ct->helper->to_nfattr)
+		ct->helper->to_nfattr(skb, ct);
+
+	NFA_NEST_END(skb, nest_helper);
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+#ifdef CONFIG_IP_NF_CT_ACCT
+static inline int
+ctnetlink_dump_counters(struct sk_buff *skb, const struct ip_conntrack *ct,
+			enum ip_conntrack_dir dir)
+{
+	enum ctattr_type type =3D dir ? CTA_COUNTERS_REPLY: CTA_COUNTERS_ORIG;
+	struct nfattr *nest_count =3D NFA_NEST(skb, type);
+	u_int64_t tmp;
+
+	tmp =3D cpu_to_be64(ct->counters[dir].packets);
+	NFA_PUT(skb, CTA_COUNTERS_PACKETS, sizeof(u_int64_t), &tmp);
+
+	tmp =3D cpu_to_be64(ct->counters[dir].bytes);
+	NFA_PUT(skb, CTA_COUNTERS_BYTES, sizeof(u_int64_t), &tmp);
+
+	NFA_NEST_END(skb, nest_count);
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+#else
+#define ctnetlink_dump_counters(a, b, c) (0)
+#endif
+
+#ifdef CONFIG_IP_NF_CONNTRACK_MARK
+static inline int
+ctnetlink_dump_mark(struct sk_buff *skb, const struct ip_conntrack *ct)
+{
+	u_int32_t mark =3D htonl(ct->mark);
+
+	NFA_PUT(skb, CTA_MARK, sizeof(u_int32_t), &mark);
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+#else
+#define ctnetlink_dump_mark(a, b) (0)
+#endif
+
+static inline int
+ctnetlink_dump_id(struct sk_buff *skb, const struct ip_conntrack *ct)
+{
+	u_int32_t id =3D htonl(ct->id);
+	NFA_PUT(skb, CTA_ID, sizeof(u_int32_t), &id);
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+static inline int
+ctnetlink_dump_use(struct sk_buff *skb, const struct ip_conntrack *ct)
+{
+	unsigned int use =3D htonl(atomic_read(&ct->ct_general.use));
+=09
+	NFA_PUT(skb, CTA_USE, sizeof(u_int32_t), &use);
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+#define tuple(ct, dir) (&(ct)->tuplehash[dir].tuple)
+
+static int
+ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+		    int event, int nowait,=20
+		    const struct ip_conntrack *ct)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	struct nfattr *nest_parms;
+	unsigned char *b;
+
+	b =3D skb->tail;
+
+	event |=3D NFNL_SUBSYS_CTNETLINK << 8;
+	nlh    =3D NLMSG_PUT(skb, pid, seq, event, sizeof(struct nfgenmsg));
+	nfmsg  =3D NLMSG_DATA(nlh);
+
+	nlh->nlmsg_flags    =3D (nowait && pid) ? NLM_F_MULTI : 0;
+	nfmsg->nfgen_family =3D AF_INET;
+	nfmsg->version      =3D NFNETLINK_V0;
+	nfmsg->res_id	    =3D 0;
+
+	nest_parms =3D NFA_NEST(skb, CTA_TUPLE_ORIG);
+	if (ctnetlink_dump_tuples(skb, tuple(ct, IP_CT_DIR_ORIGINAL)) < 0)
+		goto nfattr_failure;
+	NFA_NEST_END(skb, nest_parms);
+=09
+	nest_parms =3D NFA_NEST(skb, CTA_TUPLE_REPLY);
+	if (ctnetlink_dump_tuples(skb, tuple(ct, IP_CT_DIR_REPLY)) < 0)
+		goto nfattr_failure;
+	NFA_NEST_END(skb, nest_parms);
+
+	if (ctnetlink_dump_status(skb, ct) < 0 ||
+	    ctnetlink_dump_timeout(skb, ct) < 0 ||
+	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL) < 0 ||
+	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY) < 0 ||
+	    ctnetlink_dump_protoinfo(skb, ct) < 0 ||
+	    ctnetlink_dump_helpinfo(skb, ct) < 0 ||
+	    ctnetlink_dump_mark(skb, ct) < 0 ||
+	    ctnetlink_dump_id(skb, ct) < 0 ||
+	    ctnetlink_dump_use(skb, ct) < 0)
+		goto nfattr_failure;
+
+	nlh->nlmsg_len =3D skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+nfattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+#ifdef CONFIG_IP_NF_CONNTRACK_EVENTS
+static int ctnetlink_conntrack_event(struct notifier_block *this,
+                                     unsigned long events, void *ptr)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	struct nfattr *nest_parms;
+	struct ip_conntrack *ct =3D (struct ip_conntrack *)ptr;
+	struct sk_buff *skb;
+	unsigned int type;
+	unsigned char *b;
+	unsigned int flags =3D 0, groups;
+
+	/* ignore our fake conntrack entry */
+	if (ct =3D=3D &ip_conntrack_untracked)
+		return NOTIFY_DONE;
+
+	if (events & IPCT_DESTROY) {
+		type =3D IPCTNL_MSG_CT_DELETE;
+		groups =3D NF_NETLINK_CONNTRACK_DESTROY;
+		goto alloc_skb;
+	}
+	if (events & (IPCT_NEW | IPCT_RELATED)) {
+		type =3D IPCTNL_MSG_CT_NEW;
+		flags =3D NLM_F_CREATE|NLM_F_EXCL;
+		/* dump everything */
+		events =3D ~0UL;
+		groups =3D NF_NETLINK_CONNTRACK_NEW;
+		goto alloc_skb;
+	}
+	if (events & (IPCT_STATUS |
+		      IPCT_PROTOINFO |
+		      IPCT_HELPER |
+		      IPCT_HELPINFO |
+		      IPCT_NATINFO)) {
+		type =3D IPCTNL_MSG_CT_NEW;
+		groups =3D NF_NETLINK_CONNTRACK_UPDATE;
+		goto alloc_skb;
+	}=20
+=09
+	return NOTIFY_DONE;
+
+alloc_skb:
+  /* FIXME: Check if there are any listeners before, don't hurt performanc=
e */
+=09
+	skb =3D alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb)
+		return NOTIFY_DONE;
+
+	b =3D skb->tail;
+
+	type |=3D NFNL_SUBSYS_CTNETLINK << 8;
+	nlh   =3D NLMSG_PUT(skb, 0, 0, type, sizeof(struct nfgenmsg));
+	nfmsg =3D NLMSG_DATA(nlh);
+
+	nlh->nlmsg_flags    =3D flags;
+	nfmsg->nfgen_family =3D AF_INET;
+	nfmsg->version	=3D NFNETLINK_V0;
+	nfmsg->res_id	=3D 0;
+
+	nest_parms =3D NFA_NEST(skb, CTA_TUPLE_ORIG);
+	if (ctnetlink_dump_tuples(skb, tuple(ct, IP_CT_DIR_ORIGINAL)) < 0)
+		goto nfattr_failure;
+	NFA_NEST_END(skb, nest_parms);
+=09
+	nest_parms =3D NFA_NEST(skb, CTA_TUPLE_REPLY);
+	if (ctnetlink_dump_tuples(skb, tuple(ct, IP_CT_DIR_REPLY)) < 0)
+		goto nfattr_failure;
+	NFA_NEST_END(skb, nest_parms);
+=09
+	/* NAT stuff is now a status flag */
+	if ((events & IPCT_STATUS || events & IPCT_NATINFO)
+	    && ctnetlink_dump_status(skb, ct) < 0)
+		goto nfattr_failure;
+	if (events & IPCT_REFRESH
+	    && ctnetlink_dump_timeout(skb, ct) < 0)
+		goto nfattr_failure;
+	if (events & IPCT_PROTOINFO
+	    && ctnetlink_dump_protoinfo(skb, ct) < 0)
+		goto nfattr_failure;
+	if (events & IPCT_HELPINFO
+	    && ctnetlink_dump_helpinfo(skb, ct) < 0)
+		goto nfattr_failure;
+
+	if (ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL) < 0 ||
+	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY) < 0)
+		goto nfattr_failure;
+
+	nlh->nlmsg_len =3D skb->tail - b;
+	nfnetlink_send(skb, 0, groups, 0);
+	return NOTIFY_DONE;
+
+nlmsg_failure:
+nfattr_failure:
+	kfree_skb(skb);
+	return NOTIFY_DONE;
+}
+#endif /* CONFIG_IP_NF_CONNTRACK_EVENTS */
+
+static int ctnetlink_done(struct netlink_callback *cb)
+{
+	DEBUGP("entered %s\n", __FUNCTION__);
+	return 0;
+}
+
+static int
+ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct ip_conntrack *ct =3D NULL;
+	struct ip_conntrack_tuple_hash *h;
+	struct list_head *i;
+	u_int32_t *id =3D (u_int32_t *) &cb->args[1];
+
+	DEBUGP("entered %s, last bucket=3D%lu id=3D%u\n", __FUNCTION__,=20
+			cb->args[0], *id);
+
+	read_lock_bh(&ip_conntrack_lock);
+	for (; cb->args[0] < ip_conntrack_htable_size; cb->args[0]++, *id =3D 0) {
+		list_for_each(i, &ip_conntrack_hash[cb->args[0]]) {
+			h =3D (struct ip_conntrack_tuple_hash *) i;
+			if (DIRECTION(h) !=3D IP_CT_DIR_ORIGINAL)
+				continue;
+			ct =3D tuplehash_to_ctrack(h);
+			if (ct->id <=3D *id)
+				continue;
+			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
+		                        	cb->nlh->nlmsg_seq,
+						IPCTNL_MSG_CT_NEW,
+						1, ct) < 0)
+				goto out;
+			*id =3D ct->id;
+		}
+	}
+out:=09
+	read_unlock_bh(&ip_conntrack_lock);
+
+	DEBUGP("leaving, last bucket=3D%lu id=3D%u\n", cb->args[0], *id);
+
+	return skb->len;
+}
+
+#ifdef CONFIG_IP_NF_CT_ACCT
+static int
+ctnetlink_dump_table_w(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct ip_conntrack *ct =3D NULL;
+	struct ip_conntrack_tuple_hash *h;
+	struct list_head *i;
+	u_int32_t *id =3D (u_int32_t *) &cb->args[1];
+
+	DEBUGP("entered %s, last bucket=3D%u id=3D%u\n", __FUNCTION__,=20
+			cb->args[0], *id);
+
+	write_lock_bh(&ip_conntrack_lock);
+	for (; cb->args[0] < ip_conntrack_htable_size; cb->args[0]++, *id =3D 0) {
+		list_for_each(i, &ip_conntrack_hash[cb->args[0]]) {
+			h =3D (struct ip_conntrack_tuple_hash *) i;
+			if (DIRECTION(h) !=3D IP_CT_DIR_ORIGINAL)
+				continue;
+			ct =3D tuplehash_to_ctrack(h);
+			if (ct->id <=3D *id)
+				continue;
+			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
+		                        	cb->nlh->nlmsg_seq,
+						IPCTNL_MSG_CT_NEW,
+						1, ct) < 0)
+				goto out;
+			*id =3D ct->id;
+
+			memset(&ct->counters, 0, sizeof(ct->counters));
+		}
+	}
+out:=09
+	write_unlock_bh(&ip_conntrack_lock);
+
+	DEBUGP("leaving, last bucket=3D%lu id=3D%u\n", cb->args[0], *id);
+
+	return skb->len;
+}
+#endif
+
+static const int cta_min_ip[CTA_IP_MAX] =3D {
+	[CTA_IP_V4_SRC-1]	=3D sizeof(u_int32_t),
+	[CTA_IP_V4_DST-1]	=3D sizeof(u_int32_t),
+};
+
+static inline int
+ctnetlink_parse_tuple_ip(struct nfattr *attr, struct ip_conntrack_tuple *t=
uple)
+{
+	struct nfattr *tb[CTA_IP_MAX];
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	memset(tb, 0, CTA_IP_MAX * sizeof(tb));
+=09
+	if (nfattr_parse_nested(tb, CTA_IP_MAX, attr) < 0)
+		goto nfattr_failure;
+
+	if (nfattr_bad_size(tb, CTA_IP_MAX, cta_min_ip))
+		return -EINVAL;
+
+	if (!tb[CTA_IP_V4_SRC-1])
+		return -EINVAL;
+	tuple->src.ip =3D *(u_int32_t *)NFA_DATA(tb[CTA_IP_V4_SRC-1]);
+
+	if (!tb[CTA_IP_V4_DST-1])
+		return -EINVAL;
+	tuple->dst.ip =3D *(u_int32_t *)NFA_DATA(tb[CTA_IP_V4_DST-1]);
+
+	DEBUGP("leaving\n");
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+static const int cta_min_proto[CTA_PROTO_MAX] =3D {
+	[CTA_PROTO_NUM-1]	=3D sizeof(u_int16_t),
+	[CTA_PROTO_SRC_PORT-1]	=3D sizeof(u_int16_t),
+	[CTA_PROTO_DST_PORT-1]	=3D sizeof(u_int16_t),
+	[CTA_PROTO_ICMP_TYPE-1]	=3D sizeof(u_int8_t),
+	[CTA_PROTO_ICMP_CODE-1]	=3D sizeof(u_int8_t),
+	[CTA_PROTO_ICMP_ID-1]	=3D sizeof(u_int16_t),
+};
+
+static inline int
+ctnetlink_parse_tuple_proto(struct nfattr *attr,=20
+			    struct ip_conntrack_tuple *tuple)
+{
+	struct nfattr *tb[CTA_PROTO_MAX];
+	struct ip_conntrack_protocol *proto;
+	int ret =3D 0;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	memset(tb, 0, CTA_PROTO_MAX * sizeof(tb));
+=09
+	if (nfattr_parse_nested(tb, CTA_PROTO_MAX, attr) < 0)
+		goto nfattr_failure;
+
+	if (nfattr_bad_size(tb, CTA_PROTO_MAX, cta_min_proto))
+		return -EINVAL;
+
+	if (!tb[CTA_PROTO_NUM-1])
+		return -EINVAL;
+	tuple->dst.protonum =3D *(u_int16_t *)NFA_DATA(tb[CTA_PROTO_NUM-1]);
+
+	proto =3D ip_conntrack_proto_find_get(tuple->dst.protonum);
+
+	if (likely(proto && proto->nfattr_to_tuple)) {
+		ret =3D proto->nfattr_to_tuple(tb, tuple);
+		ip_conntrack_proto_put(proto);
+	}
+=09
+	return ret;
+
+nfattr_failure:
+	return -1;
+}
+
+static inline int
+ctnetlink_parse_tuple(struct nfattr *cda[], struct ip_conntrack_tuple *tup=
le,
+		      enum ctattr_tuple type)
+{
+	struct nfattr *tb[CTA_TUPLE_MAX];
+	int err;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	memset(tb, 0, CTA_TUPLE_MAX * sizeof(tb));
+	memset(tuple, 0, sizeof(*tuple));
+
+	if (nfattr_parse_nested(tb, CTA_TUPLE_MAX, cda[type-1]) < 0)
+		goto nfattr_failure;
+
+	if (!tb[CTA_TUPLE_IP-1])
+		return -EINVAL;
+
+	err =3D ctnetlink_parse_tuple_ip(tb[CTA_TUPLE_IP-1], tuple);
+	if (err < 0)
+		return err;
+
+	if (!tb[CTA_TUPLE_PROTO-1])
+		return -EINVAL;
+
+	err =3D ctnetlink_parse_tuple_proto(tb[CTA_TUPLE_PROTO-1], tuple);
+	if (err < 0)
+		return err;
+
+	/* orig and expect tuples get DIR_ORIGINAL */
+	if (type =3D=3D CTA_TUPLE_REPLY)
+		tuple->dst.dir =3D IP_CT_DIR_REPLY;
+	else
+		tuple->dst.dir =3D IP_CT_DIR_ORIGINAL;
+
+	DUMP_TUPLE(tuple);
+
+	DEBUGP("leaving\n");
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+#ifdef CONFIG_IP_NF_NAT_NEEDED
+static const int cta_min_protonat[CTA_PROTONAT_MAX] =3D {
+	[CTA_PROTONAT_PORT_MIN-1]	=3D sizeof(u_int16_t),
+	[CTA_PROTONAT_PORT_MAX-1]	=3D sizeof(u_int16_t),
+};
+
+static int ctnetlink_parse_nat_proto(struct nfattr *attr,
+				     const struct ip_conntrack *ct,
+				     struct ip_nat_range *range)
+{
+	struct nfattr *tb[CTA_PROTONAT_MAX];
+	struct ip_nat_protocol *npt;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	memset(tb, 0, CTA_PROTONAT_MAX * sizeof(tb));
+
+	if (nfattr_parse_nested(tb, CTA_PROTONAT_MAX, attr) < 0)
+		goto nfattr_failure;
+
+	if (nfattr_bad_size(tb, CTA_PROTONAT_MAX, cta_min_protonat))
+		goto nfattr_failure;
+
+	npt =3D ip_nat_proto_find_get(ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst=
=2Eprotonum);
+	if (!npt)
+		return 0;
+
+	if (!npt->nfattr_to_range) {
+		ip_nat_proto_put(npt);
+		return 0;
+	}
+
+	/* nfattr_to_range returns 1 if it parsed, 0 if not, neg. on error */
+	if (npt->nfattr_to_range(tb, range) > 0)
+		range->flags |=3D IP_NAT_RANGE_PROTO_SPECIFIED;
+
+	ip_nat_proto_put(npt);
+
+	DEBUGP("leaving\n");
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+static inline int
+ctnetlink_parse_nat(struct nfattr *cda[],
+		    const struct ip_conntrack *ct, struct ip_nat_range *range)
+{
+	struct nfattr *tb[CTA_NAT_MAX];
+	int err;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	memset(tb, 0, CTA_NAT_MAX * sizeof(tb));
+	memset(range, 0, sizeof(*range));
+=09
+	if (nfattr_parse_nested(tb, CTA_NAT_MAX, cda[CTA_NAT-1]) < 0)
+		goto nfattr_failure;
+
+	if (tb[CTA_NAT_MINIP-1])
+		range->min_ip =3D *(u_int32_t *)NFA_DATA(tb[CTA_NAT_MINIP-1]);
+
+	if (!tb[CTA_NAT_MAXIP-1])
+		range->max_ip =3D range->min_ip;
+	else
+		range->max_ip =3D *(u_int32_t *)NFA_DATA(tb[CTA_NAT_MAXIP-1]);
+
+	if (range->min_ip)
+		range->flags |=3D IP_NAT_RANGE_MAP_IPS;
+
+	if (!tb[CTA_NAT_PROTO-1])
+		return 0;
+
+	err =3D ctnetlink_parse_nat_proto(tb[CTA_NAT_PROTO-1], ct, range);
+	if (err < 0)
+		return err;
+
+	DEBUGP("leaving\n");
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+#endif
+
+static inline int
+ctnetlink_parse_help(struct nfattr *attr, char **helper_name)
+{
+	struct nfattr *tb[CTA_HELP_MAX];
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+	memset(tb, 0, CTA_HELP_MAX * sizeof(tb));
+
+	if (nfattr_parse_nested(tb, CTA_HELP_MAX, attr) < 0)
+		goto nfattr_failure;
+
+	if (!tb[CTA_HELP_NAME-1])
+		return -EINVAL;
+
+	*helper_name =3D NFA_DATA(tb[CTA_HELP_NAME-1]);
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+static int
+ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,=20
+			struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+{
+	struct ip_conntrack_tuple_hash *h;
+	struct ip_conntrack_tuple tuple;
+	struct ip_conntrack *ct;
+	int err =3D 0;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	if (cda[CTA_TUPLE_ORIG-1])
+		err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_ORIG);
+	else if (cda[CTA_TUPLE_REPLY-1])
+		err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_REPLY);
+	else {
+		/* Flush the whole table */
+		ip_conntrack_flush();
+		return 0;
+	}
+
+	if (err < 0)
+		return err;
+
+	h =3D ip_conntrack_find_get(&tuple, NULL);
+	if (!h) {
+		DEBUGP("tuple not found in conntrack hash\n");
+		return -ENOENT;
+	}
+
+	ct =3D tuplehash_to_ctrack(h);
+=09
+	if (cda[CTA_ID-1]) {
+		u_int32_t id =3D ntohl(*(u_int32_t *)NFA_DATA(cda[CTA_ID-1]));
+		if (ct->id !=3D id) {
+			ip_conntrack_put(ct);
+			return -ENOENT;
+		}
+	}=09
+	if (del_timer(&ct->timeout)) {
+		ip_conntrack_put(ct);
+		ct->timeout.function((unsigned long)ct);
+		return 0;
+	}
+	ip_conntrack_put(ct);
+	DEBUGP("leaving\n");
+
+	return 0;
+}
+
+static int
+ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,=20
+			struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+{
+	struct ip_conntrack_tuple_hash *h;
+	struct ip_conntrack_tuple tuple;
+	struct ip_conntrack *ct;
+	struct sk_buff *skb2 =3D NULL;
+	int err =3D 0;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct nfgenmsg *msg =3D NLMSG_DATA(nlh);
+		u32 rlen;
+
+		if (msg->nfgen_family !=3D AF_INET)
+			return -EAFNOSUPPORT;
+
+		if (NFNL_MSG_TYPE(nlh->nlmsg_type) =3D=3D
+					IPCTNL_MSG_CT_GET_CTRZERO) {
+#ifdef CONFIG_IP_NF_CT_ACCT
+			if ((*errp =3D netlink_dump_start(ctnl, skb, nlh,
+						ctnetlink_dump_table_w,
+						ctnetlink_done)) !=3D 0)
+				return -EINVAL;
+#else
+			return -ENOTSUPP;
+#endif
+		} else {
+			if ((*errp =3D netlink_dump_start(ctnl, skb, nlh,
+		      		                        ctnetlink_dump_table,
+		                                	ctnetlink_done)) !=3D 0)
+			return -EINVAL;
+		}
+
+		rlen =3D NLMSG_ALIGN(nlh->nlmsg_len);
+		if (rlen > skb->len)
+			rlen =3D skb->len;
+		skb_pull(skb, rlen);
+		return 0;
+	}
+
+	if (cda[CTA_TUPLE_ORIG-1])
+		err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_ORIG);
+	else if (cda[CTA_TUPLE_REPLY-1])
+		err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_REPLY);
+	else
+		return -EINVAL;
+
+	if (err < 0)
+		return err;
+
+	h =3D ip_conntrack_find_get(&tuple, NULL);
+	if (!h) {
+		DEBUGP("tuple not found in conntrack hash");
+		return -ENOENT;
+	}
+	DEBUGP("tuple found\n");
+	ct =3D tuplehash_to_ctrack(h);
+
+	err =3D -ENOMEM;
+	skb2 =3D alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb2) {
+		ip_conntrack_put(ct);
+		return -ENOMEM;
+	}
+	NETLINK_CB(skb2).dst_pid =3D NETLINK_CB(skb).pid;
+
+	err =3D ctnetlink_fill_info(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq,=20
+				  IPCTNL_MSG_CT_NEW, 1, ct);
+	ip_conntrack_put(ct);
+	if (err <=3D 0)
+		goto out;
+
+	err =3D netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	if (err < 0)
+		goto out;
+
+	DEBUGP("leaving\n");
+	return 0;
+
+out:
+	if (skb2)
+		kfree_skb(skb2);
+	return -1;
+}
+
+static inline int
+ctnetlink_change_status(struct ip_conntrack *ct, struct nfattr *cda[])
+{
+	unsigned long d, status =3D *(u_int32_t *)NFA_DATA(cda[CTA_STATUS-1]);
+	d =3D ct->status ^ status;
+
+	if (d & (IPS_EXPECTED|IPS_CONFIRMED|IPS_DYING))
+		/* unchangeable */
+		return -EINVAL;
+=09
+	if (d & IPS_SEEN_REPLY && !(status & IPS_SEEN_REPLY))
+		/* SEEN_REPLY bit can only be set */
+		return -EINVAL;
+
+=09
+	if (d & IPS_ASSURED && !(status & IPS_ASSURED))
+		/* ASSURED bit can only be set */
+		return -EINVAL;
+
+	if (cda[CTA_NAT-1]) {
+#ifndef CONFIG_IP_NF_NAT_NEEDED
+		return -EINVAL;
+#else
+		unsigned int hooknum;
+		struct ip_nat_range range;
+
+		if (ctnetlink_parse_nat(cda, ct, &range) < 0)
+			return -EINVAL;
+
+		DEBUGP("NAT: %u.%u.%u.%u-%u.%u.%u.%u:%u-%u\n",=20
+		       NIPQUAD(range.min_ip), NIPQUAD(range.max_ip),
+		       htons(range.min.all), htons(range.max.all));
+	=09
+		/* This is tricky but it works. ip_nat_setup_info needs the
+		 * hook number as parameter, so let's do the correct=20
+		 * conversion and run away */
+		if (status & IPS_SRC_NAT_DONE)
+			hooknum =3D NF_IP_POST_ROUTING; /* IP_NAT_MANIP_SRC */
+		else if (status & IPS_DST_NAT_DONE)
+			hooknum =3D NF_IP_PRE_ROUTING;  /* IP_NAT_MANIP_DST */
+		else=20
+			return -EINVAL; /* Missing NAT flags */
+
+		DEBUGP("NAT status: %lu\n",=20
+		       status & (IPS_NAT_MASK | IPS_NAT_DONE_MASK));
+	=09
+		if (ip_nat_initialized(ct, hooknum))
+			return -EEXIST;
+		ip_nat_setup_info(ct, &range, hooknum);
+
+                DEBUGP("NAT status after setup_info: %lu\n",
+                       ct->status & (IPS_NAT_MASK | IPS_NAT_DONE_MASK));
+#endif
+	}
+
+	/* Be careful here, modifying NAT bits can screw up things,
+	 * so don't let users modify them directly if they don't pass
+	 * ip_nat_range. */
+	ct->status |=3D status & ~(IPS_NAT_DONE_MASK | IPS_NAT_MASK);
+	return 0;
+}
+
+
+static inline int
+ctnetlink_change_helper(struct ip_conntrack *ct, struct nfattr *cda[])
+{
+	struct ip_conntrack_helper *helper;
+	char *helpname;
+	int err;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	/* don't change helper of sibling connections */
+	if (ct->master)
+		return -EINVAL;
+
+	err =3D ctnetlink_parse_help(cda[CTA_HELP-1], &helpname);
+	if (err < 0)
+		return err;
+
+	helper =3D __ip_conntrack_helper_find_byname(helpname);
+	if (!helper) {
+		if (!strcmp(helpname, ""))
+			helper =3D NULL;
+		else
+			return -EINVAL;
+	}
+
+	if (ct->helper) {
+		if (!helper) {
+			/* we had a helper before ... */
+			ip_ct_remove_expectations(ct);
+			ct->helper =3D NULL;
+		} else {
+			/* need to zero data of old helper */
+			memset(&ct->help, 0, sizeof(ct->help));
+		}
+	}
+=09
+	ct->helper =3D helper;
+
+	return 0;
+}
+
+static inline int
+ctnetlink_change_timeout(struct ip_conntrack *ct, struct nfattr *cda[])
+{
+	u_int32_t timeout =3D ntohl(*(u_int32_t *)NFA_DATA(cda[CTA_TIMEOUT-1]));
+=09
+	if (!del_timer(&ct->timeout))
+		return -ETIME;
+
+	ct->timeout.expires =3D jiffies + timeout * HZ;
+	add_timer(&ct->timeout);
+
+	return 0;
+}
+
+static int
+ctnetlink_change_conntrack(struct ip_conntrack *ct, struct nfattr *cda[])
+{
+	int err;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	if (cda[CTA_HELP-1]) {
+		err =3D ctnetlink_change_helper(ct, cda);
+		if (err < 0)
+			return err;
+	}
+
+	if (cda[CTA_TIMEOUT-1]) {
+		err =3D ctnetlink_change_timeout(ct, cda);
+		if (err < 0)
+			return err;
+	}
+
+	if (cda[CTA_STATUS-1]) {
+		err =3D ctnetlink_change_status(ct, cda);
+		if (err < 0)
+			return err;
+	}
+
+	DEBUGP("all done\n");
+	return 0;
+}
+
+static int
+ctnetlink_create_conntrack(struct nfattr *cda[],=20
+			   struct ip_conntrack_tuple *otuple,
+			   struct ip_conntrack_tuple *rtuple)
+{
+	struct ip_conntrack *ct;
+	int err =3D -EINVAL;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	ct =3D ip_conntrack_alloc(otuple, rtuple);
+	if (ct =3D=3D NULL || IS_ERR(ct))
+		return -ENOMEM;=09
+
+	if (!cda[CTA_TIMEOUT-1])
+		goto err;
+	ct->timeout.expires =3D ntohl(*(u_int32_t *)NFA_DATA(cda[CTA_TIMEOUT-1]));
+
+	ct->timeout.expires =3D jiffies + ct->timeout.expires * HZ;
+	ct->status |=3D IPS_CONFIRMED;
+
+	err =3D ctnetlink_change_status(ct, cda);
+	if (err < 0)
+		goto err;
+
+	ct->helper =3D ip_conntrack_helper_find_get(rtuple);
+
+	add_timer(&ct->timeout);
+	ip_conntrack_hash_insert(ct);
+
+	if (ct->helper)
+		ip_conntrack_helper_put(ct->helper);
+
+	DEBUGP("conntrack with id %u inserted\n", ct->id);
+	return 0;
+
+err:=09
+	ip_conntrack_free(ct);
+	return err;
+}
+
+static int=20
+ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,=20
+			struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+{
+	struct ip_conntrack_tuple otuple, rtuple;
+	struct ip_conntrack_tuple_hash *h =3D NULL;
+	int err =3D 0;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	if (cda[CTA_TUPLE_ORIG-1]) {
+		err =3D ctnetlink_parse_tuple(cda, &otuple, CTA_TUPLE_ORIG);
+		if (err < 0)
+			return err;
+	}
+
+	if (cda[CTA_TUPLE_REPLY-1]) {
+		err =3D ctnetlink_parse_tuple(cda, &rtuple, CTA_TUPLE_REPLY);
+		if (err < 0)
+			return err;
+	}
+
+	write_lock_bh(&ip_conntrack_lock);
+	if (cda[CTA_TUPLE_ORIG-1])
+		h =3D __ip_conntrack_find(&otuple, NULL);
+	else if (cda[CTA_TUPLE_REPLY-1])
+		h =3D __ip_conntrack_find(&rtuple, NULL);
+
+	if (h =3D=3D NULL) {
+		write_unlock_bh(&ip_conntrack_lock);
+		DEBUGP("no such conntrack, create new\n");
+		err =3D -ENOENT;
+		if (nlh->nlmsg_flags & NLM_F_CREATE)
+			err =3D ctnetlink_create_conntrack(cda, &otuple, &rtuple);
+		goto out_unlock;
+	} else {
+		/* we only allow nat config for new conntracks */
+		if (cda[CTA_NAT-1]) {
+			err =3D -EINVAL;
+			goto out_unlock;
+		}
+	}
+
+	/* We manipulate the conntrack inside the global conntrack table lock,
+	 * so there's no need to increase the refcount */
+	DEBUGP("conntrack found\n");
+	err =3D -EEXIST;
+	if (!(nlh->nlmsg_flags & NLM_F_EXCL))
+		err =3D ctnetlink_change_conntrack(tuplehash_to_ctrack(h), cda);
+
+out_unlock:
+	write_unlock_bh(&ip_conntrack_lock);
+	return err;
+}
+
+/***********************************************************************=
=20
+ * EXPECT=20
+ ***********************************************************************/=
=20
+
+static inline int
+ctnetlink_exp_dump_tuple(struct sk_buff *skb,
+			 const struct ip_conntrack_tuple *tuple,
+			 enum ctattr_expect type)
+{
+	struct nfattr *nest_parms =3D NFA_NEST(skb, type);
+=09
+	if (ctnetlink_dump_tuples(skb, tuple) < 0)
+		goto nfattr_failure;
+
+	NFA_NEST_END(skb, nest_parms);
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}		=09
+
+static inline int
+ctnetlink_exp_dump_expect(struct sk_buff *skb,
+                          const struct ip_conntrack_expect *exp)
+{
+	u_int32_t timeout =3D htonl((exp->timeout.expires - jiffies) / HZ);
+	u_int32_t id =3D htonl(exp->id);
+	struct nfattr *nest_parms =3D NFA_NEST(skb, CTA_EXPECT);
+
+	if (ctnetlink_exp_dump_tuple(skb, &exp->tuple, CTA_EXPECT_TUPLE) < 0)
+		goto nfattr_failure;
+	if (ctnetlink_exp_dump_tuple(skb, &exp->mask, CTA_EXPECT_MASK) < 0)
+		goto nfattr_failure;
+=09
+	NFA_PUT(skb, CTA_EXPECT_TIMEOUT, sizeof(timeout), &timeout);
+	NFA_PUT(skb, CTA_EXPECT_ID, sizeof(u_int32_t), &id);
+	NFA_NEST_END(skb, nest_parms);
+
+	return 0;
+=09
+nfattr_failure:
+	return -1;
+}
+
+static int
+ctnetlink_exp_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+		    int event,=20
+		    int nowait,=20
+		    const struct ip_conntrack_expect *exp)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	unsigned char *b;
+
+	b =3D skb->tail;
+
+	event |=3D NFNL_SUBSYS_CTNETLINK_EXP << 8;
+	nlh    =3D NLMSG_PUT(skb, pid, seq, event, sizeof(struct nfgenmsg));
+	nfmsg  =3D NLMSG_DATA(nlh);
+
+	nlh->nlmsg_flags    =3D (nowait && pid) ? NLM_F_MULTI : 0;
+	nfmsg->nfgen_family =3D AF_INET;
+	nfmsg->version	    =3D NFNETLINK_V0;
+	nfmsg->res_id	    =3D 0;
+
+	if (ctnetlink_exp_dump_expect(skb, exp) < 0)
+		goto nfattr_failure;
+
+	nlh->nlmsg_len =3D skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+nfattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+#ifdef CONFIG_IP_NF_CONNTRACK_EVENTS
+static int ctnetlink_expect_event(struct notifier_block *this,
+				  unsigned long events, void *ptr)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	struct ip_conntrack_expect *exp =3D (struct ip_conntrack_expect *)ptr;
+	struct sk_buff *skb;
+	unsigned int type;
+	unsigned char *b;
+	int flags =3D 0;
+	u16 proto;
+
+	if (events & IPEXP_NEW) {
+		type =3D IPCTNL_MSG_EXP_NEW;
+		flags =3D NLM_F_CREATE|NLM_F_EXCL;
+	} else
+		return NOTIFY_DONE;
+
+	skb =3D alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb)
+		return NOTIFY_DONE;
+
+	b =3D skb->tail;
+
+	type |=3D NFNL_SUBSYS_CTNETLINK << 8;
+	nlh   =3D NLMSG_PUT(skb, 0, 0, type, sizeof(struct nfgenmsg));
+	nfmsg =3D NLMSG_DATA(nlh);
+
+	nlh->nlmsg_flags    =3D flags;
+	nfmsg->nfgen_family =3D AF_INET;
+	nfmsg->version	    =3D NFNETLINK_V0;
+	nfmsg->res_id	    =3D 0;
+
+	if (ctnetlink_exp_dump_expect(skb, exp) < 0)
+		goto nfattr_failure;
+
+	nlh->nlmsg_len =3D skb->tail - b;
+	proto =3D exp->tuple.dst.protonum;
+	nfnetlink_send(skb, 0, NF_NETLINK_CONNTRACK_EXP_NEW, 0);
+	return NOTIFY_DONE;
+
+nlmsg_failure:
+nfattr_failure:
+	kfree_skb(skb);
+	return NOTIFY_DONE;
+}
+#endif
+
+static int
+ctnetlink_exp_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct ip_conntrack_expect *exp =3D NULL;
+	struct list_head *i;
+	u_int32_t *id =3D (u_int32_t *) &cb->args[0];
+
+	DEBUGP("entered %s, last id=3D%llu\n", __FUNCTION__, *id);
+
+	read_lock_bh(&ip_conntrack_lock);
+	list_for_each(i, &ip_conntrack_expect_list) {
+		exp =3D (struct ip_conntrack_expect *) i;
+		if (exp->id <=3D *id)
+			continue;
+		if (ctnetlink_exp_fill_info(skb, NETLINK_CB(cb->skb).pid,
+					    cb->nlh->nlmsg_seq,
+					    IPCTNL_MSG_EXP_NEW,
+					    1, exp) < 0)
+			goto out;
+		*id =3D exp->id;
+	}
+out:=09
+	read_unlock_bh(&ip_conntrack_lock);
+
+	DEBUGP("leaving, last id=3D%llu\n", *id);
+
+	return skb->len;
+}
+
+static int
+ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,=20
+		     struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+{
+	struct ip_conntrack_tuple tuple;
+	struct ip_conntrack_expect *exp;
+	struct sk_buff *skb2;
+	int err =3D 0;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct nfgenmsg *msg =3D NLMSG_DATA(nlh);
+		u32 rlen;
+
+		if (msg->nfgen_family !=3D AF_INET)
+			return -EAFNOSUPPORT;
+
+		if ((*errp =3D netlink_dump_start(ctnl, skb, nlh,
+		    				ctnetlink_exp_dump_table,
+						ctnetlink_done)) !=3D 0)
+			return -EINVAL;
+		rlen =3D NLMSG_ALIGN(nlh->nlmsg_len);
+		if (rlen > skb->len)
+			rlen =3D skb->len;
+		skb_pull(skb, rlen);
+		return 0;
+	}
+
+	if (cda[CTA_TUPLE_ORIG-1])
+		err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_ORIG);
+	else if (cda[CTA_TUPLE_REPLY-1])
+		err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_REPLY);
+	else
+		return -EINVAL;
+
+	if (err < 0)
+		return err;
+
+	exp =3D ip_conntrack_expect_find_get(&tuple);
+	if (!exp)
+		return -ENOENT;
+
+	err =3D -ENOMEM;
+	skb2 =3D alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb2)
+		goto out;
+	NETLINK_CB(skb2).dst_pid =3D NETLINK_CB(skb).pid;
+=09
+	err =3D ctnetlink_exp_fill_info(skb2, NETLINK_CB(skb).pid,=20
+				      nlh->nlmsg_seq, IPCTNL_MSG_EXP_NEW,
+				      1, exp);
+	if (err <=3D 0)
+		goto out;
+
+	ip_conntrack_expect_put(exp);
+
+	err =3D netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	if (err < 0)
+		goto free;
+
+	return err;
+
+out:
+	ip_conntrack_expect_put(exp);
+free:
+	if (skb2)
+		kfree_skb(skb2);
+	return err;
+}
+
+static int
+ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,=20
+		     struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+{
+	struct ip_conntrack_expect *exp, *tmp;
+	struct ip_conntrack_tuple tuple;
+	struct ip_conntrack_helper *h;
+	int err;
+
+	/* delete by tuple needs either orig or reply tuple */
+	if (cda[CTA_TUPLE_ORIG-1])
+		err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_ORIG);
+	else if (cda[CTA_TUPLE_REPLY-1])
+		err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_REPLY);
+	else if (cda[CTA_HELP_NAME-1]) {
+		char *name =3D NFA_DATA(cda[CTA_HELP_NAME-1]);
+
+		/* delete all expectations for this helper */
+		write_lock_bh(&ip_conntrack_lock);
+		h =3D __ip_conntrack_helper_find_byname(name);
+		if (!h) {
+			write_unlock_bh(&ip_conntrack_lock);
+			return -EINVAL;
+		}
+		list_for_each_entry_safe(exp, tmp, &ip_conntrack_expect_list,
+					 list) {
+			if (exp->master->helper =3D=3D h=20
+			    && del_timer(&exp->timeout))
+				__ip_ct_expect_unlink_destroy(exp);
+		}
+		write_unlock(&ip_conntrack_lock);
+		return 0;
+	} else {
+		/* This basically means we have to flush everything*/
+		write_lock_bh(&ip_conntrack_lock);
+		list_for_each_entry_safe(exp, tmp, &ip_conntrack_expect_list,
+					 list) {
+			if (del_timer(&exp->timeout))
+				__ip_ct_expect_unlink_destroy(exp);
+		}
+		write_unlock_bh(&ip_conntrack_lock);
+		return 0;
+	}
+
+	if (err < 0)
+		return err;
+
+	/* bump usage count to 2 */
+	exp =3D ip_conntrack_expect_find_get(&tuple);
+	if (!exp)
+		return -ENOENT;
+
+	if (cda[CTA_EXPECT_ID-1]) {
+		u_int32_t id =3D *(u_int32_t *)NFA_DATA(cda[CTA_EXPECT_ID-1]);
+		if (exp->id !=3D ntohl(id)) {
+			ip_conntrack_expect_put(exp);
+			return -ENOENT;
+		}
+	}
+
+	/* after list removal, usage count =3D=3D 1 */
+	ip_conntrack_unexpect_related(exp);
+	/* have to put what we 'get' above. after this line usage count =3D=3D 0 =
*/
+	ip_conntrack_expect_put(exp);
+
+	return 0;
+}
+static int
+ctnetlink_change_expect(struct ip_conntrack_expect *x, struct nfattr *cda[=
])
+{
+	return -EOPNOTSUPP;
+}
+
+static int
+ctnetlink_create_expect(struct nfattr *cda[])
+{
+	struct ip_conntrack_tuple tuple, mask, master_tuple;
+	struct ip_conntrack_tuple_hash *h =3D NULL;
+	struct ip_conntrack_expect *exp;
+	struct ip_conntrack *ct;
+	int err =3D 0;
+
+	DEBUGP("entered %s\n", __FUNCTION__);
+
+	err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_TUPLE);
+	if (err < 0)
+		return err;
+	err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_MASK);
+	if (err < 0)
+		return err;
+
+	if (cda[CTA_TUPLE_ORIG-1])
+		err =3D ctnetlink_parse_tuple(cda, &master_tuple, CTA_TUPLE_ORIG);
+	else if (cda[CTA_TUPLE_REPLY-1])
+		err =3D ctnetlink_parse_tuple(cda, &master_tuple,=20
+					    CTA_TUPLE_REPLY);
+	else
+		return -EINVAL;
+
+	if (err < 0)
+		return err;
+
+	/* Look for master conntrack of this expectation */
+	h =3D ip_conntrack_find_get(&master_tuple, NULL);
+	if (!h)
+		return -ENOENT;
+	ct =3D tuplehash_to_ctrack(h);
+
+	if (!ct->helper) {
+		/* such conntrack hasn't got any helper, abort */
+		err =3D -EINVAL;
+		goto out;
+	}
+
+	exp =3D ip_conntrack_expect_alloc(ct);
+	if (!exp) {
+		err =3D -ENOMEM;
+		goto out;
+	}
+=09
+	exp->expectfn =3D NULL;
+	exp->master =3D ct;
+	memcpy(&exp->tuple, &tuple, sizeof(struct ip_conntrack_tuple));
+	memcpy(&exp->mask, &mask, sizeof(struct ip_conntrack_tuple));
+
+	err =3D ip_conntrack_expect_related(exp);
+	ip_conntrack_expect_put(exp);
+
+out:=09
+	ip_conntrack_put(tuplehash_to_ctrack(h));
+	return err;
+}
+
+static int
+ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
+		     struct nlmsghdr *nlh, struct nfattr *cda[], int *errp)
+{
+	struct ip_conntrack_tuple tuple;
+	struct ip_conntrack_expect *exp;
+	int err =3D 0;
+
+	DEBUGP("entered %s\n", __FUNCTION__);=09
+
+	if (!cda[CTA_EXPECT_TUPLE-1] || !cda[CTA_EXPECT_MASK-1])
+		return -EINVAL;
+
+	err =3D ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_TUPLE);
+	if (err < 0)
+		return err;
+
+	write_lock_bh(&ip_conntrack_lock);
+	exp =3D __ip_conntrack_expect_find(&tuple);
+
+	if (!exp) {
+		write_unlock_bh(&ip_conntrack_lock);
+		err =3D -ENOENT;
+		if (nlh->nlmsg_flags & NLM_F_CREATE)
+			err =3D ctnetlink_create_expect(cda);
+		return err;
+	}
+
+	err =3D -EEXIST;
+	if (!(nlh->nlmsg_flags & NLM_F_EXCL))
+		err =3D ctnetlink_change_expect(exp, cda);
+	write_unlock_bh(&ip_conntrack_lock);
+
+	DEBUGP("leaving\n");
+=09
+	return err;
+}
+
+#ifdef CONFIG_IP_NF_CONNTRACK_EVENTS
+static struct notifier_block ctnl_notifier =3D {
+	.notifier_call	=3D ctnetlink_conntrack_event,
+};
+
+static struct notifier_block ctnl_notifier_exp =3D {
+	.notifier_call	=3D ctnetlink_expect_event,
+};
+#endif
+
+static struct nfnl_callback ctnl_cb[IPCTNL_MSG_MAX] =3D {
+	[IPCTNL_MSG_CT_NEW]		=3D { .call =3D ctnetlink_new_conntrack,
+					    .cap_required =3D CAP_NET_ADMIN },
+	[IPCTNL_MSG_CT_GET] 		=3D { .call =3D ctnetlink_get_conntrack,
+					    .cap_required =3D CAP_NET_ADMIN },
+	[IPCTNL_MSG_CT_DELETE]  	=3D { .call =3D ctnetlink_del_conntrack,
+					    .cap_required =3D CAP_NET_ADMIN },
+	[IPCTNL_MSG_CT_GET_CTRZERO] 	=3D { .call =3D ctnetlink_get_conntrack,
+					    .cap_required =3D CAP_NET_ADMIN },
+};
+
+static struct nfnl_callback ctnl_exp_cb[IPCTNL_MSG_MAX] =3D {
+	[IPCTNL_MSG_EXP_GET]		=3D { .call =3D ctnetlink_get_expect,
+					    .cap_required =3D CAP_NET_ADMIN },
+	[IPCTNL_MSG_EXP_NEW]		=3D { .call =3D ctnetlink_new_expect,
+					    .cap_required =3D CAP_NET_ADMIN },
+	[IPCTNL_MSG_EXP_DELETE]		=3D { .call =3D ctnetlink_del_expect,
+					    .cap_required =3D CAP_NET_ADMIN },
+};
+
+static struct nfnetlink_subsystem ctnl_subsys =3D {
+	.name				=3D "conntrack",
+	.subsys_id			=3D NFNL_SUBSYS_CTNETLINK,
+	.cb_count			=3D IPCTNL_MSG_MAX,
+	.attr_count			=3D CTA_MAX,
+	.cb				=3D ctnl_cb,
+};
+
+static struct nfnetlink_subsystem ctnl_exp_subsys =3D {
+	.name				=3D "conntrack_expect",
+	.subsys_id			=3D NFNL_SUBSYS_CTNETLINK_EXP,
+	.cb_count			=3D IPCTNL_MSG_EXP_MAX,
+	.attr_count			=3D CTA_MAX,
+	.cb				=3D ctnl_exp_cb,
+};
+
+static int __init ctnetlink_init(void)
+{
+	int ret;
+
+	printk("ctnetlink v%s: registering with nfnetlink.\n", version);
+	ret =3D nfnetlink_subsys_register(&ctnl_subsys);
+	if (ret < 0) {
+		printk("ctnetlink_init: cannot register with nfnetlink.\n");
+		goto err_out;
+	}
+
+	ret =3D nfnetlink_subsys_register(&ctnl_exp_subsys);
+	if (ret < 0) {
+		printk("ctnetlink_init: cannot register exp with nfnetlink.\n");
+		goto err_unreg_subsys;
+	}
+
+#ifdef CONFIG_IP_NF_CONNTRACK_EVENTS
+	ret =3D ip_conntrack_register_notifier(&ctnl_notifier);
+	if (ret < 0) {
+		printk("ctnetlink_init: cannot register notifier.\n");
+		goto err_unreg_exp_subsys;
+	}
+
+	ret =3D ip_conntrack_expect_register_notifier(&ctnl_notifier_exp);
+	if (ret < 0) {
+		printk("ctnetlink_init: cannot expect register notifier.\n");
+		goto err_unreg_notifier;
+	}
+#endif
+
+	return 0;
+
+#ifdef CONFIG_IP_NF_CONNTRACK_EVENTS
+err_unreg_notifier:
+	ip_conntrack_unregister_notifier(&ctnl_notifier);
+err_unreg_exp_subsys:
+	nfnetlink_subsys_unregister(&ctnl_exp_subsys);
+#endif
+err_unreg_subsys:
+	nfnetlink_subsys_unregister(&ctnl_subsys);
+err_out:
+	return ret;
+}
+
+static void __exit ctnetlink_exit(void)
+{
+	printk("ctnetlink: unregistering from nfnetlink.\n");
+
+#ifdef CONFIG_IP_NF_CONNTRACK_EVENTS
+	ip_conntrack_unregister_notifier(&ctnl_notifier_exp);
+	ip_conntrack_unregister_notifier(&ctnl_notifier);
+#endif
+
+	nfnetlink_subsys_unregister(&ctnl_exp_subsys);
+	nfnetlink_subsys_unregister(&ctnl_subsys);
+	return;
+}
+
+module_init(ctnetlink_init);
+module_exit(ctnetlink_exit);
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_icmp.c b/net/ipv4/netfil=
ter/ip_conntrack_proto_icmp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
@@ -109,16 +109,17 @@ static int icmp_packet(struct ip_conntra
 	return NF_ACCEPT;
 }
=20
+static u_int8_t valid_new[] =3D {=20
+	[ICMP_ECHO] =3D 1,
+	[ICMP_TIMESTAMP] =3D 1,
+	[ICMP_INFO_REQUEST] =3D 1,
+	[ICMP_ADDRESS] =3D 1=20
+};
+
 /* Called when a new connection for this protocol found. */
 static int icmp_new(struct ip_conntrack *conntrack,
 		    const struct sk_buff *skb)
 {
-	static u_int8_t valid_new[]
-		=3D { [ICMP_ECHO] =3D 1,
-		    [ICMP_TIMESTAMP] =3D 1,
-		    [ICMP_INFO_REQUEST] =3D 1,
-		    [ICMP_ADDRESS] =3D 1 };
-
 	if (conntrack->tuplehash[0].tuple.dst.u.icmp.type >=3D sizeof(valid_new)
 	    || !valid_new[conntrack->tuplehash[0].tuple.dst.u.icmp.type]) {
 		/* Can't create a new ICMP `conn' with this. */
@@ -159,11 +160,12 @@ icmp_error_message(struct sk_buff *skb,
 		return NF_ACCEPT;
 	}
=20
-	innerproto =3D ip_ct_find_proto(inside->ip.protocol);
+	innerproto =3D ip_conntrack_proto_find_get(inside->ip.protocol);
 	dataoff =3D skb->nh.iph->ihl*4 + sizeof(inside->icmp) + inside->ip.ihl*4;
 	/* Are they talking about one of our connections? */
 	if (!ip_ct_get_tuple(&inside->ip, skb, dataoff, &origtuple, innerproto)) {
 		DEBUGP("icmp_error: ! get_tuple p=3D%u", inside->ip.protocol);
+		ip_conntrack_proto_put(innerproto);
 		return NF_ACCEPT;
 	}
=20
@@ -171,8 +173,10 @@ icmp_error_message(struct sk_buff *skb,
 	   been preserved inside the ICMP. */
 	if (!ip_ct_invert_tuple(&innertuple, &origtuple, innerproto)) {
 		DEBUGP("icmp_error_track: Can't invert tuple\n");
+		ip_conntrack_proto_put(innerproto);
 		return NF_ACCEPT;
 	}
+	ip_conntrack_proto_put(innerproto);
=20
 	*ctinfo =3D IP_CT_RELATED;
=20
@@ -266,6 +270,44 @@ checksum_skipped:
 	return icmp_error_message(skb, ctinfo, hooknum);
 }
=20
+static int icmp_tuple_to_nfattr(struct sk_buff *skb,
+				const struct ip_conntrack_tuple *t)
+{
+	NFA_PUT(skb, CTA_PROTO_ICMP_ID, sizeof(u_int16_t),
+		&t->src.u.icmp.id);
+	NFA_PUT(skb, CTA_PROTO_ICMP_TYPE, sizeof(u_int8_t),
+		&t->dst.u.icmp.type);
+	NFA_PUT(skb, CTA_PROTO_ICMP_CODE, sizeof(u_int8_t),
+		&t->dst.u.icmp.code);
+
+	if (t->dst.u.icmp.type >=3D sizeof(valid_new)=20
+	    || !valid_new[t->dst.u.icmp.type])
+		return -EINVAL;
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+static int icmp_nfattr_to_tuple(struct nfattr *tb[],
+				struct ip_conntrack_tuple *tuple)
+{
+	if (!tb[CTA_PROTO_ICMP_TYPE-1]
+	    || !tb[CTA_PROTO_ICMP_CODE-1]
+	    || !tb[CTA_PROTO_ICMP_ID-1])
+		return -1;
+
+	tuple->dst.u.icmp.type =3D=20
+			*(u_int8_t *)NFA_DATA(tb[CTA_PROTO_ICMP_TYPE-1]);
+	tuple->dst.u.icmp.code =3D
+			*(u_int8_t *)NFA_DATA(tb[CTA_PROTO_ICMP_CODE-1]);
+	tuple->src.u.icmp.id =3D
+			*(u_int8_t *)NFA_DATA(tb[CTA_PROTO_ICMP_ID-1]);
+
+	return 0;
+}
+
 struct ip_conntrack_protocol ip_conntrack_protocol_icmp =3D
 {
 	.proto 			=3D IPPROTO_ICMP,
@@ -277,4 +319,6 @@ struct ip_conntrack_protocol ip_conntrac
 	.packet			=3D icmp_packet,
 	.new			=3D icmp_new,
 	.error			=3D icmp_error,
+	.tuple_to_nfattr	=3D icmp_tuple_to_nfattr,
+	.nfattr_to_tuple	=3D icmp_nfattr_to_tuple,
 };
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_sctp.c b/net/ipv4/netfil=
ter/ip_conntrack_proto_sctp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_sctp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_sctp.c
@@ -505,7 +505,9 @@ static struct ip_conntrack_protocol ip_c
 	.packet 	 =3D sctp_packet,=20
 	.new 		 =3D sctp_new,=20
 	.destroy 	 =3D NULL,=20
-	.me 		 =3D THIS_MODULE=20
+	.me 		 =3D THIS_MODULE,
+	.tuple_to_nfattr =3D ip_ct_port_tuple_to_nfattr,
+	.nfattr_to_tuple =3D ip_ct_port_nfattr_to_tuple,
 };
=20
 #ifdef CONFIG_SYSCTL
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilt=
er/ip_conntrack_proto_tcp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
@@ -336,6 +336,20 @@ static int tcp_print_conntrack(struct se
 	return seq_printf(s, "%s ", tcp_conntrack_names[state]);
 }
=20
+static int tcp_to_nfattr(struct sk_buff *skb, struct nfattr *nfa,
+			 const struct ip_conntrack *ct)
+{
+	read_lock_bh(&tcp_lock);
+	NFA_PUT(skb, CTA_PROTOINFO_TCP_STATE, sizeof(u_int8_t),
+		&ct->proto.tcp.state);
+	read_unlock_bh(&tcp_lock);
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
 static unsigned int get_conntrack_index(const struct tcphdr *tcph)
 {
 	if (tcph->rst) return TCP_RST_SET;
@@ -1100,4 +1114,7 @@ struct ip_conntrack_protocol ip_conntrac
 	.packet 		=3D tcp_packet,
 	.new 			=3D tcp_new,
 	.error			=3D tcp_error,
+	.to_nfattr		=3D tcp_to_nfattr,
+	.tuple_to_nfattr	=3D ip_ct_port_tuple_to_nfattr,
+	.nfattr_to_tuple	=3D ip_ct_port_nfattr_to_tuple,
 };
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_udp.c b/net/ipv4/netfilt=
er/ip_conntrack_proto_udp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_udp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_udp.c
@@ -145,4 +145,6 @@ struct ip_conntrack_protocol ip_conntrac
 	.packet			=3D udp_packet,
 	.new			=3D udp_new,
 	.error			=3D udp_error,
+	.tuple_to_nfattr	=3D ip_ct_port_tuple_to_nfattr,
+	.nfattr_to_tuple	=3D ip_ct_port_nfattr_to_tuple,
 };
diff --git a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfil=
ter/ip_conntrack_standalone.c
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c
@@ -5,7 +5,7 @@
 */
=20
 /* (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2002-2005 Netfilter Core Team <coreteam@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -147,8 +147,7 @@ static int ct_seq_show(struct seq_file *
 	if (DIRECTION(hash))
 		return 0;
=20
-	proto =3D ip_ct_find_proto(conntrack->tuplehash[IP_CT_DIR_ORIGINAL]
-			       .tuple.dst.protonum);
+	proto =3D __ip_conntrack_proto_find(conntrack->tuplehash[IP_CT_DIR_ORIGIN=
AL].tuple.dst.protonum);
 	IP_NF_ASSERT(proto);
=20
 	if (seq_printf(s, "%-8s %u %ld ",
@@ -283,7 +282,7 @@ static int exp_seq_show(struct seq_file=20
 	seq_printf(s, "proto=3D%u ", expect->tuple.dst.protonum);
=20
 	print_tuple(s, &expect->tuple,
-		    ip_ct_find_proto(expect->tuple.dst.protonum));
+		    __ip_conntrack_proto_find(expect->tuple.dst.protonum));
 	return seq_putc(s, '\n');
 }
=20
@@ -992,12 +991,16 @@ EXPORT_SYMBOL(ip_conntrack_helper_regist
 EXPORT_SYMBOL(ip_conntrack_helper_unregister);
 EXPORT_SYMBOL(ip_ct_iterate_cleanup);
 EXPORT_SYMBOL(ip_ct_refresh_acct);
-EXPORT_SYMBOL(ip_ct_protos);
-EXPORT_SYMBOL(ip_ct_find_proto);
+
 EXPORT_SYMBOL(ip_conntrack_expect_alloc);
 EXPORT_SYMBOL(ip_conntrack_expect_put);
+EXPORT_SYMBOL_GPL(ip_conntrack_expect_find_get);
 EXPORT_SYMBOL(ip_conntrack_expect_related);
 EXPORT_SYMBOL(ip_conntrack_unexpect_related);
+EXPORT_SYMBOL_GPL(ip_conntrack_expect_list);
+EXPORT_SYMBOL_GPL(__ip_conntrack_expect_find);
+EXPORT_SYMBOL_GPL(__ip_ct_expect_unlink_destroy);
+
 EXPORT_SYMBOL(ip_conntrack_tuple_taken);
 EXPORT_SYMBOL(ip_ct_gather_frags);
 EXPORT_SYMBOL(ip_conntrack_htable_size);
@@ -1005,7 +1008,26 @@ EXPORT_SYMBOL(ip_conntrack_lock);
 EXPORT_SYMBOL(ip_conntrack_hash);
 EXPORT_SYMBOL(ip_conntrack_untracked);
 EXPORT_SYMBOL_GPL(ip_conntrack_find_get);
-EXPORT_SYMBOL_GPL(ip_conntrack_put);
 #ifdef CONFIG_IP_NF_NAT_NEEDED
 EXPORT_SYMBOL(ip_conntrack_tcp_update);
 #endif
+
+EXPORT_SYMBOL_GPL(ip_conntrack_flush);
+EXPORT_SYMBOL_GPL(__ip_conntrack_find);
+
+EXPORT_SYMBOL_GPL(ip_conntrack_alloc);
+EXPORT_SYMBOL_GPL(ip_conntrack_free);
+EXPORT_SYMBOL_GPL(ip_conntrack_hash_insert);
+
+EXPORT_SYMBOL_GPL(ip_ct_remove_expectations);
+
+EXPORT_SYMBOL_GPL(ip_conntrack_helper_find_get);
+EXPORT_SYMBOL_GPL(ip_conntrack_helper_put);
+EXPORT_SYMBOL_GPL(__ip_conntrack_helper_find_byname);
+
+EXPORT_SYMBOL_GPL(ip_conntrack_proto_find_get);
+EXPORT_SYMBOL_GPL(ip_conntrack_proto_put);
+EXPORT_SYMBOL_GPL(__ip_conntrack_proto_find);
+
+EXPORT_SYMBOL_GPL(ip_ct_port_tuple_to_nfattr);
+EXPORT_SYMBOL_GPL(ip_ct_port_nfattr_to_tuple);
diff --git a/net/ipv4/netfilter/ip_nat_core.c b/net/ipv4/netfilter/ip_nat_c=
ore.c
--- a/net/ipv4/netfilter/ip_nat_core.c
+++ b/net/ipv4/netfilter/ip_nat_core.c
@@ -47,8 +47,39 @@ DEFINE_RWLOCK(ip_nat_lock);
 static unsigned int ip_nat_htable_size;
=20
 static struct list_head *bysource;
+
+#define MAX_IP_NAT_PROTO 256
 struct ip_nat_protocol *ip_nat_protos[MAX_IP_NAT_PROTO];
=20
+static inline struct ip_nat_protocol *
+__ip_nat_proto_find(u_int8_t protonum)
+{
+	return ip_nat_protos[protonum];
+}
+
+struct ip_nat_protocol *
+ip_nat_proto_find_get(u_int8_t protonum)
+{
+	struct ip_nat_protocol *p;
+
+	/* we need to disable preemption to make sure 'p' doesn't get
+	 * removed until we've grabbed the reference */
+	preempt_disable();
+	p =3D __ip_nat_proto_find(protonum);
+	if (p) {
+		if (!try_module_get(p->me))
+			p =3D &ip_nat_unknown_protocol;
+	}
+	preempt_enable();
+
+	return p;
+}
+
+void
+ip_nat_proto_put(struct ip_nat_protocol *p)
+{
+	module_put(p->me);
+}
=20
 /* We keep an extra hash for each conntrack, for fast searching. */
 static inline unsigned int
@@ -103,7 +134,8 @@ static int
 in_range(const struct ip_conntrack_tuple *tuple,
 	 const struct ip_nat_range *range)
 {
-	struct ip_nat_protocol *proto =3D ip_nat_find_proto(tuple->dst.protonum);
+	struct ip_nat_protocol *proto =3D=20
+				__ip_nat_proto_find(tuple->dst.protonum);
=20
 	/* If we are supposed to map IPs, then we must be in the
 	   range specified, otherwise let this drag us onto a new src IP. */
@@ -216,8 +248,7 @@ get_unique_tuple(struct ip_conntrack_tup
 		 struct ip_conntrack *conntrack,
 		 enum ip_nat_manip_type maniptype)
 {
-	struct ip_nat_protocol *proto
-		=3D ip_nat_find_proto(orig_tuple->dst.protonum);
+	struct ip_nat_protocol *proto;
=20
 	/* 1) If this srcip/proto/src-proto-part is currently mapped,
 	   and that same mapping gives a unique tuple within the given
@@ -242,14 +273,20 @@ get_unique_tuple(struct ip_conntrack_tup
 	/* 3) The per-protocol part of the manip is made to map into
 	   the range to make a unique tuple. */
=20
+	proto =3D ip_nat_proto_find_get(orig_tuple->dst.protonum);
+
 	/* Only bother mapping if it's not already in range and unique */
 	if ((!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED)
 	     || proto->in_range(tuple, maniptype, &range->min, &range->max))
-	    && !ip_nat_used_tuple(tuple, conntrack))
+	    && !ip_nat_used_tuple(tuple, conntrack)) {
+		ip_nat_proto_put(proto);
 		return;
+	}
=20
 	/* Last change: get protocol to try to obtain unique tuple. */
 	proto->unique_tuple(tuple, range, maniptype, conntrack);
+
+	ip_nat_proto_put(proto);
 }
=20
 unsigned int
@@ -320,6 +357,7 @@ manip_pkt(u_int16_t proto,
 	  enum ip_nat_manip_type maniptype)
 {
 	struct iphdr *iph;
+	struct ip_nat_protocol *p;
=20
 	if (!skb_ip_make_writable(pskb, iphdroff + sizeof(*iph)))
 		return 0;
@@ -327,9 +365,12 @@ manip_pkt(u_int16_t proto,
 	iph =3D (void *)(*pskb)->data + iphdroff;
=20
 	/* Manipulate protcol part. */
-	if (!ip_nat_find_proto(proto)->manip_pkt(pskb, iphdroff,
-	                                         target, maniptype))
+	p =3D ip_nat_proto_find_get(proto);
+	if (!p->manip_pkt(pskb, iphdroff, target, maniptype)) {
+		ip_nat_proto_put(p);
 		return 0;
+	}
+	ip_nat_proto_put(p);
=20
 	iph =3D (void *)(*pskb)->data + iphdroff;
=20
@@ -425,7 +466,8 @@ int icmp_reply_translation(struct sk_buf
=20
 	if (!ip_ct_get_tuple(&inside->ip, *pskb, (*pskb)->nh.iph->ihl*4 +
 	                     sizeof(struct icmphdr) + inside->ip.ihl*4,
-	                     &inner, ip_ct_find_proto(inside->ip.protocol)))
+	                     &inner,
+			     __ip_conntrack_proto_find(inside->ip.protocol)))
 		return 0;
=20
 	/* Change inner back to look like incoming packet.  We do the
@@ -495,6 +537,46 @@ void ip_nat_protocol_unregister(struct i
 	synchronize_net();
 }
=20
+int
+ip_nat_port_range_to_nfattr(struct sk_buff *skb,=20
+			    const struct ip_nat_range *range)
+{
+	NFA_PUT(skb, CTA_PROTONAT_PORT_MIN, sizeof(u_int16_t),
+		&range->min.tcp.port);
+	NFA_PUT(skb, CTA_PROTONAT_PORT_MAX, sizeof(u_int16_t),
+		&range->max.tcp.port);
+
+	return 0;
+
+nfattr_failure:
+	return -1;
+}
+
+int
+ip_nat_port_nfattr_to_range(struct nfattr *tb[], struct ip_nat_range *rang=
e)
+{
+	int ret =3D 0;
+=09
+	/* we have to return whether we actually parsed something or not */
+
+	if (tb[CTA_PROTONAT_PORT_MIN-1]) {
+		ret =3D 1;
+		range->min.tcp.port =3D=20
+			*(u_int16_t *)NFA_DATA(tb[CTA_PROTONAT_PORT_MIN-1]);
+	}
+=09
+	if (!tb[CTA_PROTONAT_PORT_MAX-1]) {
+		if (ret)=20
+			range->max.tcp.port =3D range->min.tcp.port;
+	} else {
+		ret =3D 1;
+		range->max.tcp.port =3D=20
+			*(u_int16_t *)NFA_DATA(tb[CTA_PROTONAT_PORT_MAX-1]);
+	}
+
+	return ret;
+}
+
 int __init ip_nat_init(void)
 {
 	size_t i;
diff --git a/net/ipv4/netfilter/ip_nat_proto_icmp.c b/net/ipv4/netfilter/ip=
_nat_proto_icmp.c
--- a/net/ipv4/netfilter/ip_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/ip_nat_proto_icmp.c
@@ -106,10 +106,12 @@ icmp_print_range(char *buffer, const str
 }
=20
 struct ip_nat_protocol ip_nat_protocol_icmp
-=3D { "ICMP", IPPROTO_ICMP,
+=3D { "ICMP", IPPROTO_ICMP, THIS_MODULE,
     icmp_manip_pkt,
     icmp_in_range,
     icmp_unique_tuple,
     icmp_print,
-    icmp_print_range
+    icmp_print_range,
+    ip_nat_port_range_to_nfattr,
+    ip_nat_port_nfattr_to_range,
 };
diff --git a/net/ipv4/netfilter/ip_nat_proto_tcp.c b/net/ipv4/netfilter/ip_=
nat_proto_tcp.c
--- a/net/ipv4/netfilter/ip_nat_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_nat_proto_tcp.c
@@ -12,6 +12,7 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/if.h>
+#include <linux/netfilter/nfnetlink_conntrack.h>
 #include <linux/netfilter_ipv4/ip_nat.h>
 #include <linux/netfilter_ipv4/ip_nat_rule.h>
 #include <linux/netfilter_ipv4/ip_nat_protocol.h>
@@ -169,10 +170,12 @@ tcp_print_range(char *buffer, const stru
 }
=20
 struct ip_nat_protocol ip_nat_protocol_tcp
-=3D { "TCP", IPPROTO_TCP,
+=3D { "TCP", IPPROTO_TCP, THIS_MODULE,
     tcp_manip_pkt,
     tcp_in_range,
     tcp_unique_tuple,
     tcp_print,
-    tcp_print_range
+    tcp_print_range,
+    ip_nat_port_range_to_nfattr,
+    ip_nat_port_nfattr_to_range,
 };
diff --git a/net/ipv4/netfilter/ip_nat_proto_udp.c b/net/ipv4/netfilter/ip_=
nat_proto_udp.c
--- a/net/ipv4/netfilter/ip_nat_proto_udp.c
+++ b/net/ipv4/netfilter/ip_nat_proto_udp.c
@@ -156,10 +156,12 @@ udp_print_range(char *buffer, const stru
 }
=20
 struct ip_nat_protocol ip_nat_protocol_udp
-=3D { "UDP", IPPROTO_UDP,
+=3D { "UDP", IPPROTO_UDP, THIS_MODULE,
     udp_manip_pkt,
     udp_in_range,
     udp_unique_tuple,
     udp_print,
-    udp_print_range
+    udp_print_range,
+    ip_nat_port_range_to_nfattr,
+    ip_nat_port_nfattr_to_range,
 };
diff --git a/net/ipv4/netfilter/ip_nat_proto_unknown.c b/net/ipv4/netfilter=
/ip_nat_proto_unknown.c
--- a/net/ipv4/netfilter/ip_nat_proto_unknown.c
+++ b/net/ipv4/netfilter/ip_nat_proto_unknown.c
@@ -61,7 +61,7 @@ unknown_print_range(char *buffer, const=20
 }
=20
 struct ip_nat_protocol ip_nat_unknown_protocol =3D {
-	"unknown", 0,
+	"unknown", 0, THIS_MODULE,
 	unknown_manip_pkt,
 	unknown_in_range,
 	unknown_unique_tuple,
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip=
_nat_standalone.c
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -390,6 +390,8 @@ module_exit(fini);
 EXPORT_SYMBOL(ip_nat_setup_info);
 EXPORT_SYMBOL(ip_nat_protocol_register);
 EXPORT_SYMBOL(ip_nat_protocol_unregister);
+EXPORT_SYMBOL_GPL(ip_nat_proto_find_get);
+EXPORT_SYMBOL_GPL(ip_nat_proto_put);
 EXPORT_SYMBOL(ip_nat_cheat_check);
 EXPORT_SYMBOL(ip_nat_mangle_tcp_packet);
 EXPORT_SYMBOL(ip_nat_mangle_udp_packet);

--Nq2Wo0NMKNjxTN9z--

--DKU6Jbt7q3WqK7+M
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC4PCBXaXGVTD0i/8RAme/AJ9ykB4W8rqjPVnVpVxSDFyTrOagVgCfdcTf
onFEgnbbbq8MI5TyN9DRuuc=
=p1YQ
-----END PGP SIGNATURE-----

--DKU6Jbt7q3WqK7+M--
