From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v1] bpf: Set register type according to is_valid_access()
Date: Thu, 22 Sep 2016 21:41:36 +0200
Message-ID: <57E433F0.90407@iogearbox.net>
References: <20160922183512.13576-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Kees Cook <keescook@chromium.org>,
        Sargun Dhillon <sargun@sargun.me>, Tejun Heo <tj@kernel.org>,
        netdev@vger.kernel.org
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160922183512.13576-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/22/2016 08:35 PM, Mickaël Salaün wrote:
> This fix a pointer leak when an unprivileged eBPF program read a pointer
> value from the context. Even if is_valid_access() returns a pointer
> type, the eBPF verifier replace it with UNKNOWN_VALUE. The register
> value containing an address is then allowed to leak. Moreover, this
> prevented unprivileged eBPF programs to use functions with (legitimate)
> pointer arguments.
>
> This bug is not an issue for now because the only unprivileged eBPF
> program allowed is of type BPF_PROG_TYPE_SOCKET_FILTER and all the types
> from its context are UNKNOWN_VALUE. However, this fix is important for
> future unprivileged eBPF program types which could use pointers in their
> context.
>
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Fixes: 969bf05eb3ce ("bpf: direct packet access")
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Kees Cook <keescook@chromium.org>
> Acked-by: Sargun Dhillon <sargun@sargun.me>
> ---
>   kernel/bpf/verifier.c | 6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index daea765d72e6..0698ccd67715 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -794,10 +794,8 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
>   		}
>   		err = check_ctx_access(env, off, size, t, &reg_type);
>   		if (!err && t == BPF_READ && value_regno >= 0) {
> -			mark_reg_unknown_value(state->regs, value_regno);
> -			if (env->allow_ptr_leaks)
> -				/* note that reg.[id|off|range] == 0 */
> -				state->regs[value_regno].type = reg_type;
> +			/* note that reg.[id|off|range] == 0 */
> +			state->regs[value_regno].type = reg_type;

True that it's not an issue currently, since reg_type is only set for
PTR_TO_PACKET/PTR_TO_PACKET_END in xdp and tc programs that can only be
loaded as privileged. So not an issue for BPF_PROG_TYPE_SOCKET_FILTER.

One thing I don't quite follow is why you remove the mark_reg_unknown_value()
as this also clears imm? I think this could result in an actual verifier
bug when it would reuse previous tracked imm value of that dst register?

>   		}
>
>   	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
>
