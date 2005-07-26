From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] move ip[6]_queue rerouting up to nf_queue
Date: Tue, 26 Jul 2005 18:45:05 +0200
Message-ID: <20050726164505.GD4279@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jt0yj30bxbg11sci"
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


--jt0yj30bxbg11sci
Content-Type: multipart/mixed; boundary="jkO+KyKz7TfD21mV"
Content-Disposition: inline


--jkO+KyKz7TfD21mV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

please apply.  If you dislike the yet-another-NPROTO nature of it, I'll
prepare one with kmalloc-at-startup.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--jkO+KyKz7TfD21mV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="12-queue-reroute.patch"
Content-Transfer-Encoding: quoted-printable

Move reroute-after-queue code from ip_queue and ip6_queue up to the
nf_queue layer.  The rerouting functionality is required by the core,
therefore it has to be implemented by the core and not in individual queue
handlers.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit f61a93c9b4b59f82ef781a50ec955c50fe32e5db
tree 588cbbf9f57d64c4be73314b9ddbbfdc6932ec55
parent 93bd54e21ddb8f5553fd8a8beaae7803ff4e3852
author laforge <laforge@netfilter.org> Di, 26 Jul 2005 18:42:37 +0200
committer laforge <laforge@netfilter.org> Di, 26 Jul 2005 18:42:37 +0200

 include/linux/netfilter.h      |   11 +++++++
 net/core/netfilter.c           |   60 ++++++++++++++++++++++++++++++------=
--
 net/ipv4/netfilter.c           |   64 ++++++++++++++++++++++++++++++++++++=
+++-
 net/ipv4/netfilter/ip_queue.c  |   27 -----------------
 net/ipv6/af_inet6.c            |    6 ++++
 net/ipv6/netfilter.c           |   62 ++++++++++++++++++++++++++++++++++++=
+++
 net/ipv6/netfilter/ip6_queue.c |   24 ---------------
 7 files changed, 189 insertions(+), 65 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -198,6 +198,17 @@ extern void nf_invalidate_cache(int pf);
    Returns true or false. */
 extern int skb_make_writable(struct sk_buff **pskb, unsigned int writable_=
len);
=20
+struct nf_queue_rerouter {
+	void (*save)(const struct sk_buff *skb, struct nf_info *info);
+	int (*reroute)(struct sk_buff **skb, const struct nf_info *info);
+	int rer_size;
+};
+
+#define nf_info_reroute(x) ((void *)x + sizeof(typeof(x)))
+
+extern int nf_register_queue_rerouter(int pf, struct nf_queue_rerouter *re=
r);
+extern int nf_unregister_queue_rerouter(int pf);
+
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) =
{}
diff --git a/net/core/netfilter.c b/net/core/netfilter.c
--- a/net/core/netfilter.c
+++ b/net/core/netfilter.c
@@ -53,6 +53,9 @@ static struct nf_queue_handler_t {
 	nf_queue_outfn_t outfn;
 	void *data;
 } queue_handler[NPROTO];
+
+static struct nf_queue_rerouter queue_rerouter[NPROTO];
+
 static DEFINE_RWLOCK(queue_handler_lock);
=20
 int nf_register_hook(struct nf_hook_ops *reg)
@@ -260,11 +263,34 @@ int nf_unregister_queue_handler(int pf)
 	return 0;
 }
=20
+int nf_register_queue_rerouter(int pf, struct nf_queue_rerouter *rer)
+{
+	if (pf >=3D NPROTO)
+		return -EINVAL;
+
+	write_lock_bh(&queue_handler_lock);
+	memcpy(&queue_rerouter[pf], rer, sizeof(queue_rerouter[pf]));
+	write_unlock_bh(&queue_handler_lock);
+
+	return 0;
+}
+
+int nf_unregister_queue_rerouter(int pf)
+{
+	if (pf >=3D NPROTO)
+		return -EINVAL;
+
+	write_lock_bh(&queue_handler_lock);
+	memset(&queue_rerouter[pf], 0, sizeof(queue_rerouter[pf]));
+	write_unlock_bh(&queue_handler_lock);
+	return 0;
+}
+
 /*=20
  * Any packet that leaves via this function must come back=20
  * through nf_reinject().
  */
