From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 1/5] netdev: introduce ndo_set_rx_headroom
Date: Wed, 24 Feb 2016 09:37:56 +0100
Message-ID: <1456303076.5436.4.camel@redhat.com>
References: <cover.1456163137.git.pabeni@redhat.com>
	 <ce1a9b0a33927547d0fbc659ac59dcf9fb7c3a33.1456163137.git.pabeni@redhat.com>
	 <CAOrHB_DgzNed9bD6F1zytxq=0m+6oXECRokRvMuP0qa7Vu7NYw@mail.gmail.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:45880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866AbcBXIiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:38:02 -0500
In-Reply-To: <CAOrHB_DgzNed9bD6F1zytxq=0m+6oXECRokRvMuP0qa7Vu7NYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-23 at 11:20 -0800, pravin shelar wrote:
> On Tue, Feb 23, 2016 at 4:53 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > This method allows the controlling device (i.e. the bridge) to specify
> > additional headroom to be allocated for skb head on frame reception.
> >
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  include/linux/netdevice.h | 20 ++++++++++++++++++++
> >  1 file changed, 20 insertions(+)
> >
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 47671ce0..fb74277 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -1093,6 +1093,12 @@ struct tc_to_netdev {
> >   *     This function is used to get egress tunnel information for given skb.
> >   *     This is useful for retrieving outer tunnel header parameters while
> >   *     sampling packet.
> ...
> 
> >  /**
> > @@ -1315,6 +1323,8 @@ struct net_device_ops {
> >   * @IFF_L3MDEV_SLAVE: device is enslaved to an L3 master device
> >   * @IFF_TEAM: device is a team device
> >   * @IFF_RXFH_CONFIGURED: device has had Rx Flow indirection table configured
> > + * @IFF_PHONY_HEADROOM: the headroom value is controlled by an external
> > + *     entity (i.e. the master device for bridged veth)
> >   */
> >  enum netdev_priv_flags {
> >         IFF_802_1Q_VLAN                 = 1<<0,
> > @@ -1343,6 +1353,7 @@ enum netdev_priv_flags {
> >         IFF_L3MDEV_SLAVE                = 1<<23,
> >         IFF_TEAM                        = 1<<24,
> >         IFF_RXFH_CONFIGURED             = 1<<25,
> > +       IFF_PHONY_HEADROOM              = 1<<26,
> >  };
> >
> >  #define IFF_802_1Q_VLAN                        IFF_802_1Q_VLAN
> > @@ -1937,6 +1948,15 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
> >                                     struct sk_buff *skb,
> >                                     void *accel_priv);
> >
> > +/* returns the headroom that the master device needs to take in account
> > + * when forwarding to this dev
> > + */
> > +static inline unsigned netdev_get_fwd_headroom(struct net_device *dev)
> > +{
> > +       return (dev->priv_flags && IFF_PHONY_HEADROOM) ? dev->needed_headroom :
> > +               0;
> > +}
> > +
> This looks like typo. It should '&' to check for the bitfield.

You are right! Thank you for spotting it.

There is also another error here; the code should be:

return (dev->priv_flags & IFF_PHONY_HEADROOM) ? 0 : dev->needed_headroom;

i.e. when computing the rx/forwarding headroom, we want to ignore
devices with phony headroom, since they actually will not requires
additional skb headroom on xmit.

I'll fix this in v2.

Paolo
