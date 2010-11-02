From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 3/4] Ethtool: convert get_tso/set_tso calls to
 hw_features flags
Date: Mon, 1 Nov 2010 19:49:57 -0700
Message-ID: <20101102024957.GB4243@mcarlson.broadcom.com>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
 <db0a20ab6e4ab3f63d782bd2c4a9f7a873ea4a64.1288496404.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Steve Glendinning" <steve.glendinning@smsc.com>,
	"Greg Kroah-Hartman" <gregkh@suse.de>,
	"Rasesh Mody" <rmody@brocade.com>,
	"Debashis Dutt" <ddutt@brocade.com>,
	"Kristoffer Glembo" <kristoffer@gaisler.com>,
	"linux-driver@qlogic.com" <linux-driver@qlogic.com>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>
To: "Micha?? Miros??aw" <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4534 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754083Ab0KBCuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 22:50:05 -0400
In-Reply-To: <db0a20ab6e4ab3f63d782bd2c4a9f7a873ea4a64.1288496404.git.mirq-linux@rere.qmqm.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 30, 2010 at 01:44:17AM -0700, Micha?? Miros??aw wrote:
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index b07e2d1..c08172d 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -6142,7 +6142,7 @@ static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
>         if (new_mtu > ETH_DATA_LEN) {
>                 if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
>                         tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
> -                       ethtool_op_set_tso(dev, 0);
> +                       dev->features &= ~NETIF_F_ALL_TSO;
>                 } else {
>                         tp->tg3_flags |= TG3_FLAG_JUMBO_RING_ENABLE;
>                 }
> @@ -9977,27 +9977,28 @@ static int tg3_set_tso(struct net_device *dev, u32 value)
>  {
>         struct tg3 *tp = netdev_priv(dev);
> 
> -       if (!(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)) {
> -               if (value)
> -                       return -EINVAL;
> +       if (!(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) && value)
> +               return -EINVAL;
> +
> +       if (!value)
>                 return 0;
> -       }
> +
> +       dev->features |= NETIF_F_TSO;
> +
>         if ((dev->features & NETIF_F_IPV6_CSUM) &&
>             ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) ||
>              (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3))) {
> -               if (value) {
> -                       dev->features |= NETIF_F_TSO6;
> -                       if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
> -                           GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
> -                           (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
> -                            GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
> -                           GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
> -                           GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
> -                               dev->features |= NETIF_F_TSO_ECN;
> -               } else
> -                       dev->features &= ~(NETIF_F_TSO6 | NETIF_F_TSO_ECN);
> +               dev->features |= NETIF_F_TSO6;
> +               if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
> +                   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
> +                   (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
> +                    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
> +                   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
> +                   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
> +                       dev->features |= NETIF_F_TSO_ECN;
>         }
> -       return ethtool_op_set_tso(dev, value);
> +
> +       return 1;

dev->hw_features looks to me like it should function as a set of flags
indicating what the hardware is currently capable of doing.  It would
clean the above code a lot if we could do:

	dev->features |= (dev->hw_features & NETIF_F_ALL_TSO);

In fact, the new member might serve as a replacement for the
TG3_FLG2_TSO_CAPABLE flag.  Let's not do that right now though,
because it requires some careful attention in other code paths which would
be a distraction.  I'll follow-up with a patch to do this.

>  }
> 
>  static int tg3_nway_reset(struct net_device *dev)
> @@ -11306,7 +11307,7 @@ static const struct ethtool_ops tg3_ethtool_ops = {
>         .get_rx_csum            = tg3_get_rx_csum,
>         .set_rx_csum            = tg3_set_rx_csum,
>         .set_tx_csum            = tg3_set_tx_csum,
> -       .set_tso                = tg3_set_tso,
> +       .hw_set_tso             = tg3_set_tso,
>         .self_test              = tg3_self_test,
>         .get_strings            = tg3_get_strings,
>         .phys_id                = tg3_phys_id,
> @@ -14681,6 +14682,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>         tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
> 
>         dev->hw_features |= NETIF_F_SG;
> +       dev->hw_features |= NETIF_F_TSO|NETIF_F_TSO6|NETIF_F_TSO_ECN;

Not all devices are TSO capable either.  There is code later in this
function that determines which TSO flags to set.  I would probably reuse
that code.

>         dev->ethtool_ops = &tg3_ethtool_ops;
>         dev->watchdog_timeo = TG3_TX_TIMEOUT;
>         dev->irq = pdev->irq;

