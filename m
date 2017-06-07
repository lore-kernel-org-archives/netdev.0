From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net v2 2/3] netvsc: fix net poll mode
Date: Wed,  7 Jun 2017 15:53:48 -0700
Message-ID: <20170607225349.28359-3-sthemmin@microsoft.com>
References: <20170607225349.28359-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34584 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751478AbdFGWyA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 18:54:00 -0400
Received: by mail-pf0-f176.google.com with SMTP id 9so10404966pfj.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 15:54:00 -0700 (PDT)
In-Reply-To: <20170607225349.28359-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ndo_poll_controller function needs to schedule NAPI to pick
up arriving packets and send completions. Otherwise no data
will ever be received. For simple case of netconsole, it also
will allow send completions to happen.  Without this netpoll
will eventually get stuck.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index d93e4da25fd2..252e5d52d17e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1158,11 +1158,22 @@ netvsc_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void netvsc_poll_controller(struct net_device *net)
+static void netvsc_poll_controller(struct net_device *dev)
 {
-	/* As netvsc_start_xmit() works synchronous we don't have to
-	 * trigger anything here.
-	 */
+	struct net_device_context *ndc = netdev_priv(dev);
+	struct netvsc_device *ndev;
+	int i;
+
+	rcu_read_lock();
+	ndev = rcu_dereference(ndc->nvdev);
+	if (ndev) {
+		for (i = 0; i < ndev->num_chn; i++) {
+			struct netvsc_channel *nvchan = &ndev->chan_table[i];
+
+			napi_schedule(&nvchan->napi);
+		}
+	}
+	rcu_read_unlock();
 }
 #endif
 
-- 
2.11.0
