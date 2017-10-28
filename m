From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: avoid matching qdisc with zero handle
Date: Fri, 27 Oct 2017 22:08:56 -0700
Message-ID: <20171028050856.18393-1-xiyou.wangcong@gmail.com>
Cc: dcaratti@redhat.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:52733 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdJ1FJT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 01:09:19 -0400
Received: by mail-pg0-f67.google.com with SMTP id a192so6739392pge.9
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 22:09:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Davide found the following script triggers a NULL pointer
dereference:

ip l a name eth0 type dummy
tc q a dev eth0 parent :1 handle 1: htb

This is because for a freshly created netdevice noop_qdisc
is attached and when passing 'parent :1', kernel actually
tries to match the major handle which is 0 and noop_qdisc
has handle 0 so is matched by mistake. Commit 69012ae425d7
tries to fix a similar bug but still misses this case.

Handle 0 is not a valid one, should be just skipped. In
fact, kernel uses it as TC_H_UNSPEC.

Fixes: 69012ae425d7 ("net: sched: fix handling of singleton qdiscs with qdisc_hash")
Fixes: 59cc1f61f09c ("net: sched:convert qdisc linked list to hashtable")
Reported-by: Davide Caratti <dcaratti@redhat.com>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_api.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c6deb74e3d2f..22bc6fc48311 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -301,6 +301,8 @@ struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 {
 	struct Qdisc *q;
 
+	if (!handle)
+		return NULL;
 	q = qdisc_match_from_root(dev->qdisc, handle);
 	if (q)
 		goto out;
-- 
2.13.0
