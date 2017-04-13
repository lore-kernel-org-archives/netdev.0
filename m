From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 7/8] net/ncsi: No error report on DP response to non-existing package
Date: Thu, 13 Apr 2017 17:48:20 +1000
Message-ID: <1492069701-20772-8-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, davem@davemloft.net,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53761 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756457AbdDMHuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 03:50:03 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D7nac9103572
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:50:02 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29t59b00hd-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:50:01 -0400
Received: from localhost
        by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 13 Apr 2017 17:49:55 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D7neFD48431190
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:49:48 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D7nGqC007307
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:49:16 +1000
In-Reply-To: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue was found from /sys/kernel/debug/ncsi/eth0/stats. The
first step in NCSI package/channel enumeration is deselect all
packages by sending DP (Deselect Package) commands. The remote
NIC replies with response while the corresponding package isn't
populated yet and it is treated as an error wrongly.

 # cat /sys/kernel/debug/ncsi/eth0/stats
 :
 RSP          OK       TIMEOUT  ERROR
 =======================================
 CIS          3        0        0
 SP           3        0        0
 DP           2        0        1

This fixes the issue by ignoring the error in DP response handler,
when the corresponding package isn't existing. With this applied,
no error reported from DP response packets.

 # cat /sys/kernel/debug/ncsi/eth0/stats
 :
 RSP          OK       TIMEOUT  ERROR
 =======================================
 CIS          3        0        0
 SP           3        0        0
 DP           3        0        0

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/ncsi-rsp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 93ebe0f..095726f 100644
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
