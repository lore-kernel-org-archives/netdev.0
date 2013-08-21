From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/2] Revert "genetlink: fix family dump race"
Date: Wed, 21 Aug 2013 16:08:02 +0200
Message-ID: <1377094083-8122-2-git-send-email-johannes@sipsolutions.net>
References: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
Cc: Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:59334 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591Ab3HUOIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 10:08:10 -0400
In-Reply-To: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

This reverts commit 58ad436fcf49810aa006016107f494c9ac9013db.

It turns out that the change introduced a potential deadlock
by causing a locking dependency with netlink's cb_mutex. I
can't seem to find a way to resolve this without doing major
changes to the locking, so revert this.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/genetlink.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f85f8a2..512718a 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -789,10 +789,6 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net *net = sock_net(skb->sk);
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
-	bool need_locking = chains_to_skip || fams_to_skip;
-
-	if (need_locking)
-		genl_lock();
 
 	for (i = chains_to_skip; i < GENL_FAM_TAB_SIZE; i++) {
 		n = 0;
@@ -814,9 +810,6 @@ errout:
 	cb->args[0] = i;
 	cb->args[1] = n;
 
-	if (need_locking)
-		genl_unlock();
-
 	return skb->len;
 }
 
-- 
1.8.4.rc2
