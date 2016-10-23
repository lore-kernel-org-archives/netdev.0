From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next v2 7/9] net: use core MTU range checking in misc
 drivers
Date: Sat, 22 Oct 2016 21:18:24 -0400
Message-ID: <20161023011824.GE32569@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
 <20161020175524.6184-8-jarod@redhat.com>
 <20161022211606.3b5d137d@kant>
 <20161022212759.228c7642@kant>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux1394-devel@lists.sourceforge.net
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161022212759.228c7642@kant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 22, 2016 at 09:27:59PM +0200, Stefan Richter wrote:
> Adding Cc: linux1394-devel, dropping several Ccs, no additional comment.
> 
> On Oct 22 Stefan Richter wrote:
> > On Oct 20 Jarod Wilson wrote:
> > > firewire-net:
> > > - set min/max_mtu
> > > - remove fwnet_change_mtu  
> > [...]
> > > --- a/drivers/firewire/net.c
> > > +++ b/drivers/firewire/net.c
> > > @@ -1349,15 +1349,6 @@ static netdev_tx_t fwnet_tx(struct sk_buff
> > > *skb, struct net_device *net) return NETDEV_TX_OK;
> > >  }
> > >  
> > > -static int fwnet_change_mtu(struct net_device *net, int new_mtu)
> > > -{
> > > -	if (new_mtu < 68)
> > > -		return -EINVAL;
> > > -
> > > -	net->mtu = new_mtu;
> > > -	return 0;
> > > -}
> > > -
> > >  static const struct ethtool_ops fwnet_ethtool_ops = {
> > >  	.get_link	= ethtool_op_get_link,
> > >  };
> > > @@ -1366,7 +1357,6 @@ static const struct net_device_ops
> > > fwnet_netdev_ops = { .ndo_open       = fwnet_open,
> > >  	.ndo_stop	= fwnet_stop,
> > >  	.ndo_start_xmit = fwnet_tx,
> > > -	.ndo_change_mtu = fwnet_change_mtu,
> > >  };
> > >  
> > >  static void fwnet_init_dev(struct net_device *net)
> > > @@ -1435,7 +1425,6 @@ static int fwnet_probe(struct fw_unit *unit,
> > >  	struct net_device *net;
> > >  	bool allocated_netdev = false;
> > >  	struct fwnet_device *dev;
> > > -	unsigned max_mtu;
> > >  	int ret;
> > >  	union fwnet_hwaddr *ha;
> > >  
> > > @@ -1478,9 +1467,10 @@ static int fwnet_probe(struct fw_unit *unit,
> > >  	 * Use the RFC 2734 default 1500 octets or the maximum payload
> > >  	 * as initial MTU
> > >  	 */
> > > -	max_mtu = (1 << (card->max_receive + 1))
> > > -		  - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
> > > -	net->mtu = min(1500U, max_mtu);
> > > +	net->max_mtu = (1 << (card->max_receive + 1))
> > > +		       - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
> > > +	net->mtu = min(1500U, net->max_mtu);
> > > +	net->min_mtu = ETH_MIN_MTU;
> > >  
> > >  	/* Set our hardware address while we're at it */
> > >  	ha = (union fwnet_hwaddr *)net->dev_addr;
> > 
> > Please preserve the current behavior, i.e. do not enforce any particular
> > upper bound.  (Especially none based on the local link layer controller's
> > max_receive parameter.)
> > 
> > BTW, after having read RFC 2734, RFC 3146, and the code, I am convinced
> > that net->mtu should be initialized to 1500, not less.  But such a change
> > should be done in a separate patch.

Okay, since it's already merged in net-next, I can do a follow-up patch
here to set max_mtu to ETH_MAX_MTU (65535), which is the largest possible
size the kernel can handle, so far as I can tell. But as long as I'm going
to be in here, if we just want to use an initial mtu of 1500, I could
clean that up at the same time, and entirely remove the max_mtu
calculation stuff, if that's what you think is more correct here.

-- 
Jarod Wilson
jarod@redhat.com
