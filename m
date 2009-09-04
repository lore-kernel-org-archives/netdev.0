From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 05/11] enic: bug fix: protect fw call i/f with
	spinlock
Date: Thu, 03 Sep 2009 20:02:14 -0700
Message-ID: <20090904030213.5047.75822.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:18759 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932711AbZIDDCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:02:11 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: bug fix: protect fw call i/f with spinlock

Some driver -> nic firmware calls weren't guarded with a spinlock, exposing
the call i/f to a race between two threads

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index d77119a..8d54deb 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1315,6 +1315,7 @@ static int enic_notify_set(struct enic *enic)
 {
 	int err;
 
+	spin_lock(&enic->devcmd_lock);
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	case VNIC_DEV_INTR_MODE_INTX:
 		err = vnic_dev_notify_set(enic->vdev, ENIC_INTX_NOTIFY);
@@ -1326,6 +1327,7 @@ static int enic_notify_set(struct enic *enic)
 		err = vnic_dev_notify_set(enic->vdev, -1 /* no intr */);
 		break;
 	}
+	spin_unlock(&enic->devcmd_lock);
 
 	return err;
 }
@@ -1379,12 +1381,16 @@ static int enic_open(struct net_device *netdev)
 	for (i = 0; i < enic->rq_count; i++)
 		vnic_rq_enable(&enic->rq[i]);
 
+	spin_lock(&enic->devcmd_lock);
 	enic_add_station_addr(enic);
+	spin_unlock(&enic->devcmd_lock);
 	enic_set_multicast_list(netdev);
 
 	netif_wake_queue(netdev);
 	napi_enable(&enic->napi);
+	spin_lock(&enic->devcmd_lock);
 	vnic_dev_enable(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
 
 	for (i = 0; i < enic->intr_count; i++)
 		vnic_intr_unmask(&enic->intr[i]);
@@ -1394,7 +1400,9 @@ static int enic_open(struct net_device *netdev)
 	return 0;
 
 err_out_notify_unset:
+	spin_lock(&enic->devcmd_lock);
 	vnic_dev_notify_unset(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
 err_out_free_intr:
 	enic_free_intr(enic);
 
@@ -1410,7 +1418,9 @@ static int enic_stop(struct net_device *netdev)
 
 	del_timer_sync(&enic->notify_timer);
 
+	spin_lock(&enic->devcmd_lock);
 	vnic_dev_disable(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
 	napi_disable(&enic->napi);
 	netif_stop_queue(netdev);
 
@@ -1428,7 +1438,9 @@ static int enic_stop(struct net_device *netdev)
 			return err;
 	}
 
+	spin_lock(&enic->devcmd_lock);
 	vnic_dev_notify_unset(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
 	enic_free_intr(enic);
 
 	(void)vnic_cq_service(&enic->cq[ENIC_CQ_RQ],

