From: Joe Jin <joe.jin@oracle.com>
Subject: [PATCH 1/1] xen-netfront: update num_queues to real created
Date: Thu, 15 Oct 2015 10:34:15 +0800
Message-ID: <561F10A7.80305@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	stable@vger.kernel.org
To: wei.liu2@citrix.com, Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27983 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754535AbbJOCeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 22:34:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes xennet_create_queues() may failed to created all requested
queues, we need to update num_queues to real created to avoid NULL
pointer dereference.

Signed-off-by: Joe Jin <joe.jin@oracle.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/xen-netfront.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f821a97..d580aec 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1746,7 +1746,7 @@ static int xennet_create_queues(struct netfront_info *info,
 		dev_err(&info->netdev->dev, "no queues\n");
 		return -EINVAL;
 	}
-	return 0;
+	return num_queues;
 }
 
 /* Common code used when first setting up, and when resuming. */
@@ -1788,9 +1788,12 @@ static int talk_to_netback(struct xenbus_device *dev,
 	if (info->queues)
 		xennet_destroy_queues(info);
 
-	err = xennet_create_queues(info, num_queues);
-	if (err < 0)
+	/* Update queues number to real created */
+	num_queues = xennet_create_queues(info, num_queues);
+	if (num_queues < 0) {
+		err = num_queues;
 		goto destroy_ring;
+	}
 
 	/* Create shared ring, alloc event channel -- for each queue */
 	for (i = 0; i < num_queues; ++i) {
-- 
1.7.1
