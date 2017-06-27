From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [PATCH] datapath: Avoid using stack larger than 1024.
Date: Tue, 27 Jun 2017 09:38:35 -0700
Message-ID: <db35e98f-5d2c-f0f4-d52b-cdfa42c08410@gmail.com>
References: <1498546983-84649-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, pravin shelar <pshelar@nicira.com>
To: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35459 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751492AbdF0Qik (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 12:38:40 -0400
Received: by mail-pf0-f193.google.com with SMTP id s66so5421367pfs.2
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 09:38:39 -0700 (PDT)
In-Reply-To: <1498546983-84649-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2017 12:03 AM, Tonghao Zhang wrote:
> When compiling OvS-master on 4.4.0-81 kernel,
> there is a warning:
>
>      CC [M]  /root/ovs/datapath/linux/datapath.o
>      /root/ovs/datapath/linux/datapath.c: In function
>      ‘ovs_flow_cmd_set’:
>      /root/ovs/datapath/linux/datapath.c:1221:1: warning:
>      the frame size of 1040 bytes is larger than 1024 bytes
>      [-Wframe-larger-than=]
>
> This patch use kmalloc to malloc mem for sw_flow_mask and
> avoid using stack.
>
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> ---
>   datapath/datapath.c | 11 ++++++++---
>   1 file changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/datapath/datapath.c b/datapath/datapath.c
> index c85029c..da8cd68 100644
> --- a/datapath/datapath.c
> +++ b/datapath/datapath.c
> @@ -1107,7 +1107,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>       struct ovs_header *ovs_header = info->userhdr;
>       struct sw_flow_key key;
>       struct sw_flow *flow;
> -    struct sw_flow_mask mask;
> +    struct sw_flow_mask *mask;
>       struct sk_buff *reply = NULL;
>       struct datapath *dp;
>       struct sw_flow_actions *old_acts = NULL, *acts = NULL;
> @@ -1120,7 +1120,11 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>
>       ufid_present = ovs_nla_get_ufid(&sfid, a[OVS_FLOW_ATTR_UFID], log);
>       if (a[OVS_FLOW_ATTR_KEY]) {
> -        ovs_match_init(&match, &key, true, &mask);
> +        mask = kmalloc(sizeof(struct sw_flow_mask), GFP_KERNEL);
> +        if (!mask)
> +            return -ENOMEM;
> +
> +        ovs_match_init(&match, &key, true, mask);
>           error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
>                         a[OVS_FLOW_ATTR_MASK], log);
>       } else if (!ufid_present) {
> @@ -1141,7 +1145,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>           }
>
>           acts = get_flow_actions(net, a[OVS_FLOW_ATTR_ACTIONS], &key,
> -                    &mask, log);
> +                    mask, log);
>           if (IS_ERR(acts)) {
>               error = PTR_ERR(acts);
>               goto error;
> @@ -1216,6 +1220,7 @@ err_unlock_ovs:
>   err_kfree_acts:
>       ovs_nla_free_flow_actions(acts);
>   error:
> +    kfree(mask);
>       return error;
>   }
>
>
It looks fine to me but let's copy the maintainer Pravin

- Greg
