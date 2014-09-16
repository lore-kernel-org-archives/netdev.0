From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/2 nf-next] net: bridge: don't register netfilter call_iptables hooks by default
Date: Tue, 16 Sep 2014 17:47:36 +0200
Message-ID: <1410882457-16641-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper reports that kernels with CONFIG_BRIDGE_NETFILTER=n show significantly
better performance vs. CONFIG_BRIDGE_NETFILTER=y, even with
bridge-nf-call-iptables=0.

This is because bridge registers some bridge netfilter hooks at
module load time, so the static key to bypass nf rule evaluation
via NF_HOOK() is false.

The hooks serve no purpose, unless iptables filtering for bridges is
desired (i.e., bridge-nf-call-*=1 and active iptables rules present).

The proper solution would be to just change the bridge-nf-call-iptables sysctl
default value to 0 and then register the hooks when user enables call-iptables
sysctl.  We cannot do that though since it breaks existing setups.

The next best solution is to delay registering of the hooks until
we know that

a) call-iptables sysctl is enabled (this is the default)
AND
b) ip(6)tables rules are loaded.

This adds br_nf_check_call_iptables() helper in bridge input before
bridge 'prerouting' (sic) hooks to perform this check.

IOW, if user does not turn off call-iptables sysctl on the bridge, hook
registering is only done if NFPROTO_IPV4/IPV6 hooks are registered as
well once the first packet arrives on a bridge port.

Doing this check for every packet is still faster than registering
the hooks unconditionally.  To not add overhead for setups where
the call-iptables hooks are required, a static key shortcut is provided.

As its not possible to register hooks from bh context (grabs mutex)
its scheduled via workqueue.

Note that, to not make this overly complicated, the hooks are not
unregistered again when the sysctl is disabled later on.

If user toggles call-iptables sysctl to 0 before adding any ports
to the bridge, those hooks are not registered even if iptables rules
are loaded.

Daniel reports following results for super_netperf/200/TCP_RR:
CONFIG_BRIDGE_NETFILTER=n: ~988k TPS
CONFIG_BRIDGE_NETFILTER=y: ~971k TPS
CONFIG_BRIDGE_NETFILTER=y /w patch: ~988k TPS

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Tested-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br_input.c     | 41 +++++++++++++++++++++++++++++
 net/bridge/br_netfilter.c | 67 ++++++++++++++++++++++++++++++++++++++---------
 net/bridge/br_private.h   | 11 ++++++++
 3 files changed, 106 insertions(+), 13 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 366c436..bd770b7 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -18,6 +18,11 @@
 #include <linux/netfilter_bridge.h>
 #include <linux/export.h>
 #include <linux/rculist.h>
+
+#ifdef CONFIG_BRIDGE_NETFILTER
+#include <linux/jump_label.h>
+#endif
+
 #include "br_private.h"
 
 /* Hook for brouter */
@@ -153,6 +158,39 @@ static int br_handle_local_finish(struct sk_buff *skb)
 	return 0;	 /* process further */
 }
 
