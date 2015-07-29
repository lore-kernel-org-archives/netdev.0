From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH net 03/11] net: thunderx: Fix RQ_DROP miscalculation
Date: Wed, 29 Jul 2015 16:49:38 +0300
Message-ID: <1438177787-20940-4-git-send-email-aleksey.makarov@caviumnetworks.com>
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

With earlier configured value sufficient number of CQEs are not
being reserved for transmitted packets. Hence under heavy incoming
traffic load, receive notifications will take away most of the CQ
thus transmit notifications will be lost resulting in tx skbs not
being freed.

Finally SQ will be full and it will be stopped, watchdog timer
will kick in. After this fix receive notifications will not take
morethan half of CQ reserving the rest for transmit notifications.

Also changed CQ & SQ sizes from 16k to 4k.
This is also due to the receive notifications taking first half of
CQ under heavy load and time taken by NAPI to clear transmit notifications
will increase with higher queue sizes. Again results in SQ being stopped.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index 8341bdf..f0937b7 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -62,7 +62,7 @@
 #define SND_QUEUE_CNT		8
 #define CMP_QUEUE_CNT		8 /* Max of RCV and SND qcount */
 
-#define SND_QSIZE		SND_QUEUE_SIZE4
+#define SND_QSIZE		SND_QUEUE_SIZE2
 #define SND_QUEUE_LEN		(1ULL << (SND_QSIZE + 10))
 #define MAX_SND_QUEUE_LEN	(1ULL << (SND_QUEUE_SIZE6 + 10))
 #define SND_QUEUE_THRESH	2ULL
@@ -70,7 +70,10 @@
 /* Since timestamp not enabled, otherwise 2 */
 #define MAX_CQE_PER_PKT_XMIT		1
 
-#define CMP_QSIZE		CMP_QUEUE_SIZE4
+/* Keep CQ and SQ sizes same, if timestamping
+ * is enabled this equation will change.
+ */
+#define CMP_QSIZE		CMP_QUEUE_SIZE2
 #define CMP_QUEUE_LEN		(1ULL << (CMP_QSIZE + 10))
 #define CMP_QUEUE_CQE_THRESH	0
 #define CMP_QUEUE_TIMER_THRESH	220 /* 10usec */
@@ -87,7 +90,12 @@
 
 #define MAX_CQES_FOR_TX		((SND_QUEUE_LEN / MIN_SQ_DESC_PER_PKT_XMIT) * \
 				 MAX_CQE_PER_PKT_XMIT)
-#define RQ_CQ_DROP		((CMP_QUEUE_LEN - MAX_CQES_FOR_TX) / 256)
+/* Calculate number of CQEs to reserve for all SQEs.
+ * Its 1/256th level of CQ size.
+ * '+ 1' to account for pipelining
+ */
+#define RQ_CQ_DROP		((256 / (CMP_QUEUE_LEN / \
+				 (CMP_QUEUE_LEN - MAX_CQES_FOR_TX))) + 1)
 
 /* Descriptor size in bytes */
 #define SND_QUEUE_DESC_SIZE	16
-- 
2.4.6
