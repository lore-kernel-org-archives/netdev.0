From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 06/12] nfp: add hardware cls_bpf offload
Date: Wed, 01 Jun 2016 22:20:54 +0200
Message-ID: <574F43A6.7000804@iogearbox.net>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com> <1464799814-4453-7-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58382 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbcFAUU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 16:20:58 -0400
In-Reply-To: <1464799814-4453-7-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2016 06:50 PM, Jakub Kicinski wrote:
> Add hardware cls_bpf offload on our smart NICs.  Detect if
> capable firmware is loaded and use it to load the code JITed
> with just added translator onto programmable engines.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
[...]
> +static int
> +nfp_net_bpf_offload_prepare(struct nfp_net *nn,
> +			    struct tc_cls_bpf_offload *cls_bpf,
> +			    struct nfp_bpf_result *res,
> +			    void **code, dma_addr_t *dma_addr, u16 max_instr)
> +{
> +	unsigned int code_sz = max_instr * sizeof(u64);
> +	u16 start_off, tgt_out, tgt_abort;
> +	const struct tc_action *a;
> +	int err;
> +
> +	if (tc_no_actions(cls_bpf->exts))
> +		return -EINVAL;
> +
> +	tc_for_each_action(a, cls_bpf->exts) {
> +		if (!is_tcf_gact_shot(a))
> +			return -EINVAL;
> +	}
> +
> +	if (cls_bpf->exts_integrated)
> +		return -EINVAL;

So cls_bpf has two working modes as mentioned: da (direct-action) and non-da.
Direct-action is I would say the most typical way to run cls_bpf as it allows
you to more naturally and efficiently code programs in the sense that classification
and action is already combined in a single program, so there's no additional
overhead of a linear action chain required, and a single program can already
have multiple action code outcomes (TC_ACT_OK, TC_ACT_SHOT, ...), so that it is
usually enough to run a single cls_bpf instance, for example, on sch_clsact
ingress or egress parent, nothing more than that to get the job done. I think
the cls_bpf->exts_integrated test could probably come first and if it's false,
we'd need to walk the actions?

> +	start_off = nn_readw(nn, NFP_NET_CFG_BPF_START);
> +	tgt_out = nn_readw(nn, NFP_NET_CFG_BPF_TGT_OUT);
> +	tgt_abort = nn_readw(nn, NFP_NET_CFG_BPF_TGT_ABORT);
> +
> +	*code = dma_zalloc_coherent(&nn->pdev->dev, code_sz, dma_addr,
> +				    GFP_KERNEL);
> +	if (!*code)
> +		return -ENOMEM;
> +
> +	err = nfp_bpf_jit(cls_bpf->filter, *code, start_off, tgt_out, tgt_abort,
> +			  max_instr, res);
> +	if (err)
> +		goto out;
> +
> +	return 0;
> +
> +out:
> +	dma_free_coherent(&nn->pdev->dev, code_sz, *code, *dma_addr);
> +	return err;
> +}
