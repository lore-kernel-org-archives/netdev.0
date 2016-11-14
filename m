From: sunil.kovvuri@gmail.com
Subject: [PATCH 5/5] net: thunderx: Fix memory leak and other issues upon
 interface toggle
Date: Mon, 14 Nov 2016 16:24:46 +0530
Message-ID: <1479120886-13425-6-git-send-email-sunil.kovvuri@gmail.com>
References: <1479120886-13425-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1479120886-13425-1-git-send-email-sunil.kovvuri@gmail.com>
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

This patch fixes the following
1. When interface is being teardown and queues are being cleaned up,
   free pending SKBs that are in SQ which are either not transmitted
   or freed as NAPI is disabled by that time.
2. While interface initialization, delay CFG_DONE notification till
   the end to avoid corner cases where TXQs are enabled but CQ
   interrupts are not which results blocking transmission and kicking
   off watchdog.
3. Check for IFF_UP while re-enabling RBDR interrupts from tasklet.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 11 +++++------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 14 +++++++++++++-
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 9dc79c05..8a37012 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -473,9 +473,6 @@ int nicvf_set_real_num_queues(struct net_device *netdev,
 static int nicvf_init_resources(struct nicvf *nic)
 {
 	int err;
-	union nic_mbx mbx = {};
-
-	mbx.msg.msg = NIC_MBOX_MSG_CFG_DONE;
 
 	/* Enable Qset */
 	nicvf_qset_config(nic, true);
@@ -488,9 +485,6 @@ static int nicvf_init_resources(struct nicvf *nic)
 		return err;
 	}
 
-	/* Send VF config done msg to PF */
-	nicvf_write_to_mbx(nic, &mbx);
-
 	return 0;
 }
 
@@ -1184,6 +1178,7 @@ int nicvf_open(struct net_device *netdev)
 	struct nicvf *nic = netdev_priv(netdev);
 	struct queue_set *qs = nic->qs;
 	struct nicvf_cq_poll *cq_poll = NULL;
+	union nic_mbx mbx = {};
 
 	netif_carrier_off(netdev);
 
@@ -1271,6 +1266,10 @@ int nicvf_open(struct net_device *netdev)
 	for (qidx = 0; qidx < qs->rbdr_cnt; qidx++)
 		nicvf_enable_intr(nic, NICVF_INTR_RBDR, qidx);
 
+	/* Send VF config done msg to PF */
+	mbx.msg.msg = NIC_MBOX_MSG_CFG_DONE;
+	nicvf_write_to_mbx(nic, &mbx);
+
 	return 0;
 cleanup:
 	nicvf_disable_intr(nic, NICVF_INTR_MBOX, 0);
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 86726ab..43ccc9d 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -271,7 +271,8 @@ static void nicvf_refill_rbdr(struct nicvf *nic, gfp_t gfp)
 			      rbdr_idx, new_rb);
 next_rbdr:
 	/* Re-enable RBDR interrupts only if buffer allocation is success */
-	if (!nic->rb_alloc_fail && rbdr->enable)
+	if (!nic->rb_alloc_fail && rbdr->enable &&
+	    netif_running(nic->pnicvf->netdev))
 		nicvf_enable_intr(nic, NICVF_INTR_RBDR, rbdr_idx);
 
 	if (rbdr_idx)
@@ -362,6 +363,8 @@ static int nicvf_init_snd_queue(struct nicvf *nic,
 
 static void nicvf_free_snd_queue(struct nicvf *nic, struct snd_queue *sq)
 {
+	struct sk_buff *skb;
+
 	if (!sq)
 		return;
 	if (!sq->dmem.base)
@@ -372,6 +375,15 @@ static void nicvf_free_snd_queue(struct nicvf *nic, struct snd_queue *sq)
 				  sq->dmem.q_len * TSO_HEADER_SIZE,
 				  sq->tso_hdrs, sq->tso_hdrs_phys);
 
+	/* Free pending skbs in the queue */
+	smp_rmb();
+	while (sq->head != sq->tail) {
+		skb = (struct sk_buff *)sq->skbuff[sq->head];
+		if (skb)
+			dev_kfree_skb_any(skb);
+		sq->head++;
+		sq->head &= (sq->dmem.q_len - 1);
+	}
 	kfree(sq->skbuff);
 	nicvf_free_q_desc_mem(nic, &sq->dmem);
 }
-- 
2.7.4
