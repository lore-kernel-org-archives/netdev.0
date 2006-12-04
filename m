From: jamal <hadi@cyberus.ca>
Subject: [PATCH][XFRM] Optimize SA dumping
Date: Mon, 04 Dec 2006 15:59:45 -0500
Message-ID: <1165265985.3643.41.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-EAB403f8SBMXDZjVrRnb"
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.233]:6878 "EHLO
	nz-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S967282AbWLDU7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 15:59:48 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1956576nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 12:59:48 -0800 (PST)
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-EAB403f8SBMXDZjVrRnb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


The SA version

cheers,
jamal


--=-EAB403f8SBMXDZjVrRnb
Content-Disposition: attachment; filename=patrick-saopt
Content-Type: text/plain; name=patrick-saopt; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] Optimize SA dumping

Same comments as in "[XFRM] Optimize policy dumping"

The numbers are (20K SAs):
------
1) before the change ..
speedopolis:~# time ./ip xf sta

real    0m5.321s
user    0m0.004s
sys     0m5.316s

2) after the change ...
speedopolis:~# time ./ip x state

real    0m1.985s
user    0m0.000s
sys     0m1.984s
------

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 55a2dc3caa86e03cb3d9e856215e2fceb5cf5f66
tree 42abe39f60fe9a22ec54c7bdbf358842a94e82e9
parent 33b1e3fcdaee3252cce3c1cadf93a4d81f2200ff
author Patrick McHardy <kaber@trash.net> Mon, 04 Dec 2006 15:41:31 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Mon, 04 Dec 2006 15:41:31 -0500

 net/xfrm/xfrm_state.c |   24 +++++++++++-------------
 1 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 864962b..11da3d3 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1099,7 +1099,7 @@ int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*),
 		    void *data)
 {
 	int i;
-	struct xfrm_state *x;
+	struct xfrm_state *x, *last = NULL;
 	struct hlist_node *entry;
 	int count = 0;
 	int err = 0;
@@ -1107,24 +1107,22 @@ int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*),
 	spin_lock_bh(&xfrm_state_lock);
 	for (i = 0; i <= xfrm_state_hmask; i++) {
 		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
-			if (xfrm_id_proto_match(x->id.proto, proto))
-				count++;
+			if (!xfrm_id_proto_match(x->id.proto, proto))
+				continue;
+			if (last) {
+				err = func(last, count, data);
+				if (err)
+					goto out;
+			}
+			last = x;
+			count++;
 		}
 	}
 	if (count == 0) {
 		err = -ENOENT;
 		goto out;
 	}
-
-	for (i = 0; i <= xfrm_state_hmask; i++) {
-		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
-			if (!xfrm_id_proto_match(x->id.proto, proto))
-				continue;
-			err = func(x, --count, data);
-			if (err)
-				goto out;
-		}
-	}
+	err = func(last, 0, data);
 out:
 	spin_unlock_bh(&xfrm_state_lock);
 	return err;

--=-EAB403f8SBMXDZjVrRnb--

