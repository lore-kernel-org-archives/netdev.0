From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 05/21] net: thunderx: Enable CQE_RX desc's extension fields
Date: Fri, 12 Aug 2016 16:51:28 +0530
Message-ID: <1471000904-21715-6-git-send-email-sunil.kovvuri@gmail.com>
References: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Unlike 88xx, CQE_RX descriptor's tunnelling extension i.e CQE_RX2_S
is always enabled on 81xx/83xx and HW does insert these fields into
CQE_RX. As a result receive buffer addresses will now be present at
7th word of CQE_RX instead of 6th.

Enable CQE_RX2_S on 88xx pass 2.x as well.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |  9 ++++++++-
 drivers/net/ethernet/cavium/thunder/nic_main.c     |  7 +++++++
 drivers/net/ethernet/cavium/thunder/nic_reg.h      |  1 +
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 12 +++++++++++-
 4 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 6b0b240..136db2a 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -493,7 +493,14 @@ static inline int nic_get_node_id(struct pci_dev *pdev)
 
 static inline bool pass1_silicon(struct pci_dev *pdev)
 {
-	return pdev->revision < 8;
+	return (pdev->revision < 8) &&
+		(pdev->subsystem_device == PCI_SUBSYS_DEVID_88XX_NIC_PF);
+}
+
+static inline bool pass2_silicon(struct pci_dev *pdev)
+{
+	return (pdev->revision >= 8) &&
+		(pdev->subsystem_device == PCI_SUBSYS_DEVID_88XX_NIC_PF);
 }
 
 int nicvf_set_real_num_queues(struct net_device *netdev,
diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 0d81117..3f52b36 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -799,6 +799,13 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 			   (mbx.rq.qs_num << NIC_QS_ID_SHIFT) |
 			   (mbx.rq.rq_num << NIC_Q_NUM_SHIFT);
 		nic_reg_write(nic, reg_addr, mbx.rq.cfg);
+		/* Enable CQE_RX2_S extension in CQE_RX descriptor.
+		 * This gets appended by default on 81xx/83xx chips,
+		 * for consistency enabling the same on 88xx pass2
+		 * where this is introduced.
+		 */
+		if (pass2_silicon(nic->pdev))
+			nic_reg_write(nic, NIC_PF_RX_CFG, 0x01);
 		break;
 	case NIC_MBOX_MSG_RQ_BP_CFG:
 		reg_addr = NIC_PF_QSET_0_127_RQ_0_7_BP_CFG |
diff --git a/drivers/net/ethernet/cavium/thunder/nic_reg.h b/drivers/net/ethernet/cavium/thunder/nic_reg.h
index 833cf3d..b4a7953 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_reg.h
+++ b/drivers/net/ethernet/cavium/thunder/nic_reg.h
@@ -36,6 +36,7 @@
 #define   NIC_PF_MAILBOX_ENA_W1C		(0x0450)
 #define   NIC_PF_MAILBOX_ENA_W1S		(0x0470)
 #define   NIC_PF_RX_ETYPE_0_7			(0x0500)
+#define   NIC_PF_RX_CFG				(0x05D0)
 #define   NIC_PF_PKIND_0_15_CFG			(0x0600)
 #define   NIC_PF_ECC0_FLIP0			(0x1000)
 #define   NIC_PF_ECC1_FLIP0			(0x1008)
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index e521a94..ca223aa 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -1190,7 +1190,17 @@ struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
 	u64 *rb_ptrs = NULL;
 
 	rb_lens = (void *)cqe_rx + (3 * sizeof(u64));
-	rb_ptrs = (void *)cqe_rx + (6 * sizeof(u64));
+	/* Except 88xx pass1 on all other chips CQE_RX2_S is added to
+	 * CQE_RX at word6, hence buffer pointers move by word
+	 *
+	 * Use existing 'hw_tso' flag which will be set for all chips
+	 * except 88xx pass1 instead of a additional cache line
+	 * access (or miss) by using pci dev's revision.
+	 */
+	if (!nic->hw_tso)
+		rb_ptrs = (void *)cqe_rx + (6 * sizeof(u64));
+	else
+		rb_ptrs = (void *)cqe_rx + (7 * sizeof(u64));
 
 	netdev_dbg(nic->netdev, "%s rb_cnt %d rb0_ptr %llx rb0_sz %d\n",
 		   __func__, cqe_rx->rb_cnt, cqe_rx->rb0_ptr, cqe_rx->rb0_sz);
-- 
2.7.4
