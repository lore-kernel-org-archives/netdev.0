From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-04-30
Date: Wed, 30 Apr 2008 20:43:29 -0400
Message-ID: <20080501004329.GA5907@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

Here is another volley of fixes for 2.6.26.  It all seems fairly
straight-forward.

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 809917903127804c2b2ac76342ab0f29f4b394d3:
  Pavel Emelyanov (1):
        ipv6: Compilation fix for compat MCAST_MSFILTER sockopts.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Harvey Harrison (1):
      mac80211: incorrect shift direction

Holger Schurig (1):
      libertas: fix use-before-check violation

Johannes Berg (3):
      mac80211: assign conf.beacon_control for mesh
      mac80211: don't allow invalid WDS peer addresses
      mac80211: insert WDS peer after adding interface

Luis Carlos Cobo (1):
      mac80211: use 4-byte mesh sequence number

Michael Buesch (1):
      b43: Fix dual-PHY devices

 drivers/net/wireless/b43/main.c      |    8 ++++++
 drivers/net/wireless/libertas/scan.c |    3 +-
 include/linux/ieee80211.h            |    2 +-
 net/mac80211/ieee80211_i.h           |    2 +-
 net/mac80211/main.c                  |   47 +++++++++++++++++++++-------------
 net/mac80211/mesh.c                  |   17 +++--------
 net/mac80211/mesh.h                  |    2 +-
 net/mac80211/tkip.c                  |    6 +---
 8 files changed, 49 insertions(+), 38 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 94a0cde..1e95c4f 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4326,6 +4326,14 @@ static int b43_wireless_core_attach(struct b43_wldev *dev)
 		err = -EOPNOTSUPP;
 		goto err_powerdown;
 	}
