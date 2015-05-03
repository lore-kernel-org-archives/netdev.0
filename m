From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 07/11] if_link: Add VF multicast promiscuous control
Date: Sun, 3 May 2015 17:16:13 +0300
Message-ID: <CAJ3xEMjtZOTkwXXk-EcSniYe99Rjz-BUTcyoZwKXpwh4DsPy+A@mail.gmail.com>
References: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1430563358-113833-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Sy Choi Jong <sy.jong.choi@intel.com>,
	Edward Cree <ecree@solarflare.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Rony Efraim <ronye@mellanox.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:34854 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbbECOQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 10:16:14 -0400
Received: by obcux3 with SMTP id ux3so91446209obc.2
        for <netdev@vger.kernel.org>; Sun, 03 May 2015 07:16:14 -0700 (PDT)
In-Reply-To: <1430563358-113833-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 2, 2015 at 1:42 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
> Add netlink directives and ndo entry to allow VF multicast promiscuous mode.
>
> This controls the permission to enter VF multicast promiscuous mode.
> The administrator will dedicatedly allow multicast promiscuous per VF.
>
> When the VF is under multicast promiscuous mode, all multicast packets are
> sent to the VF.
>
> Don't allow VF multicast promiscuous if the VM isn't fully trusted.

Guys,

I don't think the discussion we held in the past [1] on the matter
actually converged. Few open points that came up while
debating it internally with Rony:

1. maybe what we we actually want here an API that states a VF to be
privileged/trusted and then we can over load the feature set of being
such?

2. the suggested API only allows either unlimited number of mulicast
groups per VF or limited number, both numbers are vendor dependent,
right? maybe what we need for this specific matter is specifying how
many multicast groups are allowed for a VF?

[1] http://marc.info/?t=142439436800007&r=1&w=2


>
> CC: Sy Choi Jong <sy.jong.choi@intel.com>
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  include/linux/if_link.h      |  1 +
>  include/linux/netdevice.h    |  3 +++
>  include/uapi/linux/if_link.h |  6 ++++++
>  net/core/rtnetlink.c         | 19 +++++++++++++++++--
>  4 files changed, 27 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index da49299..df212f4 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -15,5 +15,6 @@ struct ifla_vf_info {
>         __u32 min_tx_rate;
>         __u32 max_tx_rate;
>         __u32 rss_query_en;
> +       __u32 mc_promisc;
>  };
>  #endif /* _LINUX_IF_LINK_H */
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index dbad4d7..66ffe63 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -874,6 +874,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int min_tx_rate,
>   *                       int max_tx_rate);
>   * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
> + * int (*ndo_set_vf_mc_promisc)(struct net_device *dev, int vf, bool setting);
>   * int (*ndo_get_vf_config)(struct net_device *dev,
>   *                         int vf, struct ifla_vf_info *ivf);
>   * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int link_state);
> @@ -1095,6 +1096,8 @@ struct net_device_ops {
>                                                    int max_tx_rate);
>         int                     (*ndo_set_vf_spoofchk)(struct net_device *dev,
>                                                        int vf, bool setting);
> +       int                     (*ndo_set_vf_mc_promisc)(struct net_device *dev,
> +                                                        int vf, bool setting);
>         int                     (*ndo_get_vf_config)(struct net_device *dev,
>                                                      int vf,
>                                                      struct ifla_vf_info *ivf);
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index d9cd192..44c3bbe 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -468,6 +468,7 @@ enum {
>         IFLA_VF_RSS_QUERY_EN,   /* RSS Redirection Table and Hash Key query
>                                  * on/off switch
>                                  */
> +       IFLA_VF_MC_PROMISC,     /* Multicast Promiscuous allow/disallow */
>         __IFLA_VF_MAX,
>  };
>
> @@ -517,6 +518,11 @@ struct ifla_vf_rss_query_en {
>         __u32 setting;
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
> index 358d52a..e8a5801 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -819,7 +819,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
>                          nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
>                          nla_total_size(sizeof(struct ifla_vf_rate)) +
>                          nla_total_size(sizeof(struct ifla_vf_link_state)) +
> -                        nla_total_size(sizeof(struct ifla_vf_rss_query_en)));
> +                        nla_total_size(sizeof(struct ifla_vf_rss_query_en)) +
> +                        nla_total_size(sizeof(struct ifla_vf_mc_promisc)));
>                 return size;
>         } else
>                 return 0;
> @@ -1134,6 +1135,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>                         struct ifla_vf_spoofchk vf_spoofchk;
>                         struct ifla_vf_link_state vf_linkstate;
>                         struct ifla_vf_rss_query_en vf_rss_query_en;
> +                       struct ifla_vf_mc_promisc vf_mc_promisc;
>
>                         /*
>                          * Not all SR-IOV capable drivers support the
> @@ -1143,6 +1145,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>                          */
>                         ivi.spoofchk = -1;
>                         ivi.rss_query_en = -1;
> +                       ivi.mc_promisc = -1;
>                         memset(ivi.mac, 0, sizeof(ivi.mac));
>                         /* The default value for VF link state is "auto"
>                          * IFLA_VF_LINK_STATE_AUTO which equals zero
> @@ -1156,7 +1159,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>                                 vf_tx_rate.vf =
>                                 vf_spoofchk.vf =
>                                 vf_linkstate.vf =
> -                               vf_rss_query_en.vf = ivi.vf;
> +                               vf_rss_query_en.vf =
> +                               vf_mc_promisc.vf = ivi.vf;
>
>                         memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
>                         vf_vlan.vlan = ivi.vlan;
> @@ -1167,6 +1171,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>                         vf_spoofchk.setting = ivi.spoofchk;
>                         vf_linkstate.link_state = ivi.linkstate;
>                         vf_rss_query_en.setting = ivi.rss_query_en;
> +                       vf_mc_promisc.setting = ivi.mc_promisc;
>                         vf = nla_nest_start(skb, IFLA_VF_INFO);
>                         if (!vf) {
>                                 nla_nest_cancel(skb, vfinfo);
> @@ -1520,6 +1525,16 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
>                                                             ivrssq_en->setting);
>                         break;
>                 }
> +               case IFLA_VF_MC_PROMISC: {
> +                       struct ifla_vf_mc_promisc *ivm;
> +
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
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
