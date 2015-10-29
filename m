From: Dan Streetman <dan.streetman@canonical.com>
Subject: [PATCHv2] xfrm: dst_entries_init() per-net dst_ops
Date: Thu, 29 Oct 2015 07:29:22 -0400
Message-ID: <1446118162-5385-1-git-send-email-dan.streetman@canonical.com>
References: <1445962519-16133-1-git-send-email-dan.streetman@canonical.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Streetman <dan.streetman@canonical.com>,
	Dan Streetman <ddstreet@ieee.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445962519-16133-1-git-send-email-dan.streetman@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the dst_entries_init/destroy calls for xfrm4 and xfrm6 dst_ops
templates; their dst_entries counters will never be used.  Move the
xfrm dst_ops initialization from the common xfrm/xfrm_policy.c to
xfrm4/xfrm4_policy.c and xfrm6/xfrm6_policy.c, and call dst_entries_init
and dst_entries_destroy for each net namespace.


The ipv4 and ipv6 xfrms each create dst_ops template, and perform
dst_entries_init on the templates.  The template values are copied to each
net namespace's xfrm.xfrm*_dst_ops.  The problem there is the dst_ops
pcpuc_entries field is a percpu counter and cannot be used correctly by
simply copying it to another object.

The result of this is a very subtle bug; changes to the dst entries
counter from one net namespace may sometimes get applied to a different
net namespace dst entries counter.  This is because of how the percpu
counter works; it has a main count field as well as a pointer to the
percpu variables.  Each net namespace maintains its own main count
variable, but all point to one set of percpu variables.  When any net
namespace happens to change one of the percpu variables to outside its
small batch range, its count is moved to the net namespace's main count
variable.  So with multiple net namespaces operating concurrently, the
dst_ops entries counter can stray from the actual value that it should
be; if counts are consistently moved from one net namespace to another
(which my testing showed is likely), then one net namespace winds up
with a negative dst_ops count while another winds up with a continually
increasing count, eventually reaching its gc_thresh limit, which causes
all new traffic on the net namespace to fail with -ENOBUFS.

Signed-off-by: Dan Streetman <dan.streetman@canonical.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
Changes since v1:
 move dst copying and entries_init from xfrm/xfrm_policy into
   ipv[46]/xfrm[46]_policy
 add dst_entries_init and destroy to xfrm[46]_policy pernet init/exit,
   so no for_each_net() is required

 net/ipv4/xfrm4_policy.c | 46 +++++++++++++++++++++++++++++++++---------
 net/ipv6/xfrm6_policy.c | 53 +++++++++++++++++++++++++++++++++++--------------
 net/xfrm/xfrm_policy.c  | 37 ----------------------------------
 3 files changed, 75 insertions(+), 61 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index f2606b9..59ce2b9 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -235,7 +235,7 @@ static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	xfrm_dst_ifdown(dst, dev);
 }
 
