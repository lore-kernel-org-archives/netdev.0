From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Bug with BPF_ALU64 | BPF_END?
Date: Fri, 15 Sep 2017 01:04:49 +0200
Message-ID: <59BB0B11.9090304@iogearbox.net>
References: <52c7df55-84d9-f6d2-ed84-51ac90eb6bcc@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>, Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37829 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751380AbdINXFC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 19:05:02 -0400
In-Reply-To: <52c7df55-84d9-f6d2-ed84-51ac90eb6bcc@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2017 07:53 PM, Edward Cree wrote:
> Is BPF_END supposed to only be used with BPF_ALU, never with BPF_ALU64?
> In kernel/bpf/core.c:___bpf_prog_run(), there are only jump table targets
>   for the BPF_ALU case, not for the BPF_ALU64 case (opcodes 0xd7 and 0xdf).
> But the verifier doesn't enforce this; by crafting a program that uses
>   these opcodes I can get a WARN when they're run (without JIT; it looks
>   like the x86 JIT, at least, won't like it either).
> Proposed patch below the cut; build-tested only.
>
> -Ed
> ---
>
> [PATCH net] bpf/verifier: reject BPF_ALU64|BPF_END
>
> Neither ___bpf_prog_run nor the JITs accept it.
>
> Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Good catch! Can you submit this as an official patch for -net together
with a test case for tools/testing/selftests/bpf/test_verifier.c?

Thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

> ---
>   kernel/bpf/verifier.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 477b693..799b245 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -2292,7 +2292,8 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
>   			}
>   		} else {
>   			if (insn->src_reg != BPF_REG_0 || insn->off != 0 ||
> -			    (insn->imm != 16 && insn->imm != 32 && insn->imm != 64)) {
> +			    (insn->imm != 16 && insn->imm != 32 && insn->imm != 64) ||
> +			    BPF_CLASS(insn->code) == BPF_ALU64) {
>   				verbose("BPF_END uses reserved fields\n");
>   				return -EINVAL;
>   			}
>
