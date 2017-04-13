From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 3/8] net/ncsi: Enforce failover on link monitor timeout
Date: Thu, 13 Apr 2017 17:48:16 +1000
Message-ID: <1492069701-20772-4-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, davem@davemloft.net,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56452 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756460AbdDMHuJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 03:50:09 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D7o1ET020446
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:50:08 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29t19xrjbd-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:50:07 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 13 Apr 2017 17:49:27 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D7nHfS46399532
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:49:25 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D7mmXC022526
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:48:48 +1000
In-Reply-To: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NCSI channel has been configured to provide service if its link
monitor timer is enabled, regardless of its state (inactive or active).
So the timeout event on the link monitor indicates the out-of-service
on that channel, for which a failover is needed.

This sets NCSI_DEV_RESHUFFLE flag to enforce failover on link monitor
timeout, regardless the channel's original state (inactive or active).
Also, the link is put into "down" state to give the failing channel
lowest priority when selecting for the active channel. The state of
failing channel should be set to active in order for deinitialization
and failover to be done.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/ncsi-manage.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index c71a3a5..13ad1f26 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -170,6 +170,7 @@ static void ncsi_channel_monitor(unsigned long data)
 	struct ncsi_channel *nc = (struct ncsi_channel *)data;
 	struct ncsi_package *np = nc->package;
 	struct ncsi_dev_priv *ndp = np->ndp;
+	struct ncsi_channel_mode *ncm;
 	struct ncsi_cmd_arg nca;
 	bool enabled, chained;
 	unsigned int monitor_state;
@@ -214,20 +215,21 @@ static void ncsi_channel_monitor(unsigned long data)
 	case NCSI_CHANNEL_MONITOR_WAIT ... NCSI_CHANNEL_MONITOR_WAIT_MAX:
 		break;
 	default:
-		if (!(ndp->flags & NCSI_DEV_HWA) &&
-		    state == NCSI_CHANNEL_ACTIVE) {
+		if (!(ndp->flags & NCSI_DEV_HWA)) {
 			ncsi_report_link(ndp, true);
 			ndp->flags |= NCSI_DEV_RESHUFFLE;
 		}
 
+		ncm = &nc->modes[NCSI_MODE_LINK];
 		spin_lock_irqsave(&nc->lock, flags);
 		nc->state = NCSI_CHANNEL_INVISIBLE;
+		ncm->data[2] &= ~0x1;
 		spin_unlock_irqrestore(&nc->lock, flags);
 
 		ncsi_stop_channel_monitor(nc);
 
 		spin_lock_irqsave(&ndp->lock, flags);
-		nc->state = NCSI_CHANNEL_INACTIVE;
+		nc->state = NCSI_CHANNEL_ACTIVE;
 		list_add_tail_rcu(&nc->link, &ndp->channel_queue);
 		spin_unlock_irqrestore(&ndp->lock, flags);
 		ncsi_process_next_channel(ndp);
-- 
2.7.4
