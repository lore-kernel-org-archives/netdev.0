From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH v6 1/3] if_link: Add control trust VF
Date: Wed, 17 Jun 2015 09:18:40 -0700
Message-ID: <55819DE0.2000205@gmail.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05EE188B@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34397 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154AbbFQQSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 12:18:42 -0400
Received: by pdbki1 with SMTP id ki1so43455106pdb.1
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 09:18:42 -0700 (PDT)
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05EE188B@BPXM14GP.gisp.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2015 04:41 AM, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
> Add netlink directives and ndo entry to trust VF user.
>
> This controls the special permission of VF user.
> The administrator will dedicatedly trust VF user to use some features
> which impacts security and/or performance.
>
> The administrator never turn it on unless VF user is fully trusted.
>
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
> include/linux/if_link.h      |  1 +
>   include/linux/netdevice.h    |  3 +++
>   include/uapi/linux/if_link.h |  6 ++++++
>   net/core/rtnetlink.c         | 19 +++++++++++++++++--
>   4 files changed, 27 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index ae5d0d2..f923d15 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -24,5 +24,6 @@ struct ifla_vf_info {
>   	__u32 min_tx_rate;
>   	__u32 max_tx_rate;
>   	__u32 rss_query_en;
> +	__u32 trusted;
>   };
>   #endif /* _LINUX_IF_LINK_H */
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index e20979d..a034fb8 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -873,6 +873,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>    * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int min_tx_rate,
>    *			  int max_tx_rate);
>    * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
> + * int (*ndo_set_vf_trust)(struct net_device *dev, int vf, bool setting);
>    * int (*ndo_get_vf_config)(struct net_device *dev,
>    *			    int vf, struct ifla_vf_info *ivf);
>    * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int link_state);
> @@ -1095,6 +1096,8 @@ struct net_device_ops {
>   						   int max_tx_rate);
>   	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
>   						       int vf, bool setting);
> +	int			(*ndo_set_vf_trust)(struct net_device *dev,
> +						    int vf, bool setting);
>   	int			(*ndo_get_vf_config)(struct net_device *dev,
>   						     int vf,
>   						     struct ifla_vf_info *ivf);
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 2c7e8e3..891050c 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -485,6 +485,7 @@ enum {
>   				 * on/off switch
>   				 */
>   	IFLA_VF_STATS,		/* network device statistics */
> +	IFLA_VF_TRUST,		/* Trust VF */
>   	__IFLA_VF_MAX,
>   };
>
> @@ -546,6 +547,11 @@ enum {
>
>   #define IFLA_VF_STATS_MAX (__IFLA_VF_STATS_MAX - 1)
>
> +struct ifla_vf_trust {
> +	__u32 vf;
> +	__u32 setting;
> +};
> +
>   /* VF ports management section
>    *
>    *	Nested layout of set/get msg is:
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 2d102ce..abd1a75 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -831,7 +831,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
>   			 /* IFLA_VF_STATS_BROADCAST */
>   			 nla_total_size(sizeof(__u64)) +
>   			 /* IFLA_VF_STATS_MULTICAST */
> -			 nla_total_size(sizeof(__u64)));
> +			 nla_total_size(sizeof(__u64)) +
> +			 nla_total_size(sizeof(struct ifla_vf_trust)));
>   		return size;
>   	} else
>   		return 0;
> @@ -1151,6 +1152,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>   			struct ifla_vf_link_state vf_linkstate;
>   			struct ifla_vf_rss_query_en vf_rss_query_en;
>   			struct ifla_vf_stats vf_stats;
> +			struct ifla_vf_trust vf_trust;
>
>   			/*
>   			 * Not all SR-IOV capable drivers support the
> @@ -1160,6 +1162,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>   			 */
>   			ivi.spoofchk = -1;
>   			ivi.rss_query_en = -1;
> +			ivi.trusted = -1;
>   			memset(ivi.mac, 0, sizeof(ivi.mac));
>   			/* The default value for VF link state is "auto"
>   			 * IFLA_VF_LINK_STATE_AUTO which equals zero
> @@ -1173,7 +1176,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>   				vf_tx_rate.vf =
>   				vf_spoofchk.vf =
>   				vf_linkstate.vf =
> -				vf_rss_query_en.vf = ivi.vf;
> +				vf_rss_query_en.vf =
> +				vf_trust.vf = ivi.vf;
>
>   			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
>   			vf_vlan.vlan = ivi.vlan;
> @@ -1184,6 +1188,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>   			vf_spoofchk.setting = ivi.spoofchk;
>   			vf_linkstate.link_state = ivi.linkstate;
>   			vf_rss_query_en.setting = ivi.rss_query_en;
> +			vf_trust.setting = ivi.trusted;
>   			vf = nla_nest_start(skb, IFLA_VF_INFO);
>   			if (!vf) {
>   				nla_nest_cancel(skb, vfinfo);

Don't you also need to define a section in ifla_vf_policy for 
IFLA_VF_TRUST?  Otherwise I thought the .len value gets configured as 0.

> @@ -1571,6 +1576,16 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
>   							    ivrssq_en->setting);
>   			break;
>   		}
> +		case IFLA_VF_TRUST: {
> +			struct ifla_vf_trust *ivt;
> +
> +			ivt = nla_data(vf);
> +			err = -EOPNOTSUPP;
> +			if (ops->ndo_set_vf_trust)
> +				err = ops->ndo_set_vf_trust(dev, ivt->vf,
> +							    ivt->setting);
> +			break;
> +		}
>   		default:
>   			err = -EINVAL;
>   			break;
>
