From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net] rtnetlink: verify IFLA_VF_INFO attributes before
 passing them to driver
Date: Tue, 07 Jul 2015 11:36:51 +0300
Message-ID: <559B8FA3.1030209@cloudius-systems.com>
References: <9b88c7217fcbf771efc162d51e3d6d1957707aa7.1436220184.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35001 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbGGIgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 04:36:55 -0400
Received: by wiga1 with SMTP id a1so249741386wig.0
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 01:36:54 -0700 (PDT)
In-Reply-To: <9b88c7217fcbf771efc162d51e3d6d1957707aa7.1436220184.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/07/15 01:07, Daniel Borkmann wrote:
> Jason Gunthorpe reported that since commit c02db8c6290b ("rtnetlink: make
> SR-IOV VF interface symmetric"), we don't verify IFLA_VF_INFO attributes
> anymore with respect to their policy, that is, ifla_vfinfo_policy[].
>
> Before, they were part of ifla_policy[], but they have been nested since
> placed under IFLA_VFINFO_LIST, that contains the attribute IFLA_VF_INFO,
> which is another nested attribute for the actual VF attributes such as
> IFLA_VF_MAC, IFLA_VF_VLAN, etc.
>
> Despite the policy being split out from ifla_policy[] in this commit,
> it's never applied anywhere. nla_for_each_nested() only does basic nla_ok()
> testing for struct nlattr, but it doesn't know about the data context and
> their requirements.
>
> Fix, on top of Jason's initial work, does 1) parsing of the attributes
> with the right policy, and 2) using the resulting parsed attribute table
> from 1) instead of the nla_for_each_nested() loop (just like we used to
> do when still part of ifla_policy[]).
>
> Reference: http://thread.gmane.org/gmane.linux.network/368913
> Fixes: c02db8c6290b ("rtnetlink: make SR-IOV VF interface symmetric")
> Reported-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Cc: Chris Wright <chrisw@sous-sol.org>
> Cc: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Rony Efraim <ronye@mellanox.com>
> Cc: Vlad Zolotarov <vladz@cloudius-systems.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Vlad Zolotarov <vladz@cloudius-systems.com>

