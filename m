From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 01/12] bpf: verifier: set reg_type on context
 accesses in second pass
Date: Thu, 12 Oct 2017 22:43:10 +0200
Message-ID: <59DFD3DE.9050907@iogearbox.net>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com> <20171012173418.4029-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41428 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753877AbdJLUnO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 16:43:14 -0400
In-Reply-To: <20171012173418.4029-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2017 07:34 PM, Jakub Kicinski wrote:
> Use a simplified is_valid_access() callback when verifier
> is used for program analysis by non-host JITs.  This allows
> us to teach the verifier about packet start and packet end
> offsets for direct packet access.
>
> We can extend the callback as needed but for most packet
> processing needs there isn't much more the offloads may
> require.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---
> CC: alexei.starovoitov@gmail.com
> CC: daniel@iogearbox.net
>
>   kernel/bpf/verifier.c | 43 +++++++++++++++++++++++++++++++++++++------
>   1 file changed, 37 insertions(+), 6 deletions(-)
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 2cdbcc4f8f6b..9755279d94cb 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -813,6 +813,36 @@ static int check_packet_access(struct bpf_verifier_env *env, u32 regno, int off,
>   	return err;
>   }
>
> +static bool analyzer_is_valid_access(struct bpf_verifier_env *env, int off,
> +				     struct bpf_insn_access_aux *info)
> +{
> +	switch (env->prog->type) {
> +	case BPF_PROG_TYPE_XDP:
> +		switch (off) {
> +		case offsetof(struct xdp_buff, data):
> +			info->reg_type = PTR_TO_PACKET;
> +			return true;
> +		case offsetof(struct xdp_buff, data_end):
> +			info->reg_type = PTR_TO_PACKET_END;
> +			return true;
> +		}
> +		return false;
> +	case BPF_PROG_TYPE_SCHED_CLS:
> +		switch (off) {
> +		case offsetof(struct sk_buff, data):
> +			info->reg_type = PTR_TO_PACKET;
> +			return true;
> +		case offsetof(struct sk_buff, cb) +
> +		     offsetof(struct bpf_skb_data_end, data_end):
> +			info->reg_type = PTR_TO_PACKET_END;
> +			return true;
> +		}
> +		return false;
> +	default:
> +		return false;
> +	}
> +}
> +
>   /* check access to 'struct bpf_context' fields.  Supports fixed offsets only */
>   static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off, int size,
>   			    enum bpf_access_type t, enum bpf_reg_type *reg_type)
> @@ -821,12 +851,13 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
>   		.reg_type = *reg_type,
>   	};
>
> -	/* for analyzer ctx accesses are already validated and converted */
> -	if (env->analyzer_ops)
> -		return 0;
> -
> -	if (env->prog->aux->ops->is_valid_access &&
> -	    env->prog->aux->ops->is_valid_access(off, size, t, &info)) {
> +	if (env->analyzer_ops) {
> +		if (analyzer_is_valid_access(env, off, &info)) {
> +			*reg_type = info.reg_type;

Is there some specific issue with the is_valid_access() callbacks that you
need to do this (I couldn't parse that out of the commit message)? It would
be nice to keep the reg_type setting in one place, meaning the callbacks
themselves, so we wouldn't need to maintain this in multiple places.

> +			return 0;
> +		}
> +	} else if (env->prog->aux->ops->is_valid_access &&
> +		   env->prog->aux->ops->is_valid_access(off, size, t, &info)) {
>   		/* A non zero info.ctx_field_size indicates that this field is a
>   		 * candidate for later verifier transformation to load the whole
>   		 * field and then apply a mask when accessed with a narrower
>
