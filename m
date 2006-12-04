From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 14:52:37 +0100
Message-ID: <45742825.8040004@trash.net>
References: <1165158707.3517.92.camel@localhost>	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070105080200020204090006"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:16305 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936859AbWLDNtb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 08:49:31 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165238776.3664.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070105080200020204090006
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

jamal wrote:
> All very valid points.
> Yikes, the directionality is not something i thought clearly about or
> tested well. I can fix this but this code will only get fuglier. How
> about the following approach:
> 
> I add a new callback which is passed in the invocation to walk. 
> This callback is invoked at the end to signal the end of the walk, sort
> of what done() does in netlink.
> netlink doesnt use this call but pfkey does. So the burden is then moved
> to pfkey to keep track of the stoopid count.
> 
> Thoughts?


I think the complications come from the fact that you remeber two
policies, but only one seems necessary.  How about this (completely
untested) patch? It simply uses increasing sequence numbers for all
but the last entry and uses zero for the last one.


--------------070105080200020204090006
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 64d3938..c790420 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -860,33 +860,12 @@ EXPORT_SYMBOL(xfrm_policy_flush);
 int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int, void*),
 		     void *data)
 {
-	struct xfrm_policy *pol;
+	struct xfrm_policy *pol, *last = NULL;
 	struct hlist_node *entry;
-	int dir, count, error;
+	int dir, last_dir, count, error;
 
 	read_lock_bh(&xfrm_policy_lock);
 	count = 0;
-	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
-		struct hlist_head *table = xfrm_policy_bydst[dir].table;
-		int i;
-
-		hlist_for_each_entry(pol, entry,
-				     &xfrm_policy_inexact[dir], bydst) {
-			if (pol->type == type)
-				count++;
-		}
-		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
-			hlist_for_each_entry(pol, entry, table + i, bydst) {
-				if (pol->type == type)
-					count++;
-			}
-		}
-	}
-
-	if (count == 0) {
-		error = -ENOENT;
-		goto out;
-	}
 
 	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
 		struct hlist_head *table = xfrm_policy_bydst[dir].table;
@@ -894,23 +873,39 @@ int xfrm_policy_walk(u8 type, int (*func
 
 		hlist_for_each_entry(pol, entry,
 				     &xfrm_policy_inexact[dir], bydst) {
+			if (last) {
+				error = func(last, last_dir % XFRM_POLICY_MAX,
+					     ++count, data);
+				if (error)
+					goto out;
+				last = NULL;
+			}
 			if (pol->type != type)
 				continue;
-			error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
-			if (error)
-				goto out;
+			last = pol;
+			last_dir = dir;
 		}
 		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
 			hlist_for_each_entry(pol, entry, table + i, bydst) {
+				if (last) {
+					error = func(last, last_dir % XFRM_POLICY_MAX,
+						     ++count, data);
+					if (error)
+						goto out;
+					last = NULL;
+				}
 				if (pol->type != type)
 					continue;
-				error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
-				if (error)
-					goto out;
+				last = pol;
+				last_dir = dir;
 			}
 		}
 	}
-	error = 0;
+	if (count == 0) {
+		error = -ENOENT;
+		goto out;
+	}
+	error = func(last, last_dir % XFRM_POLICY_MAX, 0, data);
 out:
 	read_unlock_bh(&xfrm_policy_lock);
 	return error;

--------------070105080200020204090006--
