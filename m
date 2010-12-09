From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] bridge: Fix return value of br_multicast_add_group()
Date: Thu,  9 Dec 2010 15:02:36 +0100
Message-ID: <1291903356-30618-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:57477 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756642Ab0LIOCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 09:02:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If br_multicast_new_group returns NULL, we would return 0 (no error) to
the caller, which is not what we want. Instead we should return -ENOMEM
in this case.

Also replace IS_ERR(x) || !x by IS_ERR_OR_NULL(x)

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/bridge/br_multicast.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 326e599..d4e1e81 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -713,8 +713,11 @@ static int br_multicast_add_group(struct net_bridge *br,
 
 	mp = br_multicast_new_group(br, port, group);
 	err = PTR_ERR(mp);
-	if (unlikely(IS_ERR(mp) || !mp))
+	if (IS_ERR_OR_NULL(mp)) {
+		if (!mp)
+			err = -ENOMEM;
 		goto err;
+	}
 
 	if (!port) {
 		hlist_add_head(&mp->mglist, &br->mglist);
-- 
1.7.0.4

