From: jamal <hadi@cyberus.ca>
Subject: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 15:58:03 -0500
Message-ID: <1165265883.3643.38.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-uLtkNWx7TOWf6BqV3e4/"
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.235]:6170 "EHLO
	nz-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S967119AbWLDU6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 15:58:07 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1956241nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 12:58:06 -0800 (PST)
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-uLtkNWx7TOWf6BqV3e4/
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Dave,

This one has undergone more scrutiny and testing. Against net-2.6.20

cheers,
jamal

--=-uLtkNWx7TOWf6BqV3e4/
Content-Disposition: attachment; filename=patrick-spopt
Content-Type: text/plain; name=patrick-spopt; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] Optimize policy dumping

This change optimizes the dumping of Security policies.

1) Before this change ..
speedopolis:~# time ./ip xf pol

real    0m22.274s
user    0m0.000s
sys     0m22.269s

2) Turn off sub-policies

speedopolis:~# ./ip xf pol

real    0m13.496s
user    0m0.000s
sys     0m13.493s

i suppose the above is to be expected

3) With this change ..
speedopolis:~# time ./ip x policy

real    0m7.901s
user    0m0.008s
sys     0m7.896s
---------

This is probably the best we can do for now.

The current code attempts to work well for PFKEY which
has a broken two phase semantic.

>From RFC 2367:
"
3.1.10 SADB_DUMP
   The SADB_DUMP message causes the kernel to dump the operating
   system's entire Key Table to the requesting key socket.....
   Each Security Association is returned in its own SADB_DUMP
   message.
   A SADB_DUMP message with a sadb_seq field of zero indicates
   the end of the dump transaction. The dump message is used for
   debugging purposes only and is not intended for production
   use.

   Support for the dump message MAY be discontinued
   in future versions of PF_KEY.  Key management applications MUST
   NOT depend on this message for basic operation.
 "

Note the funny comment above on the dump message being discontinued
at some point and is only for debugging ;->
The way to eventually fix this IMO and reach the goals stated by
Davem of making "pfkey more robust" is to add to pfkey a socket->cb
structure. For now i think this even improves the pfkey by reducing
the compute. The advantages are noticeable when you have a large number
of policies installed.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 33b1e3fcdaee3252cce3c1cadf93a4d81f2200ff
tree 584411b6ad0ac830cc39dd184ccb32573739036d
parent 5465ae68b5ec11b2820db3f9b4c6fd94f113da44
author Patrick McHardy <kaber@trash.net> Mon, 04 Dec 2006 15:33:48 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Mon, 04 Dec 2006 15:33:48 -0500

 net/xfrm/xfrm_policy.c |   55 ++++++++++++++++++++++--------------------------
 1 files changed, 25 insertions(+), 30 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 64d3938..c438035 100644
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
@@ -896,21 +875,37 @@ int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int, void*)
 				     &xfrm_policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
-			error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
-			if (error)
-				goto out;
+			if (last) {
+				error = func(last, last_dir % XFRM_POLICY_MAX,
+					     count, data);
+				if (error)
+					goto out;
+			}
+			last = pol;
+			last_dir = dir;
+			count++;
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
+						     count, data);
+					if (error)
+						goto out;
+				}
+				last = pol;
+				last_dir = dir;
+				count++;
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

--=-uLtkNWx7TOWf6BqV3e4/--

