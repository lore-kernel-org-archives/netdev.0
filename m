From: jamal <hadi@cyberus.ca>
Subject: [PATCH][XFRM] Optimize policy dumping
Date: Sun, 03 Dec 2006 10:11:47 -0500
Message-ID: <1165158707.3517.92.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-JmUWlf6tZVo196+rARub"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:41613 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1759691AbWLCPLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 10:11:51 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1733629nze
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 07:11:50 -0800 (PST)
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-JmUWlf6tZVo196+rARub
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


This improves dumping performance of xfrm policies. I started getting
bothered when i noticed it took upto a minute dumping 60K policies from
the kernel.

I have another one i am testing that uses the same approach for SAs.
Will send in the next hour.
Against net-2.6.20.

cheers,
jamal

--=-JmUWlf6tZVo196+rARub
Content-Disposition: attachment; filename=xfrm_pol_opt
Content-Type: text/plain; name=xfrm_pol_opt; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] Optimize policy dumping

This code is Fuugly. This patch doesnt make it fuglier.
I could have optimized more but PFKEY is a fugly protocol because
of a rather incomplete 2 phase commit semantics.
Therefore, it adds more overhead that we have to carry around.

>From RFC 2367:
"
3.1.10 SADB_DUMP
   The SADB_DUMP message causes the kernel to dump the operating
    system's entire Key Table to the requesting key socket.....
    Each Security Association is returned in its own SADB_DUMP message.
    A SADB_DUMP message with a sadb_seq field of zero indicates the end
    of the dump transaction. The dump message is used for debugging
    purposes only and is not intended for production use.

    Support for the dump message MAY be discontinued in future versions
    of PF_KEY.  Key management applications MUST NOT depend on this
    message for basic operation.
"

Note the funny comment above on the dump message being discontinued at
some point and is only for debugging ;->
The way to eventually fix this IMO and reach the goals stated by
Davem of making "pfkey more robust" is to add to pfkey a socket->cb
structure. For now i think this even improves the pfkey by reducing
the compute. The advantages are noticeable when you have a large number
of policies installed.
I have tested this with setkey (which uses the same API as racoon) and all
looks fine.
I was more interested in the performance of netlink side though; so
heres some numbers with 40K policies installed (i hacked ip xfrm so
it doesnt print the output):

---

1) original with sub-policies compiled in ..
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

3) With this patch and no subpolicies

speedopolis:~# ./ip xf pol

real    0m7.751s
user    0m0.012s
sys     0m7.740s

speedopolis:~#

------------

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 0355ced4a81a1af96b4531680e9c593d3967a5f1
tree dd60c3be71f4bd460d2e15e81689560099751daa
parent c3b92488bea3f11a6cc7c1c59101444c26ad12ce
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 03 Dec 2006 10:04:44 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 03 Dec 2006 10:04:44 -0500

 net/xfrm/xfrm_policy.c |   73 ++++++++++++++++++++++++++++--------------------
 1 files changed, 43 insertions(+), 30 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 64d3938..c8a98ca 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -860,57 +860,70 @@ EXPORT_SYMBOL(xfrm_policy_flush);
 int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int, void*),
 		     void *data)
 {
-	struct xfrm_policy *pol;
 	struct hlist_node *entry;
-	int dir, count, error;
+	int dir = 0, last_dir = 0, count = 0, error = -ENOENT;
+	struct xfrm_policy *pol = NULL, *send_pol = NULL, *last_pol = NULL;
 
 	read_lock_bh(&xfrm_policy_lock);
-	count = 0;
+
 	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
 		struct hlist_head *table = xfrm_policy_bydst[dir].table;
 		int i;
 
 		hlist_for_each_entry(pol, entry,
 				     &xfrm_policy_inexact[dir], bydst) {
-			if (pol->type == type)
-				count++;
-		}
-		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
-			hlist_for_each_entry(pol, entry, table + i, bydst) {
-				if (pol->type == type)
-					count++;
+			if (count && send_pol && send_pol != last_pol) {
+				error = func(send_pol, dir % XFRM_POLICY_MAX, count, data);
+				if (error)
+					goto out;
+				send_pol = NULL;
 			}
-		}
-	}
-
-	if (count == 0) {
-		error = -ENOENT;
-		goto out;
-	}
-
-	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
-		struct hlist_head *table = xfrm_policy_bydst[dir].table;
-		int i;
 
-		hlist_for_each_entry(pol, entry,
-				     &xfrm_policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
-			error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
-			if (error)
-				goto out;
+
+			if (!count) {
+				last_pol = send_pol = pol;
+			} else {
+				send_pol = last_pol;
+				last_pol = pol;
+			}
+
+			last_dir = dir;
+			count++;
 		}
+
 		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
 			hlist_for_each_entry(pol, entry, table + i, bydst) {
+				if (count && send_pol && send_pol != last_pol) {
+					error = func(send_pol, dir % XFRM_POLICY_MAX, count, data);
+					send_pol = NULL;
+					if (error)
+						goto out;
+				}
 				if (pol->type != type)
 					continue;
-				error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
-				if (error)
-					goto out;
+				if (!count) {
+					last_pol = send_pol = pol;
+				} else {
+					send_pol = last_pol;
+					last_pol = pol;
+				}
+				last_dir = dir;
+				count++;
 			}
 		}
 	}
-	error = 0;
+
+	if (send_pol && send_pol != last_pol) {
+		error = func(send_pol, last_dir % XFRM_POLICY_MAX, count, data);
+	}
+
+	if (count) {
+		BUG_TRAP(last_pol == NULL);
+		error = func(send_pol, last_dir % XFRM_POLICY_MAX, 0, data);
+	}
+
 out:
 	read_unlock_bh(&xfrm_policy_lock);
 	return error;

--=-JmUWlf6tZVo196+rARub--

