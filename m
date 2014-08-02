From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next] cxgb4i : remove spurious use of rcu
Date: Sat,  2 Aug 2014 15:50:44 -0700
Message-ID: <1407019844-21148-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hch@infradead.org, kxie@chelsio.com,
	manojmalviya@chelsio.com, aaron.lu@intel.com,
	xiyou.wangcong@gmail.com, fengguang.wu@intel.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:55600
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750703AbaHBWvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 18:51:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by the intel guys, there is no need to hold rcu read lock in
cxgbi_inet6addr_handler(), this patch removes it.

Fixes: 759a0cc5a3e1 ("cxgb4i: Add ipv6 code to driver, call into libcxgbi ipv6
api")
Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index a4a4e98effdd..d31f9e600639 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1646,25 +1646,22 @@ static int cxgbi_inet6addr_handler(struct notifier_block *this,
 	struct cxgbi_device *cdev;
 	int ret = NOTIFY_DONE;
 
-	rcu_read_lock();
-
 	if (event_dev->priv_flags & IFF_802_1Q_VLAN)
 		event_dev = vlan_dev_real_dev(event_dev);
 
 	cdev = cxgbi_device_find_by_netdev(event_dev, NULL);
-	if (!cdev) {
-		rcu_read_unlock();
+
+	if (!cdev)
 		return ret;
-	}
+
 	switch (event) {
 	case NETDEV_UP:
 		ret = cxgb4_clip_get(event_dev,
 				     (const struct in6_addr *)
 				     ((ifa)->addr.s6_addr));
-		if (ret < 0) {
-			rcu_read_unlock();
+		if (ret < 0)
 			return ret;
-		}
+
 		ret = NOTIFY_OK;
 		break;
 
@@ -1679,7 +1676,6 @@ static int cxgbi_inet6addr_handler(struct notifier_block *this,
 		break;
 	}
 
-	rcu_read_unlock();
 	return ret;
 }
 
-- 
2.0.3
