From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 16:55:12 +0100
Message-ID: <457444E0.8060801@trash.net>
References: <1165158707.3517.92.camel@localhost>	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost>	 <45742825.8040004@trash.net>  <45742964.9000905@trash.net>	 <1165240725.3664.72.camel@localhost>  <1165241100.3664.75.camel@localhost> <1165246635.3643.6.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010205050304080003080809"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47759 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937041AbWLDPwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 10:52:07 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165246635.3643.6.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010205050304080003080809
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

jamal wrote:
> On Mon, 2006-04-12 at 09:05 -0500, jamal wrote:
> 
>>Patrick,
>>
>>Your approach is much cleaner. Let me give these a few tests then
>>I will repost later today; forget about the callback approach for now.
>>
> 
> 
> I have just applied the policy patch; havent compiled or tested (the
> setup takes me a while to put together). But by staring, I am seeing
> that you will end up with the same thing of sending a NULL or the same
> entry twice.
> 
> Consider a simple hypothetical test. You have one one entry in the 
> xfrm_policy_inexact table that matches. It happens to be the fifth out
> of 10 elements. You find it at the 5th iteration. At the sixth iteration
> you send it and last becomes null. 
> 
> All the way down, you call func with a NULL entry. You could add a check
> to make sure it only gets invoked when last is not null, but the result
> is in such a case, you will never send a 0 count element. I am sure
> there could be other tricky scenarios like this that could be
> constructed.
> 
> Thoughts.

Double sending can't happen, but you're right about potentially
sending a NULL ptr when after setting it to NULL we don't find
any other matching elements.

This patch should fix it (and is even simpler), by moving the
check for pol->type != type before sending, we make sure that
last always contains a valid element unless count == 0.

Also fixed an incorrect gcc warning about last_dir potentially
being used uninitialized.


--------------010205050304080003080809
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 64d3938..e19ec1e 100644
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
+	int dir, last_dir = 0, count, error;
 
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
@@ -896,21 +875,35 @@ int xfrm_policy_walk(u8 type, int (*func
 				     &xfrm_policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
-			error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
-			if (error)
-				goto out;
+			if (last) {
+				error = func(last, last_dir % XFRM_POLICY_MAX,
+					     ++count, data);
+				if (error)
+					goto out;
+			}
+			last = pol;
+			last_dir = dir;
 		}
 		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
 			hlist_for_each_entry(pol, entry, table + i, bydst) {
 				if (pol->type != type)
 					continue;
-				error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
-				if (error)
-					goto out;
+				if (last) {
+					error = func(last, last_dir % XFRM_POLICY_MAX,
+						     ++count, data);
+					if (error)
+						goto out;
+				}
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

--------------010205050304080003080809--
