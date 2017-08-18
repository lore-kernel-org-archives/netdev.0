From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next] bpf/verifier: track liveness
	for pruning
Date: Fri, 18 Aug 2017 16:37:59 -0700
Message-ID: <5d4e12aa-6861-a176-a8cf-a766bbca0a7a@fb.com>
References: <f40d3d54-c88a-7348-99ca-66db8075a8d5@solarflare.com>
	<89ff34f7-84ee-0e0a-3766-5b4d046189bf@fb.com>
	<b8a46388-74ea-81f9-df08-3b6b88042229@solarflare.com>
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
In-Reply-To: <b8a46388-74ea-81f9-df08-3b6b88042229-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On 8/18/17 7:16 AM, Edward Cree wrote:
> On 18/08/17 04:21, Alexei Starovoitov wrote:
>> On 8/15/17 12:34 PM, Edward Cree wrote:
>>> State of a register doesn't matter if it wasn't read in reaching an exit;
>>>  a write screens off all reads downstream of it from all explored_states
>>>  upstream of it.
>>> This allows us to prune many more branches; here are some processed insn
>>>  counts for some Cilium programs:
>>> Program                  before  after
>>> bpf_lb_opt_-DLB_L3.o       6515   3361
>>> bpf_lb_opt_-DLB_L4.o       8976   5176
>>> bpf_lb_opt_-DUNKNOWN.o     2960   1137
>>> bpf_lxc_opt_-DDROP_ALL.o  95412  48537
>>> bpf_lxc_opt_-DUNKNOWN.o  141706  78718
>>> bpf_netdev.o              24251  17995
>>> bpf_overlay.o             10999   9385
>>>
>>> The runtime is also improved; here are 'time' results in ms:
>>> Program                  before  after
>>> bpf_lb_opt_-DLB_L3.o         24      6
>>> bpf_lb_opt_-DLB_L4.o         26     11
>>> bpf_lb_opt_-DUNKNOWN.o       11      2
>>> bpf_lxc_opt_-DDROP_ALL.o   1288    139
>>> bpf_lxc_opt_-DUNKNOWN.o    1768    234
>>> bpf_netdev.o                 62     31
>>> bpf_overlay.o                15     13
>>>
>>> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
>>
>> this is one ingenious hack. Love it!
>> I took me whole day to understand most of it, but I still have
>> few questions:
>>
>>> +
>>> +static void propagate_liveness(const struct bpf_verifier_state *state,
>>> +                   struct bpf_verifier_state *parent)
>>
>> here the name 'parent' is very confusing, since for the first
>> iteration of the loop below it transfers lives from 'neighbor'
>> state to the current state and only then traverses the link
>> of parents in the current.
>> Would be good to document it, since I was struggling the most
>> with this name until I realized that the way you build parent link list
>> in is_state_visited() is actual sequence of roughly basic blocks and
>> the name 'parent' applies there, but not for the first iteration
>> of this function.
> In the way I think about it, it really is a parent, by which I mean "a
>  block whose output registers are our inputs".  When we call
>  propagate_liveness(), we're saying "here's another block whose outputs
>  could be our inputs".  So while the 'state->parent' datastructure is a
>  linked list, the 'parentage' relationship is really a DAG.
> While 'state->parent' always has to point at an explored_state (which are
>  roughly immutable), the 'parent' we pass into propagate_liveness is just
>  env->cur_state which is mutable.  The weird "it's not actually
>  state->parent" comes from (a) there's only room for one state->parent and
>  (b) we didn't create a new_sl for it because we're pruning.
> I agree this is not at all explained in the code or comments, except for
>  the glib "Registers read by the continuation are read by us".  I will try
>  to write some comments and/or documentation explaining how and why the
>  liveness tracking works, because it _is_ subtle and a week from now _I_
>  probably won't understand it either.

a bit twisted, but yeah agree with this angle of thinking about it :)

