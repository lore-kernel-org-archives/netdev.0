From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Mon, 05 Jan 2015 19:31:14 -0800
Message-ID: <54AB5702.9030503@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194544.31070.30335.stgit@nitbit.x32> <20150104111238.GD15305@casper.infradead.org> <54AADEFF.3090306@gmail.com> <54AB303E.3000601@gmail.com> <20150106010942.GD14077@vergenet.net> <54AB381E.3010009@gmail.com> <20150106020514.GA24057@vergenet.net> <20150106025456.GB24057@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org, davem@davemloft.net,
	andy@greyhouse.net
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:48910 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551AbbAFDb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 22:31:29 -0500
Received: by mail-oi0-f52.google.com with SMTP id a3so19985794oib.11
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 19:31:29 -0800 (PST)
In-Reply-To: <20150106025456.GB24057@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[...]

>>
>> BTW, I think there are a few problems with net_flow_put_flow_action().
>>
>> I am not quite to the bottom of it but it seems that:
>> * It loops over a->args[i] and then calls net_flow_put_act_types()
>>    which performs a similar loop. This outer-loop appears to be incorrect.
>> * It passes a[i].args instead of a->args[i] to net_flow_put_act_types()
>>
>> I can post a fix once I've got it working to my satisfaction.
>> But if you are reworking that code anyway perhaps it is easier for
>> you to handle it then.
>
> FWIW this got the current scheme working for me:
>

Thanks Simon. I'll roll this in as well.

> diff --git a/net/core/flow_table.c b/net/core/flow_table.c
> index 5dbdc13..598afa2 100644
> --- a/net/core/flow_table.c
> +++ b/net/core/flow_table.c
> @@ -946,7 +946,7 @@ static int net_flow_put_flow_action(struct sk_buff *skb,
>   				    struct net_flow_action *a)
>   {
>   	struct nlattr *action, *sigs;
> -	int i, err = 0;
> +	int err = 0;
>
>   	action = nla_nest_start(skb, NET_FLOW_ACTION);
>   	if (!action)
> @@ -958,21 +958,19 @@ static int net_flow_put_flow_action(struct sk_buff *skb,
>   	if (!a->args)
>   		goto done;
>
> -	for (i = 0; a->args[i].type; i++) {
> -		sigs = nla_nest_start(skb, NET_FLOW_ACTION_ATTR_SIGNATURE);
> -		if (!sigs) {
> -			nla_nest_cancel(skb, action);
> -			return -EMSGSIZE;
> -		}
> +	sigs = nla_nest_start(skb, NET_FLOW_ACTION_ATTR_SIGNATURE);
> +	if (!sigs) {
> +		nla_nest_cancel(skb, action);
> +		return -EMSGSIZE;
> +	}
>
> -		err = net_flow_put_act_types(skb, a[i].args);
> -		if (err) {
> -			nla_nest_cancel(skb, sigs);
> -			nla_nest_cancel(skb, action);
> -			return err;
> -		}
> -		nla_nest_end(skb, sigs);
> +	err = net_flow_put_act_types(skb, a->args);
> +	if (err) {
> +		nla_nest_cancel(skb, sigs);
> +		nla_nest_cancel(skb, action);
> +		return err;
>   	}
> +	nla_nest_end(skb, sigs);
>
>   done:
>   	nla_nest_end(skb, action);
> @@ -1103,6 +1101,7 @@ static int net_flow_get_action(struct net_flow_action *a, struct nlattr *attr)
>   		}
>
>   		a->args[count] = *(struct net_flow_action_arg *)nla_data(args);
> +		count++;
>   	}
>   	return 0;
>   }
>


-- 
John Fastabend         Intel Corporation
