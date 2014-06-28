From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 08/14] bpf: add eBPF verifier
Date: Sat, 28 Jun 2014 13:25:23 -0700
Message-ID: <CAMEtUuzq4ib6MFAsp_ZpBisRa=XFUgKkX7OwwrEoOfw7O1YXCQ@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-9-git-send-email-ast@plumgrid.com>
	<CALCETrV+uTamX2BShHsHnwTr4R7+MSQXX8bXe=2Xo1hbiSAipQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrV+uTamX2BShHsHnwTr4R7+MSQXX8bXe=2Xo1hbiSAipQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 28, 2014 at 9:01 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Fri, Jun 27, 2014 at 5:06 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> Safety of eBPF programs is statically determined by the verifier, which detects:
>
> This is a very high-level review.  I haven't tried to read all the
> code yet, and this is mostly questions rather than real comments.

Great questions! :) Answers below:

>> - loops
>> - out of range jumps
>> - unreachable instructions
>> - invalid instructions
>> - uninitialized register access
>> - uninitialized stack access
>> - misaligned stack access
>> - out of range stack access
>> - invalid calling convention
>>
>> It checks that
>> - R1-R5 registers statisfy function prototype
>> - program terminates
>> - BPF_LD_ABS|IND instructions are only used in socket filters
>
> Why are these used in socket filters?  Can't ctx along with some
> accessor do the trick.

ld_abs/ind instructions are legacy instruction that assume that ctx == skb.
They're heavily used in classic bpf, so we cannot convert them to
anything else without hurting performance of libpcap. So here we
have two special instructions that are really wrappers of function calls
that can only be used when 'ctx == skb'.
bpf_prog_type_socket_filter means that 'ctx==skb', but it doesn't mean
that this is for attaching to sockets only. The same type can be used
in attaching eBPF programs to cls, xt, etc where input is skb.

> It seems to be that this is more or less a type system.  On entry to
> each instruction, each register has a type, and the instruction might
> change the types of the registers.

Exactly.

> So: what are the rules?  If I understand correctly, these are the types:

the types of registers change depending on instruction semantics.
If instruction is 'mov r1 = r5', then type of r5 is transferred to r1
and so on.

>> +       INVALID_PTR,                    /* reg doesn't contain a valid pointer */
>> +       PTR_TO_CTX,                     /* reg points to bpf_context */
>> +       PTR_TO_MAP,                     /* reg points to map element value */
>> +       PTR_TO_MAP_CONDITIONAL,         /* points to map element value or NULL */
>> +       PTR_TO_STACK,                   /* reg == frame_pointer */
>> +       PTR_TO_STACK_IMM,               /* reg == frame_pointer + imm */
>> +       PTR_TO_STACK_IMM_MAP_KEY,       /* pointer to stack used as map key */
>> +       PTR_TO_STACK_IMM_MAP_VALUE,     /* pointer to stack used as map elem */
>> +       RET_INTEGER,                    /* function returns integer */
>> +       RET_VOID,                       /* function returns void */
>> +       CONST_ARG,                      /* function expects integer constant argument */
>> +       CONST_ARG_MAP_ID,               /* int const argument that is used as map_id */
>> +       /* int const argument indicating number of bytes accessed from stack
>> +        * previous function argument must be ptr_to_stack_imm
>> +        */
>> +       CONST_ARG_STACK_IMM_SIZE,
>> +};

At the comment on top of this enum says:
/* types of values:
 * - stored in an eBPF register
 * - passed into helper functions as an argument
 * - returned from helper functions
 */

> One confusing thing here is that some of these are types and some are
> constraints.  I'm not sure this is necessary.  For example, RET_VOID

exactly. some are type of registers, some are argument constraints,
some are definitions of return types like (ret_*) types.
All three categories overlap. Therefore they're in one enum.
I can split it into three enums, but there will be duplicates and it will not
be any easier to read.

> is an odd name for VOID, and RET_INTEGER is an odd name for INTEGER.

RET_VOID means ' returns void' or as comment says 'function returns void'
It never appears as type of register. It's a type of return from a
function call.

> I think I'd have a much easier time understanding all of this if there
> were an explicit table for the transition rules.  There are a couple
> kinds of transitions.  The main one is kind of like a phi node: when
> two different control paths reach the same instruction, the types of
> each register presumably need to merge.  I would imagine rules like:
>
> VOID, anything -> VOID
> PTR_TO_MAP, PTR_TO_MAP_CONDITIONAL -> PTR_TO_MAP_CONDITIONAL
>
> Then there are arithmetic rules: if you try to add two values, it
> might be legal or illegal, and the result type needs to be known.

I sounds like you're proposing a large table of
[insn_opcode, type_x, type_y] -> type z
that won't work. Since many instruction use registers both as source
and as destination. So type changes are very specific to logic of the given
instructions and cannot be generalized into 'type transition table'.

> There are also things that happen on function entry and exit.  For
> example, unused argument slots presumably all turn into VOID.  All

Almost. Argument registers R1-R5 after function call turn into INVALID_PTR
type. RET_VOID type is a definition of return type from a function. It doesn't
appear as register type.

