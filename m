From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: gro_cells: move to net/core/gro_cells.c
Date: Tue, 07 Feb 2017 15:37:15 -0800
Message-ID: <1486510635.7793.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33383 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751336AbdBGXn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 18:43:29 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so13340772pgd.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 15:43:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We have many gro cells users, so lets move the code to avoid
duplication.

This creates a CONFIG_GRO_CELLS option.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/Kconfig     |    3 +
 include/net/gro_cells.h |   86 +----------------------------------
 net/Kconfig             |    4 +
 net/core/Makefile       |    1 
 net/core/gro_cells.c    |   92 ++++++++++++++++++++++++++++++++++++++
 net/ipv4/Kconfig        |    1 
 net/ipv6/Kconfig        |    1 
 net/xfrm/Kconfig        |    1 
 8 files changed, 107 insertions(+), 82 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 95c32f2d7601b9180d43b77e1c143d4988f5..a993cbeb9e0c84326a63369226b14ed00870 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -170,6 +170,7 @@ config VXLAN
        tristate "Virtual eXtensible Local Area Network (VXLAN)"
        depends on INET
        select NET_UDP_TUNNEL
+       select GRO_CELLS
        ---help---
 	  This allows one to create vxlan virtual interfaces that provide
 	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
@@ -184,6 +185,7 @@ config GENEVE
        tristate "Generic Network Virtualization Encapsulation"
        depends on INET && NET_UDP_TUNNEL
        select NET_IP_TUNNEL
+       select GRO_CELLS
        ---help---
 	  This allows one to create geneve virtual interfaces that provide
 	  Layer 2 Networks over Layer 3 Networks. GENEVE is often used
@@ -216,6 +218,7 @@ config MACSEC
 	select CRYPTO
 	select CRYPTO_AES
 	select CRYPTO_GCM
+	select GRO_CELLS
 	---help---
 	   MACsec is an encryption standard for Ethernet.
 
diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
index 2a1abbf8da74368cd01adc40cef6c0644e05..fcaf8f47913054543e97d606518f78eabf06 100644
--- a/include/net/gro_cells.h
+++ b/include/net/gro_cells.h
@@ -5,92 +5,14 @@
 #include <linux/slab.h>
 #include <linux/netdevice.h>
 
-struct gro_cell {
-	struct sk_buff_head	napi_skbs;
-	struct napi_struct	napi;
-};
+struct gro_cell;
 
 struct gro_cells {
 	struct gro_cell __percpu	*cells;
 };
 
-static inline int gro_cells_receive(struct gro_cells *gcells, struct sk_buff *skb)
-{
-	struct gro_cell *cell;
-	struct net_device *dev = skb->dev;
-
-	if (!gcells->cells || skb_cloned(skb) || !(dev->features & NETIF_F_GRO))
-		return netif_rx(skb);
-
-	cell = this_cpu_ptr(gcells->cells);
-
-	if (skb_queue_len(&cell->napi_skbs) > netdev_max_backlog) {
-		atomic_long_inc(&dev->rx_dropped);
-		kfree_skb(skb);
-		return NET_RX_DROP;
-	}
-
-	__skb_queue_tail(&cell->napi_skbs, skb);
-	if (skb_queue_len(&cell->napi_skbs) == 1)
-		napi_schedule(&cell->napi);
-	return NET_RX_SUCCESS;
-}
-
-/* called under BH context */
-static inline int gro_cell_poll(struct napi_struct *napi, int budget)
-{
-	struct gro_cell *cell = container_of(napi, struct gro_cell, napi);
-	struct sk_buff *skb;
-	int work_done = 0;
-
-	while (work_done < budget) {
-		skb = __skb_dequeue(&cell->napi_skbs);
-		if (!skb)
-			break;
-		napi_gro_receive(napi, skb);
-		work_done++;
-	}
-
-	if (work_done < budget)
-		napi_complete_done(napi, work_done);
-	return work_done;
-}
-
-static inline int gro_cells_init(struct gro_cells *gcells, struct net_device *dev)
-{
-	int i;
-
-	gcells->cells = alloc_percpu(struct gro_cell);
-	if (!gcells->cells)
-		return -ENOMEM;
-
-	for_each_possible_cpu(i) {
-		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
-
-		__skb_queue_head_init(&cell->napi_skbs);
-
-		set_bit(NAPI_STATE_NO_BUSY_POLL, &cell->napi.state);
-
-		netif_napi_add(dev, &cell->napi, gro_cell_poll, 64);
-		napi_enable(&cell->napi);
-	}
-	return 0;
-}
-
-static inline void gro_cells_destroy(struct gro_cells *gcells)
-{
-	int i;
-
-	if (!gcells->cells)
-		return;
-	for_each_possible_cpu(i) {
-		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
-
-		netif_napi_del(&cell->napi);
-		__skb_queue_purge(&cell->napi_skbs);
-	}
-	free_percpu(gcells->cells);
-	gcells->cells = NULL;
-}
+int gro_cells_receive(struct gro_cells *gcells, struct sk_buff *skb);
+int gro_cells_init(struct gro_cells *gcells, struct net_device *dev);
+void gro_cells_destroy(struct gro_cells *gcells);
 
 #endif
