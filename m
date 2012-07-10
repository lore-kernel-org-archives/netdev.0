From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: getting warn once around skb_try_coalesce
Date: Tue, 10 Jul 2012 13:14:08 +0200
Message-ID: <1341918848.3265.4853.camel@edumazet-glaptop>
References: <4FFBFBD2.6030004@mellanox.com>
	 <1341915510.3265.4734.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shlomo Pongratz <shlomop@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54796 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720Ab2GJLOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 07:14:12 -0400
Received: by eeit10 with SMTP id t10so4633604eei.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 04:14:11 -0700 (PDT)
In-Reply-To: <1341915510.3265.4734.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 12:18 +0200, Eric Dumazet wrote:
> On Tue, 2012-07-10 at 12:54 +0300, Or Gerlitz wrote:
> > Hi Dave, Eric,
> > 
> > Another trace that I see here with net-next is this one-time warning. I 
> > get it always
> > on the passive side of TCP, something that seems related to GRO, it 
> > happens only with
> > IPoIB, not with mlx4_en and igb (when igb get to work on net-next...)
> > 
> > The latest commit in this area is bad43ca8325f493dcaa0896c2f036276af059c7e
> > "net: introduce skb_try_coalesce()" from Eric.
> > 
> > Or.
> > 
> > -----------[ cut here ]------------
> > WARNING: at net/core/skbuff.c:3413 skb_try_coalesce+0x1f8/0x31d()
> 
> This warning catch skb truesize offenders, most probably its a driver
> issue.
> 

By the way, this driver allocates not enough tailroom in skbs, so IP/TCP
stacks need to reallocate skb head to pull IP/TCP headers. Thats not
efficient.

I suggest using following patch :

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 5c1bc99..9939869 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -159,7 +159,7 @@ static struct sk_buff *ipoib_alloc_rx_skb(struct net_device *dev, int id)
 	u64 *mapping;
 
 	if (ipoib_ud_need_sg(priv->max_ib_mtu))
-		buf_size = IPOIB_UD_HEAD_SIZE;
+		buf_size = IPOIB_UD_HEAD_SIZE + 128; /* reserve some tailroom for IP/TCP headers */
 	else
 		buf_size = IPOIB_UD_BUF_SIZE(priv->max_ib_mtu);
 
