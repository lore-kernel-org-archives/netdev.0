From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] vxlan: using kfree_rcu() to simplify the code
Date: Wed, 17 Jul 2013 13:29:58 +0800
Message-ID: <CAPgLHd89R4FkKq1tCyuL9WWRXgsCb7ZpGGsw3yiPn1Ht5X61Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, stephen@networkplumber.org,
	pshelar@nicira.com, mike.rapoport@ravellosystems.com,
	amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:34399 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372Ab3GQFaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 01:30:00 -0400
Received: by mail-bk0-f49.google.com with SMTP id mz10so556429bkb.22
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 22:29:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The callback function of call_rcu() just calls a kfree(), so we
can use kfree_rcu() instead of call_rcu() + callback function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/vxlan.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 227b54a..d6fc046 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -498,12 +498,6 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 	return 0;
 }
 
-static void vxlan_fdb_free_rdst(struct rcu_head *head)
-{
-	struct vxlan_rdst *rd = container_of(head, struct vxlan_rdst, rcu);
-	kfree(rd);
-}
-
 static void vxlan_fdb_free(struct rcu_head *head)
 {
 	struct vxlan_fdb *f = container_of(head, struct vxlan_fdb, rcu);
@@ -643,7 +637,7 @@ static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 	 */
 	if (rd && !list_is_singular(&f->remotes)) {
 		list_del_rcu(&rd->list);
-		call_rcu(&rd->rcu, vxlan_fdb_free_rdst);
+		kfree_rcu(rd, rcu);
 		goto out;
 	}
 
