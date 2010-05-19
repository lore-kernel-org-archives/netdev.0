From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/7] ixgbe: fix wrong offset to fc_frame_header in
	ixgbe_fcoe_ddp
Date: Tue, 18 May 2010 19:00:05 -0700
Message-ID: <20100519020005.18654.75760.stgit@localhost.localdomain>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:44128 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752361Ab0ESCAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:00:06 -0400
In-Reply-To: <20100519020003.18654.94899.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Make sure we point to the right offset of the fc_frame_header when
VLAN header exists and HW has VLAN stripping disabled.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 6493049..a82d2fc 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -32,6 +32,7 @@
 #endif /* CONFIG_IXGBE_DCB */
 #include <linux/if_ether.h>
 #include <linux/gfp.h>
+#include <linux/if_vlan.h>
 #include <scsi/scsi_cmnd.h>
 #include <scsi/scsi_device.h>
 #include <scsi/fc/fc_fs.h>
@@ -312,10 +313,12 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	if (fcerr == IXGBE_FCERR_BADCRC)
 		skb->ip_summed = CHECKSUM_NONE;
 
-	skb_reset_network_header(skb);
-	skb_set_transport_header(skb, skb_network_offset(skb) +
-				 sizeof(struct fcoe_hdr));
-	fh = (struct fc_frame_header *)skb_transport_header(skb);
+	if (eth_hdr(skb)->h_proto == htons(ETH_P_8021Q))
+		fh = (struct fc_frame_header *)(skb->data +
+			sizeof(struct vlan_hdr) + sizeof(struct fcoe_hdr));
+	else
+		fh = (struct fc_frame_header *)(skb->data +
+			sizeof(struct fcoe_hdr));
 	fctl = ntoh24(fh->fh_f_ctl);
 	if (fctl & FC_FC_EX_CTX)
 		xid =  be16_to_cpu(fh->fh_ox_id);

