From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] NET: cassini, fix lock imbalance
Date: Fri,  6 Nov 2009 10:14:29 +0100
Message-ID: <1257498869-4374-1-git-send-email-jirislaby@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1.wserver.cz ([82.113.45.157]:41041 "EHLO
	server1.wserver.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249AbZKFJO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 04:14:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanse found that one error path in cas_open omits to unlock pm_mutex.
Fix that.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
---
 drivers/net/cassini.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 05916aa..f857afe 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4342,11 +4342,11 @@ static int cas_open(struct net_device *dev)
 		cas_unlock_all_restore(cp, flags);
 	}
 
+	err = -ENOMEM;
 	if (cas_tx_tiny_alloc(cp) < 0)
-		return -ENOMEM;
+		goto err_unlock;
 
 	/* alloc rx descriptors */
-	err = -ENOMEM;
 	if (cas_alloc_rxds(cp) < 0)
 		goto err_tx_tiny;
 
@@ -4386,6 +4386,7 @@ err_spare:
 	cas_free_rxds(cp);
 err_tx_tiny:
 	cas_tx_tiny_free(cp);
+err_unlock:
 	mutex_unlock(&cp->pm_mutex);
 	return err;
 }
-- 
1.6.4.2

