From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH net 08/11] net: thunderx: Set watchdog timeout value
Date: Wed, 29 Jul 2015 16:49:43 +0300
Message-ID: <1438177787-20940-9-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rric@kernel.org>, David Daney <david.daney@cavium.com>,
 Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org,
 Robert Richter <robert.richter@caviumnetworks.com>,
 Sunil Goutham <sgoutham@cavium.com>, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
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

If a txq (SQ) remains in stopped state after this timeout its
considered as stuck and interface is reinited.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h        | 9 +++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 1 +
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index a0be076..8aee250 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -125,6 +125,15 @@
  */
 #define NICPF_CLK_PER_INT_TICK		2
 
+/* Time to wait before we decide that a SQ is stuck.
+ *
+ * Since both pkt rx and tx notifications are done with same CQ,
+ * when packets are being received at very high rate (eg: L2 forwarding)
+ * then freeing transmitted skbs will be delayed and watchdog
+ * will kick in, resetting interface. Hence keeping this value high.
+ */
+#define	NICVF_TX_TIMEOUT		(50 * HZ)
+
 struct nicvf_cq_poll {
 	u8	cq_idx;		/* Completion queue index */
 	struct	napi_struct napi;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 422d46e..abee2d7 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1293,6 +1293,7 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->hw_features = netdev->features;
 
 	netdev->netdev_ops = &nicvf_netdev_ops;
+	netdev->watchdog_timeo = NICVF_TX_TIMEOUT;
 
 	INIT_WORK(&nic->reset_task, nicvf_reset_task);
 
-- 
2.4.6
