From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 2/3] if_link: Add VF multicast promiscuous control
Date: Fri, 20 Feb 2015 09:48:40 +0200
Message-ID: <CAJ3xEMhA7ytWykeB3i3oTyJR7VpVmBKrNe6AMstH4dvo5Dozvg@mail.gmail.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38840@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	=?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:43174 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618AbbBTHsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 02:48:41 -0500
Received: by mail-oi0-f42.google.com with SMTP id h136so1326677oig.1
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 23:48:40 -0800 (PST)
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38840@BPXM14GP.gisp.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015, Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com> wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Add netlink directives and ndo entry to allow VF multicast promiscuous mode.
> The administrator wants to allow dedicatedly multicast promiscuous per VF.

Jeff, Hiroshi, I find this change-log to be non sufficient, it doesn't
describe the semantics of a VF which is now put into multicast
promiscuous mode. In the native (non SRIOV mode) multicast promiscuous
means get all multicast packets are arrive to the port. Is this the
case too here? if yes, just spell it out, if not or not exactly,
describe it. Also say what are the security implications, e.g that
this VF needs to be trusted or alike.

> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  include/linux/if_link.h      |  1 +
>  include/linux/netdevice.h    |  3 +++
>  include/uapi/linux/if_link.h |  6 ++++++
>  net/core/rtnetlink.c         | 18 ++++++++++++++++--
>  4 files changed, 26 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 119130e..bc29ddf 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -14,5 +14,6 @@ struct ifla_vf_info {
>         __u32 linkstate;
>         __u32 min_tx_rate;
>         __u32 max_tx_rate;
> +       __u32 mc_promisc;
>  };
>  #endif /* _LINUX_IF_LINK_H */
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d115256..fd15d87 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -870,6 +870,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int min_tx_rate,
>   *                       int max_tx_rate);
>   * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
> + * int (*ndo_set_vf_mc_promisc)(struct net_device *dev, int vf, bool setting);
>   * int (*ndo_get_vf_config)(struct net_device *dev,
>   *                         int vf, struct ifla_vf_info *ivf);
>   * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int link_state);
> @@ -1086,6 +1087,8 @@ struct net_device_ops {
>                                                    int max_tx_rate);
>         int                     (*ndo_set_vf_spoofchk)(struct net_device *dev,
>                                                        int vf, bool setting);
> +       int                     (*ndo_set_vf_mc_promisc)(struct net_device *dev,
> +                                                        int vf, bool setting);
>         int                     (*ndo_get_vf_config)(struct net_device *dev,
>                                                      int vf,
>                                                      struct ifla_vf_info *ivf);
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 0deee3e..d7dc39c 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -458,6 +458,7 @@ enum {
>         IFLA_VF_SPOOFCHK,       /* Spoof Checking on/off switch */
>         IFLA_VF_LINK_STATE,     /* link state enable/disable/auto switch */
>         IFLA_VF_RATE,           /* Min and Max TX Bandwidth Allocation */
> +       IFLA_VF_MC_PROMISC,     /* Multicast Promiscuous allow/disallow */
>         __IFLA_VF_MAX,
>  };
>
> @@ -502,6 +503,11 @@ struct ifla_vf_link_state {
>         __u32 link_state;
>  };
>
> +struct ifla_vf_mc_promisc {
> +       __u32 vf;
> +       __u32 setting;
> +};
> +
>  /* VF ports management section
>   *
>   *     Nested layout of set/get msg is:
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 5be499b..b668e96 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -818,7 +818,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
>                          nla_total_size(sizeof(struct ifla_vf_vlan)) +
>                          nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
>                          nla_total_size(sizeof(struct ifla_vf_rate)) +
> -                        nla_total_size(sizeof(struct ifla_vf_link_state)));
> +                        nla_total_size(sizeof(struct ifla_vf_link_state)) +
> +                        nla_total_size(sizeof(struct ifla_vf_mc_promisc)));
>                 return size;
>         } else
>                 return 0;
> @@ -1111,6 +1112,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>                         struct ifla_vf_tx_rate vf_tx_rate;
>                         struct ifla_vf_spoofchk vf_spoofchk;
>                         struct ifla_vf_link_state vf_linkstate;
> +                       struct ifla_vf_mc_promisc vf_mc_promisc;
>
>                         /*
>                          * Not all SR-IOV capable drivers support the
> @@ -1119,6 +1121,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>                          * report anything.
>                          */
>                         ivi.spoofchk = -1;
> +                       ivi.mc_promisc = -1;
>                         memset(ivi.mac, 0, sizeof(ivi.mac));
>                         /* The default value for VF link state is "auto"
>                          * IFLA_VF_LINK_STATE_AUTO which equals zero
> @@ -1131,7 +1134,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>                                 vf_rate.vf =
>                                 vf_tx_rate.vf =
>                                 vf_spoofchk.vf =
> -                               vf_linkstate.vf = ivi.vf;
> +                               vf_linkstate.vf =
> +                               vf_mc_promisc.vf = ivi.vf;
>
>                         memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
>                         vf_vlan.vlan = ivi.vlan;
> @@ -1140,6 +1144,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>                         vf_rate.min_tx_rate = ivi.min_tx_rate;
>                         vf_rate.max_tx_rate = ivi.max_tx_rate;
>                         vf_spoofchk.setting = ivi.spoofchk;
> +                       vf_mc_promisc.setting = ivi.mc_promisc;
>                         vf_linkstate.link_state = ivi.linkstate;
>                         vf = nla_nest_start(skb, IFLA_VF_INFO);
>                         if (!vf) {
> @@ -1481,6 +1486,15 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
>                                                                  ivl->link_state);
>                         break;
>                 }
> +               case IFLA_VF_MC_PROMISC: {
> +                       struct ifla_vf_mc_promisc *ivm;
> +                       ivm = nla_data(vf);
> +                       err = -EOPNOTSUPP;
> +                       if (ops->ndo_set_vf_mc_promisc)
> +                               err = ops->ndo_set_vf_mc_promisc(dev, ivm->vf,
> +                                                                ivm->setting);
> +                       break;
> +               }
>                 default:
>                         err = -EINVAL;
>                         break;
> --
> 2.1.0
>
