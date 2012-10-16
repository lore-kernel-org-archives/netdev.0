From: frank.blaschka@de.ibm.com
Subject: [patch 2/2] [PATCH] qeth: fix deadlock between recovery and bonding driver
Date: Tue, 16 Oct 2012 07:21:18 +0200
Message-ID: <20121016052331.818724952@de.ibm.com>
References: <20121016052116.210859505@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:36284 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291Ab2JPFXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 01:23:37 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 16 Oct 2012 06:23:36 +0100
Content-Disposition: inline; filename=601-qeth-bonding-deadlock.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

The recovery thread, when failing, tears down the respective interface. To do
so, it needs to obtain the rtnl lock first, as the interface configuration is
changed.
If another process tries to modify an interface setting at the same time, that
process can obtain the rtnl lock first, but the respective callback in the qeth
driver will block until recovery has completed - which cannot happen since the
calling process already obtained it.
In one particular case, the bonding driver acquired the rtnl lock to modify the
card's MAC address, while the recovery failed at the same time due to the card
being removed. Hence qeth_l2_set_mac_address (implicitly holding the rtnl lock)
was waiting on qeth_l2_recover, which deadlocked when waiting on the rtnl lock.
This patch uses rtnl_trylock instead of rtnl_lock in the recovery thread. If the
lock cannot be obtained, the interface will be left up, but the card state
remains in CARD_STATE_RECOVER, which will prevent any further activities on the
card.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 11 ++++++-----
 drivers/s390/net/qeth_l3_main.c | 11 ++++++-----
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 2db4093..e67e025 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1141,11 +1141,12 @@ static int qeth_l2_recover(void *ptr)
 		dev_info(&card->gdev->dev,
 			"Device successfully recovered!\n");
 	else {
-		rtnl_lock();
-		dev_close(card->dev);
-		rtnl_unlock();
-		dev_warn(&card->gdev->dev, "The qeth device driver "
-			"failed to recover an error on the device\n");
+		if (rtnl_trylock()) {
+			dev_close(card->dev);
+			rtnl_unlock();
+			dev_warn(&card->gdev->dev, "The qeth device driver "
+				"failed to recover an error on the device\n");
+		}
 	}
 	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
 	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 4cd310c..5ba3906 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3510,11 +3510,12 @@ static int qeth_l3_recover(void *ptr)
 		dev_info(&card->gdev->dev,
 			"Device successfully recovered!\n");
 	else {
-		rtnl_lock();
-		dev_close(card->dev);
-		rtnl_unlock();
-		dev_warn(&card->gdev->dev, "The qeth device driver "
-			"failed to recover an error on the device\n");
+		if (rtnl_trylock()) {
+			dev_close(card->dev);
+			rtnl_unlock();
+			dev_warn(&card->gdev->dev, "The qeth device driver "
+				"failed to recover an error on the device\n");
+		}
 	}
 	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
 	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
-- 
1.7.11.7
