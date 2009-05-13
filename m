From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/8] ixgbe: Add infrastructure code for FCoE
	large send offload to 82599
Date: Wed, 13 May 2009 16:10:44 -0700
Message-ID: <20090513231043.11416.23442.stgit@localhost.localdomain>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090513230924.11416.68752.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yi Zou <yi.zou@intel.com>

This adds infrastructure code for FCoE Tx side offload feature to
82599, including Fiber Channel CRC calculation, auto insertion of
the start of frame (SOF) and end of frame (EOF) of FCoE packets,
and large send by FCoE Sequence Offload (FSO).

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |  132 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 132 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index f8c4d35..e20facd 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -36,6 +36,138 @@
 #include <scsi/libfcoe.h>
 
 /**
+ * ixgbe_fso - ixgbe FCoE Sequence Offload (FSO)
+ * @adapter: ixgbe adapter
+ * @tx_ring: tx desc ring
+ * @skb: associated skb
+ * @tx_flags: tx flags
+ * @hdr_len: hdr_len to be returned
+ *
+ * This sets up large send offload for FCoE
+ *
+ * Returns : 0 indicates no FSO, > 0 for FSO, < 0 for error
+ */
+int ixgbe_fso(struct ixgbe_adapter *adapter,
+              struct ixgbe_ring *tx_ring, struct sk_buff *skb,
+              u32 tx_flags, u8 *hdr_len)
+{
+	u8 sof, eof;
+	u32 vlan_macip_lens;
+	u32 fcoe_sof_eof;
+	u32 type_tucmd;
+	u32 mss_l4len_idx;
+	int mss = 0;
+	unsigned int i;
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	struct ixgbe_adv_tx_context_desc *context_desc;
+	struct fc_frame_header *fh;
+
+	if (skb_is_gso(skb) && (skb_shinfo(skb)->gso_type != SKB_GSO_FCOE)) {
+		DPRINTK(DRV, ERR, "Wrong gso type %d:expecting SKB_GSO_FCOE\n",
+			skb_shinfo(skb)->gso_type);
+		return -EINVAL;
+	}
+
+	/* resets the header to point fcoe/fc */
+	skb_set_network_header(skb, skb->mac_len);
+	skb_set_transport_header(skb, skb->mac_len +
+				 sizeof(struct fcoe_hdr));
+
+	/* sets up SOF and ORIS */
+	fcoe_sof_eof = 0;
+	sof = ((struct fcoe_hdr *)skb_network_header(skb))->fcoe_sof;
+	switch (sof) {
+	case FC_SOF_I2:
+		fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_ORIS;
+		break;
+	case FC_SOF_I3:
+		fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_SOF;
+		fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_ORIS;
+		break;
+	case FC_SOF_N2:
+		break;
+	case FC_SOF_N3:
+		fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_SOF;
+		break;
+	default:
+		DPRINTK(DRV, WARNING, "unknown sof = 0x%x\n", sof);
+		return -EINVAL;
+	}
+
+	/* the first byte of the last dword is EOF */
+	skb_copy_bits(skb, skb->len - 4, &eof, 1);
+	/* sets up EOF and ORIE */
+	switch (eof) {
+	case FC_EOF_N:
+		fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_EOF_N;
+		break;
+	case FC_EOF_T:
+		/* lso needs ORIE */
+		if (skb_is_gso(skb)) {
+			fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_EOF_N;
+			fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_ORIE;
+		} else {
+			fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_EOF_T;
+		}
+		break;
+	case FC_EOF_NI:
+		fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_EOF_NI;
+		break;
+	case FC_EOF_A:
+		fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_EOF_A;
+		break;
+	default:
+		DPRINTK(DRV, WARNING, "unknown eof = 0x%x\n", eof);
+		return -EINVAL;
+	}
+
+	/* sets up PARINC indicating data offset */
+	fh = (struct fc_frame_header *)skb_transport_header(skb);
+	if (fh->fh_f_ctl[2] & FC_FC_REL_OFF)
+		fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_PARINC;
+
+	/* hdr_len includes fc_hdr if FCoE lso is enabled */
+	*hdr_len = sizeof(struct fcoe_crc_eof);
+	if (skb_is_gso(skb))
+		*hdr_len += (skb_transport_offset(skb) +
+			     sizeof(struct fc_frame_header));
+	/* vlan_macip_lens: HEADLEN, MACLEN, VLAN tag */
+	vlan_macip_lens = (skb_transport_offset(skb) +
+			  sizeof(struct fc_frame_header));
+	vlan_macip_lens |= ((skb_transport_offset(skb) - 4)
+			   << IXGBE_ADVTXD_MACLEN_SHIFT);
+	vlan_macip_lens |= (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK);
+
+	/* type_tycmd and mss: set TUCMD.FCoE to enable offload */
+	type_tucmd = IXGBE_TXD_CMD_DEXT | IXGBE_ADVTXD_DTYP_CTXT |
+		     IXGBE_ADVTXT_TUCMD_FCOE;
+	if (skb_is_gso(skb))
+		mss = skb_shinfo(skb)->gso_size;
+	/* mss_l4len_id: use 1 for FSO as TSO, no need for L4LEN */
+	mss_l4len_idx = (mss << IXGBE_ADVTXD_MSS_SHIFT) |
+			(1 << IXGBE_ADVTXD_IDX_SHIFT);
+
+	/* write context desc */
+	i = tx_ring->next_to_use;
+	context_desc = IXGBE_TX_CTXTDESC_ADV(*tx_ring, i);
+	context_desc->vlan_macip_lens	= cpu_to_le32(vlan_macip_lens);
+	context_desc->seqnum_seed	= cpu_to_le32(fcoe_sof_eof);
+	context_desc->type_tucmd_mlhl	= cpu_to_le32(type_tucmd);
+	context_desc->mss_l4len_idx	= cpu_to_le32(mss_l4len_idx);
+
+	tx_buffer_info = &tx_ring->tx_buffer_info[i];
+	tx_buffer_info->time_stamp = jiffies;
+	tx_buffer_info->next_to_watch = i;
+
+	i++;
+	if (i == tx_ring->count)
+		i = 0;
+	tx_ring->next_to_use = i;
+
+	return skb_is_gso(skb);
+}
+
+/**
  * ixgbe_configure_fcoe - configures registers for fcoe at start
  * @adapter: ptr to ixgbe adapter
  *

