From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: TUN/TAP: tap driver reports bogus interface speed in ethtool
 operations
Date: Tue, 23 Jul 2013 20:04:38 +0100
Message-ID: <1374606278.2072.11.camel@bwh-desktop.uk.level5networks.com>
References: <2F174B03-5074-4BA0-B91A-8F2F62C2B082@cygnusnetworks.de>
	 <5192BDD6.6060703@qti.qualcomm.com>
	 <3E916AF0-C587-443D-B653-C968A96C8751@cygnusnetworks.de>
	 <48A2F278-A32C-47C6-AD2D-1FC15EC73B88@cygnusnetworks.de>
	 <51E5BE27.3060207@qti.qualcomm.com>
	 <E4A37B97-95FE-42C3-AD78-119BA406A44A@cygnusnetworks.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"Max Krasnyansky" <maxk@qti.qualcomm.com>
To: Helmut Grohne <h.grohne@cygnusnetworks.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51448 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933918Ab3GWTEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 15:04:42 -0400
In-Reply-To: <E4A37B97-95FE-42C3-AD78-119BA406A44A@cygnusnetworks.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 15:32 +0200, Helmut Grohne wrote:
> On 16.07.2013, at 23:41, Max Krasnyansky <maxk@qti.qualcomm.com> wrote:
> > The patch looks fine to me (must admit that I only glanced at it). Please send it to the netdev
> > mailing list netdev@vger.kernel.org, if you have't already done so.
> > CC David Miller <davem@davemloft.net> and me.
> 
> Doing that. Now summarizing the issue for the new recipients:
> 
> Problem:
> 
> When querying a tap device for its speed using ethtool the tun driver reports a speed
> of SPEED_10. This number is hard coded into the driver. Nowadays virtual network devices
> can go way faster than that. When doing automatic bandwidth monitoring based on the
> speed reported by ethtool, tap devices tend to come up as false positives. Arguably the
> hard coded speed is wrong.
> 
> Proposed solution:
> 
> To that end I propose supporting the ETHTOOL_SSET command in addition to the already
> supported ETHTOOL_GSET. It would deny setting any setting except for the bandwidth
> where it would allow arbitrary values. You can find this patch attached.

Yes, I think this makes some sense.

[...]
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
[...]
> @@ -2197,9 +2199,11 @@ static struct miscdevice tun_miscdev = {
>  
>  static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  {
> +       struct tun_struct *tun = netdev_priv(dev);
> +
>         cmd->supported          = 0;
>         cmd->advertising        = 0;
> -       ethtool_cmd_speed_set(cmd, SPEED_10);
> +       ethtool_cmd_speed_set(cmd, tun->advertised_speed);
>         cmd->duplex             = DUPLEX_FULL;
>         cmd->port               = PORT_TP;
>
>         cmd->phy_address        = 0;
> @@ -2210,6 +2214,24 @@ static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>         return 0;
>  }
>  
> +static int tun_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> +{
> +       struct tun_struct *tun = netdev_priv(dev);
> +
> +       if(cmd->supported != 0 ||
> +                       cmd->advertising != 0 ||
> +                       cmd->duplex != DUPLEX_FULL ||
> +                       cmd->port != PORT_TP ||
> +                       cmd->phy_address != 0 ||
> +                       cmd->transceiver != XCVR_INTERNAL ||
> +                       cmd->autoneg != AUTONEG_DISABLE ||
> +                       cmd->maxtxpkt != 0 ||
> +                       cmd->maxrxpkt != 0)

This is formatted wrongly - needs a space after 'if' and all the
continuation lines should be lined up under 'cmd->supported'.

> +               return -EOPNOTSUPP;

EINVAL

> +       tun->advertised_speed = ethtool_cmd_speed(cmd);
> +       return 0;
> +}
> +
>  static void tun_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
>  {
>         struct tun_struct *tun = netdev_priv(dev);
[...]

I notice the port type is reported as PORT_TP.  Perhaps that should also
be changed to PORT_NONE (in a separate patch)?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
