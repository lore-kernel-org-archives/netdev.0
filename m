From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 2/6] bpf: introduce BPF_PROG_TYPE_PERF_EVENT
 program type
Date: Thu, 1 Sep 2016 09:44:52 +0200
Message-ID: <20160901074452.GK10153@twins.programming.kicks-ass.net>
References: <1472680243-1326608-1-git-send-email-ast@fb.com>
 <1472680243-1326608-3-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472680243-1326608-3-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 31, 2016 at 02:50:39PM -0700, Alexei Starovoitov wrote:
> +static u32 pe_prog_convert_ctx_access(enum bpf_access_type type, int dst_reg,
> +				      int src_reg, int ctx_off,
> +				      struct bpf_insn *insn_buf,
> +				      struct bpf_prog *prog)
> +{
> +	struct bpf_insn *insn = insn_buf;
> +
> +	BUILD_BUG_ON(FIELD_SIZEOF(struct perf_sample_data, period) != sizeof(u64));
> +	switch (ctx_off) {
> +	case offsetof(struct bpf_perf_event_data, sample_period):
> +		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct bpf_perf_event_data_kern, data)),
> +				      dst_reg, src_reg,
> +				      offsetof(struct bpf_perf_event_data_kern, data));
> +		*insn++ = BPF_LDX_MEM(BPF_DW, dst_reg, dst_reg,
> +				      offsetof(struct perf_sample_data, period));
> +		break;

OK, so that deals with us moving the period field in the structure, and
break compile if we'd change its size or remove it outright (highly
unlikely). In that latter case we can change this code to simply return
a (u64)0 and things would continue to 'work'.

Did I understand that correctly?
