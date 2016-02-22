From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 4/5] Support to encoding decoding skb hashid
 on IFE action
Date: Mon, 22 Feb 2016 17:56:53 +0100
Message-ID: <56CB3DD5.8090906@iogearbox.net>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com> <1456147304-13355-5-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38621 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbcBVQ44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 11:56:56 -0500
In-Reply-To: <1456147304-13355-5-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2016 02:21 PM, Jamal Hadi Salim wrote:
[...]
> diff --git a/net/sched/act_meta_skbhash.c b/net/sched/act_meta_skbhash.c
> new file mode 100644
> index 0000000..c3140ea
> --- /dev/null
> +++ b/net/sched/act_meta_skbhash.c
> @@ -0,0 +1,87 @@
> +/*
> + * net/sched/act_meta_skbhash.c IFE skb->hash metadata module
> + *
> + *		This program is free software; you can redistribute it and/or
> + *		modify it under the terms of the GNU General Public License
> + *		as published by the Free Software Foundation; either version
> + *		2 of the License, or (at your option) any later version.
> + *
> + * copyright 	Jamal Hadi Salim (2015)
> + *
> +*/
> +
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/string.h>
> +#include <linux/errno.h>
> +#include <linux/skbuff.h>
> +#include <linux/rtnetlink.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <net/netlink.h>
> +#include <net/pkt_sched.h>
> +#include <uapi/linux/tc_act/tc_ife.h>
> +#include <net/tc_act/tc_ife.h>
> +
> +static int skbhash_check(struct sk_buff *skb, struct tcf_meta_info *e)
> +{
> +	u32 skbhash = skb->hash;
> +
> +	if (e->metaval) {
> +		skbhash = *(u32 *)e->metaval;
> +	}
> +	if (!skbhash)
> +		return 0;
> +
> +	return 8;

What's magic number 8?

> +}
> +
> +static int skbhash_encode(struct sk_buff *skb, void *skbdata,
> +			  struct tcf_meta_info *e)
> +{
> +	u32 skbhash = skb->hash;
> +
> +	return encode_meta_u32(skbhash, skbdata, e);
> +}
> +
> +static int skbhash_decode(struct sk_buff *skb, void *data, u16 len)
> +{
> +	u32 skbhash = *(u32 *) data;
> +
> +	skb->hash = ntohl(skbhash);

Depending on your scenario/use case, the next skb_get_hash() call
could overwrite what you've transferred and set here.

> +	return 0;
> +}
> +
> +static struct tcf_meta_ops ife_skbhash_ops = {
> +	.metaid = IFE_META_HASHID,
> +	.metatype = NLA_U32,
> +	.name = "skbhash",
> +	.synopsis = "skb hash metadata",

MODULE_DESCRIPTION()?

> +	.check_presence = skbhash_check,
> +	.encode = skbhash_encode,
> +	.decode = skbhash_decode,
> +	.get = get_meta_u32,
> +	.alloc = alloc_meta_u32,
> +	.owner = THIS_MODULE,
> +};
> +
> +static int __init ifeskbhash_init_module(void)
> +{
> +	pr_info("Loaded IFE skbhash\n");

Leftover pr_info()?

> +	return register_ife_op(&ife_skbhash_ops);
> +}
> +
> +static void __exit ifeskbhash_cleanup_module(void)
> +{
> +	pr_info("Unloaded IFE skb hash\n");

Ditto?

> +	unregister_ife_op(&ife_skbhash_ops);
> +}
> +
> +module_init(ifeskbhash_init_module);
> +module_exit(ifeskbhash_cleanup_module);
> +
> +MODULE_AUTHOR("Jamal Hadi Salim(2015)");
> +MODULE_DESCRIPTION("Inter-FE skb hash meta action");
> +MODULE_LICENSE("GPL");
> +MODULE_ALIAS_IFE_META(IFE_META_HASHID);
>
