From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 06/12] nfp: add hardware cls_bpf offload
Date: Thu, 02 Jun 2016 01:03:03 +0200
Message-ID: <574F69A7.2020903@iogearbox.net>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com> <1464799814-4453-7-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dinan.gunawardena@netronome.com,
	john.fastabend@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41128 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbcFAXDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 19:03:06 -0400
In-Reply-To: <1464799814-4453-7-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2016 06:50 PM, Jakub Kicinski wrote:
> Add hardware cls_bpf offload on our smart NICs.  Detect if
> capable firmware is loaded and use it to load the code JITed
> with just added translator onto programmable engines.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

[...]
> @@ -2386,6 +2387,21 @@ static struct rtnl_link_stats64 *nfp_net_stat64(struct net_device *netdev,
>   	return stats;
>   }
>
> +static int
> +nfp_net_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
> +		 struct tc_to_netdev *tc)
> +{
> +	struct nfp_net *nn = netdev_priv(netdev);
> +
> +	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
> +		return -EINVAL;

General question (maybe also to John, since this construct is used elsewhere too),
does this handle the case with sch_clsact since they share the same major code?
F.e. I have the subclass with minor number TC_H_MIN_INGRESS offloaded, but can still
use TC_H_MIN_EGRESS part in SW at the same time? Do we make sure to separate that?
If not, should this info be passed via tc_to_netdev?

> +	if (tc->type == TC_SETUP_CLSBPF && nn->cap & NFP_NET_CFG_CTRL_BPF)
> +		return nfp_net_bpf_offload(nn, handle, proto, tc->cls_bpf);
> +
> +	return -EINVAL;
> +}
> +
>   static int nfp_net_set_features(struct net_device *netdev,
>   				netdev_features_t features)
>   {
> @@ -2440,6 +2456,11 @@ static int nfp_net_set_features(struct net_device *netdev,
>   			new_ctrl &= ~NFP_NET_CFG_CTRL_GATHER;
>   	}
>
> +	if (changed & NETIF_F_HW_TC && nn->ctrl & NFP_NET_CFG_CTRL_BPF) {
> +		nn_err(nn, "Cannot disable HW TC offload while in use\n");
> +		return -EBUSY;
> +	}
> +
