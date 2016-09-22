From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ipvlan: fix building without netfilter
Date: Thu, 22 Sep 2016 11:40:52 +0200
Message-ID: <20160922094130.2154824-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Mahesh Bandewar <maheshb@google.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:54244 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755623AbcIVJlm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 05:41:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new l3s mode in ipvlan relies on netfilter interfaces, but
the ipvlan driver can be configured when CONFIG_NETFILTER is disabled,
leading to a build error:

drivers/net/ipvlan/ipvlan.h:132:22: error: 'struct nf_hook_state' declared inside parameter list will not be visible outside of this definition or declaration [-Werror]
drivers/net/ipvlan/ipvlan_main.c:14:27: error: array type has incomplete element type 'struct nf_hook_ops'
...

This adds a forward declaration for struct nf_hook_state, and hides
the newly added l3s code in an #ifdef.

Fixes: 4fbae7d83c98 ("ipvlan: Introduce l3s mode")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ipvlan/ipvlan.h      | 1 +
 drivers/net/ipvlan/ipvlan_main.c | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 7e0732f5ea07..e239b90e42e0 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -128,6 +128,7 @@ bool ipvlan_addr_busy(struct ipvl_port *port, void *iaddr, bool is_v6);
 void ipvlan_ht_addr_del(struct ipvl_addr *addr);
 struct sk_buff *ipvlan_l3_rcv(struct net_device *dev, struct sk_buff *skb,
 			      u16 proto);
+struct nf_hook_state;
 unsigned int ipvlan_nf_input(void *priv, struct sk_buff *skb,
 			     const struct nf_hook_state *state);
 #endif /* __IPVLAN_H */
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index f442eb366863..19e8b0b1b56f 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -9,6 +9,7 @@
 
 #include "ipvlan.h"
 
+#ifdef CONFIG_NETFILTER
 static u32 ipvl_nf_hook_refcnt = 0;
 
 static struct nf_hook_ops ipvl_nfops[] __read_mostly = {
@@ -25,6 +26,7 @@ static struct nf_hook_ops ipvl_nfops[] __read_mostly = {
 		.priority = INT_MAX,
 	},
 };
+#endif
 
 static struct l3mdev_ops ipvl_l3mdev_ops __read_mostly = {
 	.l3mdev_l3_rcv = ipvlan_l3_rcv,
@@ -37,6 +39,7 @@ static void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
 
 static int ipvlan_register_nf_hook(void)
 {
+#ifdef CONFIG_NETFILTER
 	int err = 0;
 
 	if (!ipvl_nf_hook_refcnt) {
@@ -48,15 +51,20 @@ static int ipvlan_register_nf_hook(void)
 	}
 
 	return err;
+#else
+	return -EINVAL;
+#endif
 }
 
 static void ipvlan_unregister_nf_hook(void)
 {
+#ifdef CONFIG_NETFILTER
 	WARN_ON(!ipvl_nf_hook_refcnt);
 
 	ipvl_nf_hook_refcnt--;
 	if (!ipvl_nf_hook_refcnt)
 		_nf_unregister_hooks(ipvl_nfops, ARRAY_SIZE(ipvl_nfops));
+#endif
 }
 
 static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
-- 
2.9.0
