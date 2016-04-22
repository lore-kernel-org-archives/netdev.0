From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v2 6/9] macsec: fix memory leaks around rx_handler (un)registration
Date: Fri, 22 Apr 2016 11:28:06 +0200
Message-ID: <ee85bd0d959d7838a7e85996cb1c4ef5fc388e89.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Cc: Lance Richardson <lrichard@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132AbcDVJ2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 05:28:40 -0400
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We leak a struct macsec_rxh_data when we unregister the rx_handler in
macsec_dellink.
We also leak a struct macsec_rxh_data in register_macsec_dev if we fail
to register the rx_handler.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/macsec.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 41fbe556ba6d..826c6c9ce7fd 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -2931,8 +2931,10 @@ static void macsec_dellink(struct net_device *dev, struct list_head *head)
 
 	unregister_netdevice_queue(dev, head);
 	list_del_rcu(&macsec->secys);
-	if (list_empty(&rxd->secys))
+	if (list_empty(&rxd->secys)) {
 		netdev_rx_handler_unregister(real_dev);
+		kfree(rxd);
+	}
 
 	macsec_del_dev(macsec);
 }
@@ -2954,8 +2956,10 @@ static int register_macsec_dev(struct net_device *real_dev,
 
 		err = netdev_rx_handler_register(real_dev, macsec_handle_frame,
 						 rxd);
-		if (err < 0)
+		if (err < 0) {
+			kfree(rxd);
 			return err;
+		}
 	}
 
 	list_add_tail_rcu(&macsec->secys, &rxd->secys);
-- 
2.8.0
