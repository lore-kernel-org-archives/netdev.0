From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net v2 1/4] cxgb4i : Remove duplicated CLIP handling code
Date: Tue, 14 Oct 2014 20:07:21 -0700
Message-ID: <1413342444-16388-2-git-send-email-anish@chelsio.com>
References: <1413342444-16388-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hch@infradead.org, jbottomley@parallels.com,
	kxie@chelsio.com, manojmalviya@chelsio.com, hariprasad@chelsio.com,
	leedom@chelsio.com, swise@opengridcomputing.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:44191
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755536AbaJODIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 23:08:02 -0400
In-Reply-To: <1413342444-16388-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cxgb4 already handles CLIP updates from a previous changeset for iw_cxgb4,
there is no need to have this functionality in cxgb4i. Remove duplicated code

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   7 ++
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c              | 133 ------------------------
 2 files changed, 7 insertions(+), 133 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index fed8f26..411acf0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4490,6 +4490,13 @@ static int update_root_dev_clip(struct net_device *dev)
 		return ret;
 
 	/* Parse all bond and vlan devices layered on top of the physical dev */
+	root_dev = netdev_master_upper_dev_get_rcu(dev);
+	if (root_dev) {
+		ret = update_dev_clip(root_dev, dev);
+		if (ret)
+			return ret;
+	}
+
 	for (i = 0; i < VLAN_N_VID; i++) {
 		root_dev = __vlan_find_dev_deep_rcu(dev, htons(ETH_P_8021Q), i);
 		if (!root_dev)
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 02e69e7..18d0d1c 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1635,129 +1635,6 @@ static int cxgb4i_ddp_init(struct cxgbi_device *cdev)
 	return 0;
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
-static int cxgbi_inet6addr_handler(struct notifier_block *this,
-				   unsigned long event, void *data)
-{
-	struct inet6_ifaddr *ifa = data;
-	struct net_device *event_dev = ifa->idev->dev;
-	struct cxgbi_device *cdev;
-	int ret = NOTIFY_DONE;
-
-	if (event_dev->priv_flags & IFF_802_1Q_VLAN)
-		event_dev = vlan_dev_real_dev(event_dev);
-
-	cdev = cxgbi_device_find_by_netdev_rcu(event_dev, NULL);
-
-	if (!cdev)
-		return ret;
-
-	switch (event) {
-	case NETDEV_UP:
-		ret = cxgb4_clip_get(event_dev,
-				     (const struct in6_addr *)
-				     ((ifa)->addr.s6_addr));
-		if (ret < 0)
-			return ret;
-
-		ret = NOTIFY_OK;
-		break;
-
-	case NETDEV_DOWN:
-		cxgb4_clip_release(event_dev,
-				   (const struct in6_addr *)
-				   ((ifa)->addr.s6_addr));
-		ret = NOTIFY_OK;
-		break;
-
-	default:
-		break;
-	}
-
-	return ret;
-}
-
-static struct notifier_block cxgbi_inet6addr_notifier = {
-	.notifier_call = cxgbi_inet6addr_handler
-};
-
-/* Retrieve IPv6 addresses from a root device (bond, vlan) associated with
- * a physical device.
- * The physical device reference is needed to send the actual CLIP command.
- */
-static int update_dev_clip(struct net_device *root_dev, struct net_device *dev)
-{
-	struct inet6_dev *idev = NULL;
-	struct inet6_ifaddr *ifa;
-	int ret = 0;
-
-	idev = __in6_dev_get(root_dev);
-	if (!idev)
-		return ret;
-
-	read_lock_bh(&idev->lock);
-	list_for_each_entry(ifa, &idev->addr_list, if_list) {
-		pr_info("updating the clip for addr %pI6\n",
-			ifa->addr.s6_addr);
-		ret = cxgb4_clip_get(dev, (const struct in6_addr *)
-				     ifa->addr.s6_addr);
-		if (ret < 0)
-			break;
-	}
-
-	read_unlock_bh(&idev->lock);
-	return ret;
-}
-
-static int update_root_dev_clip(struct net_device *dev)
-{
-	struct net_device *root_dev = NULL;
-	int i, ret = 0;
-
-	/* First populate the real net device's IPv6 address */
-	ret = update_dev_clip(dev, dev);
-	if (ret)
-		return ret;
-
-	/* Parse all bond and vlan devices layered on top of the physical dev */
-	root_dev = netdev_master_upper_dev_get(dev);
-	if (root_dev) {
-		ret = update_dev_clip(root_dev, dev);
-		if (ret)
-			return ret;
-	}
-
-	for (i = 0; i < VLAN_N_VID; i++) {
-		root_dev = __vlan_find_dev_deep_rcu(dev, htons(ETH_P_8021Q), i);
-		if (!root_dev)
-			continue;
-
-		ret = update_dev_clip(root_dev, dev);
-		if (ret)
-			break;
-	}
-	return ret;
-}
-
-static void cxgbi_update_clip(struct cxgbi_device *cdev)
-{
-	int i;
-
-	rcu_read_lock();
-
-	for (i = 0; i < cdev->nports; i++) {
-		struct net_device *dev = cdev->ports[i];
-		int ret = 0;
-
-		if (dev)
-			ret = update_root_dev_clip(dev);
-		if (ret < 0)
-			break;
-	}
-	rcu_read_unlock();
-}
-#endif /* IS_ENABLED(CONFIG_IPV6) */
-
 static void *t4_uld_add(const struct cxgb4_lld_info *lldi)
 {
 	struct cxgbi_device *cdev;
@@ -1876,10 +1753,6 @@ static int t4_uld_state_change(void *handle, enum cxgb4_state state)
 	switch (state) {
 	case CXGB4_STATE_UP:
 		pr_info("cdev 0x%p, UP.\n", cdev);
-#if IS_ENABLED(CONFIG_IPV6)
-		cxgbi_update_clip(cdev);
-#endif
-		/* re-initialize */
 		break;
 	case CXGB4_STATE_START_RECOVERY:
 		pr_info("cdev 0x%p, RECOVERY.\n", cdev);
@@ -1910,17 +1783,11 @@ static int __init cxgb4i_init_module(void)
 		return rc;
 	cxgb4_register_uld(CXGB4_ULD_ISCSI, &cxgb4i_uld_info);
 
-#if IS_ENABLED(CONFIG_IPV6)
-	register_inet6addr_notifier(&cxgbi_inet6addr_notifier);
-#endif
 	return 0;
 }
 
 static void __exit cxgb4i_exit_module(void)
 {
-#if IS_ENABLED(CONFIG_IPV6)
-	unregister_inet6addr_notifier(&cxgbi_inet6addr_notifier);
-#endif
 	cxgb4_unregister_uld(CXGB4_ULD_ISCSI);
 	cxgbi_device_unregister_all(CXGBI_FLAG_DEV_T4);
 	cxgbi_iscsi_cleanup(&cxgb4i_iscsi_transport, &cxgb4i_stt);
-- 
2.1.2
