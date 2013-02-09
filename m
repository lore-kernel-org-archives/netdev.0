From: Eric Dumazet <erdnetdev@gmail.com>
Subject: [PATCH net-next] veth: fix NULL dereference in veth_dellink()
Date: Fri, 08 Feb 2013 22:10:49 -0800
Message-ID: <1360390249.6696.22.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:56574 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab3BIGKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 01:10:53 -0500
Received: by mail-pa0-f47.google.com with SMTP id bj3so2387706pad.20
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 22:10:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit d0e2c55e7c940 (veth: avoid a NULL deref in veth_stats_one)
added another NULL deref in veth_dellink().

# ip link add name veth1 type veth peer name veth0
# rmmod veth

We crash because veth_dellink() is called twice, so we must
take care of NULL peer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/veth.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index e1da42a..07a4af0 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -426,12 +426,13 @@ static void veth_dellink(struct net_device *dev, struct list_head *head)
 	 * not being freed before one RCU grace period.
 	 */
 	RCU_INIT_POINTER(priv->peer, NULL);
-
-	priv = netdev_priv(peer);
-	RCU_INIT_POINTER(priv->peer, NULL);
-
 	unregister_netdevice_queue(dev, head);
-	unregister_netdevice_queue(peer, head);
+
+	if (peer) {
+		priv = netdev_priv(peer);
+		RCU_INIT_POINTER(priv->peer, NULL);
+		unregister_netdevice_queue(peer, head);
+	}
 }
 
 static const struct nla_policy veth_policy[VETH_INFO_MAX + 1] = {
