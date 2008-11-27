From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 09/39] wimax: provides user space with information needed
 when opening a WiMAX device
Date: Thu, 27 Nov 2008 11:44:46 +0100
Message-ID: <492E7A1E.4010906@trash.net>
References: <cover.1227691434.git.inaky@linux.intel.com> <61e0e60ace9f0c441b51e5009d304229c4b234d3.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47125 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755567AbYK0Ko6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 05:44:58 -0500
In-Reply-To: <61e0e60ace9f0c441b51e5009d304229c4b234d3.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inaky Perez-Gonzalez wrote:
> +static
> +int __wimax_gnl_open_reply(struct wimax_dev *wimax_dev,
> +			   struct genl_info *genl_info)
> +{
> +	int result;
> +	void *data;
> +	struct sk_buff *reply_skb;
> +	struct nlattr *nla_groups, *nla_group;
> +	struct wimax_pipe *pipe_itr;
> +
> +	result = -ENOMEM;
> +	reply_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +	if (reply_skb == NULL)
> +		goto error_new;
> +	data = genlmsg_put_reply(reply_skb, genl_info,
> +				 &wimax_dev->gnl_family,
> +				 0, WIMAX_GNL_RP_IFINFO);
> +	if (data == NULL)
> +		goto error_put_reply;
> +
> +	nla_groups = nla_nest_start(reply_skb, WIMAX_GNL_IFINFO_MC_GROUPS);
> +	if (nla_groups == NULL)
> +		goto error_groups_start;
> +
> +	list_for_each_entry(pipe_itr, &wimax_dev->pipe_list,
> +			    list_node) {
> +		nla_group = nla_nest_start(reply_skb,
> +					   WIMAX_GNL_IFINFO_MC_GROUP);
> +		if (nla_group == NULL)
> +			goto error_group_start;
> +
> +		nla_put_u16(reply_skb, WIMAX_GNL_IFINFO_MC_ID,
> +			    pipe_itr->mcg.id);
> +		nla_put_string(reply_skb, WIMAX_GNL_IFINFO_MC_NAME,
> +			       pipe_itr->mcg.name);

The nla_put results must be checked unless there's a guarantee that
the attributes won't exceed the skbs size.

> +		nla_nest_end(reply_skb, nla_group);
> +	}
> +	nla_nest_end(reply_skb, nla_groups);
> +	genlmsg_end(reply_skb, data);
> +
> +	result = genlmsg_reply(reply_skb, genl_info);
> +	if (result < 0)
> +		goto error_reply;
> +	return 0;
> +
> +error_group_start:
> +error_groups_start:
> +error_reply:
> +error_put_reply:

This seems a bit excessive considering that its very unlikely
that you'll ever need to distinguish these cases.

> +	nlmsg_free(reply_skb);
> +error_new:
> +	return result;
> +}
