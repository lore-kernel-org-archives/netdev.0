From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v3 6/8] enic: fix lockdep around devcmd_lock
Date: Mon, 23 Jun 2014 16:08:03 +0530
Message-ID: <1403519885-4908-7-git-send-email-_govind@gmx.com>
References: <1403519885-4908-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Tony Camuso <tcamuso@redhat.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:54330 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693AbaFWKkq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 06:40:46 -0400
In-Reply-To: <1403519885-4908-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Camuso <tcamuso@redhat.com>

We were experiencing occasional "BUG: scheduling while atomic" splats
in our testing. Enabling DEBUG_SPINLOCK and DEBUG_LOCKDEP in the kernel
exposed a lockdep in the enic driver.

enic 0000:0b:00.0 eth2: Link UP
======================================================
[ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
3.12.0-rc1.x86_64-dbg+ #2 Tainted: GF       W
------------------------------------------------------
NetworkManager/4209 [HC0[0]:SC0[2]:HE1:SE0] is trying to acquire:
(&(&enic->devcmd_lock)->rlock){+.+...}, at: [<ffffffffa026b7e4>] enic_dev_packet_filter+0x44/0x90 [enic]

The fix was to replace spin_lock with spin_lock_bh for the enic
devcmd_lock, so that soft irqs would be disabled while the lock
is held.

Signed-off-by: Sujith Sankar <ssujith@cisco.com>
Signed-off-by: Tony Camuso <tcamuso@redhat.com>
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_api.c  |  4 +-
 drivers/net/ethernet/cisco/enic/enic_dev.c  | 80 ++++++++++++++---------------
 drivers/net/ethernet/cisco/enic/enic_dev.h  |  4 +-
 drivers/net/ethernet/cisco/enic/enic_main.c | 16 +++---
 4 files changed, 52 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_api.c b/drivers/net/ethernet/cisco/enic/enic_api.c
index e13efbd..b161f24 100644
--- a/drivers/net/ethernet/cisco/enic/enic_api.c
+++ b/drivers/net/ethernet/cisco/enic/enic_api.c
@@ -34,13 +34,13 @@ int enic_api_devcmd_proxy_by_index(struct net_device *netdev, int vf,
 	struct vnic_dev *vdev = enic->vdev;
 
 	spin_lock(&enic->enic_api_lock);
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 
 	vnic_dev_cmd_proxy_by_index_start(vdev, vf);
 	err = vnic_dev_cmd(vdev, cmd, a0, a1, wait);
 	vnic_dev_cmd_proxy_end(vdev);
 
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 	spin_unlock(&enic->enic_api_lock);
 
 	return err;
diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.c b/drivers/net/ethernet/cisco/enic/enic_dev.c
index 3e27df5..87ddc44 100644
--- a/drivers/net/ethernet/cisco/enic/enic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/enic_dev.c
@@ -29,9 +29,9 @@ int enic_dev_fw_info(struct enic *enic, struct vnic_devcmd_fw_info **fw_info)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_fw_info(enic->vdev, fw_info);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -40,9 +40,9 @@ int enic_dev_stats_dump(struct enic *enic, struct vnic_stats **vstats)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_stats_dump(enic->vdev, vstats);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -54,9 +54,9 @@ int enic_dev_add_station_addr(struct enic *enic)
 	if (!is_valid_ether_addr(enic->netdev->dev_addr))
 		return -EADDRNOTAVAIL;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_add_addr(enic->vdev, enic->netdev->dev_addr);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -68,9 +68,9 @@ int enic_dev_del_station_addr(struct enic *enic)
 	if (!is_valid_ether_addr(enic->netdev->dev_addr))
 		return -EADDRNOTAVAIL;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_del_addr(enic->vdev, enic->netdev->dev_addr);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -80,10 +80,10 @@ int enic_dev_packet_filter(struct enic *enic, int directed, int multicast,
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_packet_filter(enic->vdev, directed,
 		multicast, broadcast, promisc, allmulti);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -92,9 +92,9 @@ int enic_dev_add_addr(struct enic *enic, const u8 *addr)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_add_addr(enic->vdev, addr);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -103,9 +103,9 @@ int enic_dev_del_addr(struct enic *enic, const u8 *addr)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_del_addr(enic->vdev, addr);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -114,9 +114,9 @@ int enic_dev_notify_unset(struct enic *enic)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_notify_unset(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -125,9 +125,9 @@ int enic_dev_hang_notify(struct enic *enic)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_hang_notify(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -136,10 +136,10 @@ int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_set_ig_vlan_rewrite_mode(enic->vdev,
 		IG_VLAN_REWRITE_MODE_PRIORITY_TAG_DEFAULT_VLAN);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -148,9 +148,9 @@ int enic_dev_enable(struct enic *enic)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_enable_wait(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -159,9 +159,9 @@ int enic_dev_disable(struct enic *enic)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_disable(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -170,9 +170,9 @@ int enic_dev_intr_coal_timer_info(struct enic *enic)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_intr_coal_timer_info(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -181,9 +181,9 @@ int enic_vnic_dev_deinit(struct enic *enic)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_deinit(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -192,10 +192,10 @@ int enic_dev_init_prov2(struct enic *enic, struct vic_provinfo *vp)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_init_prov2(enic->vdev,
 		(u8 *)vp, vic_provinfo_size(vp));
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -204,9 +204,9 @@ int enic_dev_deinit_done(struct enic *enic, int *status)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_deinit_done(enic->vdev, status);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -217,9 +217,9 @@ int enic_vlan_rx_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	struct enic *enic = netdev_priv(netdev);
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = enic_add_vlan(enic, vid);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -230,9 +230,9 @@ int enic_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	struct enic *enic = netdev_priv(netdev);
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = enic_del_vlan(enic, vid);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -241,9 +241,9 @@ int enic_dev_enable2(struct enic *enic, int active)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_enable2(enic->vdev, active);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -252,9 +252,9 @@ int enic_dev_enable2_done(struct enic *enic, int *status)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = vnic_dev_enable2_done(enic->vdev, status);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.h b/drivers/net/ethernet/cisco/enic/enic_dev.h
index 36ea1ab..10bb970 100644
--- a/drivers/net/ethernet/cisco/enic/enic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/enic_dev.h
@@ -28,7 +28,7 @@
  */
 #define ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic, vnicdevcmdfn, ...) \
 	do { \
-		spin_lock(&enic->devcmd_lock); \
+		spin_lock_bh(&enic->devcmd_lock); \
 		if (enic_is_valid_vf(enic, vf)) { \
 			vnic_dev_cmd_proxy_by_index_start(enic->vdev, vf); \
 			err = vnicdevcmdfn(enic->vdev, ##__VA_ARGS__); \
@@ -36,7 +36,7 @@
 		} else { \
 			err = vnicdevcmdfn(enic->vdev, ##__VA_ARGS__); \
 		} \
-		spin_unlock(&enic->devcmd_lock); \
+		spin_unlock_bh(&enic->devcmd_lock); \
 	} while (0)
 
 int enic_dev_fw_info(struct enic *enic, struct vnic_devcmd_fw_info **fw_info);
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index a302f1b..5448df2 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1465,7 +1465,7 @@ static int enic_dev_notify_set(struct enic *enic)
 {
 	int err;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	case VNIC_DEV_INTR_MODE_INTX:
 		err = vnic_dev_notify_set(enic->vdev,
@@ -1479,7 +1479,7 @@ static int enic_dev_notify_set(struct enic *enic)
 		err = vnic_dev_notify_set(enic->vdev, -1 /* no intr */);
 		break;
 	}
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
@@ -1804,11 +1804,11 @@ static int enic_set_rsskey(struct enic *enic)
 
 	memcpy(rss_key_buf_va, &rss_key, sizeof(union vnic_rss_key));
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = enic_set_rss_key(enic,
 		rss_key_buf_pa,
 		sizeof(union vnic_rss_key));
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	pci_free_consistent(enic->pdev, sizeof(union vnic_rss_key),
 		rss_key_buf_va, rss_key_buf_pa);
@@ -1831,11 +1831,11 @@ static int enic_set_rsscpu(struct enic *enic, u8 rss_hash_bits)
 	for (i = 0; i < (1 << rss_hash_bits); i++)
 		(*rss_cpu_buf_va).cpu[i/4].b[i%4] = i % enic->rq_count;
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = enic_set_rss_cpu(enic,
 		rss_cpu_buf_pa,
 		sizeof(union vnic_rss_cpu));
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	pci_free_consistent(enic->pdev, sizeof(union vnic_rss_cpu),
 		rss_cpu_buf_va, rss_cpu_buf_pa);
@@ -1853,13 +1853,13 @@ static int enic_set_niccfg(struct enic *enic, u8 rss_default_cpu,
 	/* Enable VLAN tag stripping.
 	*/
 
-	spin_lock(&enic->devcmd_lock);
+	spin_lock_bh(&enic->devcmd_lock);
 	err = enic_set_nic_cfg(enic,
 		rss_default_cpu, rss_hash_type,
 		rss_hash_bits, rss_base_cpu,
 		rss_enable, tso_ipid_split_en,
 		ig_vlan_strip_en);
-	spin_unlock(&enic->devcmd_lock);
+	spin_unlock_bh(&enic->devcmd_lock);
 
 	return err;
 }
-- 
2.0.0
