From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 10:51:22 -0800
Message-ID: <20160112185121.GA34045@ast-mbp.thefacebook.com>
References: <1452621307-2213-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ast@kernel.org,
	daniel@iogearbox.net, linux-arm-kernel@lists.infradead.org
To: Rabin Vincent <rabin@rab.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34410 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbcALSv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 13:51:27 -0500
Received: by mail-pa0-f53.google.com with SMTP id uo6so327602946pac.1
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 10:51:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452621307-2213-1-git-send-email-rabin@rab.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 06:55:07PM +0100, Rabin Vincent wrote:
> On ARM64, a BUG() is triggered in the eBPF JIT if a filter with a
> constant shift that can't be encoded in the immediate field of the
> UBFM/SBFM instructions is passed to the JIT.  Since these shifts
> amounts, which are negative or >= regsize, are invalid, reject then in
> the eBPF verifier and the classic BPF filter checker, for all
> architectures.
> 
> Signed-off-by: Rabin Vincent <rabin@rab.in>
> ---
>  kernel/bpf/verifier.c | 10 ++++++++++
>  net/core/filter.c     |  5 +++++
>  2 files changed, 15 insertions(+)
> 
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index a7945d10b378..3643df0dfaa9 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1121,6 +1121,16 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
>  			return -EINVAL;
>  		}
>  
> +		if ((opcode == BPF_LSH || opcode == BPF_RSH) &&

Missing check for opcode == BPF_ARSH

Otherwise looks good. Thank you for fixing this!

> @@ -777,6 +777,11 @@ static int bpf_check_classic(const struct sock_filter *filter,
>  			if (ftest->k == 0)
>  				return -EINVAL;
>  			break;
> +		case BPF_ALU | BPF_LSH | BPF_K:
> +		case BPF_ALU | BPF_RSH | BPF_K:

here it's good. ARSH is eBPF only.
