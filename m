From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: skb_set_dev do not unconditionally drop ref to dst
Date: Wed, 02 May 2012 08:59:21 +0200
Message-ID: <1335941961.22133.48.camel@edumazet-glaptop>
References: <20120430053804.GA59677@tuxmaker.boeblingen.de.ibm.com>
	 <1335765093.2296.4.camel@edumazet-glaptop>
	 <20120502055018.GA50959@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, arnd@arndb.de,
	linux-s390@vger.kernel.org
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54766 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab2EBG71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 02:59:27 -0400
In-Reply-To: <20120502055018.GA50959@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 07:50 +0200, Frank Blaschka wrote:
> On Mon, Apr 30, 2012 at 07:51:33AM +0200, Eric Dumazet wrote:
> > On Mon, 2012-04-30 at 07:38 +0200, Frank Blaschka wrote:
> > > From: Frank Blaschka <frank.blaschka@de.ibm.com>
> > > 
> > > commit 8a83a00b0735190384a348156837918271034144 unconditionally
> > > drops dst reference when skb->dev is set. This causes a regression
> > > with VLAN and the qeth_l3 network driver. qeth_l3 can not get gw
> > > information from the skb coming from the vlan driver. It is only
> > > valid to drop the dst in case of different name spaces.
> > > 
> > > Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> > > ---
> > >  net/core/dev.c |    2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -1881,8 +1881,8 @@ EXPORT_SYMBOL(netif_device_attach);
> > >  #ifdef CONFIG_NET_NS
> > >  void skb_set_dev(struct sk_buff *skb, struct net_device *dev)
> > >  {
> > > -	skb_dst_drop(skb);
> > >  	if (skb->dev && !net_eq(dev_net(skb->dev), dev_net(dev))) {
> > > +		skb_dst_drop(skb);
> > >  		secpath_reset(skb);
> > >  		nf_reset(skb);
> > >  		skb_init_secmark(skb);
> > > 
> > 
> > You forgot CC Arnd Bergmann <arnd@arndb.de> ?
> > 
> > But we do want to do the skb_dst_drop() in dev_forward_skb()
> > 
> > Your patch breaks dev_forward_skb() then.
> If NET_NS is not defined is this broken too?
> > 
> > But apparently this forward path was alredy broken in Arnd patch...
> >
> Ok, until nobody comes up with an other idea I will post a patch to
> change back the vlan driver (use skb->dev = dev instead of skb_set_dev)
> next week. 
> > 


If Arnd doesnt care to even reply, we can just revert his buggy patch,
instead of trying to understand and fix all issues.
