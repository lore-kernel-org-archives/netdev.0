From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: NULL pointer dereference in netif_carrier_off
Date: Thu, 10 Jan 2013 10:32:45 -0800
Message-ID: <1357842765.27446.2396.camel@edumazet-glaptop>
References: <CACzvQmaj1_r4DHJjU7K4JN7jywX8y0_j_EQ_6tC8VkGryMmQPQ@mail.gmail.com>
	 <1357840590.27446.2331.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Parkin <tom.parkin@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:54127 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194Ab3AJSct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 13:32:49 -0500
Received: by mail-pa0-f48.google.com with SMTP id fa1so512539pad.35
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 10:32:48 -0800 (PST)
In-Reply-To: <1357840590.27446.2331.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Thu, 2013-01-10 at 09:56 -0800, Eric Dumazet wrote:

> 
> Hi Tom, thanks for the report, I'll take a look.

Oh well, fix seems straightforward...

Thanks !

[PATCH net-next] veth: fix a NULL deref in netif_carrier_off

In commit d0e2c55e7c94 (veth: avoid a NULL deref in veth_stats_one)
we now clear the peer pointers in veth_dellink()

veth_close() must therefore make sure the peer pointer is set.

Reported-by: Tom Parkin <tom.parkin@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/veth.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0f71a4f..e1da42a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -206,9 +206,11 @@ static int veth_open(struct net_device *dev)
 static int veth_close(struct net_device *dev)
 {
 	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *peer = rtnl_dereference(priv->peer);
 
 	netif_carrier_off(dev);
-	netif_carrier_off(rtnl_dereference(priv->peer));
+	if (peer)
+		netif_carrier_off(peer);
 
 	return 0;
 }
