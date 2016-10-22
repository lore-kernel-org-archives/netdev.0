From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH net-next v2 7/9] net: use core MTU range checking in
 misc drivers
Date: Sat, 22 Oct 2016 21:27:59 +0200
Message-ID: <20161022212759.228c7642@kant>
References: <20161019023333.15760-1-jarod@redhat.com>
        <20161020175524.6184-1-jarod@redhat.com>
        <20161020175524.6184-8-jarod@redhat.com>
        <20161022211606.3b5d137d@kant>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux1394-devel@lists.sourceforge.net
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:50850 "EHLO
        einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751241AbcJVT2P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 15:28:15 -0400
In-Reply-To: <20161022211606.3b5d137d@kant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding Cc: linux1394-devel, dropping several Ccs, no additional comment.

On Oct 22 Stefan Richter wrote:
> On Oct 20 Jarod Wilson wrote:
> > firewire-net:
> > - set min/max_mtu
> > - remove fwnet_change_mtu  
> [...]
> > --- a/drivers/firewire/net.c
> > +++ b/drivers/firewire/net.c
> > @@ -1349,15 +1349,6 @@ static netdev_tx_t fwnet_tx(struct sk_buff
> > *skb, struct net_device *net) return NETDEV_TX_OK;
> >  }
> >  
> > -static int fwnet_change_mtu(struct net_device *net, int new_mtu)
> > -{
> > -	if (new_mtu < 68)
> > -		return -EINVAL;
> > -
> > -	net->mtu = new_mtu;
> > -	return 0;
> > -}
> > -
> >  static const struct ethtool_ops fwnet_ethtool_ops = {
> >  	.get_link	= ethtool_op_get_link,
> >  };
> > @@ -1366,7 +1357,6 @@ static const struct net_device_ops
> > fwnet_netdev_ops = { .ndo_open       = fwnet_open,
> >  	.ndo_stop	= fwnet_stop,
> >  	.ndo_start_xmit = fwnet_tx,
> > -	.ndo_change_mtu = fwnet_change_mtu,
> >  };
> >  
> >  static void fwnet_init_dev(struct net_device *net)
> > @@ -1435,7 +1425,6 @@ static int fwnet_probe(struct fw_unit *unit,
> >  	struct net_device *net;
> >  	bool allocated_netdev = false;
> >  	struct fwnet_device *dev;
> > -	unsigned max_mtu;
> >  	int ret;
> >  	union fwnet_hwaddr *ha;
> >  
> > @@ -1478,9 +1467,10 @@ static int fwnet_probe(struct fw_unit *unit,
> >  	 * Use the RFC 2734 default 1500 octets or the maximum payload
> >  	 * as initial MTU
> >  	 */
> > -	max_mtu = (1 << (card->max_receive + 1))
> > -		  - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
> > -	net->mtu = min(1500U, max_mtu);
> > +	net->max_mtu = (1 << (card->max_receive + 1))
> > +		       - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
> > +	net->mtu = min(1500U, net->max_mtu);
> > +	net->min_mtu = ETH_MIN_MTU;
> >  
> >  	/* Set our hardware address while we're at it */
> >  	ha = (union fwnet_hwaddr *)net->dev_addr;
> 
> Please preserve the current behavior, i.e. do not enforce any particular
> upper bound.  (Especially none based on the local link layer controller's
> max_receive parameter.)
> 
> BTW, after having read RFC 2734, RFC 3146, and the code, I am convinced
> that net->mtu should be initialized to 1500, not less.  But such a change
> should be done in a separate patch.
-- 
Stefan Richter
-======----- =-=- =-==-
http://arcgraph.de/sr/
