From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 02/11] net: flow_table: add flow, delete flow
Date: Thu, 08 Jan 2015 22:21:31 -0800
Message-ID: <54AF736B.60104@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194615.31070.18038.stgit@nitbit.x32> <20150108173936.GD1898@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, sfeldma@gmail.com, jhs@mojatatu.com,
	simon.horman@netronome.com, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:34101 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbbAIGVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 01:21:50 -0500
Received: by mail-ob0-f177.google.com with SMTP id va2so11450350obc.8
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 22:21:49 -0800 (PST)
In-Reply-To: <20150108173936.GD1898@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2015 09:39 AM, Jiri Pirko wrote:
> Wed, Dec 31, 2014 at 08:46:16PM CET, john.fastabend@gmail.com wrote:
>> Now that the device capabilities are exposed we can add support to
>> add and delete flows from the tables.
>>
>> The two operations are
>>

[...]

>> +
>> +static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
>> +				    struct genl_info *info)
>> +{
>> +	int rem, err_handle = NET_FLOW_FLOWS_ERROR_ABORT;
>> +	struct sk_buff *skb = NULL;
>> +	struct net_flow_flow this;
>> +	struct genlmsghdr *hdr;
>> +	struct net_device *dev;
>> +	struct nlattr *flow, *flows;
>> +	int cmd = info->genlhdr->cmd;
>> +	int err = -EOPNOTSUPP;
>
> I don't like the inconsistency in var naming. Sometimes, "flow" is of type
> struct nlattr, sometimes it is of type struct net_flow_flow
> (net_flow_get_flow). It is slightly confusing.
>

Alexei made a similar comment I'll try to clean this up in v2.

>> +
>> +	dev = net_flow_get_dev(info);
>> +	if (!dev)
>> +		return -EINVAL;
>> +
>> +	if (!dev->netdev_ops->ndo_flow_set_flows ||
>> +	    !dev->netdev_ops->ndo_flow_del_flows)
>> +		goto out;
>> +
>> +	if (!info->attrs[NET_FLOW_IDENTIFIER_TYPE] ||
>> +	    !info->attrs[NET_FLOW_IDENTIFIER] ||
>> +	    !info->attrs[NET_FLOW_FLOWS]) {
>> +		err = -EINVAL;
>> +		goto out;
>> +	}
>> +
>> +	if (info->attrs[NET_FLOW_FLOWS_ERROR])
>> +		err_handle = nla_get_u32(info->attrs[NET_FLOW_FLOWS_ERROR]);
>> +
>> +	nla_for_each_nested(flow, info->attrs[NET_FLOW_FLOWS], rem) {
>> +		if (nla_type(flow) != NET_FLOW_FLOW)
>> +			continue;
>> +
>> +		err = net_flow_get_flow(&this, flow);
>> +		if (err)
>> +			goto out;
>> +
>> +		switch (cmd) {
>> +		case NET_FLOW_TABLE_CMD_SET_FLOWS:
>> +			err = dev->netdev_ops->ndo_flow_set_flows(dev, &this);
>> +			break;
>> +		case NET_FLOW_TABLE_CMD_DEL_FLOWS:
>> +			err = dev->netdev_ops->ndo_flow_del_flows(dev, &this);
>> +			break;
>> +		default:
>> +			err = -EOPNOTSUPP;
>> +			break;
>> +		}
>> +
>> +		if (err && err_handle != NET_FLOW_FLOWS_ERROR_CONTINUE) {
>> +			if (!skb) {
>> +				skb = net_flow_start_errmsg(dev, &hdr,
>> +							    info->snd_portid,
>> +							    info->snd_seq,
>> +							    cmd);
>> +				if (IS_ERR(skb)) {
>> +					err = PTR_ERR(skb);
>> +					goto out_plus_free;
>> +				}
>> +
>> +				flows = nla_nest_start(skb, NET_FLOW_FLOWS);
>> +				if (!flows) {
>> +					err = -EMSGSIZE;
>> +					goto out_plus_free;
>> +				}
>> +			}
>> +
>> +			net_flow_put_flow(skb, &this);
>> +		}
>> +
>> +		/* Cleanup flow */
>> +		kfree(this.matches);
>> +		kfree(this.actions);
>> +
>> +		if (err && err_handle == NET_FLOW_FLOWS_ERROR_ABORT)
>> +			goto out;
>> +	}
>> +
>> +	dev_put(dev);
>> +
>> +	if (skb) {
>> +		nla_nest_end(skb, flows);
>> +		net_flow_end_flow_errmsg(skb, hdr);
>> +		return genlmsg_reply(skb, info);
>> +	}
>> +	return 0;
>> +
>> +out_plus_free:
>> +	kfree(this.matches);
>> +	kfree(this.actions);
>
> 	Maybe this can be done by some "flow_free" helper...
>

Agreed I already wrote helpers for this on my local tree. I'll push it
in the next version as well.

Thanks,
John

-- 
John Fastabend         Intel Corporation
