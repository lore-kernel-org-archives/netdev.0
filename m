From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH] net: return value of skb_linearize should be handled in Linux kernel
Date: Tue,  6 Dec 2016 15:10:33 +0800
Message-ID: <1481008233-16777-1-git-send-email-zhouzhouyi@gmail.com>
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>
To: <faisal.latif@intel.com>, <dledford@redhat.com>,
        <sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
        <jeffrey.t.kirsher@intel.com>, QLogic-Storage-Upstream@qlogic.com,
        <jejb@linux.vnet.ibm.com>, <martin.petersen@oracle.com>,
        <jth@kernel.org>, <jon.maloy@ericsson.com>,
        <ying.xue@windriver.com>, <davem@davemloft.net>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-scsi@vger.kernel.org, fcoe-devel@open-fcoe.org,
        tipc-discussion@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33646 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751058AbcLFHKv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 02:10:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kmalloc_reserve may fail to allocate memory inside skb_linearize, 
which means skb_linearize's return value should not be ignored. 
Following patch correct the uses of skb_linearize.

Compiled in x86_64

Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
---
 drivers/infiniband/hw/nes/nes_nic.c           | 5 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c | 6 +++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +--
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c             | 7 +++++--
 drivers/scsi/fcoe/fcoe.c                      | 5 ++++-
 net/tipc/link.c                               | 3 ++-
 net/tipc/name_distr.c                         | 5 ++++-
 7 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 2b27d13..69372ea 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -662,10 +662,11 @@ static int nes_netdev_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 				nesnic->sq_head &= nesnic->sq_size-1;
 			}
 		} else {
-			nesvnic->linearized_skbs++;
 			hoffset = skb_transport_header(skb) - skb->data;
 			nhoffset = skb_network_header(skb) - skb->data;
-			skb_linearize(skb);
+			if (skb_linearize(skb))
+				return NETDEV_TX_BUSY;
+			nesvnic->linearized_skbs++;
 			skb_set_transport_header(skb, hoffset);
 			skb_set_network_header(skb, nhoffset);
 			if (!nes_nic_send(skb, netdev))
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 2a653ec..ab787cb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -490,7 +490,11 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	 */
 	if ((fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA) &&
 	    (fctl & FC_FC_END_SEQ)) {
-		skb_linearize(skb);
+		int err = 0;
+
+		err = skb_linearize(skb);
+		if (err)
+			return err;
 		crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
 		crc->fcoe_eof = FC_EOF_T;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fee1f29..4926d48 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2173,8 +2173,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				total_rx_bytes += ddp_bytes;
 				total_rx_packets += DIV_ROUND_UP(ddp_bytes,
 								 mss);
-			}
-			if (!ddp_bytes) {
+			} else {
 				dev_kfree_skb_any(skb);
 				continue;
 			}
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index f9ddb61..197d02e 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -542,8 +542,11 @@ static void bnx2fc_recv_frame(struct sk_buff *skb)
 		return;
 	}
 
-	if (skb_is_nonlinear(skb))
-		skb_linearize(skb);
+	if (skb_linearize(skb)) {
+		kfree_skb(skb);
+		return;
+	}
+
 	mac = eth_hdr(skb)->h_source;
 	dest_mac = eth_hdr(skb)->h_dest;
 
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 9bd41a3..f691b97 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1685,7 +1685,10 @@ static void fcoe_recv_frame(struct sk_buff *skb)
 			skb->dev ? skb->dev->name : "<NULL>");
 
 	port = lport_priv(lport);
-	skb_linearize(skb); /* check for skb_is_nonlinear is within skb_linearize */
+	if (skb_linearize(skb)) {
+		kfree_skb(skb);
+		return;
+	}
 
 	/*
 	 * Frame length checks and setting up the header pointers
diff --git a/net/tipc/link.c b/net/tipc/link.c
index bda89bf..077c570 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1446,7 +1446,8 @@ static int tipc_link_proto_rcv(struct tipc_link *l, struct sk_buff *skb,
 	if (tipc_own_addr(l->net) > msg_prevnode(hdr))
 		l->net_plane = msg_net_plane(hdr);
 
-	skb_linearize(skb);
+	if (skb_linearize(skb))
+		goto exit;
 	hdr = buf_msg(skb);
 	data = msg_data(hdr);
 
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index c1cfd92..4e05d2a 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -356,7 +356,10 @@ void tipc_named_rcv(struct net *net, struct sk_buff_head *inputq)
 
 	spin_lock_bh(&tn->nametbl_lock);
 	for (skb = skb_dequeue(inputq); skb; skb = skb_dequeue(inputq)) {
-		skb_linearize(skb);
+		if (skb_linearize(skb)) {
+			kfree_skb(skb);
+			continue;
+		}
 		msg = buf_msg(skb);
 		mtype = msg_type(msg);
 		item = (struct distr_item *)msg_data(msg);
-- 
1.9.1
