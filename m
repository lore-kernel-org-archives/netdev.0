From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] net: l2tp_eth: fix max_mtu
Date: Thu, 20 Oct 2016 23:19:33 -0400
Message-ID: <20161021031933.GB11396@redhat.com>
References: <20161020200826.24578-1-asbjorn@asbjorn.st>
 <1476998369.10048.1@x201s.roaming.asbjorn.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        R Parameswaran <parameswaran.r7@gmail.com>
To: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476998369.10048.1@x201s.roaming.asbjorn.biz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2016 at 09:19:29PM +0000, Asbjoern Sloth Toennesen wrote:
> On Thu, 20 Oct 2016 20:08:26 +0000 (UTC), ast@asbjorn.biz wrote:
> > diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
> > index 965f7e3..ba82dcc 100644
> > --- a/net/l2tp/l2tp_eth.c
> > +++ b/net/l2tp/l2tp_eth.c
> > @@ -259,6 +259,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
> >  		session->mtu = dev->mtu - session->hdr_len;
> >  	dev->mtu = session->mtu;
> >  	dev->needed_headroom += session->hdr_len;
> > +	dev->max_mtu = ETH_MAX_MTU - dev->needed_headroom;
> 
> I forgot to add that subtracting dev->needed_headroom doesn't
> give the exact maximum MTU, but one that is a bit too high.
> It could also just be set to ETH_MAX_MTU, to indicate that
> the encapsulation is not included.
> 
> Calculations like in R. Parameswaran's patch is needed for the
> exact one.
> https://lkml.org/lkml/2016/10/17/3

Argh. So there are a tiny handful of drivers that call ether_setup, but
have no ndo_change_mtu at all, which thus previously, had no mtu range
checks other than mtu < 0, and now have a range check of 68 to 1500...

Since there was no range at all before, feature-parity here should be
min_mtu = 0, max_mtu = ETH_MAX_MTU. I think I see five other cases that
are in a similar situation:

net/atm/br2684.c
net/bluetooth/bnep/netdev.c
net/dsa/slave.c
net/irda/irda_device.c
net/irda/irlan/irlan_eth.c

Honestly, I think dsa is the only one where it likely actually matters,
but I'll send a patch addressing all of those plus l2tp_eth in half a sec.

-- 
Jarod Wilson
jarod@redhat.com
