From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 4/6] xfrm: Add xfrm6 address translation function
Date: Tue, 29 Sep 2015 15:17:21 -0700
Message-ID: <1443565043-1287886-5-git-send-email-tom@herbertland.com>
References: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43473 "EHLO
	m0001303.ppops.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756830AbbI2WSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:18:02 -0400
Received: from pps.filterd (m0001303 [127.0.0.1])
	by m0001303.ppops.net (8.14.5/8.14.5) with SMTP id t8TM8Crn001947
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:17:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1x82y282p4-12
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:17:58 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 efb8fee066f711e59cdb0002c9dfb610-517f4240 for <netdev@vger.kernel.org>;	Tue,
 29 Sep 2015 15:17:56 -0700
In-Reply-To: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds xfrm6_xlat_addr which is called in the data path
to perform address translation (primarily for the receive path). Modules
may register their own callback to perform a translation-- this
registration is managed by xfrm6_xlat_addr_add and xfrm6_xlat_addr_del.
xfrm6_xlat_addr allows translation of addresses for an sk_buff.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/xfrm.h         | 25 ++++++++++++++++++
 net/ipv6/Kconfig           |  4 +++
 net/ipv6/Makefile          |  1 +
 net/ipv6/xfrm6_policy.c    |  7 +++++
 net/ipv6/xfrm6_xlat_addr.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 103 insertions(+)
 create mode 100644 net/ipv6/xfrm6_xlat_addr.c

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index fd17610..ea05c4e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -607,6 +607,31 @@ struct xfrm_mgr {
 int xfrm_register_km(struct xfrm_mgr *km);
 int xfrm_unregister_km(struct xfrm_mgr *km);
 
+struct xfrm6_xlat_addr {
+	int (*xlat)(struct sk_buff *skb);
+	struct list_head list;
+};
+
+#ifdef CONFIG_INET6_XFRM_XLAT_ADDR
+void xfrm6_xlat_addr_add(struct xfrm6_xlat_addr *xla);
+void xfrm6_xlat_addr_del(struct xfrm6_xlat_addr *xla);
+int xfrm6_xlat_addr(struct sk_buff *skb);
+int xfrm6_xlat_addr_init(void);
+void xfrm6_xlat_addr_fini(void);
+#else
+static inline int xfrm6_xlat_addr(struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline int xfrm6_xlat_addr_init(void)
+{
+	return 0;
+}
+
+static inline void xfrm6_xlat_addr_fini(void) { }
+#endif
+
 struct xfrm_tunnel_skb_cb {
 	union {
 		struct inet_skb_parm h4;
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 983bb99..6e8ca06 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -153,6 +153,10 @@ config INET6_XFRM_MODE_ROUTEOPTIMIZATION
 	---help---
 	  Support for MIPv6 route optimization mode.
 
+config INET6_XFRM_XLAT_ADDR
+	select XFRM
+	bool
+
 config IPV6_VTI
 tristate "Virtual (secure) IPv6: tunneling"
 	select IPV6_TUNNEL
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 2fbd90b..c719d6f 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -33,6 +33,7 @@ obj-$(CONFIG_INET6_XFRM_MODE_TRANSPORT) += xfrm6_mode_transport.o
 obj-$(CONFIG_INET6_XFRM_MODE_TUNNEL) += xfrm6_mode_tunnel.o
 obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
 obj-$(CONFIG_INET6_XFRM_MODE_BEET) += xfrm6_mode_beet.o
+obj-$(CONFIG_INET6_XFRM_XLAT_ADDR) += xfrm6_xlat_addr.o
 obj-$(CONFIG_IPV6_MIP6) += mip6.o
 obj-$(CONFIG_IPV6_ILA) += ila/
 obj-$(CONFIG_NETFILTER)	+= netfilter/
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 30caa28..81b9079 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -390,11 +390,17 @@ int __init xfrm6_init(void)
 	if (ret)
 		goto out_state;
 
+	ret = xfrm6_xlat_addr_init();
+	if (ret)
+		goto out_protocol;
+
 #ifdef CONFIG_SYSCTL
 	register_pernet_subsys(&xfrm6_net_ops);
 #endif
 out:
 	return ret;
+out_protocol:
+	xfrm6_protocol_fini();
 out_state:
 	xfrm6_state_fini();
 out_policy:
@@ -407,6 +413,7 @@ void xfrm6_fini(void)
 #ifdef CONFIG_SYSCTL
 	unregister_pernet_subsys(&xfrm6_net_ops);
 #endif
+	xfrm6_xlat_addr_fini();
 	xfrm6_protocol_fini();
 	xfrm6_policy_fini();
 	xfrm6_state_fini();
diff --git a/net/ipv6/xfrm6_xlat_addr.c b/net/ipv6/xfrm6_xlat_addr.c
new file mode 100644
index 0000000..dd2199a
--- /dev/null
+++ b/net/ipv6/xfrm6_xlat_addr.c
@@ -0,0 +1,66 @@
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <net/ipv6.h>
+#include <net/xfrm.h>
+
+static struct list_head xfrm6_xlat_addr_head __read_mostly;
+static DEFINE_SPINLOCK(xfrm6_xlat_addr_lock);
+
+void xfrm6_xlat_addr_add(struct xfrm6_xlat_addr *xla)
+{
+	spin_lock(&xfrm6_xlat_addr_lock);
+	list_add_rcu(&xla->list, &xfrm6_xlat_addr_head);
+	spin_unlock(&xfrm6_xlat_addr_lock);
+}
+EXPORT_SYMBOL(xfrm6_xlat_addr_add);
+
+void xfrm6_xlat_addr_del(struct xfrm6_xlat_addr *xla)
+{
+	struct xfrm6_xlat_addr *tmp;
+
+	spin_lock(&xfrm6_xlat_addr_lock);
+
+	list_for_each_entry_rcu(tmp, &xfrm6_xlat_addr_head, list) {
+		if (xla == tmp) {
+			list_del_rcu(&xla->list);
+			goto out;
+		}
+	}
+
+	pr_warn("xfrm6_xlat_addr_del: %p not found\n", xla);
+out:
+	spin_unlock(&xfrm6_xlat_addr_lock);
+}
+EXPORT_SYMBOL(xfrm6_xlat_addr_del);
+
+int xfrm6_xlat_addr(struct sk_buff *skb)
+{
+	struct xfrm6_xlat_addr *xla;
+	int err = 0;
+
+	rcu_read_lock();
+
+	list_for_each_entry_rcu(xla, &xfrm6_xlat_addr_head, list) {
+		err = xla->xlat(skb);
+		if (err < 0)
+			break;
+	}
+
+	rcu_read_unlock();
+
+	return err;
+}
+EXPORT_SYMBOL(xfrm6_xlat_addr);
+
+int __init xfrm6_xlat_addr_init(void)
+{
+	INIT_LIST_HEAD(&xfrm6_xlat_addr_head);
+
+	return 0;
+}
+
+void xfrm6_xlat_addr_fini(void)
+{
+}
+
-- 
2.4.6
