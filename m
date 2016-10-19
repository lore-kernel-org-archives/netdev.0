From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH net-next 6/6] net: use core MTU range checking in misc
 drivers
Date: Thu, 20 Oct 2016 00:38:46 +0200
Message-ID: <20161020003846.64f85f7e@kant>
References: <20161019023333.15760-1-jarod@redhat.com>
        <20161019023333.15760-7-jarod@redhat.com>
        <20161019160546.GC11224@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Faisal Latif <faisal.latif@intel.com>,
        linux-rdma@vger.kernel.org, Cliff Whickman <cpw@sgi.com>,
        Robin Holt <robinmholt@gmail.com>,
        Jes Sorensen <jes@trained-monkey.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>
To: Sabrina Dubroca <sd@queasysnail.net>,
        Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161019160546.GC11224@bistromath.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Oct 19 Sabrina Dubroca wrote:
> 2016-10-18, 22:33:33 -0400, Jarod Wilson wrote:
> [...]
> > diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
> > index 309311b..b5f125c 100644
> > --- a/drivers/firewire/net.c
> > +++ b/drivers/firewire/net.c
> > @@ -1349,15 +1349,6 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
> >  	return NETDEV_TX_OK;
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
> 
> This doesn't do any upper bound checking.

I need to check more closely, but I think the RFC 2734 encapsulation spec
and our implementation do not impose a particular upper limit.  Though I
guess it's bad to let userland set arbitrarily large values here.

> >  static const struct ethtool_ops fwnet_ethtool_ops = {
> >  	.get_link	= ethtool_op_get_link,
> >  };
> > @@ -1366,7 +1357,6 @@ static const struct net_device_ops fwnet_netdev_ops = {
> >  	.ndo_open       = fwnet_open,
> >  	.ndo_stop	= fwnet_stop,
> >  	.ndo_start_xmit = fwnet_tx,
> > -	.ndo_change_mtu = fwnet_change_mtu,
> >  };
> >  
> >  static void fwnet_init_dev(struct net_device *net)
> > @@ -1481,6 +1471,8 @@ static int fwnet_probe(struct fw_unit *unit,
> >  	max_mtu = (1 << (card->max_receive + 1))
> >  		  - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
> >  	net->mtu = min(1500U, max_mtu);
> > +	net->min_mtu = ETH_MIN_MTU;
> > +	net->max_mtu = net->mtu;  
> 
> But that will now prevent increasing the MTU above the initial value?

Indeed, therefore NAK.

PS:
If the IP packet plus encapsulation header fits into IEEE 1394 packet
payload, it is transported without link fragmentation.  If it does not
fit, link fragmentation occurs (which reduces bandwidth a bit and
consumes additional buffering resources at the transmitter and the
receiver).

Broadcast and multicast packets are transmitted via IEEE 1394 asynchronous
stream packets at a low bus speed (because our code does not attempt to
find the maximum speed and size that is supported by all potential
listeners).  This limits the payload to 512 bytes.

Unicast packets are transmitted via IEEE 1394 asynchronous write request
packets at optimum speed.  In most cases, this means that 2048 bytes
payload is possible, in some cases 4096 bytes.  Many CardBus FireWire
cards support only 1024 bytes payload of these packets though.
Furthermore, some low-speed long-haul cablings may cap the bus speed and
thereby the payload size to 1024 or 512 bytes, but this is uncommon in
practice.
-- 
Stefan Richter
-======----- =-=- =-=--
http://arcgraph.de/sr/
