From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net 3/5] net/ncsi: Fix stale link state of inactive channels on failover
Date: Fri, 14 Oct 2016 13:53:32 +1100
Message-ID: <1476413614-24586-4-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:36417 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752041AbcJNCyo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 22:54:44 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9E2nFKm087593
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 22:53:04 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
        by mx0b-001b2d01.pphosted.com with ESMTP id 262fh2qfw3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 22:53:04 -0400
Received: from localhost
        by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Fri, 14 Oct 2016 12:53:01 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id 4BA9D2CE8056
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:58 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9E2qwsd18743544
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:58 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9E2qvp6027358
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 13:52:58 +1100
In-Reply-To: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue was found on BCM5718 which has two NCSI channels in one
package: C0 and C1. Both of them are connected to different LANs,
means they are in link-up state and C0 is chosen  as the active
one until resetting BCM5718 happens as below.

Resetting BCM5718 results in LSC (Link State Change) AEN packet
received on C0, meaning LSC AEN is missed on C1. When LSC AEN packet
received on C0 to report link-down, it fails over to C1 because C1
is in link-up state as software can see. However, C1 is in link-down
state in hardware. It means the link state is out of synchronization
between hardware and software, resulting in inappropriate channel (C1)
selected as active one.

This resolves the issue by sending separate GLS (Get Link Status)
commands to all channels in the package before trying to do failover.
The last link state on all channels in the package is retrieved. With
it, C0 is selected as active one as expected.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/internal.h    |  1 +
 net/ncsi/ncsi-manage.c | 20 +++++++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletion(-)

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
index 5758a26..e959979 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -550,13 +550,31 @@ static void ncsi_suspend_channel(struct ncsi_dev_priv *ndp)
 		else
 			nca.bytes[0] = 1;
 
-		nd->state = ncsi_dev_state_suspend_dcnt;
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
+		nd->state = ncsi_dev_state_suspend_dcnt;
+
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			nca.channel = nc->id;
+			ret = ncsi_xmit_cmd(&nca);
+			if (ret)
+				goto error;
+		}
+
+		break;
 	case ncsi_dev_state_suspend_dcnt:
 	case ncsi_dev_state_suspend_dc:
 	case ncsi_dev_state_suspend_deselect:
-- 
2.1.0
