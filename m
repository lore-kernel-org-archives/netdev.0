From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH] neigh: sysctl - simplify address calculation of gc_* variables
Date: Sat, 12 Jul 2014 22:36:44 +0200
Message-ID: <1405197404-19127-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>,
	Brad Spengler <spender@grsecurity.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:44293 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbaGLUhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jul 2014 16:37:17 -0400
Received: by mail-wg0-f52.google.com with SMTP id a1so1768979wgh.23
        for <netdev@vger.kernel.org>; Sat, 12 Jul 2014 13:37:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in neigh_sysctl_register() relies on a specific layout of
struct neigh_table, namely that the 'gc_*' variables are directly
following the 'parms' member in a specific order. The code, though,
expresses this in the most ugly way.

Get rid of the ugly casts and use the 'tbl' pointer to get a handle to
the table. This way we can refer to the 'gc_*' variables directly.

Similarly seen in the grsecurity patch, written by Brad Spengler.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Brad Spengler <spender@grsecurity.net>
---
 include/net/neighbour.h |    1 -
 net/core/neighbour.c    |    9 +++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 7277caf374..47f425464f 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -203,7 +203,6 @@ struct neigh_table {
 	void			(*proxy_redo)(struct sk_buff *skb);
 	char			*id;
 	struct neigh_parms	parms;
-	/* HACK. gc_* should follow parms without a gap! */
 	int			gc_interval;
 	int			gc_thresh1;
 	int			gc_thresh2;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 32d872eec7..559890b0f0 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -3059,11 +3059,12 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 		memset(&t->neigh_vars[NEIGH_VAR_GC_INTERVAL], 0,
 		       sizeof(t->neigh_vars[NEIGH_VAR_GC_INTERVAL]));
 	} else {
+		struct neigh_table *tbl = p->tbl;
 		dev_name_source = "default";
-		t->neigh_vars[NEIGH_VAR_GC_INTERVAL].data = (int *)(p + 1);
-		t->neigh_vars[NEIGH_VAR_GC_THRESH1].data = (int *)(p + 1) + 1;
-		t->neigh_vars[NEIGH_VAR_GC_THRESH2].data = (int *)(p + 1) + 2;
-		t->neigh_vars[NEIGH_VAR_GC_THRESH3].data = (int *)(p + 1) + 3;
+		t->neigh_vars[NEIGH_VAR_GC_INTERVAL].data = &tbl->gc_interval;
+		t->neigh_vars[NEIGH_VAR_GC_THRESH1].data = &tbl->gc_thresh1;
+		t->neigh_vars[NEIGH_VAR_GC_THRESH2].data = &tbl->gc_thresh2;
+		t->neigh_vars[NEIGH_VAR_GC_THRESH3].data = &tbl->gc_thresh3;
 	}
 
 	if (handler) {
-- 
1.7.10.4
