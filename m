From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf: don't select potentially stale ri->map from
 buggy xdp progs
Date: Thu, 7 Sep 2017 15:37:17 -0700
Message-ID: <8adc9e5d-67cb-fa47-a564-166aacd06007@fb.com>
References: <01d69254802986ad3a8b18a8650c45df3df95def.1504821825.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <john.fastabend@gmail.com>, <brouer@redhat.com>,
        <andy@greyhouse.net>, <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46662 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932464AbdIGWhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 18:37:52 -0400
In-Reply-To: <01d69254802986ad3a8b18a8650c45df3df95def.1504821825.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/7/17 3:14 PM, Daniel Borkmann wrote:
> Fixes: 97f91a7cf04f ("bpf: add bpf_redirect_map helper routine")
> Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> ---
>  kernel/bpf/verifier.c | 16 ++++++++++++++++
>  net/core/filter.c     | 21 +++++++++++++++++++--
>  2 files changed, 35 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index d690c7d..477b693 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -4203,6 +4203,22 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
>  			continue;
>  		}
>
> +		if (insn->imm == BPF_FUNC_redirect_map) {
> +			u64 addr = (unsigned long)prog;
> +			struct bpf_insn r4_ld[] = {
> +				BPF_LD_IMM64(BPF_REG_4, addr),
> +				*insn,
> +			};
> +			cnt = ARRAY_SIZE(r4_ld);
> +
> +			new_prog = bpf_patch_insn_data(env, i + delta, r4_ld, cnt);

that's a neat trick.
I think we'll be seeing more of such pattern in the future.
Definitely less intrusive fix than asking drivers or net/core
to clear it.
Acked-by: Alexei Starovoitov <ast@kernel.org>
