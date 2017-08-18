From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net] net: sched: fix NULL pointer dereference when action calls some targets
Date: Fri, 18 Aug 2017 11:01:36 +0800
Message-ID: <f9e3e9338eeb819c40efb13fed33514a3df23c14.1503025296.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
        pablo@netfilter.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34299 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753892AbdHRDBp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 23:01:45 -0400
Received: by mail-pg0-f66.google.com with SMTP id y192so12721707pgd.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 20:01:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we know in some target's checkentry it may dereference par.entryinfo
to check entry stuff inside. But when sched action calls xt_check_target,
par.entryinfo is set with NULL. It would cause kernel panic when calling
some targets.

It can be reproduce with:
  # tc qd add dev eth1 ingress handle ffff:
  # tc filter add dev eth1 parent ffff: u32 match u32 0 0 action xt \
    -j ECN --ecn-tcp-remove

It could also crash kernel when using target CLUSTERIP or TPROXY.

By now there's no proper value for par.entryinfo in ipt_init_target,
but it can not be set with NULL. This patch is to void all these
panics by setting it with an ipt_entry obj with all members = 0.

Note that this issue has been there since the very beginning.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sched/act_ipt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index d516ba8..5417078 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -41,6 +41,7 @@ static int ipt_init_target(struct net *net, struct xt_entry_target *t,
 {
 	struct xt_tgchk_param par;
 	struct xt_target *target;
+	struct ipt_entry e = {};
 	int ret = 0;
 
 	target = xt_request_find_target(AF_INET, t->u.user.name,
@@ -52,6 +53,7 @@ static int ipt_init_target(struct net *net, struct xt_entry_target *t,
 	memset(&par, 0, sizeof(par));
 	par.net       = net;
 	par.table     = table;
+	par.entryinfo = &e;
 	par.target    = target;
 	par.targinfo  = t->data;
 	par.hook_mask = hook;
-- 
2.1.0
