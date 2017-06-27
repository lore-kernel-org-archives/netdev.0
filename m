From: gfree.wind@vip.163.com
Subject: [net PATCH] net: sched: Fix one possible panic when no destroy callback
Date: Tue, 27 Jun 2017 09:35:33 +0800
Message-ID: <1498527333-86838-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-177180.vip.163.com ([123.58.177.180]:49166 "EHLO
        mail-177180.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751467AbdF0Bge (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 21:36:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

When qdisc fail to init, qdisc_create would invoke the destroy callback
to cleanup. But there is no check if the callback exists really. So it
would cause the panic if there is no real destroy callback like these
qdisc codel, pfifo, pfifo_fast, and so on.

Now add one the check for destroy to avoid the possible panic.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 net/sched/sch_api.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index e88342f..cfdbfa1 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1019,7 +1019,8 @@ static struct Qdisc *qdisc_create(struct net_device *dev,
 		return sch;
 	}
 	/* ops->init() failed, we call ->destroy() like qdisc_create_dflt() */
-	ops->destroy(sch);
+	if (ops->destroy)
+		ops->destroy(sch);
 err_out3:
 	dev_put(dev);
 	kfree((char *) sch - sch->padded);
-- 
1.9.1
