From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 08/11] fcoe: add support to large send by gso through
	net_device for fcoe_sw
Date: Fri, 27 Feb 2009 14:07:15 -0800
Message-ID: <20090227220715.4987.56986.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change fcoe_xmit to setup gso for LLD LSO offload as well as CRC offload

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/fcoe/libfcoe.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/fcoe/libfcoe.c b/drivers/scsi/fcoe/libfcoe.c
index a99a428..5dae823 100644
--- a/drivers/scsi/fcoe/libfcoe.c
+++ b/drivers/scsi/fcoe/libfcoe.c
@@ -423,7 +423,7 @@ int fcoe_xmit(struct fc_lport *lp, struct fc_frame *fp)
 
 	/* crc offload */
 	if (likely(lp->crc_offload)) {
-		skb->ip_summed = CHECKSUM_COMPLETE;
+		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum_start = skb_headroom(skb);
 		skb->csum_offset = skb->len;
 		crc = 0;
@@ -483,6 +483,16 @@ int fcoe_xmit(struct fc_lport *lp, struct fc_frame *fp)
 		FC_FCOE_ENCAPS_VER(hp, FC_FCOE_VER);
 	hp->fcoe_sof = sof;
 
+#ifdef NETIF_F_FSO
+	/* fcoe lso, mss is in max_payload which is non-zero for FCP data */
+	if (lp->seq_offload && fr_max_payload(fp)) {
+		skb_shinfo(skb)->gso_type = SKB_GSO_FCOE;
+		skb_shinfo(skb)->gso_size = fr_max_payload(fp);
+	} else {
+		skb_shinfo(skb)->gso_type = 0;
+		skb_shinfo(skb)->gso_size = 0;
+	}
+#endif
 	/* update tx stats: regardless if LLD fails */
 	stats = lp->dev_stats[smp_processor_id()];
 	if (stats) {

