From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 04/11] fcoe: adds spma mode support
Date: Sun, 17 May 2009 15:33:28 -0700
Message-ID: <20090517223328.14124.25558.stgit@localhost.localdomain>
References: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Vasu Dev <vasu.dev@intel.com>, Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090517223213.14124.61405.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasu Dev <vasu.dev@intel.com>

If we can find a type NETDEV_HW_ADDR_T_SAN mac address from the
corresponding netdev for a fcoe interface then sets up added the
fc->ctlr.spma flag and stores spma mode address in ctl_src_addr.

In case the spma flag is set then:-

 1. Adds spma mode MAC address in ctl_src_addr as secondary
    MAC address, the FLOGI for FIP and pre-FIP will go out
    using this address.
 2. Cleans up stored spma MAC address in ctl_src_addr in
    fcoe_netdev_cleanup.
 3. Sets up spma bit in fip_flags for FIP solicitations along
    with exiting FPMA bit setting.
 4. Initialize the FLOGI FIP MAC descriptor to stored spma
    MAC address in ctl_src_addr. This is used as proposed
    FCoE MAC address from initiator along with both SPMA
    and FPMA bit set in FIP solicitation, in response the
    switch may grant any FPMA or SPMA mode MAC address to
    initiator.

Removes FIP descriptor type checking against ELS type
ELS_FLOGI in fcoe_ctlr_encaps to update a FIP MAC descriptor,
instead now checks against FIP_DT_FLOGI.

I've tested this with available FPMA-only FCoE switch but
since data_src_addr is updated using same old code for
both FPMA and SPMA modes with FIP or pre-FIP links, so added
SPMA mode will work with SPMA-only switch also provided that
switch grants a valid MAC address.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/scsi/fcoe/fcoe.c    |   24 ++++++++++++++++++++++--
 drivers/scsi/fcoe/libfcoe.c |   10 +++++++++-
 include/scsi/libfcoe.h      |    2 ++
 3 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 04f5005..f2d1612 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -238,6 +238,9 @@ void fcoe_netdev_cleanup(struct fcoe_softc *fc)
 	if (!is_zero_ether_addr(fc->ctlr.data_src_addr))
 		dev_unicast_delete(fc->real_dev,
 				   fc->ctlr.data_src_addr, ETH_ALEN);
+	if (fc->ctlr.spma)
+		dev_unicast_delete(fc->real_dev,
+				   fc->ctlr.ctl_src_addr, ETH_ALEN);
 	dev_mc_delete(fc->real_dev, FIP_ALL_ENODE_MACS, ETH_ALEN, 0);
 	rtnl_unlock();
 }
@@ -257,6 +260,7 @@ static int fcoe_netdev_config(struct fc_lport *lp, struct net_device *netdev)
 	u64 wwnn, wwpn;
 	struct fcoe_softc *fc;
 	u8 flogi_maddr[ETH_ALEN];
+	struct netdev_hw_addr *ha;
 
 	/* Setup lport private data to point to fcoe softc */
 	fc = lport_priv(lp);
@@ -313,9 +317,23 @@ static int fcoe_netdev_config(struct fc_lport *lp, struct net_device *netdev)
 	skb_queue_head_init(&fc->fcoe_pending_queue);
 	fc->fcoe_pending_queue_active = 0;
 
+	/* look for SAN MAC address, if multiple SAN MACs exist, only
+	 * use the first one for SPMA */
+	rcu_read_lock();
+	for_each_dev_addr(netdev, ha) {
+		if ((ha->type == NETDEV_HW_ADDR_T_SAN) &&
+		    (is_valid_ether_addr(fc->ctlr.ctl_src_addr))) {
+			memcpy(fc->ctlr.ctl_src_addr, ha->addr, ETH_ALEN);
+			fc->ctlr.spma = 1;
+			break;
+		}
+	}
+	rcu_read_unlock();
+
 	/* setup Source Mac Address */
-	memcpy(fc->ctlr.ctl_src_addr, fc->real_dev->dev_addr,
-	       fc->real_dev->addr_len);
+	if (!fc->ctlr.spma)
+		memcpy(fc->ctlr.ctl_src_addr, fc->real_dev->dev_addr,
+		       fc->real_dev->addr_len);
 
 	wwnn = fcoe_wwn_from_mac(fc->real_dev->dev_addr, 1, 0);
 	fc_set_wwnn(lp, wwnn);
