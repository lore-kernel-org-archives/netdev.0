From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/2 v2 nf-next] net: bridge: don't register netfilter call_iptables hooks by default
Date: Wed, 17 Sep 2014 17:52:16 +0200
Message-ID: <1410969137-11885-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60644 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755428AbaIQPwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 11:52:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

This adds br_nf_check_calliptables() helper in bridge input before
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

This change can be removed once the default sysctl values
are changed to 0.

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Tested-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v1:
  - don't use mutex for synchronizing vs. work queue (Nik Alexandrov),
  instead use cmpxchg() to ensure only once cpu can register hook.
  - use bool return type since the -ERR values were not used

 net/bridge/br_input.c     | 39 +++++++++++++++++++++++++++++
 net/bridge/br_netfilter.c | 62 +++++++++++++++++++++++++++++++++++++----------
 net/bridge/br_private.h   | 15 ++++++++++++
 3 files changed, 103 insertions(+), 13 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 366c436..874d023 100644
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
@@ -153,6 +158,37 @@ static int br_handle_local_finish(struct sk_buff *skb)
 	return 0;	 /* process further */
 }
 
+static inline bool br_nf_check_calliptables(const struct net_bridge *br)
+{
+#ifdef CONFIG_BRIDGE_NETFILTER
+	bool ip, ip6, arp;
+	int i;
+
+	if (static_key_true(&brnf_hooks_active))
+		return true; /* ok, hooks registered */
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
+	/* rules active and nf_call_iptables is set, need to register
+	 * the required hooks.
+	 */
+	if (i < NF_MAX_HOOKS)
+		return br_netfiler_hooks_init();
+#endif
+	return true; /* also ok: hooks are not needed */
+}
+
 /*
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
@@ -176,6 +212,9 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 
 	p = br_port_get_rcu(skb->dev);
 
+	if (!br_nf_check_calliptables(p->br))
+		goto drop;
+
 	if (unlikely(is_link_local_ether_addr(dest))) {
 		u16 fwd_mask = p->br->group_fwd_mask_required;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a615264..52c410f 100644
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
+static u32 brnf_hooks_loading __read_mostly;
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
@@ -1059,6 +1062,39 @@ static struct ctl_table brnf_table[] = {
 };
 #endif
 
+static void __br_register_hooks_init(struct work_struct *w)
+{
+	int ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+
+	kfree(w);
+
+	if (ret) {
+		WARN_ONCE(ret, "could not register bridge netfilter hook (error %d)",
+										ret);
+		brnf_hooks_loading = 0;
+		return;
+	}
+	static_key_slow_inc(&brnf_hooks_active);
+}
+
+bool br_netfiler_hooks_init(void)
+{
+	struct work_struct *w;
+
+	if (cmpxchg(&brnf_hooks_loading, 0, 1) != 0)
+		return false; /* wq not finished */
+
+	w = kzalloc(sizeof(*w), GFP_ATOMIC);
+	if (!w) {
+		brnf_hooks_loading = 0;
+		return false;
+	}
+
+	INIT_WORK(w, __br_register_hooks_init);
+	schedule_work(w);
+	return false;
+}
+
 int __init br_netfilter_init(void)
 {
 	int ret;
@@ -1067,17 +1103,11 @@ int __init br_netfilter_init(void)
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
@@ -1088,7 +1118,13 @@ int __init br_netfilter_init(void)
 
 void br_netfilter_fini(void)
 {
-	nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	while (brnf_hooks_loading && static_key_false(&brnf_hooks_active)) {
+		pr_info("waiting for hook register wq to finish");
+		schedule();
+	}
+	if (brnf_hooks_loading)
+		nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+
 #ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(brnf_sysctl_header);
 #endif
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 62a7fa2..7b39f0d 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -426,6 +426,10 @@ void br_port_flags_change(struct net_bridge_port *port, unsigned long mask);
 void br_manage_promisc(struct net_bridge *br);
 
 /* br_input.c */
+#ifdef CONFIG_BRIDGE_NETFILTER
+extern struct static_key brnf_hooks_active __read_mostly;
+#endif
+
 int br_handle_frame_finish(struct sk_buff *skb);
 rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
 
@@ -755,6 +759,17 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 int br_netfilter_init(void);
 void br_netfilter_fini(void);
 void br_netfilter_rtable_init(struct net_bridge *);
+bool br_netfiler_hooks_init(void);
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
