From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24-rc8 ppp regression
Date: Wed, 23 Jan 2008 02:58:54 -0800 (PST)
Message-ID: <20080123.025854.07563459.davem@davemloft.net>
References: <20080123093509.GA4718@stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: max@stro.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60310
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750855AbYAWK6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 05:58:45 -0500
In-Reply-To: <20080123093509.GA4718@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: maximilian attems <max@stro.at>
Date: Wed, 23 Jan 2008 10:35:09 +0100

> Jan 22 23:23:54 dual kernel: unregister_netdevice: waiting for ppp0 to become free. Usage count = 1

Already fixed by:

[NEIGH]: Revert 'Fix race between neigh_parms_release and neightbl_fill_parms'

Commit 9cd40029423701c376391da59d2c6469672b4bed (Fix race between
neigh_parms_release and neightbl_fill_parms) introduced device
reference counting regressions for several people, see:

	http://bugzilla.kernel.org/show_bug.cgi?id=9778

for example.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index cc8a2f1..29b8ee4 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1316,6 +1316,8 @@ void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms)
 			*p = parms->next;
 			parms->dead = 1;
 			write_unlock_bh(&tbl->lock);
+			if (parms->dev)
+				dev_put(parms->dev);
 			call_rcu(&parms->rcu_head, neigh_rcu_free_parms);
 			return;
 		}
@@ -1326,8 +1328,6 @@ void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms)
 
 void neigh_parms_destroy(struct neigh_parms *parms)
 {
-	if (parms->dev)
-		dev_put(parms->dev);
 	kfree(parms);
 }
 
