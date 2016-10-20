From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net 1/4] net/ncsi: Avoid if statements in ncsi_suspend_channel()
Date: Thu, 20 Oct 2016 11:45:49 +1100
Message-ID: <1476924352-31165-2-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47031 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932727AbcJTApM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 20:45:12 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9K0htX8057036
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:45:11 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
        by mx0b-001b2d01.pphosted.com with ESMTP id 266bjgevc8-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:45:11 -0400
Received: from localhost
        by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 20 Oct 2016 10:45:07 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id A38492CE8059
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:04 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9K0j481459108
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:04 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
        by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9K0j4PR009652
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:04 +1100
In-Reply-To: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several if/else statements in the state machine implemented
by switch/case in ncsi_suspend_channel() to avoid duplicated code. It
makes the code a bit hard to be understood.

This drops if/else statements in ncsi_suspend_channel() to improve the
code readability as Joel Stanley suggested. Also, it becomes easy to
add more states in the state machine without affecting current code.
No logical changes introduced by this.

Suggested-by: Joel Stanley <joel@jms.id.au>
Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/ncsi-manage.c | 78 ++++++++++++++++++++++++++++++++------------------
 1 file changed, 50 insertions(+), 28 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 5e509e5..655d0d6 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -540,42 +540,60 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
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
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		break;
 	case ncsi_dev_state_suspend_dcnt:
+		ndp->pending_req_num = 1;
+
+		nca.type = NCSI_PKT_CMD_DCNT;
+		nca.package = np->id;
+		nca.channel = nc->id;
+
+		nd->state = ncsi_dev_state_suspend_dc;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		break;
 	case ncsi_dev_state_suspend_dc:
+		ndp->pending_req_num = 1;
+
+		nca.type = NCSI_PKT_CMD_DC;
+		nca.package = np->id;
+		nca.channel = nc->id;
+		nca.bytes[0] = 1;
+
+		nd->state = ncsi_dev_state_suspend_deselect;
+		ret = ncsi_xmit_cmd(&nca);
+		if (ret)
+			goto error;
+
+		break;
 	case ncsi_dev_state_suspend_deselect:
 		ndp->pending_req_num = 1;
 
-		np = ndp->active_package;
-		nc = ndp->active_channel;
+		nca.type = NCSI_PKT_CMD_DP;
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
-			nca.type = NCSI_PKT_CMD_DCNT;
-			nca.channel = nc->id;
-			nd->state = ncsi_dev_state_suspend_dc;
-		} else if (nd->state == ncsi_dev_state_suspend_dc) {
-			nca.type = NCSI_PKT_CMD_DC;
-			nca.channel = nc->id;
-			nca.bytes[0] = 1;
-			nd->state = ncsi_dev_state_suspend_deselect;
-		} else if (nd->state == ncsi_dev_state_suspend_deselect) {
-			nca.type = NCSI_PKT_CMD_DP;
-			nca.channel = NCSI_RESERVED_CHANNEL;
-			nd->state = ncsi_dev_state_suspend_done;
-		}
+		nca.channel = NCSI_RESERVED_CHANNEL;
 
+		nd->state = ncsi_dev_state_suspend_done;
 		ret = ncsi_xmit_cmd(&nca);
-		if (ret) {
-			nd->state = ncsi_dev_state_functional;
-			return;
-		}
+		if (ret)
+			goto error;
 
 		break;
 	case ncsi_dev_state_suspend_done:
@@ -589,6 +607,10 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 		netdev_warn(nd->dev, "Wrong NCSI state 0x%x in suspend\n",
 			    nd->state);
 	}
+
+	return;
+error:
+	nd->state = ncsi_dev_state_functional;
 }
 
 static void ncsi_configure_channel(struct ncsi_dev_priv *ndp)
-- 
2.1.0
