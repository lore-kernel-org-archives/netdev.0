From: Anders Franzen <anders.franzen@ericsson.com>
Subject: [PATCH] the macvlan device causes SLAB corruption on network namespace exit.
Date: Wed, 24 Nov 2010 16:35:41 +0100
Message-ID: <1290612941-8417-1-git-send-email-anders.franzen@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<davem@davemloft.net>, Anders Franzen <anders.franzen@ericsson.com>
To: <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:60562 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443Ab0KXPfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 10:35:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When doing exit from a network namespace, cleanup functions are executed from
the function default_device_exit_batch.
In the macvlan device, this will generate a call to macvlan_dellink.
If it is the last macvlan using a ''lowerdev'' the port is
destroyed.

Later the a call to macvlan_stop is executed. when the macvlan_hash_del(vlan) is
executed, the memory of the already freed port will be corrupted.

Signed-off-by: Anders Franzen <anders.franzen@ericsson.com>
---
 drivers/net/macvlan.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 6ed577b..c1cddb6 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -338,7 +338,9 @@ static int macvlan_stop(struct net_device *dev)
 	dev_uc_del(lowerdev, dev->dev_addr);
 
 hash_del:
-	macvlan_hash_del(vlan);
+	if (macvlan_port_exists(lowerdev))
+		macvlan_hash_del(vlan);
+
 	return 0;
 }
 
-- 
1.7.2.3

