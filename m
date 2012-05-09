From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: skb_set_dev do not unconditionally drop ref to dst
Date: Wed, 9 May 2012 08:16:15 -0700
Message-ID: <20120509081615.7be58fb3@nehalam.linuxnetplumber.net>
References: <20120430053804.GA59677@tuxmaker.boeblingen.de.ibm.com>
	<1335765093.2296.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Frank Blaschka <blaschka@linux.vnet.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36278 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757038Ab2EIPQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 11:16:18 -0400
In-Reply-To: <1335765093.2296.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Apr 2012 07:51:33 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

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

Is this related to why, PMTU discover is broken now over GRE.
The simple case of doing a TCP transfer from local host over
GRE tunnel hangs.

What happens is that skb_dst(skb) is null in ip_tunnel_xmit.
Which leads to the MTU not being updated, and the ICMP_FRAG_NEEDED
is never sent.
