From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 01/10] net/ncsi: Disable HWA mode when no channels are found
Date: Wed,  3 May 2017 14:44:32 +1000
Message-ID: <1493786681-27468-2-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38677 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750819AbdECEpr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 00:45:47 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v434hvF1094411
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 00:45:46 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2a72kpv6av-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 00:45:46 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Wed, 3 May 2017 14:45:43 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v434jX8248562230
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:45:41 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v434j30Z004680
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:45:04 +1000
In-Reply-To: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there are no NCSI channels probed, HWA (Hardware Arbitration)
mode is enabled. It's not correct because HWA depends on the fact:
NCSI channels exist and all of them support HWA mode. This disables
HWA when no channels are probed.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/ncsi-manage.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index a3bd5fa..5073e15 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -839,12 +839,15 @@ static bool ncsi_check_hwa(struct ncsi_dev_priv *ndp)
 	struct ncsi_package *np;
 	struct ncsi_channel *nc;
 	unsigned int cap;
+	bool has_channel = false;
 
 	/* The hardware arbitration is disabled if any one channel
 	 * doesn't support explicitly.
 	 */
 	NCSI_FOR_EACH_PACKAGE(ndp, np) {
 		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			has_channel = true;
+
 			cap = nc->caps[NCSI_CAP_GENERIC].cap;
 			if (!(cap & NCSI_CAP_GENERIC_HWA) ||
 			    (cap & NCSI_CAP_GENERIC_HWA_MASK) !=
@@ -855,8 +858,13 @@ static bool ncsi_check_hwa(struct ncsi_dev_priv *ndp)
 		}
 	}
 
-	ndp->flags |= NCSI_DEV_HWA;
-	return true;
+	if (has_channel) {
+		ndp->flags |= NCSI_DEV_HWA;
+		return true;
+	}
+
+	ndp->flags &= ~NCSI_DEV_HWA;
+	return false;
 }
 
 static int ncsi_enable_hwa(struct ncsi_dev_priv *ndp)
-- 
2.7.4
