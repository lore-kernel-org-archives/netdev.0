From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: hold tcf_lock in netdevice notifier
Date: Wed, 16 Jul 2014 14:25:31 -0700
Message-ID: <1405545931-13832-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:47414 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312AbaGPVZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 17:25:44 -0400
Received: by mail-pd0-f175.google.com with SMTP id r10so416379pdi.20
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 14:25:43 -0700 (PDT)
In-Reply-To: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

We modify mirred action (m->tcfm_dev) in netdev event, we need to
prevent on-going mirred actions from reading freed m->tcfm_dev.
So we need to acquire this spin lock.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_mirred.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 4f912c0..eb48306 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -218,10 +218,12 @@ static int mirred_device_event(struct notifier_block *unused,
 
 	if (event == NETDEV_UNREGISTER)
 		list_for_each_entry(m, &mirred_list, tcfm_list) {
+			spin_lock_bh(&m->tcf_lock);
 			if (m->tcfm_dev == dev) {
 				dev_put(dev);
 				m->tcfm_dev = NULL;
 			}
+			spin_unlock_bh(&m->tcf_lock);
 		}
 
 	return NOTIFY_DONE;
-- 
1.8.3.1
