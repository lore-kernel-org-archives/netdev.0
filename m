From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: decnet handle a failure in neigh_parms_alloc (take 2)
Date: Wed, 24 Jan 2007 21:55:45 -0700
Message-ID: <m1irevzovi.fsf_-_@ebiederm.dsl.xmission.com>
References: <m13b601917.fsf@ebiederm.dsl.xmission.com>
	<20070124.144511.56810202.davem@davemloft.net>
	<20070124.144952.02299886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve@chygwyn.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:34301 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933218AbXAYE4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 23:56:30 -0500
In-Reply-To: <20070124.144952.02299886.davem@davemloft.net> (David Miller's
	message of "Wed, 24 Jan 2007 14:49:52 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


While enhancing the neighbour code to handle multiple network
namespaces I noticed that decnet is assuming neigh_parms_alloc
will allways succeed, which is clearly wrong.  So handle the
failure.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/decnet/dn_dev.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 324eb47..913e25a 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1140,16 +1140,23 @@ struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
 	init_timer(&dn_db->timer);
 
 	dn_db->uptime = jiffies;
+
+	dn_db->neigh_parms = neigh_parms_alloc(dev, &dn_neigh_table);
+	if (!dn_db->neigh_parms) {
+		dev->dn_ptr = NULL;
+		kfree(dn_db);
+		return NULL;
+	}
+
 	if (dn_db->parms.up) {
 		if (dn_db->parms.up(dev) < 0) {
+			neigh_parms_release(&dn_neigh_table, dn_db->neigh_parms);
 			dev->dn_ptr = NULL;
 			kfree(dn_db);
 			return NULL;
 		}
 	}
 
-	dn_db->neigh_parms = neigh_parms_alloc(dev, &dn_neigh_table);
-
 	dn_dev_sysctl_register(dev, &dn_db->parms);
 
 	dn_dev_set_timer(dev);
-- 
1.4.4.1.g278f

