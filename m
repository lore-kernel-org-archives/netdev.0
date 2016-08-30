From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/6] bpf: introduce BPF_PROG_TYPE_PERF_EVENT
 program type
Date: Tue, 30 Aug 2016 02:14:52 +0200
Message-ID: <57C4CFFC.7010006@iogearbox.net>
References: <1472265084-1767670-1-git-send-email-ast@fb.com> <1472265084-1767670-3-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472265084-1767670-3-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/27/2016 04:31 AM, Alexei Starovoitov wrote:
> Introduce BPF_PROG_TYPE_PERF_EVENT programs that can be attached to
> HW and SW perf events (PERF_TYPE_HARDWARE and PERF_TYPE_SOFTWARE
> correspondingly in uapi/linux/perf_event.h)
>
> The program visible context meta structure is
> struct bpf_perf_event_data {
>      struct pt_regs regs;
>       __u64 sample_period;
> };
> which is accessible directly from the program:
> int bpf_prog(struct bpf_perf_event_data *ctx)
> {
>    ... ctx->sample_period ...
>    ... ctx->regs.ip ...
> }
>
> The bpf verifier rewrites the accesses into kernel internal
> struct bpf_perf_event_data_kern which allows changing
> struct perf_sample_data without affecting bpf programs.
> New fields can be added to the end of struct bpf_perf_event_data
> in the future.
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Two things I noticed below, otherwise for BPF bits:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

[...]
>
> +static bool pe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
> +				    enum bpf_reg_type *reg_type)
> +{
> +	if (off < 0 || off >= sizeof(struct bpf_perf_event_data))
> +		return false;
> +	if (type != BPF_READ)
> +		return false;
> +	if (off % size != 0)
> +		return false;
> +	if (off == offsetof(struct bpf_perf_event_data, sample_period) &&
> +	    size != sizeof(u64))
> +		return false;
> +	if (size != sizeof(long))
> +		return false;

Wouldn't this one rather need to be:

if (off == offsetof(struct bpf_perf_event_data, sample_period) {
	if (size != sizeof(u64))
		return false;
} else {
	if (size != sizeof(long))
		return false;
}

Otherwise on 32bit accessing sample_period might fail?

> +	return true;
> +}
> +
> +static u32 pe_prog_convert_ctx_access(enum bpf_access_type type, int dst_reg,
> +				      int src_reg, int ctx_off,
> +				      struct bpf_insn *insn_buf,
> +				      struct bpf_prog *prog)
> +{
> +	struct bpf_insn *insn = insn_buf;
> +
> +	switch (ctx_off) {
> +	case offsetof(struct bpf_perf_event_data, sample_period):

Would be good to add a test as we usually have done:

BUILD_BUG_ON(FIELD_SIZEOF(struct perf_sample_data, period) != 8);

> +		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct bpf_perf_event_data_kern, data)),
> +				      dst_reg, src_reg,
> +				      offsetof(struct bpf_perf_event_data_kern, data));
> +		*insn++ = BPF_LDX_MEM(BPF_DW, dst_reg, dst_reg,
> +				      offsetof(struct perf_sample_data, period));
> +		break;
> +	default:
> +		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct bpf_perf_event_data_kern, regs)),
> +				      dst_reg, src_reg,
> +				      offsetof(struct bpf_perf_event_data_kern, regs));
> +		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(sizeof(long)),
> +				      dst_reg, dst_reg, ctx_off);
> +		break;
> +	}
> +	return insn - insn_buf;
> +}
> +