>
>>> @@ -3407,6 +3501,14 @@ static int is_state_visited(struct bpf_verifier_env *env, int insn_idx)
>>>      memcpy(&new_sl->state, &env->cur_state, sizeof(env->cur_state));
>>>      new_sl->next = env->explored_states[insn_idx];
>>>      env->explored_states[insn_idx] = new_sl;
>>> +    /* connect new state to parentage chain */
>>> +    env->cur_state.parent = &new_sl->state;
>>> +    /* clear liveness marks in current state */
>>> +    for (i = 0; i < BPF_REG_FP; i++)
>>> +        env->cur_state.regs[i].live = REG_LIVE_NONE;
>>> +    for (i = 0; i < MAX_BPF_STACK / BPF_REG_SIZE; i++)
>>> +        if (env->cur_state.stack_slot_type[i * BPF_REG_SIZE] == STACK_SPILL)
>>> +            env->cur_state.spilled_regs[i].live = REG_LIVE_NONE;
>>
>> and this part I don't get at all.
> The idea behind the liveness marks is that 'writes go down and reads go up
>  and up'.  That is, each state 'tells' its parent state 'I read from you'
>  (which can then end up recursing), but it remembers for itself that it
>  wrote to a register and therefore should swallow subsequent reads rather
>  than forwarding them to its parent.
> While a block is being walked, its liveness marks _only_ record writes, and
>  then only writes _made in that block_.  The read marks go to the parent,
>  which is "some block that has been walked", but whose continuations haven't
>  all been walked yet so (by looplessness) won't show up as a pruning
>  opportunity.  An explored_state's liveness marks record the writes _done in
>  reaching that state_ from its parent, but the reads _done by the state's
>  children_.  A cur_state's liveness marks do the same, but it doesn't have
>  any children yet so it never gets read-marks (until it gets turned into an
>  explored_state, of course).
> We clear our liveness marks because the writes our parent block did are not
>  writes we did, so they don't screen off our reads from our parent;

got it. makes sense. would be good to document it.

>> It seems you're trying to sort-of do per-fake-basic block liveness
>> analysis, but our state_list_marks are not correct if we go with
>> canonical basic block definition, since we mark the jump insn and
>> not insn after the branch and not every basic block boundary is
>> properly detected.
> I think the reason this works is that jump insns can't do writes.
> Whenever we pop a branch and restore its register state, we _also_ restore
>  its parentage state.  Then if we decide to prune, we're saying that
>  whatever it takes to get from sl->state to an exit, we must also do.
> A read mark on sl->state says that in the process of getting to an exit, the
>  register was written before it was read.  A write mark on sl->state says
>  that the straight-line code resulting in sl->state wrote to the register,
>  so reads shouldn't propagate to its ->parent.  But by the time we're using
>  sl->state in is_state_visited(), its continuations have all been probed, so
>  it can never gain more reads, so its write marks are irrelevant; they
>  mustn't stop the state's reads propagating to new 'pruning parents' because
>  those didn't arrive at the state through the straight-line code.
> So maybe the first iteration through propagate_liveness() really _is_
>  special, and that if it were done differently (ignoring write marks) then
>  it really wouldn't matter at all where our state_list_marks were in
>  relation to the basic blocks.  But I _think_ that, because we mark jump
>  insns as well as their destinations (and a popped branch is always a
>  destination, rather than the 'insn after the branch'), the sl->state will
>  never have any write marks and it'll all just work.
> But I should really test that!

also makes sense.

>> So if algorithm should only work for basic blocks (for sequences of
>> instructions without control flow changes) then it's broken.
>> If it should work with control flow insns then it should also work
>> for the whole chain of insns from the first one till bpf_exit...
>> So I tried removing two above clearing loops and results are much
>> better:
>>                         before  after
>> bpf_lb-DLB_L3.o         2604    1120
>> bpf_lb-DLB_L4.o         11159   1371
>> bpf_lb-DUNKNOWN.o       1116    485
>> bpf_lxc-DDROP_ALL.o     34566   12758
>> bpf_lxc-DUNKNOWN.o      53267   18337
>> bpf_netdev.o            17843   10564
>> bpf_overlay.o           8672    5513
>>
>> but it feels too good to be true and probably not correct.
>> So either way we need to fix something it seems.
> Without that clearing, write marks will never be cleared, meaning that once
>  a register has been written to it will _never again_ forward a read.  Since
>  every register (except ctx and fp) must be written before it can be read,
>  no register (except ctx) will ever be marked as read, and all the branches
>  will be pruned away.
>
> Reads are a property of a state - roughly, "what do we read in getting from
>  this state to a BPF_EXIT?" - whereas writes are a property of a block,
>  "what do we write in getting from the parent to here?"
> Thus, reads may (indeed must) propagate (upwards), but writes must _never_
>  spread beyond the 'end-state' of their block.
>
> I hope this answers your questions, because I'm not entirely sure _I_
>  understand it either.  Or rather, when I think about it for an hour, it
>  makes sense for about fifteen seconds, and then it's gone again and all I
>  can remember is "write down, read up".

yes. thank a lot for explanation.
I've been playing with algo for the whole day and yes indeed it's
magically doesn't depend on proper basic block boundaries.
So having cfg jump into or out of a block of instructions actually
doesn't break the algo. My understanding this is correct, since
we only create such blocks at state_list_marks and we also check
for state equality at the same state_list_marks, so if control flow
jumps into the middle of the block, there is no equal state to find
and it will continue as normal.

