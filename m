From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH/RFC rocker-net-next 2/6] net: flow: Handle error when
 putting a field while putting a flow
Date: Mon, 05 Jan 2015 09:28:14 -0800
Message-ID: <54AAC9AE.4010104@gmail.com>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com> <1420440610-20621-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:39436 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbbAER2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 12:28:24 -0500
Received: by mail-ob0-f178.google.com with SMTP id gq1so61893004obb.9
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 09:28:23 -0800 (PST)
In-Reply-To: <1420440610-20621-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2015 10:50 PM, Simon Horman wrote:
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>   net/core/flow_table.c | 9 +++++++--
>   1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/flow_table.c b/net/core/flow_table.c
> index 2af831e..753ebe0 100644
> --- a/net/core/flow_table.c
> +++ b/net/core/flow_table.c
> @@ -981,8 +981,9 @@ done:
>
>   int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
>   {
> -	struct nlattr *flows, *matches;
> +	struct nlattr *flows;
>   	struct nlattr *actions = NULL; /* must be null to unwind */
> +	struct nlattr *matches = NULL; /* must be null to unwind */

Actually we don't need to initialize to NULL now. That was some crazy
unwind scheme I had in place initially.

Now we only ever do a nla_nest_cancel on nested attributes that have
been initialized with nla_nest_start(). So I can simplify this to

	struct nlattr *flows, *matches, *actions;

>   	int err, j, i = 0;
>
>   	flows = nla_nest_start(skb, NET_FLOW_FLOW);
> @@ -1005,7 +1006,11 @@ int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
>   			if (!f->header)
>   				continue;
>
> -			nla_put(skb, NET_FLOW_FIELD_REF, sizeof(*f), f);
> +			err = nla_put(skb, NET_FLOW_FIELD_REF, sizeof(*f), f);

Great thanks. I missed this one.

> +			if (err) {
> +				nla_nest_cancel(skb, matches);
> +				goto flows_put_failure;
> +			}
>   		}
>   		nla_nest_end(skb, matches);
>   	}
>

I'll fold this into the series and resubmit thanks.

.John

-- 
John Fastabend         Intel Corporation
