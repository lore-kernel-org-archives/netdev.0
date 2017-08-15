From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v2 net-next] bpf/verifier: track liveness
	for pruning
Date: Tue, 15 Aug 2017 19:06:34 +0100
Message-ID: <b3fafbb2-d24b-c4b6-8bca-83bc823b03c1@solarflare.com>
References: <3c245ef4-3161-0e5a-3708-6b9b47db01cd@solarflare.com>
	<5993226A.9010704@iogearbox.net>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Alexei
	Starovoitov" <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <5993226A.9010704-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On 15/08/17 17:33, Daniel Borkmann wrote:
> On 08/15/2017 03:53 PM, Edward Cree wrote:
>> State of a register doesn't matter if it wasn't read in reaching an exit;
>>   a write screens off all reads downstream of it from all explored_states
>>   upstream of it.
>> This allows us to prune many more branches; here are some processed insn
>>   counts for some Cilium programs:
>> Program                  before  after
>> bpf_lb_opt_-DLB_L3.o       6515   3361
>> bpf_lb_opt_-DLB_L4.o       8976   5176
>> bpf_lb_opt_-DUNKNOWN.o     2960   1137
>> bpf_lxc_opt_-DDROP_ALL.o  95412  48537
>> bpf_lxc_opt_-DUNKNOWN.o  141706  78718
>> bpf_netdev.o              24251  17995
>> bpf_overlay.o             10999   9385
>>
>> The runtime is also improved; here are 'time' results in ms:
>> Program                  before  after
>> bpf_lb_opt_-DLB_L3.o         24      6
>> bpf_lb_opt_-DLB_L4.o         26     11
>> bpf_lb_opt_-DUNKNOWN.o       11      2
>> bpf_lxc_opt_-DDROP_ALL.o   1288    139
>> bpf_lxc_opt_-DUNKNOWN.o    1768    234
>> bpf_netdev.o                 62     31
>> bpf_overlay.o                15     13
>>
>> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
> [...]
>> @@ -1639,10 +1675,13 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
>>       }
>>
>>       /* reset caller saved regs */
>> -    for (i = 0; i < CALLER_SAVED_REGS; i++)
>> +    for (i = 0; i < CALLER_SAVED_REGS; i++) {
>>           mark_reg_not_init(regs, caller_saved[i]);
>> +        check_reg_arg(env, i, DST_OP_NO_MARK);
>
> Ah, I oversaw that earlier, this needs to be: s/i/caller_saved[i]/
So it does.  Of course testing didn't spot this, because
 caller_saved[i] == i currently.
>> +    }
>>
>>       /* update return register */
>> +    check_reg_arg(env, BPF_REG_0, DST_OP_NO_MARK);
>
> We could leave this for clarity, but ...
Yeah, I'll replace it with a comment, like the other one.
Thanks for review :)

-Ed