+	if (1 /* disable A-PHY */) {
+		/* FIXME: For now we disable the A-PHY on multi-PHY devices. */
+		if (dev->phy.type != B43_PHYTYPE_N) {
+			have_2ghz_phy = 1;
+			have_5ghz_phy = 0;
+		}
+	}
+
 	dev->phy.gmode = have_2ghz_phy;
 	tmp = dev->phy.gmode ? B43_TMSLOW_GMODE : 0;
 	b43_wireless_core_reset(dev, tmp);
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index e72c97a..7234669 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -298,7 +298,8 @@ static int lbs_do_scan(struct lbs_private *priv, uint8_t bsstype,
 	uint8_t *tlv;	/* pointer into our current, growing TLV storage area */
 
 	lbs_deb_enter_args(LBS_DEB_SCAN, "bsstype %d, chanlist[].chan %d, chan_count %d",
-			   bsstype, chan_list[0].channumber, chan_count);
+		bsstype, chan_list ? chan_list[0].channumber : -1,
+		chan_count);
 
 	/* create the fixed part for scan command */
 	scan_cmd = kzalloc(MAX_SCAN_CFG_ALLOC, GFP_KERNEL);
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index 529f301..0b5e03e 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -113,7 +113,7 @@ struct ieee80211_hdr {
 struct ieee80211s_hdr {
 	u8 flags;
 	u8 ttl;
-	u8 seqnum[3];
+	__le32 seqnum;
 	u8 eaddr1[6];
 	u8 eaddr2[6];
 	u8 eaddr3[6];
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 8e53ce7..c7314bf 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -354,7 +354,7 @@ struct ieee80211_if_sta {
 	int preq_queue_len;
 	struct mesh_stats mshstats;
 	struct mesh_config mshcfg;
-	u8 mesh_seqnum[3];
+	u32 mesh_seqnum;
 	bool accepting_plinks;
 #endif
 	u16 aid;
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index e9a9789..9ad4e36 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -255,22 +255,8 @@ static int ieee80211_open(struct net_device *dev)
 
 	switch (sdata->vif.type) {
 	case IEEE80211_IF_TYPE_WDS:
-		if (is_zero_ether_addr(sdata->u.wds.remote_addr))
+		if (!is_valid_ether_addr(sdata->u.wds.remote_addr))
 			return -ENOLINK;
-
-		/* Create STA entry for the WDS peer */
-		sta = sta_info_alloc(sdata, sdata->u.wds.remote_addr,
-				     GFP_KERNEL);
-		if (!sta)
-			return -ENOMEM;
-
-		sta->flags |= WLAN_STA_AUTHORIZED;
-
-		res = sta_info_insert(sta);
-		if (res) {
-			/* STA has been freed */
-			return res;
-		}
 		break;
 	case IEEE80211_IF_TYPE_VLAN:
 		if (!sdata->u.vlan.ap)
@@ -337,10 +323,8 @@ static int ieee80211_open(struct net_device *dev)
 		conf.type = sdata->vif.type;
 		conf.mac_addr = dev->dev_addr;
 		res = local->ops->add_interface(local_to_hw(local), &conf);
-		if (res && !local->open_count && local->ops->stop)
-			local->ops->stop(local_to_hw(local));
 		if (res)
-			return res;
+			goto err_stop;
 
 		ieee80211_if_config(dev);
 		ieee80211_reset_erp_info(dev);
@@ -353,9 +337,29 @@ static int ieee80211_open(struct net_device *dev)
 			netif_carrier_on(dev);
 	}
 
+	if (sdata->vif.type == IEEE80211_IF_TYPE_WDS) {
+		/* Create STA entry for the WDS peer */
+		sta = sta_info_alloc(sdata, sdata->u.wds.remote_addr,
+				     GFP_KERNEL);
+		if (!sta) {
+			res = -ENOMEM;
+			goto err_del_interface;
+		}
+
+		sta->flags |= WLAN_STA_AUTHORIZED;
+
+		res = sta_info_insert(sta);
+		if (res) {
+			/* STA has been freed */
+			goto err_del_interface;
+		}
+	}
+
 	if (local->open_count == 0) {
 		res = dev_open(local->mdev);
 		WARN_ON(res);
+		if (res)
+			goto err_del_interface;
 		tasklet_enable(&local->tx_pending_tasklet);
 		tasklet_enable(&local->tasklet);
 	}
@@ -390,6 +394,12 @@ static int ieee80211_open(struct net_device *dev)
 	netif_start_queue(dev);
 
 	return 0;
+ err_del_interface:
+	local->ops->remove_interface(local_to_hw(local), &conf);
+ err_stop:
+	if (!local->open_count && local->ops->stop)
+		local->ops->stop(local_to_hw(local));
+	return res;
 }
 
 static int ieee80211_stop(struct net_device *dev)
@@ -975,6 +985,7 @@ static int __ieee80211_if_config(struct net_device *dev,
 		conf.ssid_len = sdata->u.sta.ssid_len;
 	} else if (ieee80211_vif_is_mesh(&sdata->vif)) {
 		conf.beacon = beacon;
+		conf.beacon_control = control;
 		ieee80211_start_mesh(dev);
 	} else if (sdata->vif.type == IEEE80211_IF_TYPE_AP) {
 		conf.ssid = sdata->u.ap.ssid;
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 594a335..f76bc26 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -8,6 +8,7 @@
  * published by the Free Software Foundation.
  */
 
+#include <asm/unaligned.h>
 #include "ieee80211_i.h"
 #include "mesh.h"
 
@@ -167,8 +168,8 @@ int mesh_rmc_check(u8 *sa, struct ieee80211s_hdr *mesh_hdr,
 	struct rmc_entry *p, *n;
 
 	/* Don't care about endianness since only match matters */
-	memcpy(&seqnum, mesh_hdr->seqnum, sizeof(mesh_hdr->seqnum));
-	idx = mesh_hdr->seqnum[0] & rmc->idx_mask;
+	memcpy(&seqnum, &mesh_hdr->seqnum, sizeof(mesh_hdr->seqnum));
+	idx = le32_to_cpu(mesh_hdr->seqnum) & rmc->idx_mask;
 	list_for_each_entry_safe(p, n, &rmc->bucket[idx].list, list) {
 		++entries;
 		if (time_after(jiffies, p->exp_time) ||
@@ -393,16 +394,8 @@ int ieee80211_new_mesh_header(struct ieee80211s_hdr *meshhdr,
 {
 	meshhdr->flags = 0;
 	meshhdr->ttl = sdata->u.sta.mshcfg.dot11MeshTTL;
-
-	meshhdr->seqnum[0] = sdata->u.sta.mesh_seqnum[0]++;
-	meshhdr->seqnum[1] = sdata->u.sta.mesh_seqnum[1];
-	meshhdr->seqnum[2] = sdata->u.sta.mesh_seqnum[2];
-
-	if (sdata->u.sta.mesh_seqnum[0] == 0) {
-		sdata->u.sta.mesh_seqnum[1]++;
-		if (sdata->u.sta.mesh_seqnum[1] == 0)
-			sdata->u.sta.mesh_seqnum[2]++;
-	}
+	put_unaligned(cpu_to_le32(sdata->u.sta.mesh_seqnum), &meshhdr->seqnum);
+	sdata->u.sta.mesh_seqnum++;
 
 	return 5;
 }
diff --git a/net/mac80211/mesh.h b/net/mac80211/mesh.h
index 742003d..9f8cb76 100644
--- a/net/mac80211/mesh.h
+++ b/net/mac80211/mesh.h
@@ -139,7 +139,7 @@ struct rmc_entry {
 
 struct mesh_rmc {
 	struct rmc_entry bucket[RMC_BUCKETS];
-	u8 idx_mask;
+	u32 idx_mask;
 };
 
 
diff --git a/net/mac80211/tkip.c b/net/mac80211/tkip.c
index dddbfd6..09093da 100644
--- a/net/mac80211/tkip.c
+++ b/net/mac80211/tkip.c
@@ -230,10 +230,8 @@ void ieee80211_get_tkip_key(struct ieee80211_key_conf *keyconf,
 
 	iv16 = data[hdr_len] << 8;
 	iv16 += data[hdr_len + 2];
-	iv32 = data[hdr_len + 4] +
-		(data[hdr_len + 5] >> 8) +
-		(data[hdr_len + 6] >> 16) +
-		(data[hdr_len + 7] >> 24);
+	iv32 = data[hdr_len + 4] | (data[hdr_len + 5] << 8) |
+	       (data[hdr_len + 6] << 16) | (data[hdr_len + 7] << 24);
 
 #ifdef CONFIG_TKIP_DEBUG
 	printk(KERN_DEBUG "TKIP encrypt: iv16 = 0x%04x, iv32 = 0x%08x\n",
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
