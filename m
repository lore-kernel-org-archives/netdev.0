From: Veaceslav Falico <darkmag@gmail.com>
Subject: Re: [PATCH net-next] bond: add support to read speed and duplex via ethtool
Date: Wed, 6 Mar 2013 20:13:06 +0100
Message-ID: <CAE3RKN=d2WmY9Sf-fOuWuTJk+O9_OxZeKPTfjMwWS3iQh2B7ig@mail.gmail.com>
References: <1362595173-11442-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:40967 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364Ab3CFTN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 14:13:27 -0500
Received: by mail-we0-f169.google.com with SMTP id t11so8737993wey.0
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 11:13:26 -0800 (PST)
In-Reply-To: <1362595173-11442-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 6, 2013 at 7:39 PM, Andy Gospodarek <andy@greyhouse.net> wrote:
> This patch adds support for the get_settings ethtool op to the bonding
> driver.  This was motivated by users who wanted to get the speed of the
> bond and compare that against throughput to understand utilization.
> The behavior before this patch was added was problematic when computing
> line utilization after trying to get link-speed and throughput via SNMP.
>
> The general plan for computing link-speed was as follows:
>
> Mode                 Formula
> ----                 -------
> active-backup        speed of current active slave
> broadcast            speed of first slave with known speed
> all other modes      aggregate speed of all slaves with known speed
>
> Output from ethtool looks like this for a round-robin bond:
>
> Settings for bond0:
>         Supported ports: [ ]
>         Supported link modes:   Not reported
>         Supported pause frame use: No
>         Supports auto-negotiation: No
>         Advertised link modes:  Not reported
>         Advertised pause frame use: No
>         Advertised auto-negotiation: No
>         Speed: 11000Mb/s
>         Duplex: Full
>         Port: Twisted Pair
>         PHYAD: 0
>         Transceiver: internal
>         Auto-negotiation: off
>         MDI-X: Unknown
>         Link detected: yes
>
> I tested this and verified it works as expected.  A test was also done
> on a version backported to an older kernel and it worked well there.
>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>  drivers/net/bonding/bond_main.c | 47 +++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 47 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 7bd068a..6e70ff0 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4224,6 +4224,52 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
>         }
>  }
>
> +static int bond_ethtool_get_settings(struct net_device *bond_dev,
> +                                    struct ethtool_cmd *ecmd)
> +{
> +       struct bonding *bond = netdev_priv(bond_dev);
> +       struct slave *slave;
> +       int i;
> +       unsigned long speed = 0;
> +
> +       ecmd->speed = SPEED_UNKNOWN;
> +       ecmd->duplex = DUPLEX_UNKNOWN;
> +
> +       read_lock(&bond->lock);
> +       switch (bond->params.mode) {
> +       case BOND_MODE_ACTIVEBACKUP:
> +               read_lock(&bond->curr_slave_lock);
> +               if (bond->curr_active_slave &&
> +                   bond->curr_active_slave->speed != SPEED_UNKNOWN) {
> +                       ecmd->speed = bond->curr_active_slave->speed;
> +                       ecmd->duplex = bond->curr_active_slave->duplex;
> +               }
> +               read_unlock(&bond->curr_slave_lock);
> +               break;
> +       case BOND_MODE_BROADCAST:
> +               bond_for_each_slave(bond, slave, i) {
> +                       if (slave->speed != SPEED_UNKNOWN) {
> +                               ecmd->speed = slave->speed;
> +                               ecmd->duplex = slave->duplex;

Maybe it should be 'the smallest speed (and then duplex)' here? In
broadcast we send all packets
through all the slaves, so the effective speed/duplex would be the
speed/duplex of the slowest slave.

> +                               break;
> +                       }
> +               }
> +               break;
> +       default:
> +               bond_for_each_slave(bond, slave, i) {
> +                       if (slave->speed != SPEED_UNKNOWN) {
> +                               speed += slave->speed;
> +                       }
> +                       if (ecmd->duplex == DUPLEX_UNKNOWN &&
> +                           slave->duplex != DUPLEX_UNKNOWN)
> +                               ecmd->duplex = slave->duplex;
> +               }
> +               ecmd->speed = speed;
> +       }
> +       read_unlock(&bond->lock);
> +       return 0;
> +}
> +
>  static void bond_ethtool_get_drvinfo(struct net_device *bond_dev,
>                                      struct ethtool_drvinfo *drvinfo)
>  {
> @@ -4235,6 +4281,7 @@ static void bond_ethtool_get_drvinfo(struct net_device *bond_dev,
>
>  static const struct ethtool_ops bond_ethtool_ops = {
>         .get_drvinfo            = bond_ethtool_get_drvinfo,
> +       .get_settings           = bond_ethtool_get_settings,
>         .get_link               = ethtool_op_get_link,
>  };
>
> --
> 1.7.11.7
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Best regards,
Veaceslav Falico