> ---
>   net/core/rtnetlink.c | 187 ++++++++++++++++++++++++++-------------------------
>   1 file changed, 96 insertions(+), 91 deletions(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 01ced4a..9e433d5 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1328,10 +1328,6 @@ static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
>   	[IFLA_INFO_SLAVE_DATA]	= { .type = NLA_NESTED },
>   };
>   
> -static const struct nla_policy ifla_vfinfo_policy[IFLA_VF_INFO_MAX+1] = {
> -	[IFLA_VF_INFO]		= { .type = NLA_NESTED },
> -};
> -
>   static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
>   	[IFLA_VF_MAC]		= { .len = sizeof(struct ifla_vf_mac) },
>   	[IFLA_VF_VLAN]		= { .len = sizeof(struct ifla_vf_vlan) },
> @@ -1488,96 +1484,98 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
>   	return 0;
>   }
>   
> -static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
> +static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
>   {
> -	int rem, err = -EINVAL;
> -	struct nlattr *vf;
>   	const struct net_device_ops *ops = dev->netdev_ops;
> +	int err = -EINVAL;
>   
> -	nla_for_each_nested(vf, attr, rem) {
> -		switch (nla_type(vf)) {
> -		case IFLA_VF_MAC: {
> -			struct ifla_vf_mac *ivm;
> -			ivm = nla_data(vf);
> -			err = -EOPNOTSUPP;
> -			if (ops->ndo_set_vf_mac)
> -				err = ops->ndo_set_vf_mac(dev, ivm->vf,
> -							  ivm->mac);
> -			break;
> -		}
> -		case IFLA_VF_VLAN: {
> -			struct ifla_vf_vlan *ivv;
> -			ivv = nla_data(vf);
> -			err = -EOPNOTSUPP;
> -			if (ops->ndo_set_vf_vlan)
> -				err = ops->ndo_set_vf_vlan(dev, ivv->vf,
> -							   ivv->vlan,
> -							   ivv->qos);
> -			break;
> -		}
> -		case IFLA_VF_TX_RATE: {
> -			struct ifla_vf_tx_rate *ivt;
> -			struct ifla_vf_info ivf;
> -			ivt = nla_data(vf);
> -			err = -EOPNOTSUPP;
> -			if (ops->ndo_get_vf_config)
> -				err = ops->ndo_get_vf_config(dev, ivt->vf,
> -							     &ivf);
> -			if (err)
> -				break;
> -			err = -EOPNOTSUPP;
> -			if (ops->ndo_set_vf_rate)
> -				err = ops->ndo_set_vf_rate(dev, ivt->vf,
> -							   ivf.min_tx_rate,
> -							   ivt->rate);
> -			break;
> -		}
> -		case IFLA_VF_RATE: {
> -			struct ifla_vf_rate *ivt;
> -			ivt = nla_data(vf);
> -			err = -EOPNOTSUPP;
> -			if (ops->ndo_set_vf_rate)
> -				err = ops->ndo_set_vf_rate(dev, ivt->vf,
> -							   ivt->min_tx_rate,
> -							   ivt->max_tx_rate);
> -			break;
> -		}
> -		case IFLA_VF_SPOOFCHK: {
> -			struct ifla_vf_spoofchk *ivs;
> -			ivs = nla_data(vf);
> -			err = -EOPNOTSUPP;
> -			if (ops->ndo_set_vf_spoofchk)
> -				err = ops->ndo_set_vf_spoofchk(dev, ivs->vf,
> -							       ivs->setting);
> -			break;
> -		}
> -		case IFLA_VF_LINK_STATE: {
> -			struct ifla_vf_link_state *ivl;
> -			ivl = nla_data(vf);
> -			err = -EOPNOTSUPP;
> -			if (ops->ndo_set_vf_link_state)
> -				err = ops->ndo_set_vf_link_state(dev, ivl->vf,
> -								 ivl->link_state);
> -			break;
> -		}
> -		case IFLA_VF_RSS_QUERY_EN: {
> -			struct ifla_vf_rss_query_en *ivrssq_en;
> +	if (tb[IFLA_VF_MAC]) {
> +		struct ifla_vf_mac *ivm = nla_data(tb[IFLA_VF_MAC]);
>   
> -			ivrssq_en = nla_data(vf);
> -			err = -EOPNOTSUPP;
> -			if (ops->ndo_set_vf_rss_query_en)
> -				err = ops->ndo_set_vf_rss_query_en(dev,
> -							    ivrssq_en->vf,
> -							    ivrssq_en->setting);
> -			break;
> -		}
> -		default:
> -			err = -EINVAL;
> -			break;
> -		}
> -		if (err)
> -			break;
> +		err = -EOPNOTSUPP;
> +		if (ops->ndo_set_vf_mac)
> +			err = ops->ndo_set_vf_mac(dev, ivm->vf,
> +						  ivm->mac);
> +		if (err < 0)
> +			return err;
> +	}
> +
> +	if (tb[IFLA_VF_VLAN]) {
> +		struct ifla_vf_vlan *ivv = nla_data(tb[IFLA_VF_VLAN]);
> +
> +		err = -EOPNOTSUPP;
> +		if (ops->ndo_set_vf_vlan)
> +			err = ops->ndo_set_vf_vlan(dev, ivv->vf, ivv->vlan,
> +						   ivv->qos);
> +		if (err < 0)
> +			return err;
> +	}
> +
> +	if (tb[IFLA_VF_TX_RATE]) {
> +		struct ifla_vf_tx_rate *ivt = nla_data(tb[IFLA_VF_TX_RATE]);
> +		struct ifla_vf_info ivf;
> +
> +		err = -EOPNOTSUPP;
> +		if (ops->ndo_get_vf_config)
> +			err = ops->ndo_get_vf_config(dev, ivt->vf, &ivf);
> +		if (err < 0)
> +			return err;
> +
> +		err = -EOPNOTSUPP;
> +		if (ops->ndo_set_vf_rate)
> +			err = ops->ndo_set_vf_rate(dev, ivt->vf,
> +						   ivf.min_tx_rate,
> +						   ivt->rate);
> +		if (err < 0)
> +			return err;
> +	}
> +
> +	if (tb[IFLA_VF_RATE]) {
> +		struct ifla_vf_rate *ivt = nla_data(tb[IFLA_VF_RATE]);
> +
> +		err = -EOPNOTSUPP;
> +		if (ops->ndo_set_vf_rate)
> +			err = ops->ndo_set_vf_rate(dev, ivt->vf,
> +						   ivt->min_tx_rate,
> +						   ivt->max_tx_rate);
> +		if (err < 0)
> +			return err;
>   	}
> +
> +	if (tb[IFLA_VF_SPOOFCHK]) {
> +		struct ifla_vf_spoofchk *ivs = nla_data(tb[IFLA_VF_SPOOFCHK]);
> +
> +		err = -EOPNOTSUPP;
> +		if (ops->ndo_set_vf_spoofchk)
> +			err = ops->ndo_set_vf_spoofchk(dev, ivs->vf,
> +						       ivs->setting);
> +		if (err < 0)
> +			return err;
> +	}
> +
> +	if (tb[IFLA_VF_LINK_STATE]) {
> +		struct ifla_vf_link_state *ivl = nla_data(tb[IFLA_VF_LINK_STATE]);
> +
> +		err = -EOPNOTSUPP;
> +		if (ops->ndo_set_vf_link_state)
> +			err = ops->ndo_set_vf_link_state(dev, ivl->vf,
> +							 ivl->link_state);
> +		if (err < 0)
> +			return err;
> +	}
> +
> +	if (tb[IFLA_VF_RSS_QUERY_EN]) {
> +		struct ifla_vf_rss_query_en *ivrssq_en;
> +
> +		err = -EOPNOTSUPP;
> +		ivrssq_en = nla_data(tb[IFLA_VF_RSS_QUERY_EN]);
> +		if (ops->ndo_set_vf_rss_query_en)
> +			err = ops->ndo_set_vf_rss_query_en(dev, ivrssq_en->vf,
> +							   ivrssq_en->setting);
> +		if (err < 0)
> +			return err;
> +	}
> +
>   	return err;
>   }
>   
> @@ -1773,14 +1771,21 @@ static int do_setlink(const struct sk_buff *skb,
>   	}
>   
>   	if (tb[IFLA_VFINFO_LIST]) {
> +		struct nlattr *vfinfo[IFLA_VF_MAX + 1];
>   		struct nlattr *attr;
>   		int rem;
> +
>   		nla_for_each_nested(attr, tb[IFLA_VFINFO_LIST], rem) {
> -			if (nla_type(attr) != IFLA_VF_INFO) {
> +			if (nla_type(attr) != IFLA_VF_INFO ||
> +			    nla_len(attr) < NLA_HDRLEN) {
>   				err = -EINVAL;
>   				goto errout;
>   			}
> -			err = do_setvfinfo(dev, attr);
> +			err = nla_parse_nested(vfinfo, IFLA_VF_MAX, attr,
> +					       ifla_vf_policy);
> +			if (err < 0)
> +				goto errout;
> +			err = do_setvfinfo(dev, vfinfo);
>   			if (err < 0)
>   				goto errout;
>   			status |= DO_SETLINK_NOTIFY;
