From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v10 11/12] bpf: enable direct packet data write for xdp
 progs
Date: Tue, 19 Jul 2016 14:59:32 -0700
Message-ID: <20160719215931.GG64618@ast-mbp.thefacebook.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-12-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33456 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbcGSV7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 17:59:42 -0400
Received: by mail-pa0-f66.google.com with SMTP id q2so2009841pap.0
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 14:59:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1468955817-10604-12-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 12:16:56PM -0700, Brenden Blanco wrote:
> For forwarding to be effective, XDP programs should be allowed to
> rewrite packet data.
> 
> This requires that the drivers supporting XDP must all map the packet
> memory as TODEVICE or BIDIRECTIONAL before invoking the program.
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>  kernel/bpf/verifier.c | 17 ++++++++++++++++-
>  1 file changed, 16 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index a8d67d0..f72f23b 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -653,6 +653,16 @@ static int check_map_access(struct verifier_env *env, u32 regno, int off,
>  
>  #define MAX_PACKET_OFF 0xffff
>  
> +static bool may_write_pkt_data(enum bpf_prog_type type)
> +{
> +	switch (type) {
> +	case BPF_PROG_TYPE_XDP:
> +		return true;
> +	default:
> +		return false;
> +	}
> +}
> +
>  static int check_packet_access(struct verifier_env *env, u32 regno, int off,
>  			       int size)
>  {
> @@ -806,10 +816,15 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
>  			err = check_stack_read(state, off, size, value_regno);
>  		}
>  	} else if (state->regs[regno].type == PTR_TO_PACKET) {
> -		if (t == BPF_WRITE) {
> +		if (t == BPF_WRITE && !may_write_pkt_data(env->prog->type)) {
>  			verbose("cannot write into packet\n");
>  			return -EACCES;
>  		}
> +		if (t == BPF_WRITE && value_regno >= 0 &&
> +		    is_pointer_value(env, value_regno)) {
> +			verbose("R%d leaks addr into packet\n", value_regno);
> +			return -EACCES;
> +		}

Like this extra security check :) though it's arguably overkill.

Acked-by: Alexei Starovoitov <ast@kernel.org>
