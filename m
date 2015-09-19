From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Zero flows on allocation.
Date: Fri, 18 Sep 2015 20:38:20 -0700
Message-ID: <CALnjE+py6bNZYWCzifHQgGWyrS1Y-z8VgGdA3pwQP35cdbq_Jw@mail.gmail.com>
References: <1442628374-57025-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36029 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403AbbISDiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 23:38:21 -0400
Received: by ioii196 with SMTP id i196so75303986ioi.3
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 20:38:20 -0700 (PDT)
In-Reply-To: <1442628374-57025-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 7:06 PM, Jesse Gross <jesse@nicira.com> wrote:
> OVS tries to be clever about not touching the parts of a flow that
> aren't used. This can include leaving pieces of memory uninitialized
> if the mask is zero and therefore the value would be ignored anyways.
>
> While this works fine for the purposes of matching (which must always
> look at the mask), serialization to netlink can be problematic. Since
> the flow and the mask are serialized separately, the uninitialized
> portions of the flow can be encoded with whatever values happen to be
> present.
>
> In terms of functionality, this has little effect since these fields
> will be masked out by definition. However, it leaks kernel memory to
> userspace, which is a potential security vulnerability.
>
> This zeros the flows as they are allocated and installed. This was
> always intended to be the case as the memory optimizations were only
> supposed to apply to per-packet flow operations.
>
Good catch.

> Fixes: 07148121 ("openvswitch: Eliminate memset() from flow_extract.")
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
>  net/openvswitch/flow_table.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
> index d22d8e9..5248322 100644
> --- a/net/openvswitch/flow_table.c
> +++ b/net/openvswitch/flow_table.c
> @@ -80,7 +80,7 @@ struct sw_flow *ovs_flow_alloc(void)
>         struct flow_stats *stats;
>         int node;
>
> -       flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
> +       flow = kmem_cache_alloc(flow_cache, GFP_KERNEL | __GFP_ZERO);
>         if (!flow)
>                 return ERR_PTR(-ENOMEM);

There are few flow members set to zero that are unnecessary after this change.

>
> --
> 2.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
