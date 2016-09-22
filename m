From: sthemmin@exchange.microsoft.com
Subject: [PATCH 2/7] hv_netvsc: dev hold/put reference to VF
Date: Thu, 22 Sep 2016 16:56:30 -0700
Message-ID: <1474588595-16054-3-git-send-email-sthemmin@exchange.microsoft.com>
References: <1474588595-16054-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:54166
        "EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757854AbcIVWGH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 18:06:07 -0400
In-Reply-To: <1474588595-16054-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

The netvsc driver holds a pointer to the virtual function network device if
managing SR-IOV association. In order to ensure that the VF network device
does not disappear, it should be using dev_hold/dev_put to get a reference
count.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 2360e70..e74dbcc 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1262,6 +1262,8 @@ static int netvsc_register_vf(struct net_device *vf_netdev)
 	 * Take a reference on the module.
 	 */
 	try_module_get(THIS_MODULE);
+
+	dev_hold(vf_netdev);
 	net_device_ctx->vf_netdev = vf_netdev;
 	return NOTIFY_OK;
 }
@@ -1376,6 +1378,7 @@ static int netvsc_unregister_vf(struct net_device *vf_netdev)
 	netdev_info(ndev, "VF unregistering: %s\n", vf_netdev->name);
 	netvsc_inject_disable(net_device_ctx);
 	net_device_ctx->vf_netdev = NULL;
+	dev_put(vf_netdev);
 	module_put(THIS_MODULE);
 	return NOTIFY_OK;
 }
-- 
1.7.4.1