In particular this piece of code does it:
        /* reset caller saved regs */
        for (i = 0; i < CALLER_SAVED_REGS; i++) {
                reg = regs + caller_saved[i];
                reg->read_ok = false;     // mark R1-R5 as unreadable
                reg->ptr = INVALID_PTR;  // here all R1-R5 regs are
assigned a type
                reg->imm = 0xbadbad;
        }

        /* update return register */
        reg = regs + BPF_REG_0;
        if (fn->ret_type == RET_INTEGER) {
                reg->read_ok = true;
                reg->ptr = INVALID_PTR;
// here 'RET_INTEGER' return type is converted into INVALID_PTR type of register

        } else if (fn->ret_type != RET_VOID) {
                reg->read_ok = true;
                reg->ptr = fn->ret_type;
// and here PTR_TO_MAP_CONDITIONAL is being transferred
from function prototype into a register.
That's an overlap of different types that I was talking about.

Note, that registers most of the time have INVALID_PTR type, which
means the register has some value, but it's not a valid pointer.
For all arithmetic operations that's what we want to see.
We don't want to track arithmetic operations on pointers. It would
complicate verifier a lot. The only special case is the sequence:
mov r1 = r10
add r1, -20
1st insn copies r10 (which has PTR_TO_STACK) type into r1
and 2nd arithmetic instruction is pattern matched to recognize
that it wants to construct a pointer to some element within stack.
So after 'add r1, -20', the register r1 has type PTR_TO_STACK_IMM
(and -20 constant is remembered as well).
Meaning that this reg is a pointer to stack plus known immediate constant.
Relevant comments from bpf.h header file:
        PTR_TO_STACK,                   /* reg == frame_pointer */
        PTR_TO_STACK_IMM,               /* reg == frame_pointer + imm */

> PTR_TO_MAP seems odd.  Shouldn't that just be PTR_TO_MEM?  And for these:

When program is doing load or store insns the type of base register can only be:
PTR_TO_MAP, PTR_TO_CTX, PTR_TO_STACK.
These are exactly three conditions in check_mem_access() function.

PTR_TO_MAP means that this register is pointing to 'map element value'
and the range of [ptr, ptr + map's value_size) is accessible.

>> +       PTR_TO_STACK_IMM_MAP_KEY,       /* pointer to stack used as map key */
>> +       PTR_TO_STACK_IMM_MAP_VALUE,     /* pointer to stack used as map elem */
>
> I don't understand at all.

PTR_TO_STACK_IMM_MAP_KEY is a function argument constraint.
It means that the register type passed to this function must be
PTR_TO_STACK_IMM and it will be used inside the function as
'pointer to map element key'

Here are the argument constraints for bpf_map_lookup_elem():
        [BPF_FUNC_map_lookup_elem] = {
                .ret_type = PTR_TO_MAP_CONDITIONAL,
                .arg1_type = CONST_ARG_MAP_ID,
                .arg2_type = PTR_TO_STACK_IMM_MAP_KEY,
        },
it says that this function returns 'pointer to map elem value or null'
1st argument must be 'constant immediate' value which must
be one of valid map_ids.
2nd argument is a pointer to stack, which will be used inside
the function as a pointer to map element key.

On the kernel side the function looks like:
u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
{
        struct bpf_map *map;
        int map_id = r1;
        void *key = (void *) (unsigned long) r2;
        void *value;

so here we can access 'key' pointer safely, knowing that
[key, key + map->key_size) bytes are valid and were initialized on
the stack of eBPF program.

The eBPF program looked like:
    BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
    // after this insn R2 type is PTR_TO_STACK

    BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4), /* r2 = fp - 4 */
    // after this insn R2 type is PTR_TO_STACK_IMM

    BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, MAP_ID), /* r1 = MAP_ID */
   // after this insn R1 type is CONST_ARG

    BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
here verifier looks a prototype of map_lookup_elem and sees:
1st arg should be CONST_ARG_MAP_ID
R1 type is CONST_ARG, which is ok so far,
then it goes and finds a map with map_id equal to R1->imm value
now verifier knows that this map has key of key_size bytes

2nd arg should be PTR_TO_STACK_IMM_MAP_KEY
and R2 type is PTR_TO_STACK_IMM, so far so good.
verifier now checks that [R2, R2+ map's key_size) are within stack
limits and were initialized prior to this call.

Here it the relevant comment from verifier.c that describes this:
 * Example: before the call to bpf_map_lookup_elem(),
 * R1 must contain integer constant and R2 PTR_TO_STACK_IMM_MAP_KEY
 * Integer constant in R1 is a map_id. The verifier checks that map_id is valid
 * and corresponding map->key_size fetched to check that
 * [R2, R2 + map_info->key_size) are within stack limits and all that stack
 * memory was initiliazed earlier by BPF program.

> Next question: how does bounds checking work?  Are you separately
> tracking the offset and associated bounds of each pointer?  How does

correct. verifier separately tracks bounds for every pointer type.

> bounds checking on PTR_TO_MAP work?

the way I described above.

> How about PTR_TO_STACK?  For that
> matter, why would pointer arithmetic on the stack be needed at all?

stack_ptr + imm is the only one that is tracked.
If eBPF program does 'r1 = r10; r1 -= 4;' this will not be recognized
by the verifier.
Why it only tracks 'add'? because I tuned LLVM backend to emit
stack pointer arithmetic only in this way.
Obviously stack arithmetic can be done in million different ways.
It's impractical to teach verifier to recognize all possible ways of
doing pointer arithmetic. So here you have this trade off.
In the future we can teach verifier to be smarter and recognize
more patterns, but let's start with the simplest design.

> ISTM it would be easier to have instructions to load and store a given
> local stack slot.

classic bpf has special ld/st instructions just to load/store from 32-bit
stack slots. I considered similar approach for eBPF, but it didn't
help verifier to be any simpler, complicated LLVM a lot and
complicated JITs. So I got rid of them and here we have only
generic ld/st instructions like normal CPUs do.

These were great questions! I hope I answered them. If not, please
continue asking.

Alexei
