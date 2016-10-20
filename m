From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net 2/4] net/ncsi: Fix stale link state of inactive channels on failover
Date: Thu, 20 Oct 2016 11:45:50 +1100
Message-ID: <1476924352-31165-3-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:44567 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932509AbcJTApL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 20:45:11 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9K0iYYO009386
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:45:10 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
        by mx0a-001b2d01.pphosted.com with ESMTP id 266brh6d51-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:45:10 -0400
Received: from localhost
        by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 20 Oct 2016 10:45:07 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
        by d23dlp02.au.ibm.com (Postfix) with ESMTP id 067622BB0054
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:05 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9K0j4NB14549232
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:04 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9K0j4SM019701
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:04 +1100
In-Reply-To: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue was found on BCM5718 which has two NCSI channels in one
package: C0 and C1. Both of them are connected to different LANs,
means they are in link-up state and C0 is chosen as the active one
until resetting BCM5718 happens as below.

Resetting BCM5718 results in LSC (Link State Change) AEN packet
received on C0, meaning LSC AEN is missed on C1. When LSC AEN packet
received on C0 to report link-down, it fails over to C1 because C1
is in link-up state as software can see. However, C1 is in link-down
state in hardware. It means the link state is out of synchronization
between hardware and software, resulting in inappropriate channel (C1)
selected as active one.

This resolves the issue by sending separate GLS (Get Link Status)
commands to all channels in the package before trying to do failover.
The last link states of all channels in the package are retrieved.
With it, C0 (not C1) is selected as active one as expected.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/internal.h    |  1 +
 net/ncsi/ncsi-manage.c | 28 +++++++++++++++++++++++++++-
 2 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 13290a7..eac4858 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -246,6 +246,7 @@ enum {
 	ncsi_dev_state_config_gls,
 	ncsi_dev_state_config_done,
 	ncsi_dev_state_suspend_select	= 0x0401,
+	ncsi_dev_state_suspend_gls,
 	ncsi_dev_state_suspend_dcnt,
 	ncsi_dev_state_suspend_dc,
 	ncsi_dev_state_suspend_deselect,
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 655d0d6..4789f86 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -550,12 +550,38 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 		else
 			nca.bytes[0] = 1;
 
-		nd->state = ncsi_dev_state_suspend_dcnt;
+		/* To retrieve the last link states of channels in current
+		 * package when current active channel needs fail over to
+		 * another one. It means we will possibly select another
+		 * channel as next active one. The link states of channels
+		 * are most important factor of the selection. So we need
+		 * accurate link states. Unfortunately, the link states on
+		 * inactive channels can't be updated with LSC AEN in time.
+		 */
+		if (ndp->flags & NCSI_DEV_RESHUFFLE)
+			nd->state = ncsi_dev_state_suspend_gls;
+		else
+			nd->state = ncsi_dev_state_suspend_dcnt;
 		ret = ncsi_xmit_cmd(&nca);
 		if (ret)
 			goto error;
 
 		break;
+	case ncsi_dev_state_suspend_gls:
+		ndp->pending_req_num = np->channel_num;
+
+		nca.type = NCSI_PKT_CMD_GLS;
+		nca.package = np->id;
+
+		nd->state = ncsi_dev_state_suspend_dcnt;
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			nca.channel = nc->id;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		break;
 	case ncsi_dev_state_suspend_dcnt:
 		ndp->pending_req_num = 1;
 
-- 
2.1.0
