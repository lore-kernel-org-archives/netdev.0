From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next] bpf/verifier: track liveness
	for pruning
Date: Thu, 17 Aug 2017 20:21:41 -0700
Message-ID: <89ff34f7-84ee-0e0a-3766-5b4d046189bf@fb.com>
References: <f40d3d54-c88a-7348-99ca-66db8075a8d5@solarflare.com>
Reply-To: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei
	Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Borkmann
	<daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <f40d3d54-c88a-7348-99ca-66db8075a8d5-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On 8/15/17 12:34 PM, Edward Cree wrote:
> State of a register doesn't matter if it wasn't read in reaching an exit;
>  a write screens off all reads downstream of it from all explored_states
>  upstream of it.
> This allows us to prune many more branches; here are some processed insn
>  counts for some Cilium programs:
> Program                  before  after
> bpf_lb_opt_-DLB_L3.o       6515   3361
> bpf_lb_opt_-DLB_L4.o       8976   5176
> bpf_lb_opt_-DUNKNOWN.o     2960   1137
> bpf_lxc_opt_-DDROP_ALL.o  95412  48537
> bpf_lxc_opt_-DUNKNOWN.o  141706  78718
> bpf_netdev.o              24251  17995
> bpf_overlay.o             10999   9385
>
> The runtime is also improved; here are 'time' results in ms:
> Program                  before  after
> bpf_lb_opt_-DLB_L3.o         24      6
> bpf_lb_opt_-DLB_L4.o         26     11
> bpf_lb_opt_-DUNKNOWN.o       11      2
> bpf_lxc_opt_-DDROP_ALL.o   1288    139
> bpf_lxc_opt_-DUNKNOWN.o    1768    234
> bpf_netdev.o                 62     31
> bpf_overlay.o                15     13
>
> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>

this is one ingenious hack. Love it!
I took me whole day to understand most of it, but I still have
few questions:

> +
> +static void propagate_liveness(const struct bpf_verifier_state *state,
> +			       struct bpf_verifier_state *parent)

here the name 'parent' is very confusing, since for the first
iteration of the loop below it transfers lives from 'neighbor'
state to the current state and only then traverses the link
of parents in the current.
Would be good to document it, since I was struggling the most
with this name until I realized that the way you build parent link list
in is_state_visited() is actual sequence of roughly basic blocks and
the name 'parent' applies there, but not for the first iteration
of this function.

> @@ -3407,6 +3501,14 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
>  	memcpy(&new_sl->state, &env->cur_state, sizeof(env->cur_state));
>  	new_sl->next = env->explored_states[insn_idx];
>  	env->explored_states[insn_idx] = new_sl;
> +	/* connect new state to parentage chain */
> +	env->cur_state.parent = &new_sl->state;
> +	/* clear liveness marks in current state */
> +	for (i = 0; i < BPF_REG_FP; i++)
> +		env->cur_state.regs[i].live = REG_LIVE_NONE;
> +	for (i = 0; i < MAX_BPF_STACK / BPF_REG_SIZE; i++)
> +		if (env->cur_state.stack_slot_type[i * BPF_REG_SIZE] == STACK_SPILL)
> +			env->cur_state.spilled_regs[i].live = REG_LIVE_NONE;

and this part I don't get at all.
It seems you're trying to sort-of do per-fake-basic block liveness
analysis, but our state_list_marks are not correct if we go with
canonical basic block definition, since we mark the jump insn and
not insn after the branch and not every basic block boundary is
properly detected.
So if algorithm should only work for basic blocks (for sequences of
instructions without control flow changes) then it's broken.
If it should work with control flow insns then it should also work
for the whole chain of insns from the first one till bpf_exit...
So I tried removing two above clearing loops and results are much
better:
                         before  after
bpf_lb-DLB_L3.o         2604    1120
bpf_lb-DLB_L4.o         11159   1371
bpf_lb-DUNKNOWN.o       1116    485
bpf_lxc-DDROP_ALL.o     34566   12758
bpf_lxc-DUNKNOWN.o      53267   18337
bpf_netdev.o            17843   10564
bpf_overlay.o           8672    5513

but it feels too good to be true and probably not correct.
So either way we need to fix something it seems.
