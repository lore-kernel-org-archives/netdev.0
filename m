From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net/hyperv: fix erroneous NETDEV_TX_BUSY use
Date: Wed, 14 Mar 2012 11:53:34 -0700
Message-ID: <1331751214.6022.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:42322 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009Ab2CNSxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 14:53:37 -0400
Received: by yhmm54 with SMTP id m54so2128080yhm.19
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 11:53:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A driver start_xmit() method cannot free skb and return NETDEV_TX_BUSY,
since caller is going to reuse freed skb.

This is mostly a revert of commit bf769375c (staging: hv: fix the return
status of netvsc_start_xmit())

In fact netif_tx_stop_queue() / netif_stop_queue() is needed before
returning NETDEV_TX_BUSY or you can trigger a ksoftirqd fatal loop.

In case of memory allocation error, only safe way is to drop the packet
and return NETDEV_TX_OK

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/hyperv/netvsc_drv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 0f8e834..2517d20 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -167,7 +167,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 
 		dev_kfree_skb(skb);
 		net->stats.tx_dropped++;
-		return NETDEV_TX_BUSY;
+		return NETDEV_TX_OK;
 	}
 
 	packet->vlan_tci = skb->vlan_tci;
@@ -229,7 +229,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 		dev_kfree_skb_any(skb);
 	}
 
-	return ret ? NETDEV_TX_BUSY : NETDEV_TX_OK;
+	return NETDEV_TX_OK;
 }
 
 /*
