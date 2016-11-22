From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH net-next] net/sched: cls_flower: verify root pointer before dereferncing it
Date: Tue, 22 Nov 2016 16:25:26 +0200
Message-ID: <1479824726-62607-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Cong Wang <cwang@twopensource.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52901 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932605AbcKVOZg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 09:25:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tp->root is being allocated in init() time and kfreed in destroy()
however it is being dereferenced in classify() path.

We could be in classify() path after destroy() was called and thus 
tp->root is null. Verifying if tp->root is null in classify() path 
is enough because it's being freed with kfree_rcu() and classify() 
path is under rcu_read_lock().

Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Cc: Cong Wang <cwang@twopensource.com>
---

Hi Cong, all

As stated above, the issue was introduced with commit 1e052be69d04 ("net_sched: destroy 
proto tp when all filters are gone"). This patch provides a fix only for cls_flower where 
I succeeded in reproducing the issue. Cong, if you can/want to come up with a fix that
will be applicable for all the others classifiners, I am fine with that.

Thanks,
Roi


 net/sched/cls_flower.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index e8dd09a..88a26c4 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -135,7 +135,7 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	struct fl_flow_key skb_mkey;
 	struct ip_tunnel_info *info;
 
-	if (!atomic_read(&head->ht.nelems))
+	if (!head || !atomic_read(&head->ht.nelems))
 		return -1;
 
 	fl_clear_masked_range(&skb_key, &head->mask);
-- 
2.7.4
