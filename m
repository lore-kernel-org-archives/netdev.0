From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH v2 net-next 8/9] bpf: nfp: Report bpf_prog ID during
 XDP_QUERY_PROG
Date: Tue, 13 Jun 2017 16:52:32 -0700
Message-ID: <20170613165232.73a1a005@cakuba.netronome.com>
References: <20170613210841.509578-1-kafai@fb.com>
        <20170613210841.509578-9-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35106 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752854AbdFMXwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 19:52:35 -0400
Received: by mail-pg0-f44.google.com with SMTP id k71so67098910pgd.2
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 16:52:35 -0700 (PDT)
In-Reply-To: <20170613210841.509578-9-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Jun 2017 14:08:40 -0700, Martin KaFai Lau wrote:
> -	case XDP_QUERY_PROG:
> -		xdp->prog_attached = !!nn->dp.xdp_prog;
> +	case XDP_QUERY_PROG: {
> +		const struct bpf_prog *xdp_prog;
> +
> +		xdp_prog = nn->dp.xdp_prog;
> +		if (xdp_prog) {
> +			xdp->prog_id = xdp_prog->aux->id;
> +			xdp->prog_attached = true;
> +		} else {
> +			xdp->prog_id = 0;
> +			xdp->prog_attached = false;
> +		}
>  		return 0;
> +	}

I'm sorry to nit pick but it could be done on a single line:

	case XDP_QUERY_PROG:
		xdp->prog_attached = !!nn->dp.xdp_prog;
+		xdp->prog_id = nn->dp.xdp_prog ? nn->dp.xdp_prog->aux->id : 0;
 		return 0;
 	default:
 		return -EINVAL;


What would be even cooler is a helper like this:

static inline u32 bpf_prog_id(struct bpf_prog *prog)
{
	if (!prog)
		return 0;
	return prog->aux->id;
}

in linux/bpf.h.  

In patch 1 I would be tempted to add a new command for getting the prog
id, instead of muxing through query to avoid the output parameter?  But
I'm OK with the code as is, its just a preference rather than an objection :)
