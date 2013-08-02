From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/2] neighbour: populate neigh_parms on alloc before calling ndo_neigh_setup
Date: Fri,  2 Aug 2013 19:07:38 +0200
Message-ID: <1375463259-12033-2-git-send-email-vfalico@redhat.com>
References: <1375463259-12033-1-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	ebiederm@xmission.com, joe@perches.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30752 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754180Ab3HBRHP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 13:07:15 -0400
In-Reply-To: <1375463259-12033-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev->ndo_neigh_setup() might need some of the values of neigh_parms, so
populate them before calling it.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 net/core/neighbour.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b7de821..576d46f 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1441,16 +1441,18 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 		atomic_set(&p->refcnt, 1);
 		p->reachable_time =
 				neigh_rand_reach_time(p->base_reachable_time);
+		dev_hold(dev);
+		p->dev = dev;
+		write_pnet(&p->net, hold_net(net));
+		p->sysctl_table = NULL;
 
 		if (ops->ndo_neigh_setup && ops->ndo_neigh_setup(dev, p)) {
+			release_net(net);
+			dev_put(dev);
 			kfree(p);
 			return NULL;
 		}
 
-		dev_hold(dev);
-		p->dev = dev;
-		write_pnet(&p->net, hold_net(net));
-		p->sysctl_table = NULL;
 		write_lock_bh(&tbl->lock);
 		p->next		= tbl->parms.next;
 		tbl->parms.next = p;
-- 
1.7.1
