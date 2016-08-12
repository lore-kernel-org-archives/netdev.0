From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 04/21] net: thunderx: Set queue count based on number of
 CPUs
Date: Fri, 12 Aug 2016 16:51:27 +0530
Message-ID: <1471000904-21715-5-git-send-email-sunil.kovvuri@gmail.com>
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

81xx has only 4 CPUs, so it doesn't make sense to initialize
entire Qset i.e 8 queues by default. Made changes to queue
initialization to init queues equal to number of CPUs or
8 queues whichever is lesser. Also this will be applicable to
VMs with VNIC VF attached and having less VCPUs

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c     | 6 ++++++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 7 +++----
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 8 ++++----
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h | 5 +----
 4 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 4974923..0d81117 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -1009,6 +1009,12 @@ static int nic_num_sqs_en(struct nicpf *nic, int vf_en)
 	int pos, sqs_per_vf = MAX_SQS_PER_VF_SINGLE_NODE;
 	u16 total_vf;
 
+	/* Secondary Qsets are needed only if CPU count is
+	 * morethan MAX_QUEUES_PER_QSET.
+	 */
+	if (num_online_cpus() <= MAX_QUEUES_PER_QSET)
+		return 0;
+
 	/* Check if its a multi-node environment */
 	if (nr_node_ids > 1)
 		sqs_per_vf = MAX_SQS_PER_VF;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 0c10635..d9efe2f 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1537,14 +1537,13 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_release_regions;
 	}
 
-	qcount = MAX_CMP_QUEUES_PER_QS;
+	qcount = netif_get_num_default_rss_queues();
 
 	/* Restrict multiqset support only for host bound VFs */
 	if (pdev->is_virtfn) {
 		/* Set max number of queues per VF */
-		qcount = roundup(num_online_cpus(), MAX_CMP_QUEUES_PER_QS);
-		qcount = min(qcount,
-			     (MAX_SQS_PER_VF + 1) * MAX_CMP_QUEUES_PER_QS);
+		qcount = min_t(int, num_online_cpus(),
+			       (MAX_SQS_PER_VF + 1) * MAX_CMP_QUEUES_PER_QS);
 	}
 
 	netdev = alloc_etherdev_mqs(sizeof(struct nicvf), qcount, qcount);
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 0ff8e60..e521a94 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -762,10 +762,10 @@ int nicvf_set_qset_resources(struct nicvf *nic)
 	nic->qs = qs;
 
 	/* Set count of each queue */
-	qs->rbdr_cnt = RBDR_CNT;
-	qs->rq_cnt = RCV_QUEUE_CNT;
-	qs->sq_cnt = SND_QUEUE_CNT;
-	qs->cq_cnt = CMP_QUEUE_CNT;
+	qs->rbdr_cnt = DEFAULT_RBDR_CNT;
+	qs->rq_cnt = min_t(u8, MAX_RCV_QUEUES_PER_QS, num_online_cpus());
+	qs->sq_cnt = min_t(u8, MAX_SND_QUEUES_PER_QS, num_online_cpus());
+	qs->cq_cnt = max_t(u8, qs->rq_cnt, qs->sq_cnt);
 
 	/* Set queue lengths */
 	qs->rbdr_len = RCV_BUF_COUNT;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index 6673e11..869f338 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -57,10 +57,7 @@
 #define CMP_QUEUE_SIZE6		6ULL /* 64K entries */
 
 /* Default queue count per QS, its lengths and threshold values */
-#define RBDR_CNT		1
-#define RCV_QUEUE_CNT		8
-#define SND_QUEUE_CNT		8
-#define CMP_QUEUE_CNT		8 /* Max of RCV and SND qcount */
+#define DEFAULT_RBDR_CNT	1
 
 #define SND_QSIZE		SND_QUEUE_SIZE2
 #define SND_QUEUE_LEN		(1ULL << (SND_QSIZE + 10))
-- 
2.7.4
