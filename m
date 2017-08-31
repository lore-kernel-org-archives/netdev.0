From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 6/8] mlxsw: spectrum_dpipe: Add support for IPv6
 host table dump
Date: Thu, 31 Aug 2017 09:18:23 +0200
Message-ID: <20170831071823.GB1973@nanopsycho>
References: <20170830120306.6128-1-jiri@resnulli.us>
 <20170830120306.6128-7-jiri@resnulli.us>
 <e1e906eb-7c4e-1653-9bd2-2924127f3dcb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36682 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750897AbdHaHS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 03:18:26 -0400
Received: by mail-wr0-f194.google.com with SMTP id 40so5138068wrv.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 00:18:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <e1e906eb-7c4e-1653-9bd2-2924127f3dcb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 30, 2017 at 07:42:36PM CEST, dsahern@gmail.com wrote:
>On 8/30/17 6:03 AM, Jiri Pirko wrote:
>> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
>> index 5924e97..75da2ef 100644
>> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
>> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
>> @@ -386,8 +386,19 @@ mlxsw_sp_dpipe_table_host_match_action_prepare(struct devlink_dpipe_match *match
>>  
>>  	match = &matches[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
>>  	match->type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
>> -	match->header = &devlink_dpipe_header_ipv4;
>> -	match->field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
>> +	switch (type) {
>> +	case AF_INET:
>> +		match->header = &devlink_dpipe_header_ipv4;
>> +		match->field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
>> +		break;
>> +	case AF_INET6:
>> +		match->header = &devlink_dpipe_header_ipv6;
>> +		match->field_id = DEVLINK_DPIPE_FIELD_IPV6_DST_IP;
>> +		break;
>> +	default:
>> +		WARN_ON(1);
>
>Here as well.
>
>> +		return;
>> +	}
>>  
>>  	action->type = DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY;
>>  	action->header = &devlink_dpipe_header_ethernet;
>> @@ -424,7 +435,18 @@ mlxsw_sp_dpipe_table_host_entry_prepare(struct devlink_dpipe_entry *entry,
>>  	match_value = &match_values[MLXSW_SP_DPIPE_TABLE_HOST_MATCH_DIP];
>>  
>>  	match_value->match = match;
>> -	match_value->value_size = sizeof(u32);
>> +	switch (type) {
>> +	case AF_INET:
>> +		match_value->value_size = sizeof(u32);
>> +		break;
>> +	case AF_INET6:
>> +		match_value->value_size = sizeof(struct in6_addr);
>> +		break;
>> +	default:
>> +		WARN_ON(1);
>
>And here. WARN_ON is overkill

Again, only in case of bug in kernel.


>
>> +		return -EINVAL;
>> +	}
>> +
>>  	match_value->value = kmalloc(match_value->value_size, GFP_KERNEL);
>>  	if (!match_value->value)
>>  		return -ENOMEM;
>
