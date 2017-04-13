From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/8] net/ncsi: Properly track channel monitor timer state
Date: Thu, 13 Apr 2017 12:46:34 +1000
Message-ID: <1492051600-26706-3-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1492051600-26706-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:58435 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755943AbdDMCsn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 22:48:43 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D2j6vs123423
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 22:48:42 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29ssdkr7uq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 22:48:42 -0400
Received: from localhost
        by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 13 Apr 2017 12:48:40 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D2mTGU41615604
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 12:48:37 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D2m0Hp023451
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 12:48:01 +1000
In-Reply-To: <1492051600-26706-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The field @monitor.enabled in the NCSI channel descriptor is used
to track the state of channel monitor timer. It indicates the timer's
state (pending or not). We could not start the timer again in its
handler. In that case, We missed to update @monitor.enabled to false.
It leads to below warning printed by WARN_ON_ONCE() when the monitor
is restarted afterwards.

   ------------[ cut here ]------------
   WARNING: CPU: 0 PID: 411 at /var/lib/jenkins/workspace/openbmc-build \
   /distro/ubuntu/target/palmetto/openbmc/build/tmp/work-shared/palmetto \
   net/ncsi/ncsi-manage.c:240 ncsi_start_channel_monitor+0x44/0x7c
   CPU: 0 PID: 411 Comm: kworker/0:3 Not tainted \
   4.7.10-f26558191540830589fe03932d05577957670b8d #1
   Hardware name: ASpeed SoC
   Workqueue: events ncsi_dev_work
   [<c0106cbc>] (unwind_backtrace) from [<c0104f04>] (show_stack+0x10/0x14)
   [<c0104f04>] (show_stack) from [<c010eef8>] (__warn+0xc4/0xf0)
   [<c010eef8>] (__warn) from [<c010f018>] (warn_slowpath_null+0x1c/0x24)
   [<c010f018>] (warn_slowpath_null) from [<c03e1d10>] (ncsi_start_channel_monitor+0x44/0x7c)
   [<c03e1d10>] (ncsi_start_channel_monitor) from [<c03e29c4>] (ncsi_configure_channel+0x27c/0x2dc)
   [<c03e29c4>] (ncsi_configure_channel) from [<c03e31d0>] (ncsi_dev_work+0x39c/0x3e8)
   [<c03e31d0>] (ncsi_dev_work) from [<c0120288>] (process_one_work+0x1b8/0x2fc)
   [<c0120288>] (process_one_work) from [<c01206bc>] (worker_thread+0x2c0/0x3f8)
   [<c01206bc>] (worker_thread) from [<c0124b10>] (kthread+0xd0/0xe8)
   [<c0124b10>] (kthread) from [<c0102250>] (ret_from_fork+0x14/0x24)
   ---[ end trace 110cccf2b038c44d ]---

This fixes the issue by updating @monitor.enabled to false if needed.

Reported-by: Sridevi Ramesh <sridevra@in.ibm.com>
Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/ncsi-manage.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 5073e15..c71a3a5 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -183,11 +183,16 @@ static void ncsi_channel_monitor(unsigned long data)
 	monitor_state = nc->monitor.state;
 	spin_unlock_irqrestore(&nc->lock, flags);
 
-	if (!enabled || chained)
+	if (!enabled || chained) {
+		ncsi_stop_channel_monitor(nc);
 		return;
+	}
+
 	if (state != NCSI_CHANNEL_INACTIVE &&
-	    state != NCSI_CHANNEL_ACTIVE)
+	    state != NCSI_CHANNEL_ACTIVE) {
+		ncsi_stop_channel_monitor(nc);
 		return;
+	}
 
 	switch (monitor_state) {
 	case NCSI_CHANNEL_MONITOR_START:
@@ -199,6 +204,7 @@ static void ncsi_channel_monitor(unsigned long data)
 		nca.req_flags = 0;
 		ret = ncsi_xmit_cmd(&nca);
 		if (ret) {
+			ncsi_stop_channel_monitor(nc);
 			netdev_err(ndp->ndev.dev, "Error %d sending GLS\n",
 				   ret);
 			return;
@@ -218,6 +224,8 @@ static void ncsi_channel_monitor(unsigned long data)
 		nc->state = NCSI_CHANNEL_INVISIBLE;
 		spin_unlock_irqrestore(&nc->lock, flags);
 
+		ncsi_stop_channel_monitor(nc);
+
 		spin_lock_irqsave(&ndp->lock, flags);
 		nc->state = NCSI_CHANNEL_INACTIVE;
 		list_add_tail_rcu(&nc->link, &ndp->channel_queue);
@@ -257,6 +265,10 @@ void ncsi_stop_channel_monitor(struct ncsi_channel *nc)
 	nc->monitor.enabled = false;
 	spin_unlock_irqrestore(&nc->lock, flags);
 
+	/* The timer isn't in pending state if we're deleting the timer
+	 * in its handler. del_timer_sync() can detect it and just does
+	 * nothing.
+	 */
 	del_timer_sync(&nc->monitor.timer);
 }
 
-- 
2.7.4