I've tried moving state_list_mark all over the place. Made them
control flow accurate and it improved cilium prog load stats,
but not a lot, so I will hold on such patch for now.
Then I tried to add state_list_marks for every odd insn and
unfortunately it uncovered a bug in this liveness logic.
The following test can reproduce it with existing code (no extra hacks)
         {
                 "grr",
                 .insns = {
                         BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
                         BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
                         BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
                         BPF_LD_MAP_FD(BPF_REG_1, 0),
                         BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
                                      BPF_FUNC_map_lookup_elem),
                         BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 8),
                         BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, 0),
                         BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES),
                         BPF_JMP_REG(BPF_JSGT, BPF_REG_2, BPF_REG_1, 1),
                         BPF_MOV32_IMM(BPF_REG_1, 0),
                         BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
                         BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
                         BPF_JMP_IMM(BPF_JA, 0, 0, 0),
                         BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
                                    offsetof(struct test_val, foo)),
                         BPF_EXIT_INSN(),
                 },
                 .fixup_map2 = { 3 },
                 .errstr_unpriv = "R0 leaks addr",
                 .errstr = "R0 unbounded memory access",
                 .result_unpriv = REJECT,
                 .result = REJECT,
                 .flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
         },

the trick here is extra BPF_JMP_IMM(BPF_JA, 0, 0, 0)
which is a nop, but it forces our state_list_mark logic to
mark subsequent ST_MEM(DW) insn and liveness logic finds old
state at this insn and declares it equivalent.
The output looks like:
0: (7a) *(u64 *)(r10 -8) = 0
1: (bf) r2 = r10
2: (07) r2 += -8
3: (18) r1 = 0xffff880139d45200
5: (85) call bpf_map_lookup_elem#1
6: (15) if r0 == 0x0 goto pc+8
  R0=map_value(id=0,off=0,ks=8,vs=48,imm=0) R10=fp0
7: (79) r1 = *(u64 *)(r0 +0)
  R0=map_value(id=0,off=0,ks=8,vs=48,imm=0) R10=fp0
8: (b4) (u32) r2 = (u32) 11
9: (6d) if r2 s> r1 goto pc+1
  R0=map_value(id=0,off=0,ks=8,vs=48,imm=0) 
R1=inv(id=0,umin_value=11,umax_value=9223372036854775807,var_off=(0x0; 
0x7fffffffffffffff)) R2=inv11 R10=fp0
10: (b4) (u32) r1 = (u32) 0
11: (64) (u32) r1 <<= (u32) 2
12: (0f) r0 += r1
13: (05) goto pc+0
14: (7a) *(u64 *)(r0 +0) = 4
  R0=map_value(id=0,off=0,ks=8,vs=48,imm=0) R1=inv0 R2=inv11 R10=fp0
15: (95) exit

from 9 to 11: R0=map_value(id=0,off=0,ks=8,vs=48,imm=0) 
R1=inv(id=0,smax_value=10) R2=inv11 R10=fp0
11: (64) (u32) r1 <<= (u32) 2
12: (0f) r0 += r1
13: (05) goto pc+0
14: safe

from 6 to 15: R0=inv0 R10=fp0
15: (95) exit


that '14: safe' above is not correct.

Disabling liveness as:
@@ -3282,7 +3288,7 @@ static bool regsafe(struct bpf_reg_state *rold,
                     struct bpf_reg_state *rcur,
                     bool varlen_map_access, struct idpair *idmap)
  {
-       if (!(rold->live & REG_LIVE_READ))
+       if (0 && !(rold->live & REG_LIVE_READ))

makes the test work properly and proper verifier output is:
from 9 to 11: R0=map_value(id=0,off=0,ks=8,vs=48,imm=0) 
R1=inv(id=0,smax_value=10) R2=inv11 R10=fp0
11: (64) (u32) r1 <<= (u32) 2
12: (0f) r0 += r1
13: (05) goto pc+0
14: (7a) *(u64 *)(r0 +0) = 4
 
R0=map_value(id=0,off=0,ks=8,vs=48,umax_value=17179869180,var_off=(0x0; 
0x3fffffffc)) R1=inv(id=0,umax_value=17179869180,var_off=(0x0; 
0x3fffffffc)) R2=inv11 R10=fp0
R0 unbounded memory access, make sure to bounds check any array access 
into a map

I don't yet understand the underlying reason. R0 should have been
marked as LIVE_READ by ST_MEM...
Please help debug it further.
