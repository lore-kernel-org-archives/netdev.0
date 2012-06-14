From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 11:50:17 +0200
Message-ID: <1339667417.22704.707.camel@edumazet-glaptop>
References: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com>
	 <1339665719.22704.692.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40821 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755336Ab2FNJuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 05:50:21 -0400
Received: by eeit10 with SMTP id t10so495062eei.19
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2012 02:50:20 -0700 (PDT)
In-Reply-To: <1339665719.22704.692.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-14 at 11:22 +0200, Eric Dumazet wrote:

> So you are saying that if you make skb_orphan_try() doing nothing, it
> solves your problem ?

It probably does, if your application does an UDP flood, trying to send
more than the link bandwidth. I guess only benchmarks workloads ever try
to do that.

bonding has no way to give congestion back, it has no Qdisc by default.

We probably can defer the skb_orphan_try() for bonding master, a bit
like the IFF_XMIT_DST_RELEASE 

 drivers/net/bonding/bond_main.c |    2 +-
 include/linux/if.h              |    3 +++
 net/core/dev.c                  |    5 +++--
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2ee8cf9..1b1e9c8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4343,7 +4343,7 @@ static void bond_setup(struct net_device *bond_dev)
 	bond_dev->tx_queue_len = 0;
 	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
 	bond_dev->priv_flags |= IFF_BONDING;
-	bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
+	bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING | IFF_XMIT_ORPHAN);
 
 	/* At first, we block adding VLANs. That's the only way to
 	 * prevent problems that occur when adding VLANs over an
diff --git a/include/linux/if.h b/include/linux/if.h
index f995c66..a788e7b 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -81,6 +81,9 @@
 #define IFF_UNICAST_FLT	0x20000		/* Supports unicast filtering	*/
 #define IFF_TEAM_PORT	0x40000		/* device used as team port */
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
+#define IFF_XMIT_ORPHAN	0x100000	/* dev_hard_start_xmit() is allowed to
+					 * orphan skb
+					 */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/core/dev.c b/net/core/dev.c
index cd09819..3435463 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2193,7 +2193,8 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
 
-		skb_orphan_try(skb);
+		if (dev->priv_flags & IFF_XMIT_ORPHAN)
+			skb_orphan_try(skb);
 
 		features = netif_skb_features(skb);
 
@@ -5929,7 +5930,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
-	dev->priv_flags = IFF_XMIT_DST_RELEASE;
+	dev->priv_flags = IFF_XMIT_DST_RELEASE | IFF_XMIT_ORPHAN;
 	setup(dev);
 
 	dev->num_tx_queues = txqs;
