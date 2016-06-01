From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 05/12] nfp: add BPF to NFP code translator
Date: Wed, 01 Jun 2016 22:03:04 +0200
Message-ID: <574F3F78.1010606@iogearbox.net>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com> <1464799814-4453-6-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56775 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbcFAUDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 16:03:06 -0400
In-Reply-To: <1464799814-4453-6-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2016 06:50 PM, Jakub Kicinski wrote:
> Add translator for JITing eBPF to operations which
> can be executed on NFP's programmable engines.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
[...]
> +int
> +nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem, unsigned int prog_start,
> +	    unsigned int tgt_out, unsigned int tgt_abort,
> +	    unsigned int prog_sz, struct nfp_bpf_result *res)
> +{
> +	struct nfp_prog *nfp_prog;
> +	int ret;
> +
> +	/* TODO: maybe make this dependent on bpf_jit_enable? */

Probably makes sense to leave it independent from this.

Maybe that would rather be an ethtool flag/setting?

> +	nfp_prog = kzalloc(sizeof(*nfp_prog), GFP_KERNEL);
> +	if (!nfp_prog)
> +		return -ENOMEM;
> +
> +	INIT_LIST_HEAD(&nfp_prog->insns);
> +	nfp_prog->start_off = prog_start;
> +	nfp_prog->tgt_out = tgt_out;
> +	nfp_prog->tgt_abort = tgt_abort;
> +
> +	ret = nfp_prog_prepare(nfp_prog, filter->insnsi, filter->len);
> +	if (ret)
> +		goto out;
> +
> +	nfp_bpf_optimize(nfp_prog);
> +
> +	nfp_prog->prog = prog_mem;
> +	nfp_prog->__prog_alloc_len = prog_sz;
> +
> +	ret = nfp_translate(nfp_prog);
> +	if (ret) {
> +		pr_err("Translation failed with error %d (translated: %u)\n",
> +		       ret, nfp_prog->n_translated);
> +		ret = -EINVAL;
> +	}
> +
> +	res->n_instr = nfp_prog->prog_len;
> +out:
> +	nfp_prog_free(nfp_prog);
> +
> +	return ret;
> +}
>
