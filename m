From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] p54: add null pointer check before releasing socket buffer
Date: Mon, 10 Apr 2017 23:22:10 +0200
Message-ID: <1896493.H38pOMoCHn@debian64>
References: <1491801800-4371-1-git-send-email-mhjungk@gmail.com> <3716717.OUypxXNBrR@debian64> <20170410205414.GB12557@fqdn.specialj.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, David Miller <davem@redhat.com>,
        linux-wireless@vger.kernel.org, edumazet@google.com
To: Myungho Jung <mhjungk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35891 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752766AbdDJVWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 17:22:20 -0400
In-Reply-To: <20170410205414.GB12557@fqdn.specialj.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, April 10, 2017 1:54:14 PM CEST Myungho Jung wrote:
> On Mon, Apr 10, 2017 at 02:12:54PM +0200, Christian Lamparter wrote:
> > On Sunday, April 9, 2017 10:23:20 PM CEST Myungho Jung wrote:
> > > Kernel panic is caused by trying to dereference null pointer. Check if
> > > the pointer is null before freeing space.
> >  [...]
> > As for adding if (!skb) checks. I think kfree, kfree_skb, dev_kfree_skb 
> > (aka consume_skb) all check for null pointers already. So the logical
> > thing to do would be to make dev_kfree_skb_irq (which would also fix
> > dev_kfree_skb_any) consistent with kfree, kfree_skb, dev_kfree_skb and
> > add the check there.
> > > ---
> > >  drivers/net/wireless/intersil/p54/txrx.c | 8 ++++++--
> > >  1 file changed, 6 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/drivers/net/wireless/intersil/p54/txrx.c b/drivers/net/wireless/intersil/p54/txrx.c
> > > index 1af7da0..8956061 100644
> > > --- a/drivers/net/wireless/intersil/p54/txrx.c
> > > +++ b/drivers/net/wireless/intersil/p54/txrx.c
> > > @@ -503,7 +503,9 @@ static void p54_rx_eeprom_readback(struct p54_common *priv,
> > >  
> > >  	priv->eeprom = NULL;
> > >  	tmp = p54_find_and_unlink_skb(priv, hdr->req_id);
> > > -	dev_kfree_skb_any(tmp);
> > > +	if (unlikely(!tmp))
> > > +		dev_kfree_skb_any(tmp);
> > > +
> > >  	complete(&priv->eeprom_comp);
> > >  }
> > >  
> > > @@ -597,7 +599,9 @@ static void p54_rx_stats(struct p54_common *priv, struct sk_buff *skb)
> > >  	}
> > >  
> > >  	tmp = p54_find_and_unlink_skb(priv, hdr->req_id);
> > > -	dev_kfree_skb_any(tmp);
> > > +	if (unlikely(!tmp))
> > > +		dev_kfree_skb_any(tmp);
> > > +
> > >  	complete(&priv->stat_comp);
> > >  }
> > >  
> > > 
> > 
> > 
> [...] I'm not sure it actually caused kernel panic but guessed from
> a bug report [https://bugzilla.kernel.org/show_bug.cgi?id=195289].
Thank you for bringing this to my attention. Reading the bugreport, it
does sound like there's a bigger issue with the USB Ports. I'll see if
this can be fixed. But it does sound like a hardware issue at this 
point.

> And correct fix will be like this:
> 	if (likely(tmp))
> 		dev_kfree_skb_any(tmp);
> 
> But, like you said, I think null pointer should be checked in
> dev_kfree_skb_irq although already checking before calling it in many
> other places. I'll try another patch. Thank you for your advice.

Well, the patch could be as simple as this:
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 7869ae3837ca..44f7d5a1c67c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2450,6 +2450,9 @@ void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason)
 {
 	unsigned long flags;
 
+	if (!skb)
+		return;
+
 	if (likely(atomic_read(&skb->users) == 1)) {
 		smp_rmb();
 		atomic_set(&skb->users, 0);
---

The question is: would David or Eric support the change. Any comments,
what's the prefered solution? Just patch __dev_kfree_skb_irq to make
it consistent with *kfree*, or patch the driver? I'm fine either way,
but I would prefere patching __dev_kfree_skb_irq.

Regards,
Christian
