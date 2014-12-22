From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 4/5] netlink: call unbind when releasing socket
Date: Mon, 22 Dec 2014 18:56:38 +0100
Message-ID: <1419270999-22165-5-git-send-email-johannes@sipsolutions.net>
References: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35036 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755224AbaLVR4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:56:46 -0500
In-Reply-To: <1419270999-22165-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Currently, netlink_unbind() is only called when the socket
explicitly unbinds, which limits its usefulness (luckily
there are no users of it yet anyway.)

Call netlink_unbind() also when a socket is released, so it
becomes possible to track listeners with this callback and
without also implementing a netlink notifier (and checking
netlink_has_listeners() in there.)

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/af_netlink.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index df6086f69592..07a903de4439 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1266,6 +1266,13 @@ static int netlink_release(struct socket *sock)
 		netlink_table_ungrab();
 	}
 
+	if (nlk->netlink_unbind) {
+		int i;
+
+		for (i = 0; i < nlk->ngroups; i++)
+			if (test_bit(i, nlk->groups))
+				nlk->netlink_unbind(i + 1);
+	}
 	kfree(nlk->groups);
 	nlk->groups = NULL;
 
-- 
2.1.1
