From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [RFC PATCH] 8139cp: properly support change of MTU values
Date: Wed, 28 Nov 2012 09:23:46 +0200
Message-ID: <CAKoUArk7R3_JBn7Qdn8Ry+qy7NnidroqSArTpFwdP4WkryJypA@mail.gmail.com>
References: <1354046932-13606-1-git-send-email-jogreene@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: John Greene <jogreene@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:49551 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975Ab2K1HXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 02:23:46 -0500
Received: by mail-qc0-f174.google.com with SMTP id o22so9445156qcr.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 23:23:46 -0800 (PST)
In-Reply-To: <1354046932-13606-1-git-send-email-jogreene@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In cp_change_mtu(), there is the following check:
...
if (new_mtu < CP_MIN_MTU || new_mtu > CP_MAX_MTU)
		return -EINVAL;
...
Later on, we set dev->mtu to new_mtu.

The CP_MIN_MTU is defined to be 60; shouldn't it be 68 ?


The reason for 68 is (RFC 791,  Internet Protocol,
http://www.ietf.org/rfc/rfc791.txt):
"Every internet module must be able to forward a datagram of 68 octets
without further fragmentation.  This is because an internet  header
may be up to 60 octets, and the minimum fragment is 8 octets."

See also the generic Ethernet () method in eth_change_mtu() (net/ethernet/eth.c)

int eth_change_mtu(struct net_device *dev, int new_mtu)
{
	if (new_mtu < 68 || new_mtu > ETH_DATA_LEN)
		return -EINVAL;
	dev->mtu = new_mtu;
	return 0;
}


regards,
Rami Rosen

http://ramirose.wix.com/ramirosen

On Tue, Nov 27, 2012 at 10:08 PM, John Greene <jogreene@redhat.com> wrote:
> The 8139cp driver has a change_mtu function that has not been
> enabled since the dawn of the git repository. However, the
> generic eth_change_mtu is not used in its place, so that
> invalid MTU values can be set on the interface.
>
> Original patch salvages the broken code for the single case of
> setting the MTU while the interface is down, which is safe
> and also includes the range check.  Now enhanced to support up
> or down interface.
>
> Original patch from
> http://lkml.indiana.edu/hypermail/linux/kernel/1202.2/00770.html
>
> Testing: has been test on virtual 8139cp setup without issue,
> awaiting real hardware and retest again, but wanted to post now.
>
> Signed-Off-By: "John Greene" <jogreene@redhat.com>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>  drivers/net/ethernet/realtek/8139cp.c | 22 +++-------------------
>  1 file changed, 3 insertions(+), 19 deletions(-)
>
> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> index 6cb96b4..7847c83 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
> @@ -1226,12 +1226,9 @@ static void cp_tx_timeout(struct net_device *dev)
>         spin_unlock_irqrestore(&cp->lock, flags);
>  }
>
> -#ifdef BROKEN
>  static int cp_change_mtu(struct net_device *dev, int new_mtu)
>  {
>         struct cp_private *cp = netdev_priv(dev);
> -       int rc;
> -       unsigned long flags;
>
>         /* check for invalid MTU, according to hardware limits */
>         if (new_mtu < CP_MIN_MTU || new_mtu > CP_MAX_MTU)
> @@ -1244,22 +1241,11 @@ static int cp_change_mtu(struct net_device *dev, int new_mtu)
>                 return 0;
>         }
>
> -       spin_lock_irqsave(&cp->lock, flags);
> -
> -       cp_stop_hw(cp);                 /* stop h/w and free rings */
> -       cp_clean_rings(cp);
> -
> +       /* network IS up, close it, reset MTU, and come up again. */
> +       cp_close(dev);
>         dev->mtu = new_mtu;
> -       cp_set_rxbufsize(cp);           /* set new rx buf size */
> -
> -       rc = cp_init_rings(cp);         /* realloc and restart h/w */
> -       cp_start_hw(cp);
> -
> -       spin_unlock_irqrestore(&cp->lock, flags);
> -
> -       return rc;
> +       return cp_open(dev);
>  }
> -#endif /* BROKEN */
>
>  static const char mii_2_8139_map[8] = {
>         BasicModeCtrl,
> @@ -1835,9 +1821,7 @@ static const struct net_device_ops cp_netdev_ops = {
>         .ndo_start_xmit         = cp_start_xmit,
>         .ndo_tx_timeout         = cp_tx_timeout,
>         .ndo_set_features       = cp_set_features,
> -#ifdef BROKEN
>         .ndo_change_mtu         = cp_change_mtu,
> -#endif
>
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>         .ndo_poll_controller    = cp_poll_controller,
> --
> 1.7.11.7
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
