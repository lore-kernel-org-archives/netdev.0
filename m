From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: skb_put_padto() already frees nskb
Date: Tue, 22 Aug 2017 11:27:44 -0700 (PDT)
Message-ID: <20170822.112744.1651629564513786056.davem@davemloft.net>
References: <20170821194131.27839-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didtelot@savoirfairelinux.com, woojung.huh@microchip.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40048 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751889AbdHVS1p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:27:45 -0400
In-Reply-To: <20170821194131.27839-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 21 Aug 2017 12:41:31 -0700

> skb_put_padto() already frees the passed sk_buff reference upon error,
> so calling kfree_skb() on it again is not necessary.
> 
> Detected by CoverityScan, CID#1416687 ("USE_AFTER_FREE")
> 
> Fixes: e71cb9e00922 ("net: dsa: ksz: fix skb freeing")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

I know it seems like a lot of work, but with appropriate wrappers we
can control the freeing that skb_pad() does at the deepest part of
this call chain.

int __skb_pad(struct sk_buff *skb, int pad, bool free_skb_on_err);
static inline int skb_pad(struct sk_buff *skb, int pad)
{
	return __skb_pad(skb, pad, true);
}

static inline int __skb_put_padto(struct sk_buff *skb, unsigned int len,
				  bool free_skb_on_err)
{
	unsigned int size = skb->len;

	if (unlikely(size < len)) {
		len -= size;
		if (__skb_pad(skb, len, free_skb_on_err))
			return -ENOMEM;
		__skb_put(skb, len);
	}
	return 0;
}

static inline int skb_put_padto(struct sk_buff *skb, unsigned int len)
{
	return __skb_put_padto(skb, len, true);
}

And then here in the ksz_xmit() code, invoke __skb_put_padto() with the
boolean set appropriately.
