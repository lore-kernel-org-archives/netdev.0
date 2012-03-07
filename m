From: frank.blaschka@de.ibm.com
Subject: [patch 7/7] [PATCH] lcs: Return zero from ccwgroup devs set_offline function
Date: Wed, 07 Mar 2012 13:06:29 +0100
Message-ID: <20120307120708.254004797@de.ibm.com>
References: <20120307120622.922387262@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:38189 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755709Ab2CGMHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 07:07:15 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 7 Mar 2012 12:07:13 -0000
Content-Disposition: inline; filename=607-lcs-offline.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

A return code of non-zero of the devs ccwgroup set_offline function
leaves the dev in online state. Having done a partly offlining
may leave the dev in unusable state. To make sure the dev is set to
offline, zero is returned. A setup trace entry is written in case
the offlining steps encountered some trouble.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/lcs.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/lcs.c linux-2.6-patched/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c	2012-01-05 00:55:44.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/lcs.c	2012-03-06 13:35:58.000000000 +0100
@@ -2240,7 +2240,7 @@ __lcs_shutdown_device(struct ccwgroup_de
 {
 	struct lcs_card *card;
 	enum lcs_dev_states recover_state;
-	int ret;
+	int ret = 0, ret2 = 0, ret3 = 0;
 
 	LCS_DBF_TEXT(3, setup, "shtdndev");
 	card = dev_get_drvdata(&ccwgdev->dev);
@@ -2255,13 +2255,15 @@ __lcs_shutdown_device(struct ccwgroup_de
 	recover_state = card->state;
 
 	ret = lcs_stop_device(card->dev);
-	ret = ccw_device_set_offline(card->read.ccwdev);
-	ret = ccw_device_set_offline(card->write.ccwdev);
+	ret2 = ccw_device_set_offline(card->read.ccwdev);
+	ret3 = ccw_device_set_offline(card->write.ccwdev);
+	if (!ret)
+		ret = (ret2) ? ret2 : ret3;
+	if (ret)
+		LCS_DBF_TEXT_(3, setup, "1err:%d", ret);
 	if (recover_state == DEV_STATE_UP) {
 		card->state = DEV_STATE_RECOVER;
 	}
-	if (ret)
-		return ret;
 	return 0;
 }
 
