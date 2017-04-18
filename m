From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] smsc95xx: Use skb_cow_head to deal with cloned skbs
Date: Tue, 18 Apr 2017 15:46:01 -0700
Message-ID: <1492555561.10587.147.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170418171706.21190-1-james.hughes@raspberrypi.org>
         <1492541921.10587.135.camel@edumazet-glaptop3.roam.corp.google.com>
         <9235D6609DB808459E95D78E17F2E43D40A477A5@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: james.hughes@raspberrypi.org, netdev@vger.kernel.org,
        steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33774 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756700AbdDRWqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 18:46:03 -0400
Received: by mail-pf0-f194.google.com with SMTP id c198so968214pfc.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 15:46:03 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A477A5@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-18 at 22:09 +0000, Woojung.Huh@microchip.com wrote:
> > > @@ -2067,13 +2067,9 @@ static struct sk_buff *smsc95xx_tx_fixup(struct
> > usbnet *dev,
> > >  	/* We do not advertise SG, so skbs should be already linearized */
> > >  	BUG_ON(skb_shinfo(skb)->nr_frags);
> > >
> > > -	if (skb_headroom(skb) < overhead) {
> > > -		struct sk_buff *skb2 = skb_copy_expand(skb,
> > > -			overhead, 0, flags);
> > > -		dev_kfree_skb_any(skb);
> > > -		skb = skb2;
> > > -		if (!skb)
> > > -			return NULL;
> > > +	/* Make writable and expand header space by overhead if required
> > */
> > > +	if (skb_cow_head(skb, overhead)) {
> > 
> > I believe you still need to
> > 		dev_kfree_skb_any(skb);
> > 
> I think caller of usbnet_start_xmit() takes care of free when return NULL.

I do not think so. Here is the code in usbnet_start_xmit() :

if (info->tx_fixup) {
   skb = info->tx_fixup (dev, skb, GFP_ATOMIC);

   if (!skb) { // Note that skb is NULL now

       if (info->flags & FLAG_MULTI_PACKET)
             goto not_drop;
        netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
        goto drop;


If you really think about it (even before double checking the code in
usbnet_start_xmit()), that would have been a very serious bug.

Calling dev_kfree_skb_any(skb) in this fixup code, then later from
usbnet_start_xmit() would have been a double free, or use after free.
