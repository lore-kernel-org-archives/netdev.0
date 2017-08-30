From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 6/8] mlxsw: spectrum_dpipe: Add support for IPv6
 host table dump
Date: Wed, 30 Aug 2017 11:42:36 -0600
Message-ID: <e1e906eb-7c4e-1653-9bd2-2924127f3dcb@gmail.com>
References: <20170830120306.6128-1-jiri@resnulli.us>
 <20170830120306.6128-7-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34588 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751555AbdH3Rmj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:42:39 -0400
Received: by mail-pf0-f193.google.com with SMTP id l8so221365pfj.1
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 10:42:38 -0700 (PDT)
In-Reply-To: <20170830120306.6128-7-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/30/17 6:03 AM, Jiri Pirko wrote:
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
> index 5924e97..75da2ef 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
> @@ -386,8 +386,19 @@ mlxsw_sp_dpipe_table_host_match_action_prepare(struct devlink_dpipe_match *match
>  
>  	match = &matches[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
>  	match->type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
> -	match->header = &devlink_dpipe_header_ipv4;
> -	match->field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
> +	switch (type) {
> +	case AF_INET:
> +		match->header = &devlink_dpipe_header_ipv4;
> +		match->field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
> +		break;
> +	case AF_INET6:
> +		match->header = &devlink_dpipe_header_ipv6;
> +		match->field_id = DEVLINK_DPIPE_FIELD_IPV6_DST_IP;
> +		break;
> +	default:
> +		WARN_ON(1);

Here as well.

> +		return;
> +	}
>  
>  	action->type = DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY;
>  	action->header = &devlink_dpipe_header_ethernet;
> @@ -424,7 +435,18 @@ mlxsw_sp_dpipe_table_host_entry_prepare(struct devlink_dpipe_entry *entry,
>  	match_value = &match_values[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
>  
>  	match_value->match = match;
> -	match_value->value_size = sizeof(u32);
> +	switch (type) {
> +	case AF_INET:
> +		match_value->value_size = sizeof(u32);
> +		break;
> +	case AF_INET6:
> +		match_value->value_size = sizeof(struct in6_addr);
> +		break;
> +	default:
> +		WARN_ON(1);

And here. WARN_ON is overkill

> +		return -EINVAL;
> +	}
> +
>  	match_value->value = kmalloc(match_value->value_size, GFP_KERNEL);
>  	if (!match_value->value)
>  		return -ENOMEM;
