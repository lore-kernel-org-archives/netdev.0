From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] phonet: use call_rcu for phonet device free
Date: Mon, 7 Jun 2010 15:27:39 +0200
Message-ID: <20100607132738.GB2730@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, remi.denis-courmont@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732Ab0FGN1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 09:27:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use call_rcu rather than synchronize_rcu.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/net/phonet/pn_dev.h |    1 +
 net/phonet/pn_dev.c         |   15 +++++++++++----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index d7b989c..2d16783 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -34,6 +34,7 @@ struct phonet_device {
 	struct list_head list;
 	struct net_device *netdev;
 	DECLARE_BITMAP(addrs, 64);
+	struct rcu_head	rcu;
 };
 
 int phonet_device_init(void);
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index c33da65..b18e48f 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -162,6 +162,14 @@ int phonet_address_add(struct net_device *dev, u8 addr)
 	return err;
 }
 
+static void phonet_device_rcu_free(struct rcu_head *head)
+{
+	struct phonet_device *pnd;
+
+	pnd = container_of(head, struct phonet_device, rcu);
+	kfree(pnd);
+}
+
 int phonet_address_del(struct net_device *dev, u8 addr)
 {
 	struct phonet_device_list *pndevs = phonet_device_list(dev_net(dev));
@@ -179,10 +187,9 @@ int phonet_address_del(struct net_device *dev, u8 addr)
 		pnd = NULL;
 	mutex_unlock(&pndevs->lock);
 
-	if (pnd) {
-		synchronize_rcu();
-		kfree(pnd);
-	}
+	if (pnd)
+		call_rcu(&pnd->rcu, phonet_device_rcu_free);
+
 	return err;
 }
 
-- 
1.7.0.1

