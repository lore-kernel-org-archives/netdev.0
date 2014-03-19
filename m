From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] cxgb4: fix probe when already with invalid parameters
Date: Wed, 19 Mar 2014 15:49:54 -0300
Message-ID: <1395254994-12011-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: dm@chelsio.com,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:52346 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbaCSSuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 14:50:10 -0400
Received: from /spool/local
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Wed, 19 Mar 2014 15:50:05 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id C5E611DC0050
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 14:50:02 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2JInpP651970168
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 15:49:52 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2JIo1xV030629
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 15:50:01 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 636f9d371f70f22961fd598fe18380057518ca31 ("cxgb4: Add
support for T4 configuration file"), we have problems when probing the
device, and finding out it's already initialized, but does not have
valid buffer sizes setup.

This may happen with kexec without shutdown, or bad firmware or
bootloader.

The usual symptom is that probe fails:

[    2.605494] cxgb4 0000:50:00.4: Coming up as MASTER: Adapter already initialized
[    2.605511] cxgb4 0000:50:00.4: bad SGE FL page buffer sizes [0, 0]
[    2.625629] cxgb4: probe of 0000:50:00.4 failed with error -22

The solution is to treat the adapter as not initialized in case the
parameters are invalid.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   34 +++++++++++++---------
 1 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 34e2488..d0638f9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5237,13 +5237,27 @@ static int adap_init0(struct adapter *adap)
 	 * master initialization), note that we're living with existing
 	 * adapter parameters.  Otherwise, it's time to try initializing the
 	 * adapter ...
+	 *
+	 * If we're living with non-hard-coded parameters (either from a
+	 * Firmware Configuration File or values programmed by a different PF
+	 * Driver), give the SGE code a chance to pull in anything that it
+	 * needs ...  Note that this must be called after we retrieve our VPD
+	 * parameters in order to know how to convert core ticks to seconds.
 	 */
 	if (state == DEV_STATE_INIT) {
 		dev_info(adap->pdev_dev, "Coming up as %s: "\
 			 "Adapter already initialized\n",
 			 adap->flags & MASTER_PF ? "MASTER" : "SLAVE");
 		adap->flags |= USING_SOFT_PARAMS;
-	} else {
+		ret = t4_sge_init(adap);
+		if (ret == -EINVAL) {
+			adap->flags &= ~USING_SOFT_PARAMS;
+			state = DEV_STATE_UNINIT;
+		} else if (ret < 0) {
+			goto bye;
+		}
+	}
+	if (state != DEV_STATE_INIT) {
 		dev_info(adap->pdev_dev, "Coming up as MASTER: "\
 			 "Initializing adapter\n");
 
@@ -5300,19 +5314,11 @@ static int adap_init0(struct adapter *adap)
 				-ret);
 			goto bye;
 		}
-	}
-
-	/*
-	 * If we're living with non-hard-coded parameters (either from a
-	 * Firmware Configuration File or values programmed by a different PF
-	 * Driver), give the SGE code a chance to pull in anything that it
-	 * needs ...  Note that this must be called after we retrieve our VPD
-	 * parameters in order to know how to convert core ticks to seconds.
-	 */
-	if (adap->flags & USING_SOFT_PARAMS) {
-		ret = t4_sge_init(adap);
-		if (ret < 0)
-			goto bye;
+		if (adap->flags & USING_SOFT_PARAMS) {
+			ret = t4_sge_init(adap);
+			if (ret < 0)
+				goto bye;
+		}
 	}
 
 	if (is_bypass_device(adap->pdev->device))
-- 
1.7.1
