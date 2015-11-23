From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/6] kcm: Kernel Connection Multiplexor module
Date: Mon, 23 Nov 2015 10:42:10 +0100
Message-ID: <5652DF72.6060004@iogearbox.net>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com> <1448054520-1464587-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, davewatson@fb.com, alexei.starovoitov@gmail.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58403 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbbKWKIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 05:08:17 -0500
In-Reply-To: <1448054520-1464587-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2015 10:21 PM, Tom Herbert wrote:
[...]
> +
> +/* Macro to invoke filter function. */
> +#define KCM_RUN_FILTER(prog, ctx) \
> +	(*prog->bpf_func)(ctx, prog->insnsi)

Any reason to redefine this macro?

We already have the same one as:

#define BPF_PROG_RUN(filter, ctx)  (*filter->bpf_func)(ctx, filter->insnsi)

[...]
> +static int kcm_attach_ioctl(struct socket *sock, struct kcm_attach *info)
> +{
> +	struct socket *csock;
> +	struct bpf_prog *prog;
> +	int err;
> +
> +	csock = sockfd_lookup(info->fd, &err);
> +	if (!csock)
> +		return -ENOENT;
> +
> +	prog = bpf_prog_get(info->bpf_fd);
> +	if (IS_ERR(prog)) {
> +		err = PTR_ERR(prog);
> +		goto out;
> +	}
> +
> +	if (prog->type != BPF_PROG_TYPE_SOCKET_FILTER) {
> +		bpf_prog_put(prog);

I'd move this and the below bpf_prog_put() under out_put label, too.

> +		err = -EINVAL;
> +		goto out;
> +	}
> +
> +	err = kcm_attach(sock, csock, prog);
> +	if (err) {
> +		bpf_prog_put(prog);

                 ^^^

> +		goto out;
> +	}
> +
> +	/* Keep reference on file also */
> +
> +	return 0;
> +out:
> +	fput(csock->file);
> +	return err;
> +}
[...]
