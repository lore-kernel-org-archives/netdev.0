From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: skb_set_dev do not unconditionally drop ref to dst
Date: Mon, 30 Apr 2012 08:53:22 +0200
Message-ID: <20120430065322.GA28320@tuxmaker.boeblingen.de.ibm.com>
References: <20120430053804.GA59677@tuxmaker.boeblingen.de.ibm.com> <1335765093.2296.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd@arndb.de, davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:51817 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab2D3Gxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 02:53:44 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Mon, 30 Apr 2012 07:53:41 +0100
Content-Disposition: inline
In-Reply-To: <1335765093.2296.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 30, 2012 at 07:51:33AM +0200, Eric Dumazet wrote:
> On Mon, 2012-04-30 at 07:38 +0200, Frank Blaschka wrote:
> > From: Frank Blaschka <frank.blaschka@de.ibm.com>
> > 
> > commit 8a83a00b0735190384a348156837918271034144 unconditionally
> > drops dst reference when skb->dev is set. This causes a regression
> > with VLAN and the qeth_l3 network driver. qeth_l3 can not get gw
> > information from the skb coming from the vlan driver. It is only
> > valid to drop the dst in case of different name spaces.
> > 
> > Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> > ---
> >  net/core/dev.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -1881,8 +1881,8 @@ EXPORT_SYMBOL(netif_device_attach);
> >  #ifdef CONFIG_NET_NS
> >  void skb_set_dev(struct sk_buff *skb, struct net_device *dev)
> >  {
> > -	skb_dst_drop(skb);
> >  	if (skb->dev && !net_eq(dev_net(skb->dev), dev_net(dev))) {
> > +		skb_dst_drop(skb);
> >  		secpath_reset(skb);
> >  		nf_reset(skb);
> >  		skb_init_secmark(skb);
> > 
> 
> You forgot CC Arnd Bergmann <arnd@arndb.de> ?
> 
> But we do want to do the skb_dst_drop() in dev_forward_skb()
> 
> Your patch breaks dev_forward_skb() then.
> 
> But apparently this forward path was alredy broken in Arnd patch...
>
Hi Eric,

do you have and suggestions how to fix this regression?
The qeth_l3 driver needs the gw information to address the frame.
The way to look at dst works well for the non vlan case and was
also working for vlan prior Arnds changes. 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
