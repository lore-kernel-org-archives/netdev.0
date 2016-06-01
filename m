From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 03/12] net: cls_bpf: limit hardware offload by software-only
 flag
Date: Wed, 01 Jun 2016 21:40:23 +0200
Message-ID: <574F3A27.5050208@iogearbox.net>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com> <1464799814-4453-4-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54478 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbcFATkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 15:40:25 -0400
In-Reply-To: <1464799814-4453-4-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2016 06:50 PM, Jakub Kicinski wrote:
> Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_HW flag.
> Unlike U32 and flower cls_bpf already has some netlink
> flags defined.  I chose to create a new attribute to be
> able to use the same flag values as the above.

Yeah, that's totally fine to make it a new flag attribute.

> Unknown flags are ignored and not reported upon dump.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

[...]
> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
> index f4297c8a42fe..93a86edf3bd8 100644
> --- a/include/uapi/linux/pkt_cls.h
> +++ b/include/uapi/linux/pkt_cls.h
> @@ -395,6 +395,7 @@ enum {
>   	TCA_BPF_FD,
>   	TCA_BPF_NAME,
>   	TCA_BPF_FLAGS,
> +	TCA_BPF_GEN_TCA_FLAGS,

Small nit for the non-RFC set: I'd simply name that TCA_BPF_FLAGS_GEN.

>   	__TCA_BPF_MAX,
>   };
>
[...]
> @@ -400,8 +406,11 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
>
>   		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
>   	}
> +	if (tb[TCA_BPF_GEN_TCA_FLAGS])
> +		gen_flags = nla_get_u32(tb[TCA_BPF_GEN_TCA_FLAGS]);
>
>   	prog->exts_integrated = have_exts;
> +	prog->gen_flags = gen_flags & CLS_BPF_SUPPORTED_GEN_FLAGS;

Invalid flags should probably be rejected here with -EINVAL or something.

>   	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
>   		       cls_bpf_prog_from_efd(tb, prog, tp);
> @@ -568,6 +577,9 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
>   		bpf_flags |= TCA_BPF_FLAG_ACT_DIRECT;
>   	if (bpf_flags && nla_put_u32(skb, TCA_BPF_FLAGS, bpf_flags))
>   		goto nla_put_failure;
> +	if (prog->gen_flags &&
> +	    nla_put_u32(skb, TCA_BPF_GEN_TCA_FLAGS, prog->gen_flags))
> +		goto nla_put_failure;
>
>   	nla_nest_end(skb, nest);
>
>

Otherwise looks good:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
