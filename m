From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [patch net-next RFC v3 04/10] rtnl: expose physical switch id for
 particular device
Date: Thu, 17 Apr 2014 14:40:05 +0200
Message-ID: <CAGm1_kt3AN_5sdPJvCKF4QqQWttvv8sdzpjRb9MLJd7a62L3BA@mail.gmail.com>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us> <1397736876-11771-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, Ben Hutchings <ben@decadent.org.uk>,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com,
	Felix Fietkau <nbd@openwrt.org>, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:62940 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754394AbaDQMk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 08:40:26 -0400
Received: by mail-pa0-f53.google.com with SMTP id ld10so332264pab.26
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 05:40:25 -0700 (PDT)
In-Reply-To: <1397736876-11771-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 17, 2014 at 2:14 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> The the netdevice represents a port in a switch, it will expose

remove one 'the'

> IFLA_PHYS_SWITCH_ID value via rtnl. Two netdevices with a same value

s/a same/the same

> belong to one physical switch.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Reviewed-by: Yegor Yefremov <yegorslists@googlemail.com>

> ---
>  include/uapi/linux/if_link.h |  1 +
>  net/core/rtnetlink.c         | 26 +++++++++++++++++++++++++-
>  2 files changed, 26 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 9a7f7ac..c11f492 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -145,6 +145,7 @@ enum {
>         IFLA_CARRIER,
>         IFLA_PHYS_PORT_ID,
>         IFLA_CARRIER_CHANGES,
> +       IFLA_PHYS_SWITCH_ID,
>         __IFLA_MAX
>  };
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 231e043..7170e24 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -43,6 +43,7 @@
>
>  #include <linux/inet.h>
>  #include <linux/netdevice.h>
> +#include <linux/switchdev.h>
>  #include <net/ip.h>
>  #include <net/protocol.h>
>  #include <net/arp.h>
> @@ -829,7 +830,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>                + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
>                + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
>                + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
> -              + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_PORT_ID */
> +              + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
> +              + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_SWITCH_ID */
>  }
>
>  static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
> @@ -926,6 +928,24 @@ static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
>         return 0;
>  }
>
> +static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
> +{
> +       int err;
> +       struct netdev_phys_item_id psid;
> +
> +       err = swdev_get_id(dev, &psid);
> +       if (err) {
> +               if (err == -EOPNOTSUPP)
> +                       return 0;
> +               return err;
> +       }
> +
> +       if (nla_put(skb, IFLA_PHYS_SWITCH_ID, psid.id_len, psid.id))
> +               return -EMSGSIZE;
> +
> +       return 0;
> +}
> +
>  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>                             int type, u32 pid, u32 seq, u32 change,
>                             unsigned int flags, u32 ext_filter_mask)
> @@ -998,6 +1018,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>         if (rtnl_phys_port_id_fill(skb, dev))
>                 goto nla_put_failure;
>
> +       if (rtnl_phys_switch_id_fill(skb, dev))
> +               goto nla_put_failure;
> +
>         attr = nla_reserve(skb, IFLA_STATS,
>                         sizeof(struct rtnl_link_stats));
>         if (attr == NULL)
> @@ -1151,6 +1174,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>         [IFLA_NUM_RX_QUEUES]    = { .type = NLA_U32 },
>         [IFLA_PHYS_PORT_ID]     = { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>         [IFLA_CARRIER_CHANGES]  = { .type = NLA_U32 },  /* ignored */
> +       [IFLA_PHYS_SWITCH_ID]   = { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>  };
>
>  static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
> --
> 1.9.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
