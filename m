From: Myungho Jung <mhjungk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] p54: add null pointer check before releasing socket
 buffer
Date: Mon, 10 Apr 2017 13:54:14 -0700
Message-ID: <20170410205414.GB12557@fqdn.specialj.com>
References: <1491801800-4371-1-git-send-email-mhjungk@gmail.com>
 <3716717.OUypxXNBrR@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3716717.OUypxXNBrR@debian64>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2017 at 02:12:54PM +0200, Christian Lamparter wrote:
> (Added linux-wireless, since this is a wireless driver)
> 
> On Sunday, April 9, 2017 10:23:20 PM CEST Myungho Jung wrote:
> > Kernel panic is caused by trying to dereference null pointer. Check if
> > the pointer is null before freeing space.
> Do you have the kernel panic somewhere?
> I think you have an even bigger problem: You see, in order to get EEPROM
> readback and rx_stats feedback you need to sent a request to the firmware
> and if the response's req_id cookies don't match, you end up filling up 
> the very limited device address space.
> 
> As for adding if (!skb) checks. I think kfree, kfree_skb, dev_kfree_skb 
> (aka consume_skb) all check for null pointers already. So the logical
> thing to do would be to make dev_kfree_skb_irq (which would also fix
> dev_kfree_skb_any) consistent with kfree, kfree_skb, dev_kfree_skb and
> add the check there.
> 
> > Signed-off-by: Myungho Jung <mhjungk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  drivers/net/wireless/intersil/p54/txrx.c | 8 ++++++--
> >  1 file changed, 6 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/wireless/intersil/p54/txrx.c b/drivers/net/wireless/intersil/p54/txrx.c
> > index 1af7da0..8956061 100644
> > --- a/drivers/net/wireless/intersil/p54/txrx.c
> > +++ b/drivers/net/wireless/intersil/p54/txrx.c
> > @@ -503,7 +503,9 @@ static void p54_rx_eeprom_readback(struct p54_common *priv,
> >  
> >  	priv->eeprom = NULL;
> >  	tmp = p54_find_and_unlink_skb(priv, hdr->req_id);
> > -	dev_kfree_skb_any(tmp);
> > +	if (unlikely(!tmp))
> > +		dev_kfree_skb_any(tmp);
> > +
> >  	complete(&priv->eeprom_comp);
> >  }
> >  
> > @@ -597,7 +599,9 @@ static void p54_rx_stats(struct p54_common *priv, struct sk_buff *skb)
> >  	}
> >  
> >  	tmp = p54_find_and_unlink_skb(priv, hdr->req_id);
> > -	dev_kfree_skb_any(tmp);
> > +	if (unlikely(!tmp))
> > +		dev_kfree_skb_any(tmp);
> > +
> >  	complete(&priv->stat_comp);
> >  }
> >  
> > 
> 
> 

I found that the fix was totally opposite to my thought. Sorry about
confusion. I'm not sure it actually caused kernel panic but guessed from
a bug report [https://bugzilla.kernel.org/show_bug.cgi?id=195289]. And
correct fix will be like this:
	if (likely(tmp))
		dev_kfree_skb_any(tmp);

But, like you said, I think null pointer should be checked in
dev_kfree_skb_irq although already checking before calling it in many
other places. I'll try another patch. Thank you for your advice.

Thanks,
Myungho
