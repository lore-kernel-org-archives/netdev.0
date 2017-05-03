From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 09/10] net/ncsi: No error report on DP response to non-existing package
Date: Wed,  3 May 2017 14:44:40 +1000
Message-ID: <1493786681-27468-10-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:51868 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751247AbdECEqQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 00:46:16 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v434huM1050735
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 00:46:11 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a7598xeet-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 00:46:11 -0400
Received: from localhost
        by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Wed, 3 May 2017 14:46:08 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v434jwTC18874424
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:46:06 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v434jSQ0005822
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:45:28 +1000
In-Reply-To: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue was found from /sys/kernel/debug/ncsi/eth0/stats. The
first step in NCSI package/channel enumeration is deselect all
packages by sending DP (Deselect Package) commands. The remote
NIC replies with response while the corresponding package isn't
populated yet and it is treated as an error wrongly.

 # ethtool --ncsi eth0 swstats
     :
 RESPONSE     OK       TIMEOUT  ERROR
 =======================================
 DP           2        0        1

This fixes the issue by ignoring the error in DP response handler,
when the corresponding package isn't existing. With this applied,
no error reported from DP response packets.

 # ethtool --ncsi eth0 swstats
     :
 RESPONSE     OK       TIMEOUT  ERROR
 =======================================
 DP           3        0        0

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/ncsi-rsp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 41479a4..5097d86 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -118,7 +118,7 @@ static int ncsi_rsp_handler_dp(struct ncsi_request *nr)
 	ncsi_find_package_and_channel(ndp, rsp->rsp.common.channel,
 				      &np, NULL);
 	if (!np)
-		return -ENODEV;
+		return 0;
 
 	/* Change state of all channels attached to the package */
 	NCSI_FOR_EACH_CHANNEL(np, nc) {
-- 
2.7.4
