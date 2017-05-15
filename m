From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 1/2] ldmvsw: unregistering netdev before disable hardware
Date: Mon, 15 May 2017 10:51:07 -0700
Message-ID: <1494870668-65047-2-git-send-email-shannon.nelson@oracle.com>
References: <1494870668-65047-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, Thomas Tai <thomas.tai@oracle.com>,
        Shannon Nelson <shannon.nelson@oracle.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32447 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757956AbdEORzO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 13:55:14 -0400
In-Reply-To: <1494870668-65047-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Tai <thomas.tai@oracle.com>

When running LDom binding/unbinding test, kernel may panic
in ldmvsw_open(). It is more likely that because we're removing
the ldc connection before unregistering the netdev in vsw_port_remove(),
we set up a window of time where one process could be removing the
device while another trying to UP the device. This also sometimes causes
vio handshake error due to opening a device without closing it completely.
We should unregister the netdev before we disable the "hardware".

Orabug: 25980913, 25925306

Signed-off-by: Thomas Tai <thomas.tai@oracle.com>
Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 5a90fed..309747c 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -413,6 +413,7 @@ static int vsw_port_remove(struct vio_dev *vdev)
 		del_timer_sync(&port->vio.timer);
 
 		napi_disable(&port->napi);
+		unregister_netdev(port->dev);
 
 		list_del_rcu(&port->list);
 
@@ -427,7 +428,6 @@ static int vsw_port_remove(struct vio_dev *vdev)
 
 		dev_set_drvdata(&vdev->dev, NULL);
 
-		unregister_netdev(port->dev);
 		free_netdev(port->dev);
 	}
 
-- 
1.7.1