-static struct dst_ops xfrm4_dst_ops = {
+static struct dst_ops xfrm4_dst_ops_template = {
 	.family =		AF_INET,
 	.gc =			xfrm4_garbage_collect,
 	.update_pmtu =		xfrm4_update_pmtu,
@@ -249,7 +249,7 @@ static struct dst_ops xfrm4_dst_ops = {
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 	.family = 		AF_INET,
-	.dst_ops =		&xfrm4_dst_ops,
+	.dst_ops =		&xfrm4_dst_ops_template,
 	.dst_lookup =		xfrm4_dst_lookup,
 	.get_saddr =		xfrm4_get_saddr,
 	.decode_session =	_decode_session4,
@@ -271,7 +271,7 @@ static struct ctl_table xfrm4_policy_table[] = {
 	{ }
 };
 
-static int __net_init xfrm4_net_init(struct net *net)
+static int __net_init xfrm4_net_sysctl_init(struct net *net)
 {
 	struct ctl_table *table;
 	struct ctl_table_header *hdr;
@@ -299,7 +299,7 @@ err_alloc:
 	return -ENOMEM;
 }
 
-static void __net_exit xfrm4_net_exit(struct net *net)
+static void __net_exit xfrm4_net_sysctl_exit(struct net *net)
 {
 	struct ctl_table *table;
 
@@ -311,12 +311,44 @@ static void __net_exit xfrm4_net_exit(struct net *net)
 	if (!net_eq(net, &init_net))
 		kfree(table);
 }
+#else /* CONFIG_SYSCTL */
+static int inline xfrm4_net_sysctl_init(struct net *net)
+{
+	return 0;
+}
+
+static void inline xfrm4_net_sysctl_exit(struct net *net)
+{
+}
+#endif
+
+static int __net_init xfrm4_net_init(struct net *net)
+{
+	int ret;
+
+	memcpy(&net->xfrm.xfrm4_dst_ops, &xfrm4_dst_ops_template,
+	       sizeof(xfrm4_dst_ops_template));
+	ret = dst_entries_init(&net->xfrm.xfrm4_dst_ops);
+	if (ret)
+		return ret;
+
+	ret = xfrm4_net_sysctl_init(net);
+	if (ret)
+		dst_entries_destroy(&net->xfrm.xfrm4_dst_ops);
+
+	return ret;
+}
+
+static void __net_exit xfrm4_net_exit(struct net *net)
+{
+	xfrm4_net_sysctl_exit(net);
+	dst_entries_destroy(&net->xfrm.xfrm4_dst_ops);
+}
 
 static struct pernet_operations __net_initdata xfrm4_net_ops = {
 	.init	= xfrm4_net_init,
 	.exit	= xfrm4_net_exit,
 };
-#endif
 
 static void __init xfrm4_policy_init(void)
 {
@@ -325,13 +357,9 @@ static void __init xfrm4_policy_init(void)
 
 void __init xfrm4_init(void)
 {
-	dst_entries_init(&xfrm4_dst_ops);
-
 	xfrm4_state_init();
 	xfrm4_policy_init();
 	xfrm4_protocol_init();
-#ifdef CONFIG_SYSCTL
 	register_pernet_subsys(&xfrm4_net_ops);
-#endif
 }
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 2cc5840..7b0bbb8 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -279,7 +279,7 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	xfrm_dst_ifdown(dst, dev);
 }
 
-static struct dst_ops xfrm6_dst_ops = {
+static struct dst_ops xfrm6_dst_ops_template = {
 	.family =		AF_INET6,
 	.gc =			xfrm6_garbage_collect,
 	.update_pmtu =		xfrm6_update_pmtu,
@@ -293,7 +293,7 @@ static struct dst_ops xfrm6_dst_ops = {
 
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
 	.family =		AF_INET6,
-	.dst_ops =		&xfrm6_dst_ops,
+	.dst_ops =		&xfrm6_dst_ops_template,
 	.dst_lookup =		xfrm6_dst_lookup,
 	.get_saddr =		xfrm6_get_saddr,
 	.decode_session =	_decode_session6,
@@ -325,7 +325,7 @@ static struct ctl_table xfrm6_policy_table[] = {
 	{ }
 };
 
-static int __net_init xfrm6_net_init(struct net *net)
+static int __net_init xfrm6_net_sysctl_init(struct net *net)
 {
 	struct ctl_table *table;
 	struct ctl_table_header *hdr;
@@ -353,7 +353,7 @@ err_alloc:
 	return -ENOMEM;
 }
 
-static void __net_exit xfrm6_net_exit(struct net *net)
+static void __net_exit xfrm6_net_sysctl_exit(struct net *net)
 {
 	struct ctl_table *table;
 
@@ -365,24 +365,52 @@ static void __net_exit xfrm6_net_exit(struct net *net)
 	if (!net_eq(net, &init_net))
 		kfree(table);
 }
+#else /* CONFIG_SYSCTL */
+static int inline xfrm6_net_sysctl_init(struct net *net)
+{
+	return 0;
+}
+
+static void inline xfrm6_net_sysctl_exit(struct net *net)
+{
+}
+#endif
+
+static int __net_init xfrm6_net_init(struct net *net)
+{
+	int ret;
+
+	memcpy(&net->xfrm.xfrm6_dst_ops, &xfrm6_dst_ops_template,
+	       sizeof(xfrm6_dst_ops_template));
+	ret = dst_entries_init(&net->xfrm.xfrm6_dst_ops);
+	if (ret)
+		return ret;
+
+	ret = xfrm6_net_sysctl_init(net);
+	if (ret)
+		dst_entries_destroy(&net->xfrm.xfrm6_dst_ops);
+
+	return ret;
+}
+
+static void __net_exit xfrm6_net_exit(struct net *net)
+{
+	xfrm6_net_sysctl_exit(net);
+	dst_entries_destroy(&net->xfrm.xfrm6_dst_ops);
+}
 
 static struct pernet_operations xfrm6_net_ops = {
 	.init	= xfrm6_net_init,
 	.exit	= xfrm6_net_exit,
 };
-#endif
 
 int __init xfrm6_init(void)
 {
 	int ret;
 
-	dst_entries_init(&xfrm6_dst_ops);
-
 	ret = xfrm6_policy_init();
-	if (ret) {
-		dst_entries_destroy(&xfrm6_dst_ops);
+	if (ret)
 		goto out;
-	}
 	ret = xfrm6_state_init();
 	if (ret)
 		goto out_policy;
@@ -391,9 +419,7 @@ int __init xfrm6_init(void)
 	if (ret)
 		goto out_state;
 
-#ifdef CONFIG_SYSCTL
 	register_pernet_subsys(&xfrm6_net_ops);
-#endif
 out:
 	return ret;
 out_state:
@@ -405,11 +431,8 @@ out_policy:
 
 void xfrm6_fini(void)
 {
-#ifdef CONFIG_SYSCTL
 	unregister_pernet_subsys(&xfrm6_net_ops);
-#endif
 	xfrm6_protocol_fini();
 	xfrm6_policy_fini();
 	xfrm6_state_fini();
-	dst_entries_destroy(&xfrm6_dst_ops);
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 09bfcba..836229c 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2835,26 +2835,6 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 	}
 	spin_unlock(&xfrm_policy_afinfo_lock);
 
-	rtnl_lock();
-	for_each_net(net) {
-		struct dst_ops *xfrm_dst_ops;
-
-		switch (afinfo->family) {
-		case AF_INET:
-			xfrm_dst_ops = &net->xfrm.xfrm4_dst_ops;
-			break;
-#if IS_ENABLED(CONFIG_IPV6)
-		case AF_INET6:
-			xfrm_dst_ops = &net->xfrm.xfrm6_dst_ops;
-			break;
-#endif
-		default:
-			BUG();
-		}
-		*xfrm_dst_ops = *afinfo->dst_ops;
-	}
-	rtnl_unlock();
-
 	return err;
 }
 EXPORT_SYMBOL(xfrm_policy_register_afinfo);
@@ -2890,22 +2870,6 @@ int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
 }
 EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
 
-static void __net_init xfrm_dst_ops_init(struct net *net)
-{
-	struct xfrm_policy_afinfo *afinfo;
-
-	rcu_read_lock();
-	afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET]);
-	if (afinfo)
-		net->xfrm.xfrm4_dst_ops = *afinfo->dst_ops;
-#if IS_ENABLED(CONFIG_IPV6)
-	afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET6]);
-	if (afinfo)
-		net->xfrm.xfrm6_dst_ops = *afinfo->dst_ops;
-#endif
-	rcu_read_unlock();
-}
-
 static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
@@ -3054,7 +3018,6 @@ static int __net_init xfrm_net_init(struct net *net)
 	rv = xfrm_policy_init(net);
 	if (rv < 0)
 		goto out_policy;
-	xfrm_dst_ops_init(net);
 	rv = xfrm_sysctl_init(net);
 	if (rv < 0)
 		goto out_sysctl;
-- 
2.5.0
