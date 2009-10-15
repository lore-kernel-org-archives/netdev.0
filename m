From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 4/5] [PATCH] lcs: Recognize return codes of ccw_device_set_online().
Date: Thu, 15 Oct 2009 10:54:58 +0200
Message-ID: <20091015090749.898475000@linux.vnet.ibm.com>
References: <20091015085454.124154000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:38927 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756436AbZJOJI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 05:08:28 -0400
Content-Disposition: inline; filename=611-lcs-set_online-rc.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

The creation of a new lcs device requires a call to the function
ccw_device_set_online() for the read and the write channel. Failure
of either call should terminate the lcs device creation immediately
with return code -ENODEV.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/lcs.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/lcs.c linux-2.6-patched/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c	2009-10-15 10:19:52.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/lcs.c	2009-10-15 10:19:52.000000000 +0200
@@ -2130,8 +2130,12 @@ lcs_new_device(struct ccwgroup_device *c
 	card->write.ccwdev = ccwgdev->cdev[1];
 
 	recover_state = card->state;
-	ccw_device_set_online(card->read.ccwdev);
-	ccw_device_set_online(card->write.ccwdev);
+	rc = ccw_device_set_online(card->read.ccwdev);
+	if (rc)
+		goto out_err;
+	rc = ccw_device_set_online(card->write.ccwdev);
+	if (rc)
+		goto out_werr;
 
 	LCS_DBF_TEXT(3, setup, "lcsnewdv");
 
@@ -2210,8 +2214,10 @@ netdev_out:
 	return 0;
 out:
 
-	ccw_device_set_offline(card->read.ccwdev);
 	ccw_device_set_offline(card->write.ccwdev);
+out_werr:
+	ccw_device_set_offline(card->read.ccwdev);
+out_err:
 	return -ENODEV;
 }
 

