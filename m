From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next 1/2] net: provide a default dev->ethtool_ops
Date: Fri, 14 Sep 2012 10:10:53 -0700
Message-ID: <CANP3RGevLSvETJse_XFB6qa6QZoyuaaP7CcfGiw9QPUNnhw_hA@mail.gmail.com>
References: <1347607441.8555.265.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:52660 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab2INRKy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 13:10:54 -0400
Received: by ieje11 with SMTP id e11so7205868iej.19
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 10:10:53 -0700 (PDT)
In-Reply-To: <1347607441.8555.265.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any cleanups like this are always nice to see.

On Fri, Sep 14, 2012 at 12:24 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Instead of forcing device drivers to provide empty ethtool_ops or twe=
ak
> net/core/ethtool.c again, we could provide a generic ethtool_ops.
>
> This occurred to me when I wanted to add GSO support to GRE tunnels.
> ethtool -k support should be generic for all drivers.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> ---
>  net/core/dev.c     |    5 +++
>  net/core/ethtool.c |   54 +++++++++++++++++-------------------------=
-
>  2 files changed, 27 insertions(+), 32 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b1e6d63..ff8dcfc 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6045,6 +6045,11 @@ struct net_device *alloc_netdev_mqs(int sizeof=
_priv, const char *name,
>
>         strcpy(dev->name, name);
>         dev->group =3D INIT_NETDEV_GROUP;
> +       if (!dev->ethtool_ops) {
> +               static const struct ethtool_ops default_ethtool_ops;
> +
> +               dev->ethtool_ops =3D &default_ethtool_ops;
> +       }
>         return dev;
>
>  free_all:
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index cbf033d..aef0162 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -175,7 +175,7 @@ static int __ethtool_get_sset_count(struct net_de=
vice *dev, int sset)
>         if (sset =3D=3D ETH_SS_FEATURES)
>                 return ARRAY_SIZE(netdev_features_strings);
>
> -       if (ops && ops->get_sset_count && ops->get_strings)
> +       if (ops->get_sset_count && ops->get_strings)
>                 return ops->get_sset_count(dev, sset);
>         else
>                 return -EOPNOTSUPP;
> @@ -311,7 +311,7 @@ int __ethtool_get_settings(struct net_device *dev=
, struct ethtool_cmd *cmd)
>  {
>         ASSERT_RTNL();
>
> -       if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
> +       if (!dev->ethtool_ops->get_settings)
>                 return -EOPNOTSUPP;
>
>         memset(cmd, 0, sizeof(struct ethtool_cmd));
> @@ -355,7 +355,7 @@ static noinline_for_stack int ethtool_get_drvinfo=
(struct net_device *dev,
>
>         memset(&info, 0, sizeof(info));
>         info.cmd =3D ETHTOOL_GDRVINFO;
> -       if (ops && ops->get_drvinfo) {
> +       if (ops->get_drvinfo) {
>                 ops->get_drvinfo(dev, &info);
>         } else if (dev->dev.parent && dev->dev.parent->driver) {
>                 strlcpy(info.bus_info, dev_name(dev->dev.parent),
> @@ -370,7 +370,7 @@ static noinline_for_stack int ethtool_get_drvinfo=
(struct net_device *dev,
>          * this method of obtaining string set info is deprecated;
>          * Use ETHTOOL_GSSET_INFO instead.
>          */
> -       if (ops && ops->get_sset_count) {
> +       if (ops->get_sset_count) {
>                 int rc;
>
>                 rc =3D ops->get_sset_count(dev, ETH_SS_TEST);
> @@ -383,9 +383,9 @@ static noinline_for_stack int ethtool_get_drvinfo=
(struct net_device *dev,
>                 if (rc >=3D 0)
>                         info.n_priv_flags =3D rc;
>         }
> -       if (ops && ops->get_regs_len)
> +       if (ops->get_regs_len)
>                 info.regdump_len =3D ops->get_regs_len(dev);
> -       if (ops && ops->get_eeprom_len)
> +       if (ops->get_eeprom_len)
>                 info.eedump_len =3D ops->get_eeprom_len(dev);
>
>         if (copy_to_user(useraddr, &info, sizeof(info)))
> @@ -1275,7 +1275,7 @@ static int ethtool_get_dump_flag(struct net_dev=
ice *dev,
>         struct ethtool_dump dump;
>         const struct ethtool_ops *ops =3D dev->ethtool_ops;
>
> -       if (!dev->ethtool_ops->get_dump_flag)
> +       if (!ops->get_dump_flag)
>                 return -EOPNOTSUPP;
>
>         if (copy_from_user(&dump, useraddr, sizeof(dump)))
> @@ -1299,8 +1299,7 @@ static int ethtool_get_dump_data(struct net_dev=
ice *dev,
>         const struct ethtool_ops *ops =3D dev->ethtool_ops;
>         void *data =3D NULL;
>
> -       if (!dev->ethtool_ops->get_dump_data ||
> -               !dev->ethtool_ops->get_dump_flag)
> +       if (!ops->get_dump_data || !ops->get_dump_flag)
>                 return -EOPNOTSUPP;
>
>         if (copy_from_user(&dump, useraddr, sizeof(dump)))
> @@ -1349,7 +1348,7 @@ static int ethtool_get_ts_info(struct net_devic=
e *dev, void __user *useraddr)
>
>                 err =3D phydev->drv->ts_info(phydev, &info);
>
> -       } else if (dev->ethtool_ops && dev->ethtool_ops->get_ts_info)=
 {
> +       } else if (ops->get_ts_info) {
>
>                 err =3D ops->get_ts_info(dev, &info);
>
> @@ -1410,8 +1409,9 @@ static int ethtool_get_module_eeprom(struct net=
_device *dev,
>                                       modinfo.eeprom_len);
>  }
>
> -/* The main entry point in this file.  Called from net/core/dev.c */
> -
> +/* The main entry point in this file.  Called from net/core/dev.c
> + * with RTNL held.
> + */
>  int dev_ethtool(struct net *net, struct ifreq *ifr)
>  {
>         struct net_device *dev =3D __dev_get_by_name(net, ifr->ifr_na=
me);
> @@ -1419,25 +1419,15 @@ int dev_ethtool(struct net *net, struct ifreq=
 *ifr)
>         u32 ethcmd;
>         int rc;
>         u32 old_features;
> +       const struct ethtool_ops *ops;
>
>         if (!dev || !netif_device_present(dev))
>                 return -ENODEV;
>
> +       ops =3D dev->ethtool_ops;
>         if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
>                 return -EFAULT;
>
> -       if (!dev->ethtool_ops) {
> -               /* A few commands do not require any driver support,
> -                * are unprivileged, and do not change anything, so w=
e
> -                * can take a shortcut to them. */
> -               if (ethcmd =3D=3D ETHTOOL_GDRVINFO)
> -                       return ethtool_get_drvinfo(dev, useraddr);
> -               else if (ethcmd =3D=3D ETHTOOL_GET_TS_INFO)
> -                       return ethtool_get_ts_info(dev, useraddr);
> -               else
> -                       return -EOPNOTSUPP;
> -       }
> -
>         /* Allow some commands to be done by anyone */
>         switch (ethcmd) {
>         case ETHTOOL_GSET:
> @@ -1476,8 +1466,8 @@ int dev_ethtool(struct net *net, struct ifreq *=
ifr)
>                         return -EPERM;
>         }
>
> -       if (dev->ethtool_ops->begin) {
> -               rc =3D dev->ethtool_ops->begin(dev);
> +       if (ops->begin) {
> +               rc =3D ops->begin(dev);
>                 if (rc  < 0)
>                         return rc;
>         }
> @@ -1504,11 +1494,11 @@ int dev_ethtool(struct net *net, struct ifreq=
 *ifr)
>                 break;
>         case ETHTOOL_GMSGLVL:
>                 rc =3D ethtool_get_value(dev, useraddr, ethcmd,
> -                                      dev->ethtool_ops->get_msglevel=
);
> +                                      ops->get_msglevel);
>                 break;
>         case ETHTOOL_SMSGLVL:
>                 rc =3D ethtool_set_value_void(dev, useraddr,
> -                                      dev->ethtool_ops->set_msglevel=
);
> +                                           ops->set_msglevel);
>                 break;
>         case ETHTOOL_GEEE:
>                 rc =3D ethtool_get_eee(dev, useraddr);
> @@ -1570,11 +1560,11 @@ int dev_ethtool(struct net *net, struct ifreq=
 *ifr)
>                 break;
>         case ETHTOOL_GPFLAGS:
>                 rc =3D ethtool_get_value(dev, useraddr, ethcmd,
> -                                      dev->ethtool_ops->get_priv_fla=
gs);
> +                                      ops->get_priv_flags);
>                 break;
>         case ETHTOOL_SPFLAGS:
>                 rc =3D ethtool_set_value(dev, useraddr,
> -                                      dev->ethtool_ops->set_priv_fla=
gs);
> +                                      ops->set_priv_flags);
>                 break;
>         case ETHTOOL_GRXFH:
>         case ETHTOOL_GRXRINGS:
> @@ -1655,8 +1645,8 @@ int dev_ethtool(struct net *net, struct ifreq *=
ifr)
>                 rc =3D -EOPNOTSUPP;
>         }
>
> -       if (dev->ethtool_ops->complete)
> -               dev->ethtool_ops->complete(dev);
> +       if (ops->complete)
> +               ops->complete(dev);
>
>         if (old_features !=3D dev->features)
>                 netdev_features_change(dev);
>
>
