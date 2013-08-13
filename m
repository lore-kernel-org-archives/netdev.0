From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 3.11 v3] genetlink: fix family dump race
Date: Tue, 13 Aug 2013 09:04:05 +0200
Message-ID: <1376377445-8937-1-git-send-email-johannes@sipsolutions.net>
Cc: linux-wireless@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:53972 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691Ab3HMHEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 03:04:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

When dumping generic netlink families, only the first dump call
is locked with genl_lock(), which protects the list of families,
and thus subsequent calls can access the data without locking,
racing against family addition/removal. This can cause a crash.
Fix it - the locking needs to be conditional because the first
time around it's already locked.

A similar bug was reported to me on an old kernel (3.4.47) but
the exact scenario that happened there is no longer possible,
on those kernels the first round wasn't locked either. Looking
at the current code I found the race described above, which had
also existed on the old kernel.

Cc: stable@vger.kernel.org
Reported-by: Andrei Otcheretianski <andrei.otcheretianski@intel.com>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/genetlink.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2fd6dbe..6b6a03a 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -789,6 +789,10 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net *net = sock_net(skb->sk);
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
+	bool need_locking = chains_to_skip || fams_to_skip;
+
+	if (need_locking)
+		genl_lock();
 
 	for (i = chains_to_skip; i < GENL_FAM_TAB_SIZE; i++) {
 		n = 0;
@@ -810,6 +814,9 @@ errout:
 	cb->args[0] = i;
 	cb->args[1] = n;
 
+	if (need_locking)
+		genl_unlock();
+
 	return skb->len;
 }
 
-- 
1.8.0
