From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2/2] tg3: Add code to allow ethtool to
 enable/disable loopback.
Date: Thu, 28 Apr 2011 19:46:52 -0700
Message-ID: <20110429024652.GB20805@mcarlson.broadcom.com>
References: <1304033599-8395-1-git-send-email-maheshb@google.com>
 <1304033599-8395-2-git-send-email-maheshb@google.com>
 <1304033599-8395-3-git-send-email-maheshb@google.com>
 <20110429002855.GC19665@mcarlson.broadcom.com>
 <BANLkTimA9YGFKjB0_UMsAJeSGEbKGoFJXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Micha? Miros?aw" <mirq-linux@rere.qmqm.pl>
To: "Mahesh Bandewar" <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3996 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753168Ab1D2Cdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 22:33:37 -0400
In-Reply-To: <BANLkTimA9YGFKjB0_UMsAJeSGEbKGoFJXQ@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2011 at 06:42:02PM -0700, Mahesh Bandewar wrote:
> >> + ? ? spin_unlock_bh(&tp->lock);
> >> +
> >> + ? ? return err;
> >> +}
> >> +
> >> ?static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
> >> ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?int new_mtu)
> >> ?{
> >> @@ -15028,6 +15055,7 @@ static const struct net_device_ops tg3_netdev_ops = {
> >> ? ? ? .ndo_tx_timeout ? ? ? ? = tg3_tx_timeout,
> >> ? ? ? .ndo_change_mtu ? ? ? ? = tg3_change_mtu,
> >> ? ? ? .ndo_fix_features ? ? ? = tg3_fix_features,
> >> + ? ? .ndo_set_features ? ? ? = tg3_set_features,
> >> ?#ifdef CONFIG_NET_POLL_CONTROLLER
> >> ? ? ? .ndo_poll_controller ? ?= tg3_poll_controller,
> >> ?#endif
> >> @@ -15044,6 +15072,7 @@ static const struct net_device_ops tg3_netdev_ops_dma_bug = {
> >> ? ? ? .ndo_do_ioctl ? ? ? ? ? = tg3_ioctl,
> >> ? ? ? .ndo_tx_timeout ? ? ? ? = tg3_tx_timeout,
> >> ? ? ? .ndo_change_mtu ? ? ? ? = tg3_change_mtu,
> >> + ? ? .ndo_set_features ? ? ? = tg3_set_features,
> >> ?#ifdef CONFIG_NET_POLL_CONTROLLER
> >> ? ? ? .ndo_poll_controller ? ?= tg3_poll_controller,
> >> ?#endif
> >> @@ -15241,6 +15270,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
> >> ? ? ? dev->features |= hw_features;
> >> ? ? ? dev->vlan_features |= hw_features;
> >>
> >> + ? ? /* Add the loopback capability */
> >> + ? ? dev->hw_features |= NETIF_F_LOOPBACK;
> >
> > Not all tg3 devices can do MAC loopback. ?I'd suggest qualifying this
> > with:
> >
> > ? ? ? ? ? ? ? ?if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780 ||
> > ? ? ? ? ? ? ? ? ? ?(tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))
> >
> > But that will exclude a lot of our newer devices. ?Does it matter what
> > type of loopback is used? ?Newer devices prefer internal phy loopback
> > over MAC loopback.
> >
> As long as device supports some sort of loopback, we should be setting
> this capability and move this logic (or similar) to set_features() and
> choose the method that is supported. Since several devices support
> loopback at various levels, to keep it consistent, we should be
> setting the loopback closest to the host. So can I simply set the
> int-phy loopback in the else part of the above 'provided if' or would
> need other logic? or in other words -
> 
>  if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780 ||
> (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))
>     supported_mode = MAC;
> else
>     supported_mode = INTPHY;
> 
> if (supported_mode == MAC)
>     cur_mode = tr32(MAC_MODE);
> else
>     tg3_readphy(tp, MII_BMCR, &cur_mode);
> 
> Would something like this work?

That might be where we want to end up, but it'll be some work to get
there.  Maybe it makes sense to just keep MAC loopback mode for now and
only enable it for a subset of devices.  Adding phy loopback mode sounds
like it will require some surgery.

