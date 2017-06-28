From: gfree.wind@vip.163.com
Subject: [PATCH net v2] net: sched: Fix one possible panic when no destroy callback
Date: Wed, 28 Jun 2017 12:53:54 +0800
Message-ID: <1498625634-115351-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m181-177.vip.163.com ([123.58.177.181]:58994 "EHLO
        m181-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751616AbdF1EyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 00:54:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

When qdisc fail to init, qdisc_create would invoke the destroy callback
to cleanup. But there is no check if the callback exists really. So it
would cause the panic if there is no real destroy callback like the qdisc
codel, fq, and so on.

Take codel as an example following:
When a malicious user constructs one invalid netlink msg, it would cause
codel_init->codel_change->nla_parse_nested failed.
Then kernel would invoke the destroy callback directly but qdisc codel
doesn't define one. It causes one panic as a result.

Now add one the check for destroy to avoid the possible panic.

Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 v2: Add the Fixes and an example in changelog, Per Cong Wang & Eric
 v1: initial version

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