-static int nf_queue(struct sk_buff *skb,=20
+static int nf_queue(struct sk_buff **skb,=20
 		    struct list_head *elem,=20
 		    int pf, unsigned int hook,
 		    struct net_device *indev,
@@ -282,17 +308,17 @@ static int nf_queue(struct sk_buff *skb,
 	read_lock(&queue_handler_lock);
 	if (!queue_handler[pf].outfn) {
 		read_unlock(&queue_handler_lock);
-		kfree_skb(skb);
+		kfree_skb(*skb);
 		return 1;
 	}
=20
-	info =3D kmalloc(sizeof(*info), GFP_ATOMIC);
+	info =3D kmalloc(sizeof(*info)+queue_rerouter[pf].rer_size, GFP_ATOMIC);
 	if (!info) {
 		if (net_ratelimit())
 			printk(KERN_ERR "OOM queueing packet %p\n",
-			       skb);
+			       *skb);
 		read_unlock(&queue_handler_lock);
-		kfree_skb(skb);
+		kfree_skb(*skb);
 		return 1;
 	}
=20
@@ -311,15 +337,21 @@ static int nf_queue(struct sk_buff *skb,
 	if (outdev) dev_hold(outdev);
=20
 #ifdef CONFIG_BRIDGE_NETFILTER
-	if (skb->nf_bridge) {
-		physindev =3D skb->nf_bridge->physindev;
+	if ((*skb)->nf_bridge) {
+		physindev =3D (*skb)->nf_bridge->physindev;
 		if (physindev) dev_hold(physindev);
-		physoutdev =3D skb->nf_bridge->physoutdev;
+		physoutdev =3D (*skb)->nf_bridge->physoutdev;
 		if (physoutdev) dev_hold(physoutdev);
 	}
 #endif
+	if (queue_rerouter[pf].save)
+		queue_rerouter[pf].save(*skb, info);
+
+	status =3D queue_handler[pf].outfn(*skb, info, queue_handler[pf].data);
+
+	if (status >=3D 0 && queue_rerouter[pf].reroute)
+		status =3D queue_rerouter[pf].reroute(skb, info);
=20
-	status =3D queue_handler[pf].outfn(skb, info, queue_handler[pf].data);
 	read_unlock(&queue_handler_lock);
=20
 	if (status < 0) {
@@ -332,9 +364,11 @@ static int nf_queue(struct sk_buff *skb,
 #endif
 		module_put(info->elem->owner);
 		kfree(info);
-		kfree_skb(skb);
+		kfree_skb(*skb);
+
 		return 1;
 	}
+
 	return 1;
 }
=20
@@ -365,7 +399,7 @@ next_hook:
 		ret =3D -EPERM;
 	} else if (verdict =3D=3D NF_QUEUE) {
 		NFDEBUG("nf_hook: Verdict =3D QUEUE.\n");
-		if (!nf_queue(*pskb, elem, pf, hook, indev, outdev, okfn))
+		if (!nf_queue(pskb, elem, pf, hook, indev, outdev, okfn))
 			goto next_hook;
 	}
 unlock:
@@ -428,7 +462,7 @@ void nf_reinject(struct sk_buff *skb, st
 		break;
=20
 	case NF_QUEUE:
-		if (!nf_queue(skb, elem, info->pf, info->hook,=20
+		if (!nf_queue(&skb, elem, info->pf, info->hook,=20
 			      info->indev, info->outdev, info->okfn))
 			goto next_hook;
 		break;
@@ -573,4 +607,6 @@ EXPORT_SYMBOL(nf_reinject);
 EXPORT_SYMBOL(nf_setsockopt);
 EXPORT_SYMBOL(nf_unregister_hook);
 EXPORT_SYMBOL(nf_unregister_queue_handler);
+EXPORT_SYMBOL_GPL(nf_register_queue_rerouter);
+EXPORT_SYMBOL_GPL(nf_unregister_queue_rerouter);
 EXPORT_SYMBOL(nf_unregister_sockopt);
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -1,10 +1,11 @@
-#include <linux/config.h>
+/* IPv4 specific functions of netfilter core */
=20
+#include <linux/config.h>
 #ifdef CONFIG_NETFILTER
=20
-/* IPv4 specific functions of netfilter core */
 #include <linux/kernel.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
=20
 #include <linux/tcp.h>
 #include <linux/udp.h>
@@ -76,4 +77,63 @@ int ip_route_me_harder(struct sk_buff **
 	return 0;
 }
 EXPORT_SYMBOL(ip_route_me_harder);
+
+/*
+ * Extra routing may needed on local out, as the QUEUE target never
+ * returns control to the table.
+ */
+
+struct ip_rt_info {
+	u_int32_t daddr;
+	u_int32_t saddr;
+	u_int8_t tos;
+};
+
+static void queue_save(const struct sk_buff *skb, struct nf_info *info)
+{
+	struct ip_rt_info *rt_info =3D nf_info_reroute(info);
+
+	if (info->hook =3D=3D NF_IP_LOCAL_OUT) {
+		const struct iphdr *iph =3D skb->nh.iph;
+
+		rt_info->tos =3D iph->tos;
+		rt_info->daddr =3D iph->daddr;
+		rt_info->saddr =3D iph->saddr;
+	}
+}
+
+static int queue_reroute(struct sk_buff **pskb, const struct nf_info *info)
+{
+	const struct ip_rt_info *rt_info =3D nf_info_reroute(info);
+
+	if (info->hook =3D=3D NF_IP_LOCAL_OUT) {
+		struct iphdr *iph =3D (*pskb)->nh.iph;
+
+		if (!(iph->tos =3D=3D rt_info->tos
+		      && iph->daddr =3D=3D rt_info->daddr
+		      && iph->saddr =3D=3D rt_info->saddr))
+			return ip_route_me_harder(pskb);
+	}
+	return 0;
+}
+
+static struct nf_queue_rerouter ip_reroute =3D {
+	.rer_size	=3D sizeof(struct ip_rt_info),
+	.save		=3D queue_save,
+	.reroute	=3D queue_reroute,
+};
+
+static int init(void)
+{
+	return nf_register_queue_rerouter(PF_INET, &ip_reroute);
+}
+
+static void fini(void)
+{
+	nf_unregister_queue_rerouter(PF_INET);
+}
+
+module_init(init);
+module_exit(fini);
+
 #endif /* CONFIG_NETFILTER */
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -43,17 +43,10 @@
 #define NET_IPQ_QMAX 2088
 #define NET_IPQ_QMAX_NAME "ip_queue_maxlen"
=20
-struct ipq_rt_info {
-	__u8 tos;
-	__u32 daddr;
-	__u32 saddr;
-};
-
 struct ipq_queue_entry {
 	struct list_head list;
 	struct nf_info *info;
 	struct sk_buff *skb;
-	struct ipq_rt_info rt_info;
 };
=20
 typedef int (*ipq_cmpfn)(struct ipq_queue_entry *, unsigned long);
@@ -299,14 +292,6 @@ ipq_enqueue_packet(struct sk_buff *skb,=20
 	entry->info =3D info;
 	entry->skb =3D skb;
=20
-	if (entry->info->hook =3D=3D NF_IP_LOCAL_OUT) {
-		struct iphdr *iph =3D skb->nh.iph;
-
-		entry->rt_info.tos =3D iph->tos;
-		entry->rt_info.daddr =3D iph->daddr;
-		entry->rt_info.saddr =3D iph->saddr;
-	}
-
 	nskb =3D ipq_build_packet_message(entry, &status);
 	if (nskb =3D=3D NULL)
 		goto err_out_free;
@@ -386,18 +371,6 @@ ipq_mangle_ipv4(ipq_verdict_msg_t *v, st
 		return -ENOMEM;
 	memcpy(e->skb->data, v->payload, v->data_len);
=20
-	/*
-	 * Extra routing may needed on local out, as the QUEUE target never
-	 * returns control to the table.
-	 */
-	if (e->info->hook =3D=3D NF_IP_LOCAL_OUT) {
-		struct iphdr *iph =3D e->skb->nh.iph;
-
-		if (!(iph->tos =3D=3D e->rt_info.tos
-		      && iph->daddr =3D=3D e->rt_info.daddr
-		      && iph->saddr =3D=3D e->rt_info.saddr))
-			return ip_route_me_harder(&e->skb);
-	}
 	return 0;
 }
=20
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -757,6 +757,9 @@ static int __init inet6_init(void)
 	err =3D igmp6_init(&inet6_family_ops);
 	if (err)
 		goto igmp_fail;
+	err =3D ipv6_netfilter_init();
+	if (err)
+		goto netfilter_fail;
 	/* Create /proc/foo6 entries. */
 #ifdef CONFIG_PROC_FS
 	err =3D -ENOMEM;
@@ -813,6 +816,8 @@ proc_tcp6_fail:
 	raw6_proc_exit();
 proc_raw6_fail:
 #endif
+	ipv6_netfilter_fini();
+netfilter_fail:
 	igmp6_cleanup();
 igmp_fail:
 	ndisc_cleanup();
@@ -852,6 +857,7 @@ static void __exit inet6_exit(void)
 	ip6_route_cleanup();
 	ipv6_packet_cleanup();
 	igmp6_cleanup();
+	ipv6_netfilter_fini();
 	ndisc_cleanup();
 	icmpv6_cleanup();
 #ifdef CONFIG_SYSCTL
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -4,6 +4,8 @@
=20
 #include <linux/kernel.h>
 #include <linux/ipv6.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
 #include <net/dst.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
@@ -39,4 +41,64 @@ int ip6_route_me_harder(struct sk_buff *
 }
 EXPORT_SYMBOL(ip6_route_me_harder);
=20
+/*
+ * Extra routing may needed on local out, as the QUEUE target never
+ * returns control to the table.
+ */
+
+struct ip6_rt_info {
+	struct in6_addr daddr;
+	struct in6_addr saddr;
+};
+
+static void save(const struct sk_buff *skb, struct nf_info *info)
+{
+	struct ip6_rt_info *rt_info =3D nf_info_reroute(info);
+
+	if (info->hook =3D=3D NF_IP6_LOCAL_OUT) {
+		struct ipv6hdr *iph =3D skb->nh.ipv6h;
+
+		rt_info->daddr =3D iph->daddr;
+		rt_info->saddr =3D iph->saddr;
+	}
+}
+
+static int reroute(struct sk_buff **pskb, const struct nf_info *info)
+{
+	struct ip6_rt_info *rt_info =3D nf_info_reroute(info);
+
+	if (info->hook =3D=3D NF_IP6_LOCAL_OUT) {
+		struct ipv6hdr *iph =3D (*pskb)->nh.ipv6h;
+		if (!ipv6_addr_equal(&iph->daddr, &rt_info->daddr) ||
+		    !ipv6_addr_equal(&iph->saddr, &rt_info->saddr))
+			return ip6_route_me_harder(*pskb);
+	}
+	return 0;
+}
+
+static struct nf_queue_rerouter ip6_reroute =3D {
+	.rer_size	=3D sizeof(struct ip6_rt_info),
+	.save 		=3D &save,
+	.reroute	=3D &reroute,
+};
+
+int __init ipv6_netfilter_init(void)
+{
+	return nf_register_queue_rerouter(PF_INET6, &ip6_reroute);
+}
+
+void __exit ipv6_netfilter_fini(void)
+{
+	nf_unregister_queue_rerouter(PF_INET6);
+}
+
+#else /* CONFIG_NETFILTER */
+int __init ipv6_netfilter_init(void)
+{
+	return 0;
+}
+
+void __exit ipv6_netfilter_fini(void)
+{
+}
 #endif /* CONFIG_NETFILTER */
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -47,16 +47,10 @@
 #define NET_IPQ_QMAX 2088
 #define NET_IPQ_QMAX_NAME "ip6_queue_maxlen"
=20
-struct ipq_rt_info {
-	struct in6_addr daddr;
-	struct in6_addr saddr;
-};
-
 struct ipq_queue_entry {
 	struct list_head list;
 	struct nf_info *info;
 	struct sk_buff *skb;
-	struct ipq_rt_info rt_info;
 };
=20
 typedef int (*ipq_cmpfn)(struct ipq_queue_entry *, unsigned long);
@@ -296,13 +290,6 @@ ipq_enqueue_packet(struct sk_buff *skb,=20
 	entry->info =3D info;
 	entry->skb =3D skb;
=20
-	if (entry->info->hook =3D=3D NF_IP_LOCAL_OUT) {
-		struct ipv6hdr *iph =3D skb->nh.ipv6h;
-
-		entry->rt_info.daddr =3D iph->daddr;
-		entry->rt_info.saddr =3D iph->saddr;
-	}
-
 	nskb =3D ipq_build_packet_message(entry, &status);
 	if (nskb =3D=3D NULL)
 		goto err_out_free;
@@ -382,17 +369,6 @@ ipq_mangle_ipv6(ipq_verdict_msg_t *v, st
 		return -ENOMEM;
 	memcpy(e->skb->data, v->payload, v->data_len);
=20
-	/*
-	 * Extra routing may needed on local out, as the QUEUE target never
-	 * returns control to the table.
-         * Not a nice way to cmp, but works
-	 */
-	if (e->info->hook =3D=3D NF_IP_LOCAL_OUT) {
-		struct ipv6hdr *iph =3D e->skb->nh.ipv6h;
-		if (!ipv6_addr_equal(&iph->daddr, &e->rt_info.daddr) ||
-		    !ipv6_addr_equal(&iph->saddr, &e->rt_info.saddr))
-			return ip6_route_me_harder(e->skb);
-	}
 	return 0;
 }
=20

--jkO+KyKz7TfD21mV--

--jt0yj30bxbg11sci
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC5miRXaXGVTD0i/8RArIeAJ4xtXzrmw5AmOMGrtWXtbxDyDtvxgCggOt8
MUNrDU+qfZTe8hJ2p2zUFSc=
=OE8Y
-----END PGP SIGNATURE-----

--jt0yj30bxbg11sci--
