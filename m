From: kaber@trash.net
Subject: [PATCH 23/72] IPVS: management of persistence engine modules
Date: Thu, 21 Oct 2010 17:19:10 +0200
Message-ID: <1287674399-31455-24-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

This is based heavily on the scheduler management code

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h           |    6 ++
 net/netfilter/ipvs/Makefile   |    2 +-
 net/netfilter/ipvs/ip_vs_pe.c |  147 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 154 insertions(+), 1 deletions(-)
 create mode 100644 net/netfilter/ipvs/ip_vs_pe.c

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 974daf5..a6b93a2 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -796,6 +796,12 @@ extern int ip_vs_app_pkt_in(struct ip_vs_conn *, struct sk_buff *skb);
 extern int ip_vs_app_init(void);
 extern void ip_vs_app_cleanup(void);
 
+void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe);
+void ip_vs_unbind_pe(struct ip_vs_service *svc);
+int register_ip_vs_pe(struct ip_vs_pe *pe);
+int unregister_ip_vs_pe(struct ip_vs_pe *pe);
+extern struct ip_vs_pe *ip_vs_pe_get(const char *name);
+extern void ip_vs_pe_put(struct ip_vs_pe *pe);
 
 /*
  *	IPVS protocol functions (from ip_vs_proto.c)
diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
index 349fe88..4a87bf3 100644
--- a/net/netfilter/ipvs/Makefile
+++ b/net/netfilter/ipvs/Makefile
@@ -14,7 +14,7 @@ ip_vs-extra_objs-$(CONFIG_IP_VS_NFCT) += ip_vs_nfct.o
 
 ip_vs-objs :=	ip_vs_conn.o ip_vs_core.o ip_vs_ctl.o ip_vs_sched.o	   \
 		ip_vs_xmit.o ip_vs_app.o ip_vs_sync.o	   		   \
-		ip_vs_est.o ip_vs_proto.o 				   \
+		ip_vs_est.o ip_vs_proto.o ip_vs_pe.o			   \
 		$(ip_vs_proto-objs-y) $(ip_vs-extra_objs-y)
 
 
diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
new file mode 100644
index 0000000..3414af7
--- /dev/null
+++ b/net/netfilter/ipvs/ip_vs_pe.c
@@ -0,0 +1,147 @@
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/module.h>
+#include <linux/spinlock.h>
+#include <linux/interrupt.h>
+#include <asm/string.h>
+#include <linux/kmod.h>
+#include <linux/sysctl.h>
+
+#include <net/ip_vs.h>
+
+/* IPVS pe list */
+static LIST_HEAD(ip_vs_pe);
+
+/* lock for service table */
+static DEFINE_SPINLOCK(ip_vs_pe_lock);
+
+/* Bind a service with a pe */
+void ip_vs_bind_pe(struct ip_vs_service *svc, struct ip_vs_pe *pe)
+{
+	svc->pe = pe;
+}
+
+/* Unbind a service from its pe */
+void ip_vs_unbind_pe(struct ip_vs_service *svc)
+{
+	svc->pe = NULL;
+}
+
+/* Get pe in the pe list by name */
+static struct ip_vs_pe *
+ip_vs_pe_getbyname(const char *pe_name)
+{
+	struct ip_vs_pe *pe;
+
+	IP_VS_DBG(2, "%s(): pe_name \"%s\"\n", __func__,
+		  pe_name);
+
+	spin_lock_bh(&ip_vs_pe_lock);
+
+	list_for_each_entry(pe, &ip_vs_pe, n_list) {
+		/* Test and get the modules atomically */
+		if (pe->module &&
+		    !try_module_get(pe->module)) {
+			/* This pe is just deleted */
+			continue;
+		}
+		if (strcmp(pe_name, pe->name)==0) {
+			/* HIT */
+			spin_unlock_bh(&ip_vs_pe_lock);
+			return pe;
+		}
+		if (pe->module)
+			module_put(pe->module);
+	}
+
+	spin_unlock_bh(&ip_vs_pe_lock);
+	return NULL;
+}
+
+/* Lookup pe and try to load it if it doesn't exist */
+struct ip_vs_pe *ip_vs_pe_get(const char *name)
+{
+	struct ip_vs_pe *pe;
+
+	/* Search for the pe by name */
+	pe = ip_vs_pe_getbyname(name);
+
+	/* If pe not found, load the module and search again */
+	if (!pe) {
+		request_module("ip_vs_pe_%s", name);
+		pe = ip_vs_pe_getbyname(name);
+	}
+
+	return pe;
+}
+
+void ip_vs_pe_put(struct ip_vs_pe *pe)
+{
+	if (pe && pe->module)
+		module_put(pe->module);
+}
+
+/* Register a pe in the pe list */
+int register_ip_vs_pe(struct ip_vs_pe *pe)
+{
+	struct ip_vs_pe *tmp;
+
+	/* increase the module use count */
+	ip_vs_use_count_inc();
+
+	spin_lock_bh(&ip_vs_pe_lock);
+
+	if (!list_empty(&pe->n_list)) {
+		spin_unlock_bh(&ip_vs_pe_lock);
+		ip_vs_use_count_dec();
+		pr_err("%s(): [%s] pe already linked\n",
+		       __func__, pe->name);
+		return -EINVAL;
+	}
+
+	/* Make sure that the pe with this name doesn't exist
+	 * in the pe list.
+	 */
+	list_for_each_entry(tmp, &ip_vs_pe, n_list) {
+		if (strcmp(tmp->name, pe->name) == 0) {
+			spin_unlock_bh(&ip_vs_pe_lock);
+			ip_vs_use_count_dec();
+			pr_err("%s(): [%s] pe already existed "
+			       "in the system\n", __func__, pe->name);
+			return -EINVAL;
+		}
+	}
+	/* Add it into the d-linked pe list */
+	list_add(&pe->n_list, &ip_vs_pe);
+	spin_unlock_bh(&ip_vs_pe_lock);
+
+	pr_info("[%s] pe registered.\n", pe->name);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(register_ip_vs_pe);
+
+/* Unregister a pe from the pe list */
+int unregister_ip_vs_pe(struct ip_vs_pe *pe)
+{
+	spin_lock_bh(&ip_vs_pe_lock);
+	if (list_empty(&pe->n_list)) {
+		spin_unlock_bh(&ip_vs_pe_lock);
+		pr_err("%s(): [%s] pe is not in the list. failed\n",
+		       __func__, pe->name);
+		return -EINVAL;
+	}
+
+	/* Remove it from the d-linked pe list */
+	list_del(&pe->n_list);
+	spin_unlock_bh(&ip_vs_pe_lock);
+
+	/* decrease the module use count */
+	ip_vs_use_count_dec();
+
+	pr_info("[%s] pe unregistered.\n", pe->name);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(unregister_ip_vs_pe);
-- 
1.7.1

