From: Jens Laas <jens.laas@its.uu.se>
Subject: [PATCH net-next-2.6] fib_trie: resize rework
Date: Fri, 21 Aug 2009 13:19:36 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0908211318070.28188@jens.its.uu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from klais.its.uu.se ([130.238.7.59]:49657 "EHLO klais.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754694AbZHUL0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 07:26:12 -0400
Received: from jens.its.uu.se (jens.its.uu.se [130.238.131.153])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by klais.its.uu.se (Postfix) with ESMTP id F3C3038371F
	for <netdev@vger.kernel.org>; Fri, 21 Aug 2009 13:19:36 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is rework and cleanup of the resize function.

Some bugs we had. We were using ->parent when we should use=20
node_parent(). Also we used ->parent which is not assigned by
inflate in inflate loop.

Also a fix to set thresholds to power 2 to fit halve=20
and double strategy.

max_resize is renamed to max_work which better indicates
it's function.

Reaching max_work is not an error, so warning is removed.=20
max_work only limits amount of work done per resize.
(limits CPU-usage, outstanding memory etc).

The clean-up makes it relatively easy to add fixed sized=20
root-nodes if we would like to decrease the memory pressure
on routers with large routing tables and dynamic routing.
If we'll need that...

Its been tested with 280k routes.

Work done together with Robert Olsson.

Signed-off-by: Jens L=E5=E5s <jens.laas@its.uu.se>

---
 net/ipv4/fib_trie.c |   95 ++++++++++++-------------------------------=
-------
 1 files changed, 23 insertions(+), 72 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index fe3c846..291bdf5 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -48,7 +48,7 @@
  *		Patrick McHardy <kaber@trash.net>
  */
=20
-#define VERSION "0.408"
+#define VERSION "0.409"
=20
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -325,10 +325,7 @@ static inline void check_tnode(const struct tnode =
*tn)
 static const int halve_threshold =3D 25;
 static const int inflate_threshold =3D 50;
 static const int halve_threshold_root =3D 15;
-static const int inflate_threshold_root =3D 25;
-
-static int inflate_threshold_root_fix;
-#define INFLATE_FIX_MAX 10	/* a comment in resize() */
+static const int inflate_threshold_root =3D 30;
=20
 static void __alias_free_mem(struct rcu_head *head)
 {
@@ -516,14 +513,14 @@ static void tnode_put_child_reorg(struct tnode *t=
n, int i, struct node *n,
 	rcu_assign_pointer(tn->child[i], n);
 }
=20
+#define MAX_WORK 10
 static struct node *resize(struct trie *t, struct tnode *tn)
 {
 	int i;
-	int err =3D 0;
 	struct tnode *old_tn;
 	int inflate_threshold_use;
 	int halve_threshold_use;
-	int max_resize;
+	int max_work;
=20
 	if (!tn)
 		return NULL;
@@ -538,18 +535,7 @@ static struct node *resize(struct trie *t, struct =
tnode *tn)
 	}
 	/* One child */
 	if (tn->empty_children =3D=3D tnode_child_length(tn) - 1)
-		for (i =3D 0; i < tnode_child_length(tn); i++) {
-			struct node *n;
-
-			n =3D tn->child[i];
-			if (!n)
-				continue;
-
-			/* compress one level */
-			node_set_parent(n, NULL);
-			tnode_free_safe(tn);
-			return n;
-		}
+		goto one_child;
 	/*
 	 * Double as long as the resulting node has a number of
 	 * nonempty nodes that are above the threshold.
@@ -618,15 +604,17 @@ static struct node *resize(struct trie *t, struct=
 tnode *tn)
=20
 	/* Keep root node larger  */
=20
-	if (!tn->parent)
-		inflate_threshold_use =3D inflate_threshold_root +
-					inflate_threshold_root_fix;
-	else
+	if (!node_parent((struct node*) tn)) {
+		inflate_threshold_use =3D inflate_threshold_root;
+		halve_threshold_use =3D halve_threshold_root;
+	}
+	else {
 		inflate_threshold_use =3D inflate_threshold;
+		halve_threshold_use =3D halve_threshold;
+	}
=20
-	err =3D 0;
-	max_resize =3D 10;
-	while ((tn->full_children > 0 &&  max_resize-- &&
+	max_work =3D MAX_WORK;
+	while ((tn->full_children > 0 &&  max_work-- &&
 		50 * (tn->full_children + tnode_child_length(tn)
 		      - tn->empty_children)
 		>=3D inflate_threshold_use * tnode_child_length(tn))) {
@@ -643,47 +631,19 @@ static struct node *resize(struct trie *t, struct=
 tnode *tn)
 		}
 	}
=20
-	if (max_resize < 0) {
-		if (!tn->parent) {
-			/*
-			 * It was observed that during large updates even
-			 * inflate_threshold_root =3D 35 might be needed to avoid
-			 * this warning; but it should be temporary, so let's
-			 * try to handle this automatically.
-			 */
-			if (inflate_threshold_root_fix < INFLATE_FIX_MAX)
-				inflate_threshold_root_fix++;
-			else
-				pr_warning("Fix inflate_threshold_root."
-					   " Now=3D%d size=3D%d bits fix=3D%d\n",
-					   inflate_threshold_root, tn->bits,
-					   inflate_threshold_root_fix);
-		} else {
-			pr_warning("Fix inflate_threshold."
-				   " Now=3D%d size=3D%d bits\n",
-				   inflate_threshold, tn->bits);
-		}
-	} else if (max_resize > 3 && !tn->parent && inflate_threshold_root_fi=
x)
-		inflate_threshold_root_fix--;
-
 	check_tnode(tn);
=20
+	/* Return if at least one inflate is run */
+	if( max_work !=3D MAX_WORK)
+		return (struct node *) tn;
+
 	/*
 	 * Halve as long as the number of empty children in this
 	 * node is above threshold.
 	 */
=20
-
-	/* Keep root node larger  */
-
-	if (!tn->parent)
-		halve_threshold_use =3D halve_threshold_root;
-	else
-		halve_threshold_use =3D halve_threshold;
-
-	err =3D 0;
-	max_resize =3D 10;
-	while (tn->bits > 1 &&  max_resize-- &&
+	max_work =3D MAX_WORK;
+	while (tn->bits > 1 &&  max_work-- &&
 	       100 * (tnode_child_length(tn) - tn->empty_children) <
 	       halve_threshold_use * tnode_child_length(tn)) {
=20
@@ -698,19 +658,10 @@ static struct node *resize(struct trie *t, struct=
 tnode *tn)
 		}
 	}
=20
-	if (max_resize < 0) {
-		if (!tn->parent)
-			pr_warning("Fix halve_threshold_root."
-				   " Now=3D%d size=3D%d bits\n",
-				   halve_threshold_root, tn->bits);
-		else
-			pr_warning("Fix halve_threshold."
-				   " Now=3D%d size=3D%d bits\n",
-				   halve_threshold, tn->bits);
-	}
=20
 	/* Only one child remains */
-	if (tn->empty_children =3D=3D tnode_child_length(tn) - 1)
+	if (tn->empty_children =3D=3D tnode_child_length(tn) - 1) {
+one_child:
 		for (i =3D 0; i < tnode_child_length(tn); i++) {
 			struct node *n;
=20
@@ -724,7 +675,7 @@ static struct node *resize(struct trie *t, struct t=
node *tn)
 			tnode_free_safe(tn);
 			return n;
 		}
-
+	}
 	return (struct node *) tn;
 }
=20
