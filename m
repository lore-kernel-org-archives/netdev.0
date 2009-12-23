From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: ixgbe warning
Date: Wed, 23 Dec 2009 14:38:55 +0530
Message-ID: <OF78047910.1202C26A-ON65257695.0030A7D8-65257695.00313863@in.ibm.com>
References: <86802c440912222100j1c23f3d9xfb734a6e52fa2ec9@mail.gmail.com>
	<OF748A4720.94B5A869-ON65257695.00267BA3-65257695.0027EDC4@in.ibm.com>
	<4B31D1AE.3090500@kernel.org>
	<OF7CCEEFED.46E6EE59-ON65257695.002F98AC-65257695.00303B56@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <OF7CCEEFED.46E6EE59-ON65257695.002F98AC-65257695.00303B56@in.ibm.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> Krishna Kumar2/India/IBM@IBMIN wrote
>
> > > I guess you are running on a big SMP system? If so,
> > > ixgbe_select_queue() is not limiting the queue_index
> > > based on real_num_tx_queues, and possibly returning
> > > a bad txq from:
> > >
> > >       if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
> > >             return txq;
> > >
> > > Also, I was looking at other providers of select_queue and found:
> > >
> > > u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb)
> > > {
> > >         return skb_get_queue_mapping(skb);
> > > }
> > >
> > > How can this be correct (driver supports upto 8 txq's). Unless txq=0
> for
> > > xmits of all locally
> > > generated packets is fine.
> >
> > may need this one...
> >
> > ---
> >  drivers/net/ixgbe/ixgbe_main.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > Index: linux-2.6/drivers/net/ixgbe/ixgbe_main.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/ixgbe/ixgbe_main.c
> > +++ linux-2.6/drivers/net/ixgbe/ixgbe_main.c
> > @@ -5317,7 +5317,7 @@ static int ixgbe_maybe_stop_tx(struct ne
> >  static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff
> *skb)
> >  {
> >     struct ixgbe_adapter *adapter = netdev_priv(dev);
> > -   int txq = smp_processor_id();
> > +   int txq = smp_processor_id() % adapter->num_tx_queues;
> >
> >     if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
> >        return txq;
>
> The modulo operation is not required (and costly too) for
> other cases. You should move it inside the if case, or I
> guess Jeff can suggest the right fix.

BTW, do your warnings disappear when you put the modulo inside
the above 'if' condition?

thanks,

- KK


------------------------------------------------------------------------------
This SF.Net email is sponsored by the Verizon Developer Community
Take advantage of Verizon's best-in-class app development support
A streamlined, 14 day to market process makes app distribution fast and easy
Join now and get one step closer to millions of Verizon customers
http://p.sf.net/sfu/verizon-dev2dev 
