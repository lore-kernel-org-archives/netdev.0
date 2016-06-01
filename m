From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 04/12] net: cls_bpf: add support for marking filters as
 hardware-only
Date: Wed, 01 Jun 2016 21:57:01 +0200
Message-ID: <574F3E0D.70103@iogearbox.net>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com> <1464799814-4453-5-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56213 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbcFAT5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 15:57:04 -0400
In-Reply-To: <1464799814-4453-5-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2016 06:50 PM, Jakub Kicinski wrote:
> Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_SW flag.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---
>   net/sched/cls_bpf.c | 39 +++++++++++++++++++++++++++++----------
>   1 file changed, 29 insertions(+), 10 deletions(-)
>
> diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
> index 9f1bc37dcbbc..1083910cebaf 100644
> --- a/net/sched/cls_bpf.c
> +++ b/net/sched/cls_bpf.c
> @@ -28,7 +28,7 @@ MODULE_DESCRIPTION("TC BPF based classifier");
>
>   #define CLS_BPF_NAME_LEN	256
>   #define CLS_BPF_SUPPORTED_GEN_FLAGS		\
> -	TCA_CLS_FLAGS_SKIP_HW
> +	(TCA_CLS_FLAGS_SKIP_HW | TCA_CLS_FLAGS_SKIP_SW)
>
>   struct cls_bpf_head {
>   	struct list_head plist;
> @@ -98,7 +98,9 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>
>   		qdisc_skb_cb(skb)->tc_classid = prog->res.classid;
>
> -		if (at_ingress) {
> +		if (tc_skip_sw(prog->gen_flags)) {
> +			filter_res = 0;

Seems okay to me, depending on the working mode of cls_bpf (da or non-da),
this either means TC_ACT_OK (== 0) or 'not classified'.

> +		} else if (at_ingress) {
>   			/* It is safe to push/pull even if skb_shared() */
>   			__skb_push(skb, skb->mac_len);
>   			bpf_compute_data_end(skb);

[...]
> @@ -406,8 +418,11 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
>
>   		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
>   	}
> -	if (tb[TCA_BPF_GEN_TCA_FLAGS])
> +	if (tb[TCA_BPF_GEN_TCA_FLAGS]) {
>   		gen_flags = nla_get_u32(tb[TCA_BPF_GEN_TCA_FLAGS]);
> +		if (!tc_flags_valid(gen_flags))
> +			return -EINVAL;
> +	}

Resolves my earlier comment, okay to put it here after supporting all flags.

>   	prog->exts_integrated = have_exts;
>   	prog->gen_flags = gen_flags & CLS_BPF_SUPPORTED_GEN_FLAGS;
> @@ -493,7 +508,11 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
>   	if (ret < 0)
>   		goto errout;

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
