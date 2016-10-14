From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net 2/5] net/ncsi: Split out logic for ncsi_dev_state_suspend_select
Date: Fri, 14 Oct 2016 13:53:31 +1100
Message-ID: <1476413614-24586-3-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52268 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751559AbcJNCyo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 22:54:44 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9E2nDIn067177
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 22:53:02 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 262h973656-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 22:53:02 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Fri, 14 Oct 2016 12:52:59 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id 95DE52CE8046
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:57 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9E2qv2f19988636
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:57 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9E2qv67001470
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:57 +1100
In-Reply-To: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This splits out the code that handles ncsi_dev_state_suspend_select
so that we can add more code to the handler in subsequent patch.
Apart from adding a error tag to reuse the code in error path,
no logical changes introduced.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/ncsi-manage.c | 38 +++++++++++++++++++++++++-------------
 1 file changed, 25 insertions(+), 13 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 1bc96dc..5758a26 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -540,21 +540,30 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 		nd->state = ncsi_dev_state_suspend_select;
 		/* Fall through */
 	case ncsi_dev_state_suspend_select:
+		ndp->pending_req_num = 1;
+
+		nca.type = NCSI_PKT_CMD_SP;
+		nca.package = np->id;
+		nca.channel = NCSI_RESERVED_CHANNEL;
+		if (ndp->flags & NCSI_DEV_HWA)
+			nca.bytes[0] = 0;
+		else
+			nca.bytes[0] = 1;
+
+		nd->state = ncsi_dev_state_suspend_dcnt;
+
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		break;
 	case ncsi_dev_state_suspend_dcnt:
 	case ncsi_dev_state_suspend_dc:
 	case ncsi_dev_state_suspend_deselect:
 		ndp->pending_req_num = 1;
 
 		nca.package = np->id;
-		if (nd->state == ncsi_dev_state_suspend_select) {
-			nca.type = NCSI_PKT_CMD_SP;
-			nca.channel = NCSI_RESERVED_CHANNEL;
-			if (ndp->flags & NCSI_DEV_HWA)
-				nca.bytes[0] = 0;
-			else
-				nca.bytes[0] = 1;
-			nd->state = ncsi_dev_state_suspend_dcnt;
-		} else if (nd->state == ncsi_dev_state_suspend_dcnt) {
+		if (nd->state == ncsi_dev_state_suspend_dcnt) {
 			nca.type = NCSI_PKT_CMD_DCNT;
 			nca.channel = nc->id;
 			nd->state = ncsi_dev_state_suspend_dc;
@@ -570,10 +579,8 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 		}
 
 		ret = ncsi_xmit_cmd(&nca);
-		if (ret) {
-			nd->state = ncsi_dev_state_functional;
-			return;
-		}
+		if (ret)
+			goto error;
 
 		break;
 	case ncsi_dev_state_suspend_done:
@@ -587,6 +594,11 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 		netdev_warn(nd->dev, "Wrong NCSI state 0x%x in suspend\n",
 			    nd->state);
 	}
+
+	return;
+
+error:
+	nd->state = ncsi_dev_state_functional;
 }
 
 static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
-- 
2.1.0
