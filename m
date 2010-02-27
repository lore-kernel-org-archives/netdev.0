From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] wireless: convert to use netdev_for_each_mc_addr
Date: Sat, 27 Feb 2010 18:35:45 +0100
Message-ID: <20100227173543.GA6550@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030293Ab0B0Rft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 12:35:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


also added missed locking in rndis_wlan.c

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/wireless/libertas/main.c |    8 ++++++--
 drivers/net/wireless/orinoco/hw.c    |   22 +++++++---------------
 drivers/net/wireless/orinoco/hw.h    |    2 +-
 drivers/net/wireless/orinoco/main.c  |    3 +--
 drivers/net/wireless/ray_cs.c        |    8 ++++----
 drivers/net/wireless/rndis_wlan.c    |   15 ++++++++-------
 drivers/net/wireless/zd1201.c        |    9 ++++-----
 7 files changed, 31 insertions(+), 36 deletions(-)

diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index cd8ed7f..28a1c9d 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -319,15 +319,18 @@ static int lbs_add_mcast_addrs(struct cmd_ds_mac_multicast_adr *cmd,
 {
 	int i = nr_addrs;
 	struct dev_mc_list *mc_list;
+	int cnt;
 
 	if ((dev->flags & (IFF_UP|IFF_MULTICAST)) != (IFF_UP|IFF_MULTICAST))
 		return nr_addrs;
 
 	netif_addr_lock_bh(dev);
-	for (mc_list = dev->mc_list; mc_list; mc_list = mc_list->next) {
+	cnt = netdev_mc_count(dev);
+	netdev_for_each_mc_addr(mc_list, dev) {
 		if (mac_in_list(cmd->maclist, nr_addrs, mc_list->dmi_addr)) {
 			lbs_deb_net("mcast address %s:%pM skipped\n", dev->name,
 				    mc_list->dmi_addr);
+			cnt--;
 			continue;
 		}
 
@@ -337,9 +340,10 @@ static int lbs_add_mcast_addrs(struct cmd_ds_mac_multicast_adr *cmd,
 		lbs_deb_net("mcast address %s:%pM added to filter\n", dev->name,
 			    mc_list->dmi_addr);
 		i++;
+		cnt--;
 	}
 	netif_addr_unlock_bh(dev);
-	if (mc_list)
+	if (cnt)
 		return -EOVERFLOW;
 
 	return i;
diff --git a/drivers/net/wireless/orinoco/hw.c b/drivers/net/wireless/orinoco/hw.c
index 404830f..e636924 100644
--- a/drivers/net/wireless/orinoco/hw.c
+++ b/drivers/net/wireless/orinoco/hw.c
@@ -1028,7 +1028,7 @@ int orinoco_clear_tkip_key(struct orinoco_private *priv, int key_idx)
 }
 
 int __orinoco_hw_set_multicast_list(struct orinoco_private *priv,
-				    struct dev_addr_list *mc_list,
+				    struct net_device *dev,
 				    int mc_count, int promisc)
 {
 	hermes_t *hw = &priv->hw;
@@ -1049,24 +1049,16 @@ int __orinoco_hw_set_multicast_list(struct orinoco_private *priv,
 	 * group address if either we want to multicast, or if we were
 	 * multicasting and want to stop */
 	if (!promisc && (mc_count || priv->mc_count)) {
-		struct dev_mc_list *p = mc_list;
+		struct dev_mc_list *p;
 		struct hermes_multicast mclist;
-		int i;
+		int i = 0;
 
-		for (i = 0; i < mc_count; i++) {
-			/* paranoia: is list shorter than mc_count? */
-			BUG_ON(!p);
-			/* paranoia: bad address size in list? */
-			BUG_ON(p->dmi_addrlen != ETH_ALEN);
-
-			memcpy(mclist.addr[i], p->dmi_addr, ETH_ALEN);
-			p = p->next;
+		netdev_for_each_mc_addr(p, dev) {
+			if (i == mc_count)
+				break;
+			memcpy(mclist.addr[i++], p->dmi_addr, ETH_ALEN);
 		}
 
-		if (p)
-			printk(KERN_WARNING "%s: Multicast list is "
-			       "longer than mc_count\n", priv->ndev->name);
-
 		err = hermes_write_ltv(hw, USER_BAP,
 				   HERMES_RID_CNFGROUPADDRESSES,
 				   HERMES_BYTES_TO_RECLEN(mc_count * ETH_ALEN),
diff --git a/drivers/net/wireless/orinoco/hw.h b/drivers/net/wireless/orinoco/hw.h
index e2f7fdc..9799a1d 100644
--- a/drivers/net/wireless/orinoco/hw.h
+++ b/drivers/net/wireless/orinoco/hw.h
@@ -43,7 +43,7 @@ int __orinoco_hw_set_tkip_key(struct orinoco_private *priv, int key_idx,
 			      u8 *tsc, size_t tsc_len);
 int orinoco_clear_tkip_key(struct orinoco_private *priv, int key_idx);
 int __orinoco_hw_set_multicast_list(struct orinoco_private *priv,
-				    struct dev_addr_list *mc_list,
+				    struct net_device *dev,
 				    int mc_count, int promisc);
 int orinoco_hw_get_essid(struct orinoco_private *priv, int *active,
 			 char buf[IW_ESSID_MAX_SIZE+1]);
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index a9e9cea..b42634c 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -1676,8 +1676,7 @@ __orinoco_set_multicast_list(struct net_device *dev)
 		mc_count = netdev_mc_count(dev);
 	}
 
-	err = __orinoco_hw_set_multicast_list(priv, dev->mc_list, mc_count,
-					      promisc);
+	err = __orinoco_hw_set_multicast_list(priv, dev, mc_count, promisc);
 
 	return err;
 }
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 85905ca..84c530a 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1871,10 +1871,8 @@ static void ray_update_parm(struct net_device *dev, UCHAR objid, UCHAR *value,
 /*===========================================================================*/
 static void ray_update_multi_list(struct net_device *dev, int all)
 {
-	struct dev_mc_list *dmi, **dmip;
 	int ccsindex;
 	struct ccs __iomem *pccs;
-	int i = 0;
 	ray_dev_t *local = netdev_priv(dev);
 	struct pcmcia_device *link = local->finder;
 	void __iomem *p = local->sram + HOST_TO_ECF_BASE;
@@ -1895,9 +1893,11 @@ static void ray_update_multi_list(struct net_device *dev, int all)
 		writeb(0xff, &pccs->var);
 		local->num_multi = 0xff;
 	} else {
+		struct dev_mc_list *dmi;
+		int i = 0;
+
 		/* Copy the kernel's list of MC addresses to card */
-		for (dmip = &dev->mc_list; (dmi = *dmip) != NULL;
-		     dmip = &dmi->next) {
+		netdev_for_each_mc_addr(dmi, dev) {
 			memcpy_toio(p, dmi->dmi_addr, ETH_ALEN);
 			dev_dbg(&link->dev,
 			      "ray_update_multi add addr %02x%02x%02x%02x%02x%02x\n",
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 65cbd06..9f6d6bf 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1502,6 +1502,7 @@ static void set_multicast_list(struct usbnet *usbdev)
 
 	filter = RNDIS_PACKET_TYPE_DIRECTED | RNDIS_PACKET_TYPE_BROADCAST;
 
+	netif_addr_lock_bh(usbdev->net);
 	if (usbdev->net->flags & IFF_PROMISC) {
 		filter |= RNDIS_PACKET_TYPE_PROMISCUOUS |
 			RNDIS_PACKET_TYPE_ALL_LOCAL;
@@ -1515,16 +1516,15 @@ static void set_multicast_list(struct usbnet *usbdev)
 			netdev_warn(usbdev->net,
 				    "couldn't alloc %d bytes of memory\n",
 				    size * ETH_ALEN);
+			netif_addr_unlock_bh(usbdev->net);
 			return;
 		}
 
-		mclist = usbdev->net->mc_list;
-		for (i = 0; i < size && mclist; mclist = mclist->next) {
-			if (mclist->dmi_addrlen != ETH_ALEN)
-				continue;
-
-			memcpy(buf + i * ETH_ALEN, mclist->dmi_addr, ETH_ALEN);
-			i++;
+		i = 0;
+		netdev_for_each_mc_addr(mclist, usbdev->net) {
+			if (i == size)
+				break;
+			memcpy(buf + i++ * ETH_ALEN, mclist->dmi_addr, ETH_ALEN);
 		}
 
 		ret = rndis_set_oid(usbdev, OID_802_3_MULTICAST_LIST, buf,
@@ -1539,6 +1539,7 @@ static void set_multicast_list(struct usbnet *usbdev)
 
 		kfree(buf);
 	}
+	netif_addr_unlock_bh(usbdev->net);
 
 	ret = rndis_set_oid(usbdev, OID_GEN_CURRENT_PACKET_FILTER, &filter,
 							sizeof(filter));
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 5d2b52f..6917286 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -875,17 +875,16 @@ static struct iw_statistics *zd1201_get_wireless_stats(struct net_device *dev)
 static void zd1201_set_multicast(struct net_device *dev)
 {
 	struct zd1201 *zd = netdev_priv(dev);
-	struct dev_mc_list *mc = dev->mc_list;
+	struct dev_mc_list *mc;
 	unsigned char reqbuf[ETH_ALEN*ZD1201_MAXMULTI];
 	int i;
 
 	if (netdev_mc_count(dev) > ZD1201_MAXMULTI)
 		return;
 
-	for (i=0; i<netdev_mc_count(dev); i++) {
-		memcpy(reqbuf+i*ETH_ALEN, mc->dmi_addr, ETH_ALEN);
-		mc = mc->next;
-	}
+	i = 0;
+	netdev_for_each_mc_addr(mc, dev)
+		memcpy(reqbuf + i++ * ETH_ALEN, mc->dmi_addr, ETH_ALEN);
 	zd1201_setconfig(zd, ZD1201_RID_CNFGROUPADDRESS, reqbuf,
 			 netdev_mc_count(dev) * ETH_ALEN, 0);
 }
-- 
1.6.6

