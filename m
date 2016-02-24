From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Wed, 24 Feb 2016 18:37:49 +0100
Message-ID: <56CDEA6D.1000908@iogearbox.net>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com> <1456231760-2513-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	dj@verizon.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60669 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831AbcBXRh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:37:58 -0500
In-Reply-To: <1456231760-2513-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2016 01:49 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
[...]
> +static const struct nla_policy ife_policy[TCA_IFE_MAX + 1] = {
> +	[TCA_IFE_PARMS] = {.len = sizeof(struct tc_ife)},
> +	[TCA_IFE_DMAC] = {.type = NLA_BINARY,.len = ETH_ALEN},
> +	[TCA_IFE_SMAC] = {.type = NLA_BINARY,.len = ETH_ALEN},

This is buggy btw ...

> +	[TCA_IFE_TYPE] = {.type = NLA_U16},
> +};

[...]

> +	if (parm->flags & IFE_ENCODE) {
> +		ife_type = *(u16 *) nla_data(tb[TCA_IFE_TYPE]);

( We have accessors for such things. Please also check coding style
   and white space things in your series, there's couple of things all
   over the place. )

> +		if (tb[TCA_IFE_DMAC] != NULL)
> +			daddr = nla_data(tb[TCA_IFE_DMAC]);
> +		if (tb[TCA_IFE_SMAC] != NULL)
> +			saddr = nla_data(tb[TCA_IFE_SMAC]);

... NLA_BINARY with len means: max length. But there's nothing
that checks a min length on this, so you potentially access out
of bounds since everything <= ETH_ALEN is allowed in your case.

> +	}
> +
> +	spin_lock_bh(&ife->tcf_lock);

Maybe try to make this lockless in the fast path? Otherwise placing
this on ingress / egress (f.e. clsact) doesn't really scale.

> +	ife->tcf_action = parm->action;
> +
> +	if (parm->flags & IFE_ENCODE) {
> +		if (daddr)
> +			ether_addr_copy(ife->eth_dst, daddr);
> +		else
> +			eth_zero_addr(ife->eth_dst);
> +
> +		if (saddr)
> +			ether_addr_copy(ife->eth_src, saddr);
> +		else
> +			eth_zero_addr(ife->eth_src);
> +
> +		ife->eth_type = ife_type;
> +	}
