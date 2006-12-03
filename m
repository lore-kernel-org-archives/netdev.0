From: jamal <hadi@cyberus.ca>
Subject: [XFRM] Optimize SA dumping
Date: Sun, 03 Dec 2006 11:33:30 -0500
Message-ID: <1165163610.3517.96.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-FEE7EVVy4v1fEeXIQQOX"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.234]:40645 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1756869AbWLCQdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 11:33:36 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1739154nze
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 08:33:35 -0800 (PST)
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-FEE7EVVy4v1fEeXIQQOX
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Ok, heres is the SA version and the numbers.
Against net-2.6.20

cheers,
jamal


--=-FEE7EVVy4v1fEeXIQQOX
Content-Disposition: attachment; filename=xfrm_sa_dumpopt
Content-Type: text/plain; name=xfrm_sa_dumpopt; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] Optimize SA dumping

Same comments as in "[XFRM] Optimize policy dumping"

Again, the same issue as in the policy optimization; we could do better
only if we didnt have to do bending backwards to make pfkey happy.
In the future we could move some of this burden to pfkey itself.
For now this is better than whats there today.

The numbers are (20K SAs):

------
1) before the change ..
speedopolis:~# time ./ip xf sta

real    0m5.321s
user    0m0.004s
sys     0m5.316s

2) after the change ...
speedopolis:~# time ./ip x state

real    0m1.994s
user    0m0.000s
sys     0m1.992s
------

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 8a0f11d0e7197624341ab0536fbf24af5cb67e2b
tree 48dc4e907733e9c6989e7c4e8ac9bcd72c4d26b6
parent 0355ced4a81a1af96b4531680e9c593d3967a5f1
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 03 Dec 2006 10:29:50 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 03 Dec 2006 10:29:50 -0500

 net/xfrm/xfrm_state.c |   38 +++++++++++++++++++++++---------------
 1 files changed, 23 insertions(+), 15 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 864962b..148b148 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1099,32 +1099,40 @@ int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*),
 		    void *data)
 {
 	int i;
-	struct xfrm_state *x;
 	struct hlist_node *entry;
+	struct xfrm_state *x, *send_x = NULL, *last_x = NULL;
 	int count = 0;
-	int err = 0;
+	int err = -ENOENT;
 
 	spin_lock_bh(&xfrm_state_lock);
-	for (i = 0; i <= xfrm_state_hmask; i++) {
-		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
-			if (xfrm_id_proto_match(x->id.proto, proto))
-				count++;
-		}
-	}
-	if (count == 0) {
-		err = -ENOENT;
-		goto out;
-	}
 
 	for (i = 0; i <= xfrm_state_hmask; i++) {
 		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
+			if (count && send_x != last_x) {
+				err = func(send_x, count, data);
+				if (err)
+					goto out;
+				send_x = NULL;
+			}
 			if (!xfrm_id_proto_match(x->id.proto, proto))
 				continue;
-			err = func(x, --count, data);
-			if (err)
-				goto out;
+
+			if (!count) {
+				last_x = send_x = x;
+			} else {
+				send_x = last_x;
+				last_x = x;
+			}
+			count++;
 		}
 	}
+
+	if (send_x && send_x != last_x) 
+		err = func(send_x, count, data);
+	if (count) {
+		BUG_TRAP(last_x == NULL);
+		err = func(last_x, 0, data);
+	}
 out:
 	spin_unlock_bh(&xfrm_state_lock);
 	return err;

--=-FEE7EVVy4v1fEeXIQQOX--

