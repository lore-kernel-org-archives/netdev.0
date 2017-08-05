From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] net: sched: fix NULL pointer dereference when action calls some targets
Date: Sat,  5 Aug 2017 19:35:07 +0800
Message-ID: <0fa9a53725dd661571461cf283ec88cf15f4b139.1501932907.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34935 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751226AbdHELfQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 07:35:16 -0400
Received: by mail-pf0-f194.google.com with SMTP id j68so4294417pfc.2
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2017 04:35:16 -0700 (PDT)
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
panics by setting it with an ipt_entry obj with all members 0.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sched/act_ipt.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 7c4816b..0f09f70 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -41,6 +41,7 @@ static int ipt_init_target(struct net *net, struct xt_entry_target *t,
 {
 	struct xt_tgchk_param par;
 	struct xt_target *target;
+	struct ipt_entry e;
 	int ret = 0;
 
 	target = xt_request_find_target(AF_INET, t->u.user.name,
@@ -48,10 +49,11 @@ static int ipt_init_target(struct net *net, struct xt_entry_target *t,
 	if (IS_ERR(target))
 		return PTR_ERR(target);
 
+	memset(&e, 0, sizeof(e));
 	t->u.kernel.target = target;
 	par.net       = net;
 	par.table     = table;
-	par.entryinfo = NULL;
+	par.entryinfo = &e;
 	par.target    = target;
 	par.targinfo  = t->data;
 	par.hook_mask = hook;
-- 
2.1.0
