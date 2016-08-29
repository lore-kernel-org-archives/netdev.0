From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFCv2 03/16] net: cls_bpf: limit hardware offload by software-only
 flag
Date: Mon, 29 Aug 2016 17:06:34 +0200
Message-ID: <57C44F7A.5060501@iogearbox.net>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com> <1472234775-29453-4-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43947 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757440AbcH2PHE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 11:07:04 -0400
In-Reply-To: <1472234775-29453-4-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2016 08:06 PM, Jakub Kicinski wrote:
> Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_HW flag.
> Unlike U32 and flower cls_bpf already has some netlink
> flags defined.  I chose to create a new attribute to be
> able to use the same flag values as the above.
>
> Unknown flags are ignored and not reported upon dump.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
[...]
> @@ -55,6 +58,7 @@ struct cls_bpf_prog {
>   static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
>   	[TCA_BPF_CLASSID]	= { .type = NLA_U32 },
>   	[TCA_BPF_FLAGS]		= { .type = NLA_U32 },
> +	[TCA_BPF_FLAGS_GEN]	= { .type = NLA_U32 },
>   	[TCA_BPF_FD]		= { .type = NLA_U32 },
>   	[TCA_BPF_NAME]		= { .type = NLA_NUL_STRING, .len = CLS_BPF_NAME_LEN },
>   	[TCA_BPF_OPS_LEN]	= { .type = NLA_U16 },
> @@ -156,6 +160,7 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
>   	bpf_offload.filter = prog->filter;
>   	bpf_offload.name = prog->bpf_name;
>   	bpf_offload.exts_integrated = prog->exts_integrated;
> +	bpf_offload.gen_flags = prog->gen_flags;
>
>   	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
>   					     tp->protocol, &offload);
> @@ -169,14 +174,14 @@ static void cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
>   	enum tc_clsbpf_command cmd;
>
>   	if (oldprog && oldprog->offloaded) {
> -		if (tc_should_offload(dev, tp, 0)) {
> +		if (tc_should_offload(dev, tp, prog->gen_flags)) {
>   			cmd = TC_CLSBPF_REPLACE;
>   		} else {
>   			obj = oldprog;
>   			cmd = TC_CLSBPF_DESTROY;
>   		}
>   	} else {
> -		if (!tc_should_offload(dev, tp, 0))
> +		if (!tc_should_offload(dev, tp, prog->gen_flags))
>   			return;
>   		cmd = TC_CLSBPF_ADD;
>   	}
> @@ -372,6 +377,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
>   {
>   	bool is_bpf, is_ebpf, have_exts = false;
>   	struct tcf_exts exts;
> +	u32 gen_flags = 0;
>   	int ret;
>
>   	is_bpf = tb[TCA_BPF_OPS_LEN] && tb[TCA_BPF_OPS];
> @@ -396,8 +402,16 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
>
>   		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
>   	}
> +	if (tb[TCA_BPF_FLAGS_GEN]) {
> +		gen_flags = nla_get_u32(tb[TCA_BPF_FLAGS_GEN]);
> +		/* Make sure dump doesn't report back flags we don't handle */
> +		gen_flags &= CLS_BPF_SUPPORTED_GEN_FLAGS;

Instead of above rather ...

	if (gen_flags & ~CLS_BPF_SUPPORTED_GEN_FLAGS) {
		ret = -EINVAL;
		goto errout;
	}

... so that we can handle further additions properly like we do with
tb[TCA_BPF_FLAGS]?

> +		if (!tc_flags_valid(gen_flags))
> +			return -EINVAL;

Shouldn't we: goto errout?

> +	}
>
>   	prog->exts_integrated = have_exts;
> +	prog->gen_flags = gen_flags;
>
>   	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
>   		       cls_bpf_prog_from_efd(tb, prog, tp);
> @@ -569,6 +583,9 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
>   		bpf_flags |= TCA_BPF_FLAG_ACT_DIRECT;
>   	if (bpf_flags && nla_put_u32(skb, TCA_BPF_FLAGS, bpf_flags))
>   		goto nla_put_failure;
> +	if (prog->gen_flags &&
> +	    nla_put_u32(skb, TCA_BPF_FLAGS_GEN, prog->gen_flags))
> +		goto nla_put_failure;
>
>   	nla_nest_end(skb, nest);

Rest looks good:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
