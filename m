From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next] switchdev: Enable HW offloading of fdb
 add/delete on team devices.
Date: Tue, 31 Mar 2015 09:16:05 -0700
Message-ID: <CAE4R7bCG24SrzLFezCuB7OVbds9qaSegT-w-Dud3+V4Yz=SoRg@mail.gmail.com>
References: <1427748998-14346-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	sfeldman@gmail.com, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:33600 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084AbbCaQQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 12:16:06 -0400
Received: by qgfa8 with SMTP id a8so18960413qgf.0
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 09:16:05 -0700 (PDT)
In-Reply-To: <1427748998-14346-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sridhar,

Thanks for working on this.  It looks good to me.  But, this is an
example of the ops code exposition I was trying to address in my swdev
attrs patch.  I'll planning on sending a v2 for that patch set
tonight, and I think you'll see adding your work for FDB add/del over
stacked drivers will just fall out with just a little bit of new code.
I hope you would resend this patch based on my v2?

BTW, swdev attrs is what I had in v1. What's coming in v2 in addition
to swdev attrs and swdev objs, to support things that are objects and
not attributes, like VLANs, FDB entries, FIB entries.  Hopefully it
makes sense when you see it.

-scott

On Mon, Mar 30, 2015 at 1:56 PM, Sridhar Samudrala
<sridhar.samudrala@intel.com> wrote:
> switchdev: Enable HW offloading of fdb add/delete on team devices.
>
> This patch enables HW offloading of fdb add/delete on a team device with
> switchdev member ports and not attached to a bridge.
>
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> ---
>  drivers/net/team/team.c   |   2 +
>  include/net/switchdev.h   |  47 +++++++++++++++++
>  net/switchdev/switchdev.c | 125 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 174 insertions(+)
>
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index 6928448..3de7ab3 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -1979,6 +1979,8 @@ static const struct net_device_ops team_netdev_ops = {
>         .ndo_change_carrier     = team_change_carrier,
>         .ndo_bridge_setlink     = ndo_dflt_netdev_switch_port_bridge_setlink,
>         .ndo_bridge_dellink     = ndo_dflt_netdev_switch_port_bridge_dellink,
> +       .ndo_fdb_add            = ndo_dflt_netdev_switch_port_fdb_add,
> +       .ndo_fdb_del            = ndo_dflt_netdev_switch_port_fdb_del,
>         .ndo_features_check     = passthru_features_check,
>  };
>
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index d2e69ee..7902909 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -81,6 +81,19 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
>                                                struct nlmsghdr *nlh, u16 flags);
>  int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
>                                                struct nlmsghdr *nlh, u16 flags);
> +int netdev_switch_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> +                              struct net_device *dev,
> +                              const unsigned char *addr, u16 vid, u16 flags);
> +int netdev_switch_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
> +                              struct net_device *dev,
> +                              const unsigned char *addr, u16 vid);
> +int ndo_dflt_netdev_switch_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> +                                       struct net_device *dev,
> +                                       const unsigned char *addr, u16 vid,
> +                                       u16 flags);
> +int ndo_dflt_netdev_switch_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
> +                                       struct net_device *dev,
> +                                       const unsigned char *addr, u16 vid);
>  int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
>                                u8 tos, u8 type, u32 nlflags, u32 tb_id);
>  int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
> @@ -145,6 +158,40 @@ static inline int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *
>         return 0;
>  }
>
> +static inline int netdev_switch_port_fdb_add(struct ndmsg *ndm,
> +                                       struct nlattr *tb[],
> +                                       struct net_device *dev,
> +                                       const unsigned char *addr, u16 vid,
> +                                       u16 flags)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
> +static inline int netdev_switch_port_fdb_del(struct ndmsg *ndm,
> +                                       struct nlattr *tb[],
> +                                       struct net_device *dev,
> +                                       const unsigned char *addr, u16 vid)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
> +static inline int ndo_dflt_netdev_switch_port_fdb_add(struct ndmsg *ndm,
> +                                       struct nlattr *tb[],
> +                                       struct net_device *dev,
> +                                       const unsigned char *addr, u16 vid,
> +                                       u16 flags)
> +{
> +       return 0;
> +}
> +
> +static inline int ndo_dflt_netdev_switch_port_fdb_del(struct ndmsg *ndm,
> +                                       struct nlattr *tb[],
> +                                       struct net_device *dev,
> +                                       const unsigned char *addr, u16 vid)
> +{
> +       return 0;
> +}
> +
>  static inline int netdev_switch_fib_ipv4_add(u32 dst, int dst_len,
>                                              struct fib_info *fi,
>                                              u8 tos, u8 type,
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 46568b8..f3e4e16 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -237,6 +237,131 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
>  }
>  EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_bridge_dellink);
>
> +/**
> + *     netdev_switch_port_fdb_add -  Add fdb entry to switch device port
> + *
> + *     @ndm: struct ndmsg
> + *     @tb: pointer to array of nlattr
> + *     @dev: switch device port netdev
> + *     @addr: MAC address entry to be added
> + *     @vid: VLAN id
> + *     @flags: flags for fdb addition
> + *
> + *     Add fdb entry to switch device port.
> + */
> +int netdev_switch_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> +                              struct net_device *dev,
> +                              const unsigned char *addr, u16 vid, u16 flags)
> +{
> +       const struct net_device_ops *ops = dev->netdev_ops;
> +
> +       if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
> +               return 0;
> +
> +       if (!ops->ndo_fdb_add)
> +               return -EOPNOTSUPP;
> +
> +       return ops->ndo_fdb_add(ndm, tb, dev, addr, vid, flags);
> +
> +}
> +EXPORT_SYMBOL_GPL(netdev_switch_port_fdb_add);
> +
> +/**
> + *     netdev_switch_port_fdb_del -  Delete fdb entry from switch device port
> + *
> + *     @ndm: struct ndmsg
> + *     @tb: pointer to array of nlattr
> + *     @dev: switch device port netdev
> + *     @addr: MAC address entry to be added
> + *     @vid: VLAN id
> + *
> + *     Delete fdb entry from switch device port.
> + */
> +int netdev_switch_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
> +                              struct net_device *dev,
> +                              const unsigned char *addr, u16 vid)
> +{
> +       const struct net_device_ops *ops = dev->netdev_ops;
> +
> +       if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
> +               return 0;
> +
> +       if (!ops->ndo_fdb_del)
> +               return -EOPNOTSUPP;
> +
> +       return ops->ndo_fdb_del(ndm, tb, dev, addr, vid);
> +}
> +EXPORT_SYMBOL_GPL(netdev_switch_port_fdb_del);
> +
> +/**
> + *     ndo_dflt_netdev_switch_port_fdb_add - Propagate add fdb entry to all
> + *     the slave devices.
> + *
> + *     @ndm: struct ndmsg
> + *     @tb: pointer to array of nlattr
> + *     @dev: switch device port netdev
> + *     @addr: MAC address entry to be added
> + *     @vid: VLAN id
> + *     @flags: flags for fdb addition
> + *
> + *     Propagate add fdb entry to all the slave devices.
> + */
> +int ndo_dflt_netdev_switch_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> +                                       struct net_device *dev,
> +                                       const unsigned char *addr, u16 vid,
> +                                       u16 flags)
> +{
> +       struct net_device *lower_dev;
> +       struct list_head *iter;
> +       int ret = 0, err = 0;
> +
> +       if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
> +               return ret;
> +
> +       netdev_for_each_lower_dev(dev, lower_dev, iter) {
> +               err = netdev_switch_port_fdb_add(ndm, tb, lower_dev, addr,vid,
> +                                                flags);
> +               if (err && err != -EOPNOTSUPP)
> +                       ret = err;
> +       }
> +
> +       return ret;
> +}
> +EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_fdb_add);
> +
> +/**
> + *     ndo_dflt_netdev_switch_port_fdb_del - Propagate delete fdb entry to all
> + *     the slave devices.
> + *
> + *     @ndm: struct ndmsg
> + *     @tb: pointer to array of nlattr
> + *     @dev: switch device port netdev
> + *     @addr: MAC address entry to be added
> + *     @vid: VLAN id
> + *
> + *     Propagate delete fdb entry to all the slave devices.
> + */
> +int ndo_dflt_netdev_switch_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
> +                                       struct net_device *dev,
> +                                       const unsigned char *addr, u16 vid)
> +{
> +       struct net_device *lower_dev;
> +       struct list_head *iter;
> +       int ret = 0, err = 0;
> +
> +       if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
> +               return ret;
> +
> +       netdev_for_each_lower_dev(dev, lower_dev, iter) {
> +               err = netdev_switch_port_fdb_del(ndm, tb, lower_dev, addr,vid);
> +               if (err && err != -EOPNOTSUPP)
> +                       ret = err;
> +       }
> +
> +       return ret;
> +}
> +EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_fdb_del);
> +
>  static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
>  {
>         const struct swdev_ops *ops = dev->swdev_ops;
> --
> 1.8.4.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
