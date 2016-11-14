From: sunil.kovvuri@gmail.com
Subject: [PATCH 3/5] net: thunderx: Fix configuration of L3/L4 length checking
Date: Mon, 14 Nov 2016 16:24:44 +0530
Message-ID: <1479120886-13425-4-git-send-email-sunil.kovvuri@gmail.com>
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

This patch fixes enabling of HW verification of L3/L4 length and
TCP/UDP checksum which is currently being cleared. Also fixed VLAN
stripping config which is being cleared when multiqset is enabled.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index f0e0ca6..3050177 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -538,9 +538,12 @@ static void nicvf_rcv_queue_config(struct nicvf *nic, struct queue_set *qs,
 	mbx.rq.cfg = (1ULL << 62) | (RQ_CQ_DROP << 8);
 	nicvf_send_msg_to_pf(nic, &mbx);
 
-	nicvf_queue_reg_write(nic, NIC_QSET_RQ_GEN_CFG, 0, 0x00);
-	if (!nic->sqs_mode)
+	if (!nic->sqs_mode && (qidx == 0)) {
+		/* Enable checking L3/L4 length and TCP/UDP checksums */
+		nicvf_queue_reg_write(nic, NIC_QSET_RQ_GEN_CFG, 0,
+				      ((1 << 24) | (1 << 23) | (1 << 21)));
 		nicvf_config_vlan_stripping(nic, nic->netdev->features);
+	}
 
 	/* Enable Receive queue */
 	memset(&rq_cfg, 0, sizeof(struct rq_cfg));
-- 
2.7.4
