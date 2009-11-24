From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/4] macvlan: implement bridge, VEPA and private mode
Date: Tue, 24 Nov 2009 13:45:46 +0100
Message-ID: <200911241345.46475.arnd@arndb.de>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <1259024166-28158-4-git-send-email-arnd@arndb.de> <4B0BB89F.7030605@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:60464 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422AbZKXMqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 07:46:30 -0500
In-Reply-To: <4B0BB89F.7030605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 24 November 2009, Patrick McHardy wrote:
> Arnd Bergmann wrote:

> > @@ -29,9 +29,16 @@
> >  #include <linux/if_link.h>
> >  #include <linux/if_macvlan.h>
> >  #include <net/rtnetlink.h>
> > +#include <net/xfrm.h>
> 
> Do we really need this?

Not any more. I originally did secpath_reset here, but that is now moved
to dev_forward_skb() in net/core/dev.c so I'll remove the include here.

> > @@ -129,11 +137,14 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan, int length,
> >  }
> >  
> >  static int macvlan_broadcast_one(struct sk_buff *skb, struct net_device *dev,
> > -				 const struct ethhdr *eth)
> > +				 const struct ethhdr *eth, int local)
> 
> bool local?

Already changed as a reply to Eric's comments

> > @@ -159,8 +172,12 @@ static void macvlan_broadcast(struct sk_buff *skb,
> >  
> >  	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
> >  		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
> > +			if ((vlan->dev == src) || !(vlan->mode & mode))
> 
> Please remove those unnecessary parentheses around the
> device comparison.

Ok. I usually prefer to have some extra parentheses in places that not
everyone finds obvious but these are pretty clear.

> 
> The '|' should go on the first line.

> 
> Multi-line comments should begin every line with '*'.

> 
> Please align the mode values (in all cases above) to the arguments
> on the line above.

ok

> > +static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
> > +{
> > +	const struct macvlan_dev *vlan = netdev_priv(dev);
> > +	const struct macvlan_port *port = vlan->port;
> > +	const struct macvlan_dev *dest;
> > +
> > +	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
> > +		const struct ethhdr *eth = (void *)skb->data;
> 
> eth_hdr()?

This is done before calling eth_type_trans and skb->mac_header
appears to be uninitialized then, which gave me an instant kernel
panic here.
 
> > +		dest = macvlan_hash_lookup(port, eth->h_dest);
> > +		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
> > +			int length = skb->len + ETH_HLEN;
> 
> unsigned int for length values please.

ok

Thanks for the detailed review,

	Arnd <><
