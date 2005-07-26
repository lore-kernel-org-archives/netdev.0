From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] move ip[6]_queue rerouting up to nf_queue
Date: Wed, 27 Jul 2005 01:52:23 +0200
Message-ID: <20050726235223.GD4673@rama.de.gnumonks.org>
References: <20050726164505.GD4279@rama.de.gnumonks.org>
	<20050726.161300.12130036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fmvA4kSBHQVZhkR6"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050726.161300.12130036.davem@davemloft.net>
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


--fmvA4kSBHQVZhkR6
Content-Type: multipart/mixed; boundary="0OWHXb1mYLuhj1Ox"
Content-Disposition: inline


--0OWHXb1mYLuhj1Ox
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 26, 2005 at 04:13:00PM -0700, David S. Miller wrote:

> > please apply.  If you dislike the yet-another-NPROTO nature of it, I'll
> > prepare one with kmalloc-at-startup.
>=20
> Please do, thanks.

See attached file "12-queue-reroute.patch.2". I'll also prepare a
modified version of the nfnetlink module refcounting patch, but I'm not
submitting it until you've applied ll of the other pending netfilter
patches since they would conflict (re-attached the other two pending
patches from earlier today. they apply cleanly on top of the
"12-queue-reroute.patch.2".  "15-nf_info_reroute-fix.patch" is already
included and no longer needed.

Please apply, thanks.

futher BSS-NPROTO-sized-array clanups of old code are following in the
next couple of days.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--0OWHXb1mYLuhj1Ox
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="12-queue-reroute.patch.2"
Content-Transfer-Encoding: quoted-printable

Move reroute-after-queue code from ip_queue and ip6_queue up to the
nf_queue layer.  The rerouting functionality is required by the core,
therefore it has to be implemented by the core and not in individual queue
handlers.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 1cf7694f46449b2602133e0668e53dc4219f73d7
tree 226a89eeb4cb2cd45cfede8106602aa77d95bee1
parent 2b8f1184ff934f6395ca86fd23fc0c2b316532db
author laforge <laforge@netfilter.org> Mi, 27 Jul 2005 01:42:02 +0200
committer laforge <laforge@netfilter.org> Mi, 27 Jul 2005 01:42:02 +0200

 include/linux/netfilter.h      |   11 +++++++
 net/core/netfilter.c           |   66 +++++++++++++++++++++++++++++++++---=
----
 net/ipv4/netfilter.c           |   64 ++++++++++++++++++++++++++++++++++++=
++-
 net/ipv4/netfilter/ip_queue.c  |   27 ----------------
 net/ipv6/af_inet6.c            |    6 ++++
 net/ipv6/netfilter.c           |   62 ++++++++++++++++++++++++++++++++++++=
++
 net/ipv6/netfilter/ip6_queue.c |   24 ---------------
 7 files changed, 195 insertions(+), 65 deletions(-)

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
+#define nf_info_reroute(x) ((void *)x + sizeof(struct nf_info))
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
+static struct nf_queue_rerouter *queue_rerouter;
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
@@ -555,6 +589,12 @@ void __init netfilter_init(void)
 {
 	int i, h;
=20
+	queue_rerouter =3D kmalloc(NPROTO * sizeof(struct nf_queue_rerouter),
+				 GFP_KERNEL);
+	if (!queue_rerouter)
+		panic("netfilter: cannot allocate queue rerouter array\n");
+	memset(queue_rerouter, 0, NPROTO * sizeof(struct nf_queue_rerouter));
+
 	for (i =3D 0; i < NPROTO; i++) {
 		for (h =3D 0; h < NF_MAX_HOOKS; h++)
 			INIT_LIST_HEAD(&nf_hooks[i][h]);
@@ -573,4 +613,6 @@ EXPORT_SYMBOL(nf_reinject);
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

--0OWHXb1mYLuhj1Ox
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="13-multiqueue.patch"
Content-Transfer-Encoding: quoted-printable

netfiler core changes required by upcoming nfnetlink_queue code:
- split netfiler verdict in 16bit verdict and 16bit queue number
- add 'queuenum' argument to nf_queue_outfn_t and its users ip[6]_queue
- move NFNL_SUBSYS_ definitions from enum to #define
- introduce autoloading for nfnetlink subsystem modules
- add MODULE_ALIAS_NFNL_SUBSYS macro
- add nf_unregister_queue_handlers() to register all handlers for a given
  nf_queue_outfn_t
- add more verbose DEBUGP macro definition to nfnetlink.c
- make nfnetlink_subsys_register fail if subsys already exists
- add some more comments and debug statements to nfnetlink.c

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 4557bbef246922e030176404bcf5aa05f9a81d21
tree af907043ed27a6f0ea87326aec9a473c4226be47
parent f61a93c9b4b59f82ef781a50ec955c50fe32e5db
author laforge <laforge@netfilter.org> Di, 26 Jul 2005 18:53:19 +0200
committer laforge <laforge@netfilter.org> Di, 26 Jul 2005 18:53:19 +0200

 include/linux/netfilter.h           |   14 +++++++++++-
 include/linux/netfilter/nfnetlink.h |   20 ++++++++++--------
 net/core/netfilter.c                |   40 +++++++++++++++++++++++++++++--=
----
 net/ipv4/netfilter/ip_queue.c       |    3 ++-
 net/ipv6/netfilter/ip6_queue.c      |    3 ++-
 net/netfilter/nfnetlink.c           |   28 +++++++++++++++++++------
 6 files changed, 83 insertions(+), 25 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -21,6 +21,16 @@
 #define NF_STOP 5
 #define NF_MAX_VERDICT NF_STOP
=20
+/* we overload the higher bits for encoding auxiliary data such as the que=
ue
+ * number. Not nice, but better than additional function arguments. */
+#define NF_VERDICT_MASK 0x0000ffff
+#define NF_VERDICT_BITS 16
+
+#define NF_VERDICT_QMASK 0xffff0000
+#define NF_VERDICT_QBITS 16
+
+#define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK || NF_Q=
UEUE)
+
 /* only for userspace compatibility */
 #ifndef __KERNEL__
 /* Generic cache responses from hook functions.
@@ -179,10 +189,12 @@ int nf_getsockopt(struct sock *sk, int p
=20
 /* Packet queuing */
 typedef int (*nf_queue_outfn_t)(struct sk_buff *skb,=20
-                                struct nf_info *info, void *data);
+                                struct nf_info *info,
+				unsigned int queuenum, void *data);
 extern int nf_register_queue_handler(int pf,=20
                                      nf_queue_outfn_t outfn, void *data);
 extern int nf_unregister_queue_handler(int pf);
+extern void nf_unregister_queue_handlers(nf_queue_outfn_t outfn);
 extern void nf_reinject(struct sk_buff *skb,
 			struct nf_info *info,
 			unsigned int verdict);
diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/=
nfnetlink.h
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -69,15 +69,14 @@ struct nfgenmsg {
 #define NFNL_SUBSYS_ID(x)	((x & 0xff00) >> 8)
 #define NFNL_MSG_TYPE(x)	(x & 0x00ff)
=20
-enum nfnl_subsys_id {
-	NFNL_SUBSYS_NONE =3D 0,
-	NFNL_SUBSYS_CTNETLINK,
-	NFNL_SUBSYS_CTNETLINK_EXP,
-	NFNL_SUBSYS_IPTNETLINK,
-	NFNL_SUBSYS_QUEUE,
-	NFNL_SUBSYS_ULOG,
-	NFNL_SUBSYS_COUNT,
-};
+/* No enum here, otherwise __stringify() trick of MODULE_ALIAS_NFNL_SUBSYS=
()
+ * won't work anymore */
+#define NFNL_SUBSYS_NONE 		0
+#define NFNL_SUBSYS_CTNETLINK		1
+#define NFNL_SUBSYS_CTNETLINK_EXP	2
+#define NFNL_SUBSYS_QUEUE		3
+#define NFNL_SUBSYS_ULOG		4
+#define NFNL_SUBSYS_COUNT		5
=20
 #ifdef __KERNEL__
=20
@@ -142,5 +141,8 @@ extern int nfnetlink_send(struct sk_buff
 			  int echo);
 extern int nfnetlink_unicast(struct sk_buff *skb, u_int32_t pid, int flags=
);
=20
+#define MODULE_ALIAS_NFNL_SUBSYS(subsys) \
+	MODULE_ALIAS("nfnetlink-subsys-" __stringify(subsys))
+
 #endif	/* __KERNEL__ */
 #endif	/* _NFNETLINK_H */
diff --git a/net/core/netfilter.c b/net/core/netfilter.c
--- a/net/core/netfilter.c
+++ b/net/core/netfilter.c
@@ -221,7 +221,8 @@ static unsigned int nf_iterate(struct li
 		verdict =3D elem->hook(hook, skb, indev, outdev, okfn);
 		if (verdict !=3D NF_ACCEPT) {
 #ifdef CONFIG_NETFILTER_DEBUG
-			if (unlikely(verdict > NF_MAX_VERDICT)) {
+			if (unlikely((verdict & NF_VERDICT_MASK)
+							> NF_MAX_VERDICT)) {
 				NFDEBUG("Evil return from %p(%u).\n",
 				        elem->hook, hook);
 				continue;
@@ -239,6 +240,9 @@ int nf_register_queue_handler(int pf, nf
 {     =20
 	int ret;
=20
+	if (pf >=3D NPROTO)
+		return -EINVAL;
+
 	write_lock_bh(&queue_handler_lock);
 	if (queue_handler[pf].outfn)
 		ret =3D -EBUSY;
@@ -255,6 +259,9 @@ int nf_register_queue_handler(int pf, nf
 /* The caller must flush their queue before this */
 int nf_unregister_queue_handler(int pf)
 {
+	if (pf >=3D NPROTO)
+		return -EINVAL;
+
 	write_lock_bh(&queue_handler_lock);
 	queue_handler[pf].outfn =3D NULL;
 	queue_handler[pf].data =3D NULL;
@@ -286,6 +293,20 @@ int nf_unregister_queue_rerouter(int pf)
 	return 0;
 }
=20
+void nf_unregister_queue_handlers(nf_queue_outfn_t outfn)
+{
+	int pf;
+
+	write_lock_bh(&queue_handler_lock);
+	for (pf =3D 0; pf < NPROTO; pf++)  {
+		if (queue_handler[pf].outfn =3D=3D outfn) {
+			queue_handler[pf].outfn =3D NULL;
+			queue_handler[pf].data =3D NULL;
+		}
+	}
+	write_unlock_bh(&queue_handler_lock);
+}
+
 /*=20
  * Any packet that leaves via this function must come back=20
  * through nf_reinject().
@@ -295,7 +316,8 @@ static int nf_queue(struct sk_buff **skb
 		    int pf, unsigned int hook,
 		    struct net_device *indev,
 		    struct net_device *outdev,
-		    int (*okfn)(struct sk_buff *))
+		    int (*okfn)(struct sk_buff *),
+		    unsigned int queuenum)
 {
 	int status;
 	struct nf_info *info;
@@ -347,7 +369,8 @@ static int nf_queue(struct sk_buff **skb
 	if (queue_rerouter[pf].save)
 		queue_rerouter[pf].save(*skb, info);
=20
-	status =3D queue_handler[pf].outfn(*skb, info, queue_handler[pf].data);
+	status =3D queue_handler[pf].outfn(*skb, info, queuenum,
+					 queue_handler[pf].data);
=20
 	if (status >=3D 0 && queue_rerouter[pf].reroute)
 		status =3D queue_rerouter[pf].reroute(skb, info);
@@ -397,9 +420,10 @@ next_hook:
 	} else if (verdict =3D=3D NF_DROP) {
 		kfree_skb(*pskb);
 		ret =3D -EPERM;
-	} else if (verdict =3D=3D NF_QUEUE) {
+	} else if ((verdict & NF_VERDICT_MASK)  =3D=3D NF_QUEUE) {
 		NFDEBUG("nf_hook: Verdict =3D QUEUE.\n");
-		if (!nf_queue(pskb, elem, pf, hook, indev, outdev, okfn))
+		if (!nf_queue(pskb, elem, pf, hook, indev, outdev, okfn,
+			      verdict >> NF_VERDICT_BITS))
 			goto next_hook;
 	}
 unlock:
@@ -456,14 +480,15 @@ void nf_reinject(struct sk_buff *skb, st
 				     info->okfn, INT_MIN);
 	}
=20
-	switch (verdict) {
+	switch (verdict & NF_VERDICT_MASK) {
 	case NF_ACCEPT:
 		info->okfn(skb);
 		break;
=20
 	case NF_QUEUE:
 		if (!nf_queue(&skb, elem, info->pf, info->hook,=20
-			      info->indev, info->outdev, info->okfn))
+			      info->indev, info->outdev, info->okfn,
+			      verdict >> NF_VERDICT_BITS))
 			goto next_hook;
 		break;
 	}
@@ -607,6 +632,7 @@ EXPORT_SYMBOL(nf_reinject);
 EXPORT_SYMBOL(nf_setsockopt);
 EXPORT_SYMBOL(nf_unregister_hook);
 EXPORT_SYMBOL(nf_unregister_queue_handler);
+EXPORT_SYMBOL_GPL(nf_unregister_queue_handlers);
 EXPORT_SYMBOL_GPL(nf_register_queue_rerouter);
 EXPORT_SYMBOL_GPL(nf_unregister_queue_rerouter);
 EXPORT_SYMBOL(nf_unregister_sockopt);
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -274,7 +274,8 @@ nlmsg_failure:
 }
=20
 static int
-ipq_enqueue_packet(struct sk_buff *skb, struct nf_info *info, void *data)
+ipq_enqueue_packet(struct sk_buff *skb, struct nf_info *info,
+		   unsigned int queuenum, void *data)
 {
 	int status =3D -EINVAL;
 	struct sk_buff *nskb;
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -272,7 +272,8 @@ nlmsg_failure:
 }
=20
 static int
-ipq_enqueue_packet(struct sk_buff *skb, struct nf_info *info, void *data)
+ipq_enqueue_packet(struct sk_buff *skb, struct nf_info *info,=20
+		   unsigned int queuenum, void *data)
 {
 	int status =3D -EINVAL;
 	struct sk_buff *nskb;
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -42,7 +42,9 @@ MODULE_LICENSE("GPL");
 static char __initdata nfversion[] =3D "0.30";
=20
 #if 0
-#define DEBUGP printk
+#define DEBUGP(format, args...)	\
+		printk(KERN_DEBUG "%s(%d):%s(): " format, __FILE__, \
+			__LINE__, __FUNCTION__, ## args)
 #else
 #define DEBUGP(format, args...)
 #endif
@@ -65,11 +67,11 @@ int nfnetlink_subsys_register(struct nfn
 {
 	DEBUGP("registering subsystem ID %u\n", n->subsys_id);
=20
-	/* If the netlink socket wasn't created, then fail */
-	if (!nfnl)
-		return -1;
-
 	nfnl_lock();
+	if (subsys_table[n->subsys_id]) {
+		nfnl_unlock();
+		return -EBUSY;
+	}
 	subsys_table[n->subsys_id] =3D n;
 	nfnl_unlock();
=20
@@ -225,8 +227,18 @@ static inline int nfnetlink_rcv_msg(stru
=20
 	type =3D nlh->nlmsg_type;
 	ss =3D nfnetlink_get_subsys(type);
-	if (!ss)
+	if (!ss) {
+#ifdef CONFIG_KMOD
+		/* don't call nfnl_shunlock, since it would reenter
+		 * with further packet processing */
+		up(&nfnl_sem);
+		request_module("nfnetlink-subsys-%d", NFNL_SUBSYS_ID(type));
+		nfnl_shlock();
+		ss =3D nfnetlink_get_subsys(type);
+		if (!ss)
+#endif
 		goto err_inval;
+	}
=20
 	nc =3D nfnetlink_find_client(type, ss);
 	if (!nc) {
@@ -250,12 +262,14 @@ static inline int nfnetlink_rcv_msg(stru
 		if (err < 0)
 			goto err_inval;
=20
+		DEBUGP("calling handler\n");
 		err =3D nc->call(nfnl, skb, nlh, cda, errp);
 		*errp =3D err;
 		return err;
 	}
=20
 err_inval:
+	DEBUGP("returning -EINVAL\n");
 	*errp =3D -EINVAL;
 	return -1;
 }
@@ -309,6 +323,8 @@ static void nfnetlink_rcv(struct sock *s
 			kfree_skb(skb);
 		}
=20
+		/* don't call nfnl_shunlock, since it would reenter
+		 * with further packet processing */
 		up(&nfnl_sem);
 	} while(nfnl && nfnl->sk_receive_queue.qlen);
 }

--0OWHXb1mYLuhj1Ox
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="14-nfnetlink_queue.patch"
Content-Transfer-Encoding: quoted-printable

Add "nfnetlink_queue" netfilter queue handler over nfnetlink:
- Add new nfnetlink_queue module
- Add new ipt_NFQUEUE and ip6t_NFQUEUE modules to access queue numbers 1-65=
535
- Mark ip_queue and ip6_queue Kconfig options as OBSOLETE
- Update feature-removal-schedule to remove ip[6]_queue in December

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 7237f235b6bd25773b566d88ec846245c852b1ee
tree d8bf4d0e82e9f0bdd570d1678f162f6c59d2d361
parent 4557bbef246922e030176404bcf5aa05f9a81d21
author laforge <laforge@netfilter.org> Di, 26 Jul 2005 23:52:26 +0200
committer laforge <laforge@netfilter.org> Di, 26 Jul 2005 23:52:26 +0200

 Documentation/feature-removal-schedule.txt |   12=20
 include/linux/netfilter/nfnetlink_queue.h  |   85 +++
 include/linux/netfilter_ipv4/ipt_NFQUEUE.h |   16 +
 net/ipv4/netfilter/Kconfig                 |    6=20
 net/ipv4/netfilter/Makefile                |    1=20
 net/ipv4/netfilter/ipt_NFQUEUE.c           |   70 ++
 net/ipv6/netfilter/Kconfig                 |   11=20
 net/ipv6/netfilter/Makefile                |    1=20
 net/ipv6/netfilter/ip6t_NFQUEUE.c          |   70 ++
 net/netfilter/Kconfig                      |    8=20
 net/netfilter/Makefile                     |    1=20
 net/netfilter/nfnetlink_queue.c            |  877 ++++++++++++++++++++++++=
++++
 12 files changed, 1153 insertions(+), 5 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/fea=
ture-removal-schedule.txt
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -135,3 +135,15 @@ Why:	With the 16-bit PCMCIA subsystem no
 	pcmciautils package available at
 	http://kernel.org/pub/linux/utils/kernel/pcmcia/
 Who:	Dominik Brodowski <linux@brodo.de>
+
+---------------------------
+
+What:	ip_queue and ip6_queue (old ipv4-only and ipv6-only netfilter queue)
+When:	December 2005
+Why:	This interface has been obsoleted by the new layer3-independent
+	"nfnetlink_queue".  The Kernel interface is compatible, so the old
+	ip[6]tables "QUEUE" targets still work and will transparently handle
+	all packets into nfnetlink queue number 0.  Userspace users will have
+	to link against API-compatible library on top of libnfnetlink_queue=20
+	instead of the current 'libipq'.
+Who:	Harald Welte <laforge@netfilter.org>
diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netf=
ilter/nfnetlink_queue.h
new file mode 100644
--- /dev/null
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -0,0 +1,85 @@
+#ifndef _NFNETLINK_QUEUE_H
+#define _NFNETLINK_QUEUE_H
+
+#include <linux/netfilter/nfnetlink.h>
+
+enum nfqnl_msg_types {
+	NFQNL_MSG_PACKET,		/* packet from kernel to userspace */
+	NFQNL_MSG_VERDICT,		/* verdict from userspace to kernel */
+	NFQNL_MSG_CONFIG,		/* connect to a particular queue */
+
+	NFQNL_MSG_MAX
+};
+
+struct nfqnl_msg_packet_hdr {
+	u_int32_t	packet_id;	/* unique ID of packet in queue */
+	u_int16_t	hw_protocol;	/* hw protocol (network order) */
+	u_int8_t	hook;		/* netfilter hook */
+} __attribute__ ((packed));
+
+struct nfqnl_msg_packet_hw {
+	u_int16_t	hw_addrlen;
+	u_int16_t	_pad;
+	u_int8_t	hw_addr[8];
+} __attribute__ ((packed));
+
+struct nfqnl_msg_packet_timestamp {
+	u_int64_t	sec;
+	u_int64_t	usec;
+} __attribute__ ((packed));
+
+enum nfqnl_attr_type {
+	NFQA_UNSPEC,
+	NFQA_PACKET_HDR,
+	NFQA_VERDICT_HDR,		/* nfqnl_msg_verdict_hrd */
+	NFQA_MARK,			/* u_int32_t nfmark */
+	NFQA_TIMESTAMP,			/* nfqnl_msg_packet_timestamp */
+	NFQA_IFINDEX_INDEV,		/* u_int32_t ifindex */
+	NFQA_IFINDEX_OUTDEV,		/* u_int32_t ifindex */
+	NFQA_HWADDR,			/* nfqnl_msg_packet_hw */
+	NFQA_PAYLOAD,			/* opaque data payload */
+
+	__NFQA_MAX
+};
+#define NFQA_MAX (__NFQA_MAX - 1)
+
+struct nfqnl_msg_verdict_hdr {
+	u_int32_t verdict;
+	u_int32_t id;
+} __attribute__ ((packed));
+
+
+enum nfqnl_msg_config_cmds {
+	NFQNL_CFG_CMD_NONE,
+	NFQNL_CFG_CMD_BIND,
+	NFQNL_CFG_CMD_UNBIND,
+	NFQNL_CFG_CMD_PF_BIND,
+	NFQNL_CFG_CMD_PF_UNBIND,
+};
+
+struct nfqnl_msg_config_cmd {
+	u_int8_t	command;	/* nfqnl_msg_config_cmds */
+	u_int8_t	_pad;
+	u_int16_t	pf;		/* AF_xxx for PF_[UN]BIND */
+} __attribute__ ((packed));
+
+enum nfqnl_config_mode {
+	NFQNL_COPY_NONE,
+	NFQNL_COPY_META,
+	NFQNL_COPY_PACKET,
+};
+
+struct nfqnl_msg_config_params {
+	u_int32_t	copy_range;
+	u_int8_t	copy_mode;	/* enum nfqnl_config_mode */
+} __attribute__ ((packed));
+
+
+enum nfqnl_attr_config {
+	NFQA_CFG_UNSPEC,
+	NFQA_CFG_CMD,			/* nfqnl_msg_config_cmd */
+	NFQA_CFG_PARAMS,		/* nfqnl_msg_config_params */
+	__NFQA_CFG_MAX
+};
+
+#endif /* _NFNETLINK_QUEUE_H */
diff --git a/include/linux/netfilter_ipv4/ipt_NFQUEUE.h b/include/linux/net=
filter_ipv4/ipt_NFQUEUE.h
new file mode 100644
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ipt_NFQUEUE.h
@@ -0,0 +1,16 @@
+/* iptables module for using NFQUEUE mechanism
+ *
+ * (C) 2005 Harald Welte <laforge@netfilter.org>
+ *
+ * This software is distributed under GNU GPL v2, 1991
+ *=20
+*/
+#ifndef _IPT_NFQ_TARGET_H
+#define _IPT_NFQ_TARGET_H
+
+/* target info */
+struct ipt_NFQ_info {
+	u_int16_t queuenum;
+};
+
+#endif /* _IPT_DSCP_TARGET_H */
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -110,11 +110,15 @@ config IP_NF_AMANDA
 	  To compile it as a module, choose M here.  If unsure, say Y.
=20
 config IP_NF_QUEUE
-	tristate "Userspace queueing via NETLINK"
+	tristate "IP Userspace queueing via NETLINK (OBSOLETE)"
 	help
 	  Netfilter has the ability to queue packets to user space: the
 	  netlink device can be used to access them using this driver.
=20
+	  This option enables the old IPv4-only "ip_queue" implementation
+	  which has been obsoleted by the new "nfnetlink_queue" code (see
+	  CONFIG_NETFILTER_NETLINK_QUEUE).
+
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
 config IP_NF_IPTABLES
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -91,3 +91,4 @@ obj-$(CONFIG_IP_NF_ARP_MANGLE) +=3D arpt_m
 obj-$(CONFIG_IP_NF_ARPFILTER) +=3D arptable_filter.o
=20
 obj-$(CONFIG_IP_NF_QUEUE) +=3D ip_queue.o
+obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) +=3D ipt_NFQUEUE.o
diff --git a/net/ipv4/netfilter/ipt_NFQUEUE.c b/net/ipv4/netfilter/ipt_NFQU=
EUE.c
new file mode 100644
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_NFQUEUE.c
@@ -0,0 +1,70 @@
+/* iptables module for using new netfilter netlink queue
+ *
+ * (C) 2005 by Harald Welte <laforge@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as=20
+ * published by the Free Software Foundation.
+ *=20
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv4/ipt_NFQUEUE.h>
+
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("iptables NFQUEUE target");
+MODULE_LICENSE("GPL");
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const void *targinfo,
+       void *userinfo)
+{
+	const struct ipt_NFQ_info *tinfo =3D targinfo;
+
+	return NF_QUEUE_NR(tinfo->queuenum);
+}
+
+static int
+checkentry(const char *tablename,
+	   const struct ipt_entry *e,
+           void *targinfo,
+           unsigned int targinfosize,
+           unsigned int hook_mask)
+{
+	if (targinfosize !=3D IPT_ALIGN(sizeof(struct ipt_NFQ_info))) {
+		printk(KERN_WARNING "NFQUEUE: targinfosize %u !=3D %Zu\n",
+		       targinfosize,
+		       IPT_ALIGN(sizeof(struct ipt_NFQ_info)));
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct ipt_target ipt_NFQ_reg =3D {
+	.name		=3D "NFQUEUE",
+	.target		=3D target,
+	.checkentry	=3D checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	return ipt_register_target(&ipt_NFQ_reg);
+}
+
+static void __exit fini(void)
+{
+	ipt_unregister_target(&ipt_NFQ_reg);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -10,13 +10,16 @@ menu "IPv6: Netfilter Configuration (EXP
 #  dep_tristate '  FTP protocol support' CONFIG_IP6_NF_FTP $CONFIG_IP6_NF_=
CONNTRACK
 #fi
 config IP6_NF_QUEUE
-	tristate "Userspace queueing via NETLINK"
+	tristate "IP6 Userspace queueing via NETLINK (OBSOLETE)"
 	---help---
=20
 	  This option adds a queue handler to the kernel for IPv6
-	  packets which lets us to receive the filtered packets
-	  with QUEUE target using libiptc as we can do with
-	  the IPv4 now.
+	  packets which enables users to receive the filtered packets
+	  with QUEUE target using libipq.
+
+	  THis option enables the old IPv6-only "ip6_queue" implementation
+	  which has been obsoleted by the new "nfnetlink_queue" code (see
+	  CONFIG_NETFILTER_NETLINK_QUEUE).
=20
 	  (C) Fernando Anton 2001
 	  IPv64 Project - Work based in IPv64 draft by Arturo Azcorra.
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -24,3 +24,4 @@ obj-$(CONFIG_IP6_NF_QUEUE) +=3D ip6_queue.
 obj-$(CONFIG_IP6_NF_TARGET_LOG) +=3D ip6t_LOG.o
 obj-$(CONFIG_IP6_NF_RAW) +=3D ip6table_raw.o
 obj-$(CONFIG_IP6_NF_MATCH_HL) +=3D ip6t_hl.o
+obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) +=3D ip6t_NFQUEUE.o
diff --git a/net/ipv6/netfilter/ip6t_NFQUEUE.c b/net/ipv6/netfilter/ip6t_NF=
QUEUE.c
new file mode 100644
--- /dev/null
+++ b/net/ipv6/netfilter/ip6t_NFQUEUE.c
@@ -0,0 +1,70 @@
+/* ip6tables module for using new netfilter netlink queue
+ *
+ * (C) 2005 by Harald Welte <laforge@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as=20
+ * published by the Free Software Foundation.
+ *=20
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <linux/netfilter_ipv4/ipt_NFQUEUE.h>
+
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_DESCRIPTION("ip6tables NFQUEUE target");
+MODULE_LICENSE("GPL");
+
+static unsigned int
+target(struct sk_buff **pskb,
+       const struct net_device *in,
+       const struct net_device *out,
+       unsigned int hooknum,
+       const void *targinfo,
+       void *userinfo)
+{
+	const struct ipt_NFQ_info *tinfo =3D targinfo;
+
+	return NF_QUEUE_NR(tinfo->queuenum);
+}
+
+static int
+checkentry(const char *tablename,
+	   const struct ip6t_entry *e,
+           void *targinfo,
+           unsigned int targinfosize,
+           unsigned int hook_mask)
+{
+	if (targinfosize !=3D IP6T_ALIGN(sizeof(struct ipt_NFQ_info))) {
+		printk(KERN_WARNING "NFQUEUE: targinfosize %u !=3D %Zu\n",
+		       targinfosize,
+		       IP6T_ALIGN(sizeof(struct ipt_NFQ_info)));
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct ip6t_target ipt_NFQ_reg =3D {
+	.name		=3D "NFQUEUE",
+	.target		=3D target,
+	.checkentry	=3D checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	return ip6t_register_target(&ipt_NFQ_reg);
+}
+
+static void __exit fini(void)
+{
+	ip6t_unregister_target(&ipt_NFQ_reg);
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -3,3 +3,11 @@ config NETFILTER_NETLINK
        help
          If this option is enabled, the kernel will include support
          for the new netfilter netlink interface.
+
+config NETFILTER_NETLINK_QUEUE
+	tristate "Netfilter NFQUEUE over NFNETLINK interface"
+	depends on NETFILTER_NETLINK
+	help
+	  If this option isenabled, the kernel will include support
+	  for queueing packets via NFNETLINK.
+	 =20
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -1 +1,2 @@
 obj-$(CONFIG_NETFILTER_NETLINK) +=3D nfnetlink.o
+obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) +=3D nfnetlink_queue.o
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queu=
e.c
new file mode 100644
--- /dev/null
+++ b/net/netfilter/nfnetlink_queue.c
@@ -0,0 +1,877 @@
+/*
+ * This is a module which is used for queueing packets and communicating w=
ith
+ * userspace via nfetlink.
+ *
+ * (C) 2005 by Harald Welte <laforge@netfilter.org>
+ *
+ * Based on the old ipv4-only ip_queue.c:
+ * (C) 2000-2002 James Morris <jmorris@intercode.com.au>
+ * (C) 2003-2005 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <linux/spinlock.h>
+#include <linux/notifier.h>
+#include <linux/netdevice.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_queue.h>
+#include <linux/list.h>
+#include <net/sock.h>
+
+#include <asm/atomic.h>
+
+#define NFQNL_QMAX_DEFAULT 1024
+
+#if 0
+#define QDEBUG(x, args ...)	printk(KERN_DEBUG "%s(%d):%s():	" x, 	   \
+					__FILE__, __LINE__, __FUNCTION__,  \
+					## args)
+#else
+#define QDEBUG(x, ...)
+#endif
+
+struct nfqnl_queue_entry {
+	struct list_head list;
+	struct nf_info *info;
+	struct sk_buff *skb;
+	unsigned int id;
+};
+
+struct nfqnl_instance {
+	struct hlist_node hlist;		/* global list of queues */
+
+	int peer_pid;
+	unsigned int queue_maxlen;
+	unsigned int copy_range;
+	unsigned int queue_total;
+	unsigned int queue_dropped;
+	unsigned int queue_user_dropped;
+
+	atomic_t id_sequence;			/* 'sequence' of pkt ids */
+
+	u_int16_t queue_num;			/* number of this queue */
+	u_int8_t copy_mode;
+
+	spinlock_t lock;
+
+	struct list_head queue_list;		/* packets in queue */
+};
+
+typedef int (*nfqnl_cmpfn)(struct nfqnl_queue_entry *, unsigned long);
+
+static DEFINE_RWLOCK(instances_lock);
+
+u_int64_t htonll(u_int64_t in)
+{
+	u_int64_t out;
+	int i;
+
+	for (i =3D 0; i < sizeof(u_int64_t); i++)
+		((u_int8_t *)&out)[sizeof(u_int64_t)-1] =3D ((u_int8_t *)&in)[i];
+
+	return out;
+}
+
+#define INSTANCE_BUCKETS	16
+static struct hlist_head instance_table[INSTANCE_BUCKETS];
+
+static inline u_int8_t instance_hashfn(u_int16_t queue_num)
+{
+	return ((queue_num >> 8) | queue_num) % INSTANCE_BUCKETS;
+}
+
+static struct nfqnl_instance *
+__instance_lookup(u_int16_t queue_num)
+{
+	struct hlist_head *head;
+	struct hlist_node *pos;
+	struct nfqnl_instance *inst;
+
+	head =3D &instance_table[instance_hashfn(queue_num)];
+	hlist_for_each_entry(inst, pos, head, hlist) {
+		if (inst->queue_num =3D=3D queue_num)
+			return inst;
+	}
+	return NULL;
+}
+
+static struct nfqnl_instance *
+instance_lookup(u_int16_t queue_num)
+{
+	struct nfqnl_instance *inst;
+
+	read_lock_bh(&instances_lock);
+	inst =3D __instance_lookup(queue_num);
+	read_unlock_bh(&instances_lock);
+
+	return inst;
+}
+
+static struct nfqnl_instance *
+instance_create(u_int16_t queue_num, int pid)
+{
+	struct nfqnl_instance *inst;
+
+	QDEBUG("entering for queue_num=3D%u, pid=3D%d\n", queue_num, pid);
+
+	write_lock_bh(&instances_lock);=09
+	if (__instance_lookup(queue_num)) {
+		inst =3D NULL;
+		QDEBUG("aborting, instance already exists\n");
+		goto out_unlock;
+	}
+
+	inst =3D kmalloc(sizeof(*inst), GFP_ATOMIC);
+	if (!inst)
+		goto out_unlock;
+
+	memset(inst, 0, sizeof(*inst));
+	inst->queue_num =3D queue_num;
+	inst->peer_pid =3D pid;
+	inst->queue_maxlen =3D NFQNL_QMAX_DEFAULT;
+	inst->copy_range =3D 0xfffff;
+	inst->copy_mode =3D NFQNL_COPY_NONE;
+	atomic_set(&inst->id_sequence, 0);
+	inst->lock =3D SPIN_LOCK_UNLOCKED;
+	INIT_LIST_HEAD(&inst->queue_list);
+
+	if (!try_module_get(THIS_MODULE))
+		goto out_free;
+
+	hlist_add_head(&inst->hlist,=20
+		       &instance_table[instance_hashfn(queue_num)]);
+
+	write_unlock_bh(&instances_lock);
+
+	QDEBUG("successfully created new instance\n");
+
+	return inst;
+
+out_free:
+	kfree(inst);
+out_unlock:
+	write_unlock_bh(&instances_lock);
+	return NULL;
+}
+
+static void nfqnl_flush(struct nfqnl_instance *queue, int verdict);
+
+static void
+_instance_destroy2(struct nfqnl_instance *inst, int lock)
+{
+	/* first pull it out of the global list */
+	if (lock)
+		write_lock_bh(&instances_lock);
+
+	QDEBUG("removing instance %p (queuenum=3D%u) from hash\n",
+		inst, inst->queue_num);
+	hlist_del(&inst->hlist);
+
+	if (lock)
+		write_unlock_bh(&instances_lock);
+
+	/* then flush all pending skbs from the queue */
+	nfqnl_flush(inst, NF_DROP);
+
+	/* and finally free the data structure */
+	kfree(inst);
+
+	module_put(THIS_MODULE);
+}
+
+static inline void
+__instance_destroy(struct nfqnl_instance *inst)
+{
+	_instance_destroy2(inst, 0);
+}
+
+static inline void
+instance_destroy(struct nfqnl_instance *inst)
+{
+	_instance_destroy2(inst, 1);
+}
+
+
+
+static void
+issue_verdict(struct nfqnl_queue_entry *entry, int verdict)
+{
+	QDEBUG("entering for entry %p, verdict %u\n", entry, verdict);
+
+	/* TCP input path (and probably other bits) assume to be called
+	 * from softirq context, not from syscall, like issue_verdict is
+	 * called.  TCP input path deadlocks with locks taken from timer
+	 * softirq, e.g.  We therefore emulate this by local_bh_disable() */
+
+	local_bh_disable();
+	nf_reinject(entry->skb, entry->info, verdict);
+	local_bh_enable();
+
+	kfree(entry);
+}
+
+static inline void
+__enqueue_entry(struct nfqnl_instance *queue,
+		      struct nfqnl_queue_entry *entry)
+{
+       list_add(&entry->list, &queue->queue_list);
+       queue->queue_total++;
+}
+
+/*
+ * Find and return a queued entry matched by cmpfn, or return the last
+ * entry if cmpfn is NULL.
+ */
+static inline struct nfqnl_queue_entry *
+__find_entry(struct nfqnl_instance *queue, nfqnl_cmpfn cmpfn,=20
+		   unsigned long data)
+{
+	struct list_head *p;
+
+	list_for_each_prev(p, &queue->queue_list) {
+		struct nfqnl_queue_entry *entry =3D (struct nfqnl_queue_entry *)p;
+	=09
+		if (!cmpfn || cmpfn(entry, data))
+			return entry;
+	}
+	return NULL;
+}
+
+static inline void
+__dequeue_entry(struct nfqnl_instance *q, struct nfqnl_queue_entry *entry)
+{
+	list_del(&entry->list);
+	q->queue_total--;
+}
+
+static inline struct nfqnl_queue_entry *
+__find_dequeue_entry(struct nfqnl_instance *queue,
+		     nfqnl_cmpfn cmpfn, unsigned long data)
+{
+	struct nfqnl_queue_entry *entry;
+
+	entry =3D __find_entry(queue, cmpfn, data);
+	if (entry =3D=3D NULL)
+		return NULL;
+
+	__dequeue_entry(queue, entry);
+	return entry;
+}
+
+
+static inline void
+__nfqnl_flush(struct nfqnl_instance *queue, int verdict)
+{
+	struct nfqnl_queue_entry *entry;
+=09
+	while ((entry =3D __find_dequeue_entry(queue, NULL, 0)))
+		issue_verdict(entry, verdict);
+}
+
+static inline int
+__nfqnl_set_mode(struct nfqnl_instance *queue,
+		 unsigned char mode, unsigned int range)
+{
+	int status =3D 0;
+=09
+	switch (mode) {
+	case NFQNL_COPY_NONE:
+	case NFQNL_COPY_META:
+		queue->copy_mode =3D mode;
+		queue->copy_range =3D 0;
+		break;
+	=09
+	case NFQNL_COPY_PACKET:
+		queue->copy_mode =3D mode;
+		/* we're using struct nfattr which has 16bit nfa_len */
+		if (range > 0xffff)
+			queue->copy_range =3D 0xffff;
+		else
+			queue->copy_range =3D range;
+		break;
+	=09
+	default:
+		status =3D -EINVAL;
+
+	}
+	return status;
+}
+
+static struct nfqnl_queue_entry *
+find_dequeue_entry(struct nfqnl_instance *queue,
+			 nfqnl_cmpfn cmpfn, unsigned long data)
+{
+	struct nfqnl_queue_entry *entry;
+=09
+	spin_lock_bh(&queue->lock);
+	entry =3D __find_dequeue_entry(queue, cmpfn, data);
+	spin_unlock_bh(&queue->lock);
+
+	return entry;
+}
+
+static void
+nfqnl_flush(struct nfqnl_instance *queue, int verdict)
+{
+	spin_lock_bh(&queue->lock);
+	__nfqnl_flush(queue, verdict);
+	spin_unlock_bh(&queue->lock);
+}
+
+static struct sk_buff *
+nfqnl_build_packet_message(struct nfqnl_instance *queue,
+			   struct nfqnl_queue_entry *entry, int *errp)
+{
+	unsigned char *old_tail;
+	size_t size;
+	size_t data_len =3D 0;
+	struct sk_buff *skb;
+	struct nfqnl_msg_packet_hdr pmsg;
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	unsigned int tmp_uint;
+
+	QDEBUG("entered\n");
+
+	/* all macros expand to constant values at compile time */
+	size =3D    NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_hdr))
+		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
+		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
+		+ NLMSG_SPACE(sizeof(u_int32_t))	/* mark */
+		+ NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_hw))
+		+ NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_timestamp));
+
+	spin_lock_bh(&queue->lock);
+=09
+	switch (queue->copy_mode) {
+	case NFQNL_COPY_META:
+	case NFQNL_COPY_NONE:
+		data_len =3D 0;
+		break;
+=09
+	case NFQNL_COPY_PACKET:
+		if (queue->copy_range =3D=3D 0=20
+		    || queue->copy_range > entry->skb->len)
+			data_len =3D entry->skb->len;
+		else
+			data_len =3D queue->copy_range;
+	=09
+		size +=3D NLMSG_SPACE(data_len);
+		break;
+=09
+	default:
+		*errp =3D -EINVAL;
+		spin_unlock_bh(&queue->lock);
+		return NULL;
+	}
+
+	spin_unlock_bh(&queue->lock);
+
+	skb =3D alloc_skb(size, GFP_ATOMIC);
+	if (!skb)
+		goto nlmsg_failure;
+	=09
+	old_tail=3D skb->tail;
+	nlh =3D NLMSG_PUT(skb, 0, 0,=20
+			NFNL_SUBSYS_QUEUE << 8 | NFQNL_MSG_PACKET,
+			sizeof(struct nfgenmsg));
+	nfmsg =3D NLMSG_DATA(nlh);
+	nfmsg->nfgen_family =3D entry->info->pf;
+	nfmsg->version =3D NFNETLINK_V0;
+	nfmsg->res_id =3D htons(queue->queue_num);
+
+	pmsg.packet_id 		=3D htonl(entry->id);
+	pmsg.hw_protocol	=3D htons(entry->skb->protocol);
+	pmsg.hook		=3D entry->info->hook;
+
+	NFA_PUT(skb, NFQA_PACKET_HDR, sizeof(pmsg), &pmsg);
+
+	if (entry->info->indev) {
+		tmp_uint =3D htonl(entry->info->indev->ifindex);
+		NFA_PUT(skb, NFQA_IFINDEX_INDEV, sizeof(tmp_uint), &tmp_uint);
+	}
+
+	if (entry->info->outdev) {
+		tmp_uint =3D htonl(entry->info->outdev->ifindex);
+		NFA_PUT(skb, NFQA_IFINDEX_OUTDEV, sizeof(tmp_uint), &tmp_uint);
+	}
+
+	if (entry->skb->nfmark) {
+		tmp_uint =3D htonl(entry->skb->nfmark);
+		NFA_PUT(skb, NFQA_MARK, sizeof(u_int32_t), &tmp_uint);
+	}
+
+	if (entry->info->indev && entry->skb->dev
+	    && entry->skb->dev->hard_header_parse) {
+		struct nfqnl_msg_packet_hw phw;
+
+		phw.hw_addrlen =3D
+			entry->skb->dev->hard_header_parse(entry->skb,
+			                                   phw.hw_addr);
+		phw.hw_addrlen =3D htons(phw.hw_addrlen);
+		NFA_PUT(skb, NFQA_HWADDR, sizeof(phw), &phw);
+	}
+
+	if (entry->skb->stamp.tv_sec) {
+		struct nfqnl_msg_packet_timestamp ts;
+
+		ts.sec =3D htonll(entry->skb->stamp.tv_sec);
+		ts.usec =3D htonll(entry->skb->stamp.tv_usec);
+
+		NFA_PUT(skb, NFQA_TIMESTAMP, sizeof(ts), &ts);
+	}
+
+	if (data_len) {
+		struct nfattr *nfa;
+		int size =3D NFA_LENGTH(data_len);
+
+		if (skb_tailroom(skb) < (int)NFA_SPACE(data_len)) {
+			printk(KERN_WARNING "nf_queue: no tailroom!\n");
+			goto nlmsg_failure;
+		}
+
+		nfa =3D (struct nfattr *)skb_put(skb, NFA_ALIGN(size));
+		nfa->nfa_type =3D NFQA_PAYLOAD;
+		nfa->nfa_len =3D size;
+
+		if (skb_copy_bits(entry->skb, 0, NFA_DATA(nfa), data_len))
+			BUG();
+	}
+	=09
+	nlh->nlmsg_len =3D skb->tail - old_tail;
+	return skb;
+
+nlmsg_failure:
+nfattr_failure:
+	if (skb)
+		kfree_skb(skb);
+	*errp =3D -EINVAL;
+	if (net_ratelimit())
+		printk(KERN_ERR "nf_queue: error creating packet message\n");
+	return NULL;
+}
+
+static int
+nfqnl_enqueue_packet(struct sk_buff *skb, struct nf_info *info,=20
+		     unsigned int queuenum, void *data)
+{
+	int status =3D -EINVAL;
+	struct sk_buff *nskb;
+	struct nfqnl_instance *queue;
+	struct nfqnl_queue_entry *entry;
+
+	QDEBUG("entered\n");
+
+	queue =3D instance_lookup(queuenum);
+	if (!queue) {
+		QDEBUG("no queue instance matching\n");
+		return -EINVAL;
+	}
+
+	if (queue->copy_mode =3D=3D NFQNL_COPY_NONE) {
+		QDEBUG("mode COPY_NONE, aborting\n");
+		return -EAGAIN;
+	}
+
+	entry =3D kmalloc(sizeof(*entry), GFP_ATOMIC);
+	if (entry =3D=3D NULL) {
+		if (net_ratelimit())
+			printk(KERN_ERR=20
+				"nf_queue: OOM in nfqnl_enqueue_packet()\n");
+		return -ENOMEM;
+	}
+
+	entry->info =3D info;
+	entry->skb =3D skb;
+	entry->id =3D atomic_inc_return(&queue->id_sequence);
+
+	nskb =3D nfqnl_build_packet_message(queue, entry, &status);
+	if (nskb =3D=3D NULL)
+		goto err_out_free;
+	=09
+	spin_lock_bh(&queue->lock);
+=09
+	if (!queue->peer_pid)
+		goto err_out_free_nskb;=20
+
+	if (queue->queue_total >=3D queue->queue_maxlen) {
+                queue->queue_dropped++;
+		status =3D -ENOSPC;
+		if (net_ratelimit())
+		          printk(KERN_WARNING "ip_queue: full at %d entries, "
+				 "dropping packets(s). Dropped: %d\n",=20
+				 queue->queue_total, queue->queue_dropped);
+		goto err_out_free_nskb;
+	}
+
+	/* nfnetlink_unicast will either free the nskb or add it to a socket */
+	status =3D nfnetlink_unicast(nskb, queue->peer_pid, MSG_DONTWAIT);
+	if (status < 0) {
+	        queue->queue_user_dropped++;
+		goto err_out_unlock;
+	}
+
+	__enqueue_entry(queue, entry);
+
+	spin_unlock_bh(&queue->lock);
+	return status;
+
+err_out_free_nskb:
+	kfree_skb(nskb);=20
+=09
+err_out_unlock:
+	spin_unlock_bh(&queue->lock);
+
+err_out_free:
+	kfree(entry);
+	return status;
+}
+
+static int
+nfqnl_mangle(void *data, int data_len, struct nfqnl_queue_entry *e)
+{
+	int diff;
+
+	diff =3D data_len - e->skb->len;
+	if (diff < 0)
+		skb_trim(e->skb, data_len);
+	else if (diff > 0) {
+		if (data_len > 0xFFFF)
+			return -EINVAL;
+		if (diff > skb_tailroom(e->skb)) {
+			struct sk_buff *newskb;
+		=09
+			newskb =3D skb_copy_expand(e->skb,
+			                         skb_headroom(e->skb),
+			                         diff,
+			                         GFP_ATOMIC);
+			if (newskb =3D=3D NULL) {
+				printk(KERN_WARNING "ip_queue: OOM "
+				      "in mangle, dropping packet\n");
+				return -ENOMEM;
+			}
+			if (e->skb->sk)
+				skb_set_owner_w(newskb, e->skb->sk);
+			kfree_skb(e->skb);
+			e->skb =3D newskb;
+		}
+		skb_put(e->skb, diff);
+	}
+	if (!skb_make_writable(&e->skb, data_len))
+		return -ENOMEM;
+	memcpy(e->skb->data, data, data_len);
+
+	return 0;
+}
+
+static inline int
+id_cmp(struct nfqnl_queue_entry *e, unsigned long id)
+{
+	return (id =3D=3D e->id);
+}
+
+static int
+nfqnl_set_mode(struct nfqnl_instance *queue,
+	       unsigned char mode, unsigned int range)
+{
+	int status;
+
+	spin_lock_bh(&queue->lock);
+	status =3D __nfqnl_set_mode(queue, mode, range);
+	spin_unlock_bh(&queue->lock);
+
+	return status;
+}
+
+static int
+dev_cmp(struct nfqnl_queue_entry *entry, unsigned long ifindex)
+{
+	if (entry->info->indev)
+		if (entry->info->indev->ifindex =3D=3D ifindex)
+			return 1;
+		=09
+	if (entry->info->outdev)
+		if (entry->info->outdev->ifindex =3D=3D ifindex)
+			return 1;
+
+	return 0;
+}
+
+/* drop all packets with either indev or outdev =3D=3D ifindex from all qu=
eue
+ * instances */
+static void
+nfqnl_dev_drop(int ifindex)
+{
+	int i;
+=09
+	QDEBUG("entering for ifindex %u\n", ifindex);
+
+	/* this only looks like we have to hold the readlock for a way too long
+	 * time, issue_verdict(),  nf_reinject(), ... - but we always only
+	 * issue NF_DROP, which is processed directly in nf_reinject() */
+	read_lock_bh(&instances_lock);
+
+	for  (i =3D 0; i < INSTANCE_BUCKETS; i++) {
+		struct hlist_node *tmp;
+		struct nfqnl_instance *inst;
+		struct hlist_head *head =3D &instance_table[i];
+
+		hlist_for_each_entry(inst, tmp, head, hlist) {
+			struct nfqnl_queue_entry *entry;
+			while ((entry =3D find_dequeue_entry(inst, dev_cmp,=20
+							   ifindex)) !=3D NULL)
+				issue_verdict(entry, NF_DROP);
+		}
+	}
+
+	read_unlock_bh(&instances_lock);
+}
+
+#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } whi=
le (0)
+
+static int
+nfqnl_rcv_dev_event(struct notifier_block *this,
+		    unsigned long event, void *ptr)
+{
+	struct net_device *dev =3D ptr;
+
+	/* Drop any packets associated with the downed device */
+	if (event =3D=3D NETDEV_DOWN)
+		nfqnl_dev_drop(dev->ifindex);
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block nfqnl_dev_notifier =3D {
+	.notifier_call	=3D nfqnl_rcv_dev_event,
+};
+
+static int
+nfqnl_rcv_nl_event(struct notifier_block *this,
+		   unsigned long event, void *ptr)
+{
+	struct netlink_notify *n =3D ptr;
+
+	if (event =3D=3D NETLINK_URELEASE &&
+	    n->protocol =3D=3D NETLINK_NETFILTER && n->pid) {
+		int i;
+
+		/* destroy all instances for this pid */
+		write_lock_bh(&instances_lock);
+		for  (i =3D 0; i < INSTANCE_BUCKETS; i++) {
+			struct hlist_node *tmp, *t2;
+			struct nfqnl_instance *inst;
+			struct hlist_head *head =3D &instance_table[i];
+
+			hlist_for_each_entry_safe(inst, tmp, t2, head, hlist) {
+				if (n->pid =3D=3D inst->peer_pid)
+					__instance_destroy(inst);
+			}
+		}
+		write_unlock_bh(&instances_lock);
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block nfqnl_rtnl_notifier =3D {
+	.notifier_call	=3D nfqnl_rcv_nl_event,
+};
+
+static int
+nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
+		   struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
+{
+	struct nfgenmsg *nfmsg =3D NLMSG_DATA(nlh);
+	u_int16_t queue_num =3D ntohs(nfmsg->res_id);
+
+	struct nfqnl_msg_verdict_hdr *vhdr;
+	struct nfqnl_instance *queue;
+	unsigned int verdict;
+	struct nfqnl_queue_entry *entry;
+
+	queue =3D instance_lookup(queue_num);
+	if (!queue)
+		return -ENODEV;
+
+	if (queue->peer_pid !=3D NETLINK_CB(skb).pid)
+		return -EPERM;
+
+	if (!nfqa[NFQA_VERDICT_HDR-1])
+		return -EINVAL;
+
+	vhdr =3D NFA_DATA(nfqa[NFQA_VERDICT_HDR-1]);
+	verdict =3D ntohl(vhdr->verdict);
+
+	if ((verdict & NF_VERDICT_MASK) > NF_MAX_VERDICT)
+		return -EINVAL;
+
+	entry =3D find_dequeue_entry(queue, id_cmp, ntohl(vhdr->id));
+	if (entry =3D=3D NULL)
+		return -ENOENT;
+
+	if (nfqa[NFQA_PAYLOAD-1]) {
+		if (nfqnl_mangle(NFA_DATA(nfqa[NFQA_PAYLOAD-1]),
+				 NFA_PAYLOAD(nfqa[NFQA_PAYLOAD-1]), entry) < 0)
+			verdict =3D NF_DROP;
+	}
+
+	if (nfqa[NFQA_MARK-1])
+		skb->nfmark =3D ntohl(*(u_int32_t *)NFA_DATA(nfqa[NFQA_MARK-1]));
+	=09
+	issue_verdict(entry, verdict);
+	return 0;
+}
+
+static int
+nfqnl_recv_unsupp(struct sock *ctnl, struct sk_buff *skb,
+		  struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
+{
+	return -ENOTSUPP;
+}
+
+static int
+nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
+		  struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
+{
+	struct nfgenmsg *nfmsg =3D NLMSG_DATA(nlh);
+	u_int16_t queue_num =3D ntohs(nfmsg->res_id);
+	struct nfqnl_instance *queue;
+
+	QDEBUG("entering for msg %u\n", NFNL_MSG_TYPE(nlh->nlmsg_type));
+
+	queue =3D instance_lookup(queue_num);
+	if (nfqa[NFQA_CFG_CMD-1]) {
+		struct nfqnl_msg_config_cmd *cmd;
+		cmd =3D NFA_DATA(nfqa[NFQA_CFG_CMD-1]);
+		QDEBUG("found CFG_CMD\n");
+
+		switch (cmd->command) {
+		case NFQNL_CFG_CMD_BIND:
+			if (queue)
+				return -EBUSY;
+
+			queue =3D instance_create(queue_num, NETLINK_CB(skb).pid);
+			if (!queue)
+				return -EINVAL;
+			break;
+		case NFQNL_CFG_CMD_UNBIND:
+			if (!queue)
+				return -ENODEV;
+
+			if (queue->peer_pid !=3D NETLINK_CB(skb).pid)
+				return -EPERM;
+
+			instance_destroy(queue);
+			break;
+		case NFQNL_CFG_CMD_PF_BIND:
+			QDEBUG("registering queue handler for pf=3D%u\n",
+				ntohs(cmd->pf));
+			return nf_register_queue_handler(ntohs(cmd->pf),
+							 nfqnl_enqueue_packet,
+							 NULL);
+
+			break;
+		case NFQNL_CFG_CMD_PF_UNBIND:
+			QDEBUG("unregistering queue handler for pf=3D%u\n",
+				ntohs(cmd->pf));
+			/* This is a bug and a feature.  We can unregister
+			 * other handlers(!) */
+			return nf_unregister_queue_handler(ntohs(cmd->pf));
+			break;
+		default:
+			return -EINVAL;
+		}
+	} else {
+		if (!queue) {
+			QDEBUG("no config command, and no instance ENOENT\n");
+			return -ENOENT;
+		}
+
+		if (queue->peer_pid !=3D NETLINK_CB(skb).pid) {
+			QDEBUG("no config command, and wrong pid\n");
+			return -EPERM;
+		}
+	}
+
+	if (nfqa[NFQA_CFG_PARAMS-1]) {
+		struct nfqnl_msg_config_params *params;
+		params =3D NFA_DATA(nfqa[NFQA_CFG_PARAMS-1]);
+
+		nfqnl_set_mode(queue, params->copy_mode,
+				ntohl(params->copy_range));
+	}
+
+	return 0;
+}
+
+static struct nfnl_callback nfqnl_cb[NFQNL_MSG_MAX] =3D {
+	[NFQNL_MSG_PACKET]	=3D { .call =3D nfqnl_recv_unsupp,
+				    .cap_required =3D CAP_NET_ADMIN },
+	[NFQNL_MSG_VERDICT]	=3D { .call =3D nfqnl_recv_verdict,
+				    .cap_required =3D CAP_NET_ADMIN },
+	[NFQNL_MSG_CONFIG]	=3D { .call =3D nfqnl_recv_config,
+				    .cap_required =3D CAP_NET_ADMIN },
+};
+
+static struct nfnetlink_subsystem nfqnl_subsys =3D {
+	.name		=3D "nf_queue",
+	.subsys_id	=3D NFNL_SUBSYS_QUEUE,
+	.cb_count	=3D NFQNL_MSG_MAX,
+	.attr_count	=3D NFQA_MAX,
+	.cb		=3D nfqnl_cb,
+};
+
+static int
+init_or_cleanup(int init)
+{
+	int status =3D -ENOMEM;
+=09
+	if (!init)
+		goto cleanup;
+
+	netlink_register_notifier(&nfqnl_rtnl_notifier);
+	status =3D nfnetlink_subsys_register(&nfqnl_subsys);
+	if (status < 0) {
+		printk(KERN_ERR "nf_queue: failed to create netlink socket\n");
+		goto cleanup_netlink_notifier;
+	}
+
+	register_netdevice_notifier(&nfqnl_dev_notifier);
+	return status;
+
+cleanup:
+	nf_unregister_queue_handlers(nfqnl_enqueue_packet);
+	unregister_netdevice_notifier(&nfqnl_dev_notifier);
+	nfnetlink_subsys_unregister(&nfqnl_subsys);
+=09
+cleanup_netlink_notifier:
+	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
+	return status;
+}
+
+static int __init init(void)
+{
+=09
+	return init_or_cleanup(1);
+}
+
+static void __exit fini(void)
+{
+	init_or_cleanup(0);
+}
+
+MODULE_DESCRIPTION("netfilter packet queue handler");
+MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_QUEUE);
+
+module_init(init);
+module_exit(fini);

--0OWHXb1mYLuhj1Ox--

--fmvA4kSBHQVZhkR6
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC5sy2XaXGVTD0i/8RAg7rAJ9Ol54Uh26CkpkBp6bgSIj8PGAbSQCgj1re
Os7l+alEmxeb+ypBBiEiGr4=
=y4rf
-----END PGP SIGNATURE-----

--fmvA4kSBHQVZhkR6--