diff --git a/net/Kconfig b/net/Kconfig
index 2f2842d2d3edde3f13574923953d4c33aff0..f19c0c3b9589757856502bc91398e6ee17d8 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -413,6 +413,10 @@ config DST_CACHE
 	bool
 	default n
 
+config GRO_CELLS
+	bool
+	default n
+
 config NET_DEVLINK
 	tristate "Network physical/parent device Netlink interface"
 	help
diff --git a/net/core/Makefile b/net/core/Makefile
index f6761b6e3b29bc4c645585bfdcb38ca94bda..79f9479e965812c635b5337ff89d393a7176 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -28,3 +28,4 @@ obj-$(CONFIG_LWTUNNEL_BPF) += lwt_bpf.o
 obj-$(CONFIG_DST_CACHE) += dst_cache.o
 obj-$(CONFIG_HWBM) += hwbm.o
 obj-$(CONFIG_NET_DEVLINK) += devlink.o
+obj-$(CONFIG_GRO_CELLS) += gro_cells.o
diff --git a/net/core/gro_cells.c b/net/core/gro_cells.c
new file mode 100644
index 000000000000000000000000000000000000..c98bbfbd26b8645bb2a273bdee61f285606e
--- /dev/null
+++ b/net/core/gro_cells.c
@@ -0,0 +1,92 @@
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/netdevice.h>
+#include <net/gro_cells.h>
+
+struct gro_cell {
+	struct sk_buff_head	napi_skbs;
+	struct napi_struct	napi;
+};
+
+int gro_cells_receive(struct gro_cells *gcells, struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	struct gro_cell *cell;
+
+	if (!gcells->cells || skb_cloned(skb) || !(dev->features & NETIF_F_GRO))
+		return netif_rx(skb);
+
+	cell = this_cpu_ptr(gcells->cells);
+
+	if (skb_queue_len(&cell->napi_skbs) > netdev_max_backlog) {
+		atomic_long_inc(&dev->rx_dropped);
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
+	__skb_queue_tail(&cell->napi_skbs, skb);
+	if (skb_queue_len(&cell->napi_skbs) == 1)
+		napi_schedule(&cell->napi);
+	return NET_RX_SUCCESS;
+}
+EXPORT_SYMBOL(gro_cells_receive);
+
+/* called under BH context */
+static int gro_cell_poll(struct napi_struct *napi, int budget)
+{
+	struct gro_cell *cell = container_of(napi, struct gro_cell, napi);
+	struct sk_buff *skb;
+	int work_done = 0;
+
+	while (work_done < budget) {
+		skb = __skb_dequeue(&cell->napi_skbs);
+		if (!skb)
+			break;
+		napi_gro_receive(napi, skb);
+		work_done++;
+	}
+
+	if (work_done < budget)
+		napi_complete_done(napi, work_done);
+	return work_done;
+}
+
+int gro_cells_init(struct gro_cells *gcells, struct net_device *dev)
+{
+	int i;
+
+	gcells->cells = alloc_percpu(struct gro_cell);
+	if (!gcells->cells)
+		return -ENOMEM;
+
+	for_each_possible_cpu(i) {
+		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
+
+		__skb_queue_head_init(&cell->napi_skbs);
+
+		set_bit(NAPI_STATE_NO_BUSY_POLL, &cell->napi.state);
+
+		netif_napi_add(dev, &cell->napi, gro_cell_poll,
+			       NAPI_POLL_WEIGHT);
+		napi_enable(&cell->napi);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(gro_cells_init);
+
+void gro_cells_destroy(struct gro_cells *gcells)
+{
+	int i;
+
+	if (!gcells->cells)
+		return;
+	for_each_possible_cpu(i) {
+		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
+
+		netif_napi_del(&cell->napi);
+		__skb_queue_purge(&cell->napi_skbs);
+	}
+	free_percpu(gcells->cells);
+	gcells->cells = NULL;
+}
+EXPORT_SYMBOL(gro_cells_destroy);
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 6e7baaf814c608b4e222406c42287382d4ee..e30f9caddae8a221c693b97e1b81acff491c 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -187,6 +187,7 @@ config NET_IPGRE_DEMUX
 config NET_IP_TUNNEL
 	tristate
 	select DST_CACHE
+	select GRO_CELLS
 	default n
 
 config NET_IPGRE
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index ec1267e2bd1f8c9168687513010cec7a7271..3c7c76b2a7baafc1a67df8c5be2166aafcd9 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -208,6 +208,7 @@ config IPV6_TUNNEL
 	tristate "IPv6: IP-in-IPv6 tunnel (RFC2473)"
 	select INET6_TUNNEL
 	select DST_CACHE
+	select GRO_CELLS
 	---help---
 	  Support for IPv6-in-IPv6 and IPv4-in-IPv6 tunnels described in
 	  RFC 2473.
diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index bda1a13628a8143b812554d0d29fd83cac3a..c06d3997c6e7b11e32d086d015945918468e 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -4,6 +4,7 @@
 config XFRM
        bool
        depends on NET
+       select GRO_CELLS
 
 config XFRM_ALGO
 	tristate
