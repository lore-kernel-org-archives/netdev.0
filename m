From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 5/5] veth: implement ndo_set_rx_headroom
Date: Wed, 24 Feb 2016 10:17:34 +0100
Message-ID: <1456305454.5436.28.camel@redhat.com>
References: <cover.1456163137.git.pabeni@redhat.com>
	 <193cf433bb4b8dac52ca1a76477b651c47e01ed3.1456163137.git.pabeni@redhat.com>
	 <CAOrHB_BzDhT_MTXPoEm-AaaVA++u_p_AdapMygMuw0gzgDUcyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480AbcBXJRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 04:17:39 -0500
In-Reply-To: <CAOrHB_BzDhT_MTXPoEm-AaaVA++u_p_AdapMygMuw0gzgDUcyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-23 at 11:21 -0800, pravin shelar wrote:
> On Tue, Feb 23, 2016 at 4:53 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > The rx headroom for veth dev is the peer device needed_headroom.
> > Avoid ping-pong updates setting the private flag IFF_PHONY_HEADROOM.
> >
> > This avoids skb head reallocation when forwarding from a veth dev
> > towards a device adding some kind of encapsulation.
> >
> > When forwarding frames below the MTU size towards a vxlan device,
> > this gives about 10% performance speed-up when OVS is used to connect
> > the veth and the vxlan device and a little more when using a
> > plain Linux bridge.
> >
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  drivers/net/veth.c | 26 ++++++++++++++++++++++++++
> >  1 file changed, 26 insertions(+)
> >
> > diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> > index ba21d07..4f30a6a 100644
> > --- a/drivers/net/veth.c
> > +++ b/drivers/net/veth.c
> > @@ -35,6 +35,7 @@ struct pcpu_vstats {
> >  struct veth_priv {
> >         struct net_device __rcu *peer;
> >         atomic64_t              dropped;
> > +       unsigned                requested_headroom;
> >  };
> >
> >  /*
> > @@ -271,6 +272,29 @@ static int veth_get_iflink(const struct net_device *dev)
> >         return iflink;
> >  }
> >
> > +static void veth_set_rx_headroom(struct net_device *dev, int new_hr)
> > +{
> > +       struct veth_priv *peer_priv, *priv = netdev_priv(dev);
> > +       struct net_device *peer;
> > +
> > +       if (new_hr < 0)
> > +               new_hr = 0;
> > +
> > +       rcu_read_lock();
> > +       peer = rcu_dereference(priv->peer);
> > +       if (unlikely(!peer))
> > +               goto out;
> > +
> > +       peer_priv = netdev_priv(peer);
> > +       priv->requested_headroom = new_hr;
> > +       new_hr = max(priv->requested_headroom, peer_priv->requested_headroom);
> > +       dev->needed_headroom = new_hr;
> > +       peer->needed_headroom = new_hr;
> > +
> > +out:
> > +       rcu_read_unlock();
> > +}
> > +
> I am not sure why new priv->requested_headroom is introduced. I think
> you can just compare new_hr with dev->needed_headroom and set the max
> value to both devices.

The requested_headroom headroom was intended to cope with with this
scenario:

brctl addif br0 veth0
brctl delif br0 veth0
brctl addif br1 veth0

If I set needed_headroom to the max value to both veth peers, after the
last call veth will use max(br0 headroom, br1 headroom), instead of br1
headroom.

Paolo
