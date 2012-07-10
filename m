From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: getting warn once around skb_try_coalesce
Date: Tue, 10 Jul 2012 15:01:47 +0200
Message-ID: <1341925307.3265.5087.camel@edumazet-glaptop>
References: <4FFBFBD2.6030004@mellanox.com>
	 <1341915510.3265.4734.camel@edumazet-glaptop>
	 <1341918848.3265.4853.camel@edumazet-glaptop>
	 <1341919328.3265.4871.camel@edumazet-glaptop>
	 <4FFC2191.1040001@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Erez Shitrit <erezsh@mellanox.com>
To: Shlomo Pongartz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60140 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755729Ab2GJNBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 09:01:52 -0400
Received: by eaak11 with SMTP id k11so4677738eaa.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 06:01:50 -0700 (PDT)
In-Reply-To: <4FFC2191.1040001@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 15:35 +0300, Shlomo Pongartz wrote:

> I've applied the patch and there are no more warnings. Thanks.
> Can you please elaborate on this issue which was there from day one and 
> AFAIK never manifested itself.

two problems :

1) truesize underestimation

Well, I posted at least 50 patches related to various skb->truesize
mismatches in the past year.

skb->truesize is/should_be the true size of skb, that is the memory
allocated for sk_buff, skb->head and all fragments

Check commit e1ac50f64691de9a (bnx2x: fix skb truesize underestimation)
for a similar fix done on bnx2x

Its very important to do so to avoid OOM.

If you account few bytes per fragment but allocate PAGE_SIZE bytes, its
pretty easy to allocate far more memory than allowed by various
socket/tcp/udp/... limits, and exhaust kernel memory.

commit 924a4c7d2e962b (myri10ge: fix truesize underestimation)
commit 7b8b59617ead5acc (igbvf: fix truesize underestimation)

I probably missed your driver because it was not on drivers/net tree but
drivers/infiniband

2) Not enough tailroom

   Invisible but performance suffers, because IP/TCP will need 
to call pskb_may_pull() and the expensive __pskb_pull_tail().

   So each incoming IP packet needs at least one pskb_expand_head().



I'll send an official patch, but I believe I should refine the tailroom
allocation like that :

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
 
