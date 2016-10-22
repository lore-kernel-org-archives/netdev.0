From: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Subject: Re: [PATCH net-next 6/6] net: use core MTU range checking in misc
 drivers
Date: Sat, 22 Oct 2016 11:36:07 +0200
Message-ID: <20161022113607.55832988@kant>
References: <20161019023333.15760-1-jarod@redhat.com>
        <20161019023333.15760-7-jarod@redhat.com>
        <20161019160546.GC11224@bistromath.localdomain>
        <20161020003846.64f85f7e@kant>
        <20161020031641.GJ18569@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sabrina Dubroca <sd-y1jBWg8GRStKuXlAQpz2QA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cliff Whickman <cpw-sJ/iWh9BUns@public.gmane.org>,
        Robin Holt <robinmholt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jes Sorensen <jes-dtAfj9ClZIwnoBwkMbRkTB2eb7JE58TQ@public.gmane.org>,
        Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
        Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>,
        Antonio Quartulli <a@unstable.cc>
To: Jarod Wilson <jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161020031641.GJ18569-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Oct 19 Jarod Wilson wrote:
> On Thu, Oct 20, 2016 at 12:38:46AM +0200, Stefan Richter wrote:
> > On Oct 19 Sabrina Dubroca wrote:
> > > 2016-10-18, 22:33:33 -0400, Jarod Wilson wrote:
> > > [...]
> > > > diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
> > > > index 309311b..b5f125c 100644
> > > > --- a/drivers/firewire/net.c
> > > > +++ b/drivers/firewire/net.c
> > > > @@ -1349,15 +1349,6 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
> > > >  	return NETDEV_TX_OK;
> > > >  }
> > > >  
> > > > -static int fwnet_change_mtu(struct net_device *net, int new_mtu)
> > > > -{
> > > > -	if (new_mtu < 68)
> > > > -		return -EINVAL;
> > > > -
> > > > -	net->mtu = new_mtu;
> > > > -	return 0;
> > > > -}
> > > > -  
> > > 
> > > This doesn't do any upper bound checking.
> > 
> > I need to check more closely, but I think the RFC 2734 encapsulation spec
> > and our implementation do not impose a particular upper limit.  Though I
> > guess it's bad to let userland set arbitrarily large values here.
> 
> In which case, that would suggest using IP_MAX_MTU (65535) here.

Probably.  I (or somebody) need to check the spec and the code once more.

[...]
> > > > @@ -1481,6 +1471,8 @@ static int fwnet_probe(struct fw_unit *unit,
> > > >  	max_mtu = (1 << (card->max_receive + 1))
> > > >  		  - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
> > > >  	net->mtu = min(1500U, max_mtu);
> > > > +	net->min_mtu = ETH_MIN_MTU;
> > > > +	net->max_mtu = net->mtu;  
> > > 
> > > But that will now prevent increasing the MTU above the initial value?
> > 
> > Indeed, therefore NAK.
> 
> However, there's an explicit calculation for 'max_mtu' right there that I
> glazed right over. It would seem perhaps *that* should be used for
> net->max_mtu here, no?

No.  This 'max_mtu' here is not the absolute maximum.  It is only an
initial MTU which has the property that link fragmentation is not
going to happen (if all other peers will at least as capable as this
node).
-- 
Stefan Richter
-======----- =-=- =-==-
http://arcgraph.de/sr/
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
