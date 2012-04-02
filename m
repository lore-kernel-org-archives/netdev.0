From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 33/51] enic: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:23 -0400
Message-ID: <1333335521-1348-34-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460Ab2DBDAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:06 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 77b4e87..d7ac6c1 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1193,18 +1193,16 @@ static int enic_get_vf_port(struct net_device *netdev, int vf,
 	if (err)
 		return err;
 
-	NLA_PUT_U16(skb, IFLA_PORT_REQUEST, pp->request);
-	NLA_PUT_U16(skb, IFLA_PORT_RESPONSE, response);
-	if (pp->set & ENIC_SET_NAME)
-		NLA_PUT(skb, IFLA_PORT_PROFILE, PORT_PROFILE_MAX,
-			pp->name);
-	if (pp->set & ENIC_SET_INSTANCE)
-		NLA_PUT(skb, IFLA_PORT_INSTANCE_UUID, PORT_UUID_MAX,
-			pp->instance_uuid);
-	if (pp->set & ENIC_SET_HOST)
-		NLA_PUT(skb, IFLA_PORT_HOST_UUID, PORT_UUID_MAX,
-			pp->host_uuid);
-
+	if (nla_put_u16(skb, IFLA_PORT_REQUEST, pp->request) ||
+	    nla_put_u16(skb, IFLA_PORT_RESPONSE, response) ||
+	    ((pp->set & ENIC_SET_NAME) &&
+	     nla_put(skb, IFLA_PORT_PROFILE, PORT_PROFILE_MAX, pp->name)) ||
+	    ((pp->set & ENIC_SET_INSTANCE) &&
+	     nla_put(skb, IFLA_PORT_INSTANCE_UUID, PORT_UUID_MAX,
+		     pp->instance_uuid)) ||
+	    ((pp->set & ENIC_SET_HOST) &&
+	     nla_put(skb, IFLA_PORT_HOST_UUID, PORT_UUID_MAX, pp->host_uuid)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