+#ifdef CONFIG_BRIDGE_NETFILTER
+extern struct static_key brnf_hooks_active;
+
+static inline int br_nf_check_call_iptables(const struct net_bridge *br)
+{
+	bool ip, ip6, arp;
+	int i;
+
+	if (static_key_true(&brnf_hooks_active))
+		return 0;
+
+	ip  = brnf_call_iptables  || br->nf_call_iptables;
+	ip6 = brnf_call_ip6tables || br->nf_call_ip6tables;
+	arp = brnf_call_arptables || br->nf_call_arptables;
+
+	for (i=0; i < NF_MAX_HOOKS; i++) {
+		if (nf_hooks_active(NFPROTO_IPV4, i) && ip)
+			break;
+		if (nf_hooks_active(NFPROTO_IPV6, i) && ip6)
+			break;
+		if (nf_hooks_active(NFPROTO_ARP, i) && arp)
+			break;
+	}
+
+	if (i < NF_MAX_HOOKS)
+		return br_netfiler_hooks_init();
+
+	return 0;
+}
+#else
+static inline int br_nf_check_call_iptables(const struct net_bridge *br){}
+#endif
+
 /*
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
@@ -176,6 +214,9 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 
 	p = br_port_get_rcu(skb->dev);
 
+	if (br_nf_check_call_iptables(p->br))
+		goto drop;
+
 	if (unlikely(is_link_local_ether_addr(dest))) {
 		u16 fwd_mask = p->br->group_fwd_mask_required;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a615264..c6715a2 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -31,6 +31,8 @@
 #include <linux/netfilter_arp.h>
 #include <linux/in_route.h>
 #include <linux/inetdevice.h>
+#include <linux/workqueue.h>
+#include <linux/jump_label.h>
 
 #include <net/ip.h>
 #include <net/ipv6.h>
@@ -47,18 +49,19 @@
 #define store_orig_dstaddr(skb)	 (skb_origaddr(skb) = ip_hdr(skb)->daddr)
 #define dnat_took_place(skb)	 (skb_origaddr(skb) != ip_hdr(skb)->daddr)
 
+struct static_key brnf_hooks_active __read_mostly;
+static DEFINE_MUTEX(brnf_hook_mutex);
+
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
-static int brnf_call_iptables __read_mostly = 1;
-static int brnf_call_ip6tables __read_mostly = 1;
-static int brnf_call_arptables __read_mostly = 1;
 static int brnf_filter_vlan_tagged __read_mostly = 0;
 static int brnf_filter_pppoe_tagged __read_mostly = 0;
 static int brnf_pass_vlan_indev __read_mostly = 0;
+
+int brnf_call_iptables __read_mostly = 1;
+int brnf_call_ip6tables __read_mostly = 1;
+int brnf_call_arptables __read_mostly = 1;
 #else
-#define brnf_call_iptables 1
-#define brnf_call_ip6tables 1
-#define brnf_call_arptables 1
 #define brnf_filter_vlan_tagged 0
 #define brnf_filter_pppoe_tagged 0
 #define brnf_pass_vlan_indev 0
@@ -1059,6 +1062,45 @@ static struct ctl_table brnf_table[] = {
 };
 #endif
 
+static void __br_register_hooks_init(struct work_struct *w)
+{
+	int ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	if (ret == 0)
+		static_key_slow_inc(&brnf_hooks_active);
+
+	mutex_unlock(&brnf_hook_mutex);
+	kfree(w);
+
+	WARN_ONCE(ret, "could not register bridge netfilter hook (error %d)",
+									ret);
+}
+
+int br_netfiler_hooks_init(void)
+{
+	struct work_struct *w;
+
+	/* called from bh context, cannot sleep */
+	if (!mutex_trylock(&brnf_hook_mutex))
+		return -EBUSY;
+
+	if (static_key_true(&brnf_hooks_active)) {
+		mutex_unlock(&brnf_hook_mutex);
+		return 0;
+	}
+
+	w = kzalloc(sizeof(*w), GFP_ATOMIC);
+	if (!w) {
+		mutex_unlock(&brnf_hook_mutex);
+		return -ENOMEM;
+	}
+
+	INIT_WORK(w, __br_register_hooks_init);
+	schedule_work(w);
+	/* worker will unlock mutex */
+
+	return 0;
+}
+
 int __init br_netfilter_init(void)
 {
 	int ret;
@@ -1067,17 +1109,11 @@ int __init br_netfilter_init(void)
 	if (ret < 0)
 		return ret;
 
-	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
-	if (ret < 0) {
-		dst_entries_destroy(&fake_dst_ops);
-		return ret;
-	}
 #ifdef CONFIG_SYSCTL
 	brnf_sysctl_header = register_net_sysctl(&init_net, "net/bridge", brnf_table);
 	if (brnf_sysctl_header == NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
-		nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
 		dst_entries_destroy(&fake_dst_ops);
 		return -ENOMEM;
 	}
@@ -1088,7 +1124,12 @@ int __init br_netfilter_init(void)
 
 void br_netfilter_fini(void)
 {
-	nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	/* sync with possibly running __br_register_hooks_init() */
+	mutex_lock(&brnf_hook_mutex);
+
+	if (static_key_enabled(&brnf_hooks_active))
+		nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	mutex_unlock(&brnf_hook_mutex);
 #ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(brnf_sysctl_header);
 #endif
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 62a7fa2..e3b80ce 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -755,6 +755,17 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 int br_netfilter_init(void);
 void br_netfilter_fini(void);
 void br_netfilter_rtable_init(struct net_bridge *);
+int br_netfiler_hooks_init(void);
+
+#ifdef CONFIG_SYSCTL
+extern int brnf_call_iptables;
+extern int brnf_call_ip6tables;
+extern int brnf_call_arptables;
+#else
+#define brnf_call_iptables 1
+#define brnf_call_ip6tables 1
+#define brnf_call_arptables 1
+#endif
 #else
 #define br_netfilter_init()	(0)
 #define br_netfilter_fini()	do { } while (0)
-- 
1.8.1.5

