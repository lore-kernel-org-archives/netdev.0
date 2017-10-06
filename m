From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf: fix liveness marking
Date: Fri, 6 Oct 2017 09:43:27 -0700
Message-ID: <0445f2ed-01c7-5256-955d-92b0201648f0@fb.com>
References: <20171005232056.2234669-1-ast@fb.com>
 <759810f5-f6db-0439-1b2d-637cf83ac2f8@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Edward Cree <ecree@solarflare.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41224 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751654AbdJFQnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 12:43:53 -0400
In-Reply-To: <759810f5-f6db-0439-1b2d-637cf83ac2f8@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/6/17 9:33 AM, Edward Cree wrote:
> On 06/10/17 00:20, Alexei Starovoitov wrote:
>> while processing Rx = Ry instruction the verifier does
>> regs[insn->dst_reg] = regs[insn->src_reg]
>> which often clears write mark (when Ry doesn't have it)
>> that was just set by check_reg_arg(Rx) prior to the assignment.
>> That causes mark_reg_read() to keep marking Rx in this block as
>> REG_LIVE_READ (since the logic incorrectly misses that it's
>> screened by the write) and in many of its parents (until lucky
>> write into the same Rx or beginning of the program).
>> That causes is_state_visited() logic to miss many pruning opportunities.
> Good catch!
>> Furthermore mark_reg_read() logic propagates the read mark
>> for BPF_REG_FP as well (though it's readonly) which causes
>> harmless but unnecssary work during is_state_visited().
> Surely it's unnecessary for is_state_visited() to even look at
>  BPF_REG_FP anyway, so in addition to your change we could make
>  states_equal just do `for (i = 0; i < BPF_REG_FP; i++)`?  That
>  might save a bit more time.

yeah. before this patch it was doing extra
memcmp(rold, rcur, ..) on FP reg. This patch saves this memcpy.
The i < BPF_REG_FP would effectively do the same, but I'm not sure
I want to do it just yet.
For net-next I have a bunch of changes for verifier to support bpf_call
and there two different states may have two different FPs.
One FP from caller and one from callee.
So I might still need to do full
for (i = 0; i < MAX_BPF_REG; i++)
      if (!regsafe(..))

>> Note that do_propagate_liveness() skips FP correctly,
>> so do the same in mark_reg_read() as well.
>> It saves 0.2 seconds for the test below
>>
>> program               before  after
>> bpf_lb-DLB_L3.o       2604    2304
>> bpf_lb-DLB_L4.o       11159   3723
>> bpf_lb-DUNKNOWN.o     1116    1110
>> bpf_lxc-DDROP_ALL.o   34566   28004
>> bpf_lxc-DUNKNOWN.o    53267   39026
>> bpf_netdev.o          17843   16943
>> bpf_overlay.o         8672    7929
>> time                  ~11 sec  ~4 sec
>>
>> Fixes: dc503a8ad984 ("bpf/verifier: track liveness for pruning")
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Very nice numbers!
> Acked-by: Edward Cree <ecree@solarflare.com>

Thanks!
