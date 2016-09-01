From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 2/6] bpf: introduce BPF_PROG_TYPE_PERF_EVENT
 program type
Date: Thu, 01 Sep 2016 10:33:59 +0200
Message-ID: <57C7E7F7.5090304@iogearbox.net>
References: <1472680243-1326608-1-git-send-email-ast@fb.com> <1472680243-1326608-3-git-send-email-ast@fb.com> <20160901074452.GK10153@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Peter Zijlstra <peterz@infradead.org>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160901074452.GK10153@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/01/2016 09:44 AM, Peter Zijlstra wrote:
> On Wed, Aug 31, 2016 at 02:50:39PM -0700, Alexei Starovoitov wrote:
>> +static u32 pe_prog_convert_ctx_access(enum bpf_access_type type, int dst_reg,
>> +				      int src_reg, int ctx_off,
>> +				      struct bpf_insn *insn_buf,
>> +				      struct bpf_prog *prog)
>> +{
>> +	struct bpf_insn *insn = insn_buf;
>> +
>> +	BUILD_BUG_ON(FIELD_SIZEOF(struct perf_sample_data, period) != sizeof(u64));
>> +	switch (ctx_off) {
>> +	case offsetof(struct bpf_perf_event_data, sample_period):
>> +		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct bpf_perf_event_data_kern, data)),
>> +				      dst_reg, src_reg,
>> +				      offsetof(struct bpf_perf_event_data_kern, data));
>> +		*insn++ = BPF_LDX_MEM(BPF_DW, dst_reg, dst_reg,
>> +				      offsetof(struct perf_sample_data, period));
>> +		break;
>
> OK, so that deals with us moving the period field in the structure, and
> break compile if we'd change its size or remove it outright (highly
> unlikely). In that latter case we can change this code to simply return
> a (u64)0 and things would continue to 'work'.
>
> Did I understand that correctly?

Yes, if a program accesses sample_period member of the struct bpf_perf_event_data
context, then the verifier rewrites this into above two loads to eventually fetch
the struct perf_sample_data's period to the given target register. As you said,
should the period field change size (or get removed), compilation would break
so this doesn't get unnoticed and the code can be adapted along with it. In the
(hopefully very unlikely) case the member gets removed, it could be replaced with
loading 0 (or some other, better workaround to derive it, if possible).
