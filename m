From: Joe Jin <joe.jin@oracle.com>
Subject: [PATCH v2 1/1] xen-netfront: update num_queues to real created
Date: Mon, 19 Oct 2015 13:37:17 +0800
Message-ID: <5624818D.4010902@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	stable@vger.kernel.org
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	"annie.li@oracle.com" <annie.li@oracle.com>, davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sometimes xennet_create_queues() may failed to created all requested
queues, we need to update num_queues to real created to avoid NULL
pointer dereference.

Signed-off-by: Joe Jin <joe.jin@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/xen-netfront.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f821a97..6febc05 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1706,19 +1706,19 @@ static void xennet_destroy_queues(struct netfront_info *info)
 }
 
 static int xennet_create_queues(struct netfront_info *info,
-				unsigned int num_queues)
+				unsigned int *num_queues)
 {
 	unsigned int i;
 	int ret;
 
-	info->queues = kcalloc(num_queues, sizeof(struct netfront_queue),
+	info->queues = kcalloc(*num_queues, sizeof(struct netfront_queue),
 			       GFP_KERNEL);
 	if (!info->queues)
 		return -ENOMEM;
 
 	rtnl_lock();
 
-	for (i = 0; i < num_queues; i++) {
+	for (i = 0; i < *num_queues; i++) {
 		struct netfront_queue *queue = &info->queues[i];
 
 		queue->id = i;
@@ -1728,7 +1728,7 @@ static int xennet_create_queues(struct netfront_info *info,
 		if (ret < 0) {
 			dev_warn(&info->netdev->dev,
 				 "only created %d queues\n", i);
-			num_queues = i;
+			*num_queues = i;
 			break;
 		}
 
@@ -1738,11 +1738,11 @@ static int xennet_create_queues(struct netfront_info *info,
 			napi_enable(&queue->napi);
 	}
 
-	netif_set_real_num_tx_queues(info->netdev, num_queues);
+	netif_set_real_num_tx_queues(info->netdev, *num_queues);
 
 	rtnl_unlock();
 
-	if (num_queues == 0) {
+	if (*num_queues == 0) {
 		dev_err(&info->netdev->dev, "no queues\n");
 		return -EINVAL;
 	}
@@ -1788,7 +1788,7 @@ static int talk_to_netback(struct xenbus_device *dev,
 	if (info->queues)
 		xennet_destroy_queues(info);
 
-	err = xennet_create_queues(info, num_queues);
+	err = xennet_create_queues(info, &num_queues);
 	if (err < 0)
 		goto destroy_ring;
 
-- 
1.7.1