@@ -331,6 +349,8 @@ static int fcoe_netdev_config(struct fc_lport *lp, struct net_device *netdev)
 	rtnl_lock();
 	memcpy(flogi_maddr, (u8[6]) FC_FCOE_FLOGI_MAC, ETH_ALEN);
 	dev_unicast_add(fc->real_dev, flogi_maddr, ETH_ALEN);
+	if (fc->ctlr.spma)
+		dev_unicast_add(fc->real_dev, fc->ctlr.ctl_src_addr, ETH_ALEN);
 	rtnl_unlock();
 
 	/*
diff --git a/drivers/scsi/fcoe/libfcoe.c b/drivers/scsi/fcoe/libfcoe.c
index f410f4a..444a06b 100644
--- a/drivers/scsi/fcoe/libfcoe.c
+++ b/drivers/scsi/fcoe/libfcoe.c
@@ -198,6 +198,8 @@ static void fcoe_ctlr_solicit(struct fcoe_ctlr *fip, struct fcoe_fcf *fcf)
 	sol->fip.fip_subcode = FIP_SC_SOL;
 	sol->fip.fip_dl_len = htons(sizeof(sol->desc) / FIP_BPW);
 	sol->fip.fip_flags = htons(FIP_FL_FPMA);
+	if (fip->spma)
+		sol->fip.fip_flags |= htons(FIP_FL_SPMA);
 
 	sol->desc.mac.fd_desc.fip_dtype = FIP_DT_MAC;
 	sol->desc.mac.fd_desc.fip_dlen = sizeof(sol->desc.mac) / FIP_BPW;
@@ -350,6 +352,8 @@ static void fcoe_ctlr_send_keep_alive(struct fcoe_ctlr *fip, int ports, u8 *sa)
 	kal->fip.fip_dl_len = htons((sizeof(kal->mac) +
 				    ports * sizeof(*vn)) / FIP_BPW);
 	kal->fip.fip_flags = htons(FIP_FL_FPMA);
+	if (fip->spma)
+		kal->fip.fip_flags |= htons(FIP_FL_SPMA);
 
 	kal->mac.fd_desc.fip_dtype = FIP_DT_MAC;
 	kal->mac.fd_desc.fip_dlen = sizeof(kal->mac) / FIP_BPW;
@@ -413,6 +417,8 @@ static int fcoe_ctlr_encaps(struct fcoe_ctlr *fip,
 	cap->fip.fip_subcode = FIP_SC_REQ;
 	cap->fip.fip_dl_len = htons((dlen + sizeof(*mac)) / FIP_BPW);
 	cap->fip.fip_flags = htons(FIP_FL_FPMA);
+	if (fip->spma)
+		cap->fip.fip_flags |= htons(FIP_FL_SPMA);
 
 	cap->encaps.fd_desc.fip_dtype = dtype;
 	cap->encaps.fd_desc.fip_dlen = dlen / FIP_BPW;
@@ -421,8 +427,10 @@ static int fcoe_ctlr_encaps(struct fcoe_ctlr *fip,
 	memset(mac, 0, sizeof(mac));
 	mac->fd_desc.fip_dtype = FIP_DT_MAC;
 	mac->fd_desc.fip_dlen = sizeof(*mac) / FIP_BPW;
-	if (dtype != ELS_FLOGI)
+	if (dtype != FIP_DT_FLOGI)
 		memcpy(mac->fd_mac, fip->data_src_addr, ETH_ALEN);
+	else if (fip->spma)
+		memcpy(mac->fd_mac, fip->ctl_src_addr, ETH_ALEN);
 
 	skb->protocol = htons(ETH_P_802_3);
 	skb_reset_mac_header(skb);
diff --git a/include/scsi/libfcoe.h b/include/scsi/libfcoe.h
index 666cc13..b241060 100644
--- a/include/scsi/libfcoe.h
+++ b/include/scsi/libfcoe.h
@@ -73,6 +73,7 @@ enum fip_state {
  * @link:	current link status for libfc.
  * @last_link:	last link state reported to libfc.
  * @map_dest:	use the FC_MAP mode for destination MAC addresses.
+ * @spma:	supports SPMA server-provided MACs mode
  * @dest_addr:	MAC address of the selected FC forwarder.
  * @ctl_src_addr: the native MAC address of our local port.
  * @data_src_addr: the assigned MAC address for the local port after FLOGI.
@@ -104,6 +105,7 @@ struct fcoe_ctlr {
 	u8 link;
 	u8 last_link;
 	u8 map_dest;
+	u8 spma;
 	u8 dest_addr[ETH_ALEN];
 	u8 ctl_src_addr[ETH_ALEN];
 	u8 data_src_addr[ETH_ALEN];

