From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] IPoIB: fix skb truesize underestimatiom
Date: Tue, 10 Jul 2012 22:03:41 +0200
Message-ID: <1341950621.3265.6331.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.com>,
	Roland Dreier <roland@purestorage.com>,
	netdev <netdev@vger.kernel.org>,
	Shlomo Pongartz <shlomop@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54049 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640Ab2GJUDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 16:03:46 -0400
Received: by eaak11 with SMTP id k11so145069eaa.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 13:03:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Or Gerlitz reported triggering of WARN_ON_ONCE(delta < len); in
skb_try_coalesce()
This warning tracks drivers that incorrectly set skb->truesize

IPoIB indeed allocates a full page to store a fragment, but only
accounts in skb->truesize the used part of the page (frame length)

This patch fixes skb truesize underestimation, and
also fixes a performance issue, because RX skbs have not enough tailroom
to allow IP and TCP stacks to pull their header in skb linear part
without an expensive call to pskb_expand_head()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
Cc: Erez Shitrit <erezsh@mellanox.com>
Cc: Shlomo Pongartz <shlomop@mellanox.com>
Cc: Roland Dreier <roland@purestorage.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_ib.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 5c1bc99..f10221f 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -123,7 +123,7 @@ static void ipoib_ud_skb_put_frags(struct ipoib_dev_priv *priv,
 
 		skb_frag_size_set(frag, size);
 		skb->data_len += size;
-		skb->truesize += size;
+		skb->truesize += PAGE_SIZE;
 	} else
 		skb_put(skb, length);
 
@@ -156,14 +156,18 @@ static struct sk_buff *ipoib_alloc_rx_skb(struct net_device *dev, int id)
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct sk_buff *skb;
 	int buf_size;
+	int tailroom;
 	u64 *mapping;
 
-	if (ipoib_ud_need_sg(priv->max_ib_mtu))
+	if (ipoib_ud_need_sg(priv->max_ib_mtu)) {
 		buf_size = IPOIB_UD_HEAD_SIZE;
-	else
+		tailroom = 128; /* reserve some tailroom for IP/TCP headers */
+	} else {
 		buf_size = IPOIB_UD_BUF_SIZE(priv->max_ib_mtu);
+		tailroom = 0;
+	}
 
-	skb = dev_alloc_skb(buf_size + 4);
+	skb = dev_alloc_skb(buf_size + tailroom + 4);
 	if (unlikely(!skb))
 		return NULL;
 
