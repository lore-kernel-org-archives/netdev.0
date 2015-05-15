From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2] rocker: fix a neigh entry leak issue
Date: Fri, 15 May 2015 09:33:25 +0800
Message-ID: <1431653605-11922-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <jiri@resnulli.us>, <sfeldma@gmail.com>,
	<davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39280 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423117AbbEOBex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 21:34:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once we get a neighbour through looking up arp cache or creating a
new one in rocker_port_ipv4_resolve(), the neighbour's refcount is
already taken. But as we don't put the refcount again after it's
used, this makes the neighbour entry leaked.

Suggested-by: Eric Dumazet <edumazet@google.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
v2:
  Add the checking of return value of neigh_create() with IS_ERR()
  to avoid another crash, which is suggested by Eric Dumazet.

 drivers/net/ethernet/rocker/rocker.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index f0a9cb4..3e13dcc 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3037,10 +3037,11 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 	struct neighbour *n = __ipv4_neigh_lookup(dev, (__force u32)ip_addr);
 	int err = 0;
 
-	if (!n)
+	if (!n) {
 		n = neigh_create(&arp_tbl, &ip_addr, dev);
-	if (!n)
-		return -ENOMEM;
+		if (IS_ERR(n))
+			return IS_ERR(n);
+	}
 
 	/* If the neigh is already resolved, then go ahead and
 	 * install the entry, otherwise start the ARP process to
@@ -3053,6 +3054,7 @@ static int rocker_port_ipv4_resolve(struct rocker_port *rocker_port,
 	else
 		neigh_event_send(n, NULL);
 
+	neigh_release(n);
 	return err;
 }
 
-- 
1.7.9.5
