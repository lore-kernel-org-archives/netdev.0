From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: Re: [PATCH V1 1/1] NET: add a bpf jit for Alpha
Date: Thu, 5 Apr 2012 02:24:48 +0200
Message-ID: <4F7CE650.8020207@googlemail.com>
References: <4F75CA89.4010709@googlemail.com> <4F7A033D.4040901@googlemail.com> <4F7C5A65.7090504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Matt Evans <matt@ozlabs.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-arch@vger.kernel.org>, <linux-alpha@vger.kernel.org>
To: Richard Henderson <rth@redhat.com>
Return-path: <linux-alpha-owner@vger.kernel.org>
In-Reply-To: <4F7C5A65.7090504@redhat.com>
Sender: linux-alpha-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Henderson schrieb:

Thanks for the review Mr.Henderson. I'm so grateful you taken some of y=
our
valuable time for this.

> On 04/02/2012 03:51 PM, Jan Seiffert wrote:
[snip]
> You will never need NEGLI or SEXTLI, as both results can be had with =
LDA.
>=20

Removed

>> +static void load_complex_constant(u32 *image, struct codegen_contex=
t *ctx,
>> +				  unsigned int i, int K, int r)
>> +
>> +{
>> +	if (K =3D=3D 0) {
>> +		ALPHA_CLR(r);
>> +		return;
>> +	}
>> +	if (optimize_size =3D=3D 0 || constant_needs(K) < 2 ||
>> +	    i > (0x7fff/sizeof(struct sock_filter))) {
>> +		add_constant(image, ctx, K, r_zero, r);
>> +	} else {
>> +		/* load the constant from the filter program */
>> +		ALPHA_LDL(r_sf, (i * sizeof(struct sock_filter)) +
>> +			  offsetof(struct sock_filter, k), r);
>=20
> Worst case for constant loading is 3.  That's the same as the delay f=
or
> loading from memory.  Unless you're very concerned about translated s=
ize
> of the filter,

I'm unsure. The problem goes like this:
Since constant loading can take so much instructions, the code tends to
get big. This is bad for jump ranges, the icache and pinned kernel mem.
I would not mind about it (it's a RISC, it is meant to be that way), if
the constants weren't right there. We get the original filter program
(which contains the constants) passed as second parameter, on a silver
platter (i was even thinking about moving the second parameter 32k
forward to get the full imm16 range, on the other hand if struct
sock_filter is 8 byte on Alpha, then +32k is good enough for
MAX_BPF_INSN =3D=3D 4096).

Essentially this is two questions, one for the Alpha =C2=B5-arch gurus =
and=20
one for the kernel (net-)devs.
=C2=B5-Arch Gurus: How bad are mem accesses in contrast to icache for e=
xample.
Kernel devs: how important is memory consumption/how much "faster"
the jitted code has to be?

> I'd drop this condition and make your compiler run faster.
>=20
>=20
>> +	if (optimize_size =3D=3D 0 || constant_needs(K) < 2 ||
>> +	    i > (0x7fff/sizeof(struct sock_filter))) {
>> +		add_constant(image, ctx, K, r_A, r_t);
>> +		ALPHA_SEXTL(r_t, r_t);
>=20
> OTOH, this test should be simply is_imm8 and use ADDLI,
> else is_imm8(-K) use SUBLI, else load_constant ADDL.
>=20

add_constant takes care of that, only the entry condition is so
complicated because of the optimize_size case.

[snip - ugly and optimization]
>=20
> Really?

yes, i was typing as fast as i was thinking: "hmmm, a constant can
look like this or like that or like this...". The optimizations where a=
n
"afterthought", i first broke the operations out into a helper and simp=
ly
made it work. Because i knew there are some shenanigans you can do with
zapnot i revisited it at the end. I will now grab a brown paper bag.

>  This ought to be as simple as
>=20
>   mask =3D 0;
>   for (j =3D 0; j < 4; j++) {
>     int b =3D (K >> i*8) & 0xff;
>     if (b =3D=3D 0xff)
>       mask |=3D 1 << i;
>     else if (b !=3D 0)
>       mask =3D -1;
>   }
>   if (mask !=3D -1) {
>     ALPHA_ZAPNOTI(r_A, mask, r_t);
>     return;
>   }
>=20

Works like a charm, only had to change i for j. Thanks!

[snip - or 0xffffffff]
>=20
> Really?  Think about what you're doing here.  LDA(r_A, -1)
>=20

changed

[snip]
>> +		if (off =3D=3D 0)
>> +			ALPHA_ZEXTW(r, r);
>> +		else
>> +			ALPHA_EXTWLI(r, off, r);
>=20
> No point in the off=3D=3D0 special case.
>=20

I was thinking maybe the zapnot^wzextw is faster, because it does not
have to do the shift and it should be the common case.
But if extw is good enough, thus removed.

>> +static void emit_call(u32 *image, struct codegen_context *ctx,
>> +		      void *func, int r)
>> +{
>> +	ptrdiff_t disp =3D (char *)func - (char *)&image[ctx->idx + 1];
>> +	if (disp >=3D -2147483648 && disp <=3D 2147483647) {
>> +		if (is_imm_jdisp(disp)) {
>> +			ALPHA_BSR(r, disp);
>> +			return;
>> +		}
>=20
> Is this known to be calling another BPF function, and not back into C=
?
> Otherwise you've got an error in PV handling for the calling conventi=
on.
>=20

It is known to either call special bpf helper or __divlu (the kernel
version). The special helper are responsible for setting pv right when
they have to call to C again (which is deemed as the exceptional case).

That was my idea, so i don't have to set pv again after every call,
which would bloat up every filter program.

But i don't know if the helper do the "pv and call and gp"-dance right =
:(

[snip - div 0 test]
>=20
> Re-order these to clear r_ret before the cjmp and you don't need
> the branch-around branch.
>=20

Can't do.
When building the program we are searching for a ret 0 case.
As long as no case is found (or is never found), we have to build one.

Besides, i know it's dirty, r_ret and r_A share the same register.
I was squeezing on the register usage so i may use the register as
storage for the 16 bpf mem[] slots like powerpc, i mean Alpha has
31 like powerpc. But in the end i was to stupid to achieve this.
At least this hack saves a mov at the end.

>> +		case BPF_S_ALU_LSH_X: /* A <<=3D X; */
>> +			ctx->seen |=3D SEEN_XREG;
>> +			ALPHA_SLL(r_A, r_X, r_A);
>> +			ALPHA_ZEXTL(r_A, r_A);
>=20
> So... are you attempting to have canonical zero-extended values,
> or canonical sign-extended values?  Because at the moment you have
> a mix of both.
>=20

I know, and i don't know what i want.

> Either drop the canonicalization and consider high-32 bits as
> garbage (and then explicitly extend whereever necessary) or pick
> one and stick with it.  Of course, the sign-extending of addl etc
> will force you to choose sign-extend not zero-extend as canonical.
>=20

The problem is the bpf cpu is inherently unsigned. It does all loads
zero extended, only has logical shifts, does all compares unsigned.
Which sounds like i have to zero extend like crazy. (i took the=20
Powerpc code as example, it does most things unsigned and on 32 Bit,
but has similar "add is sign extending" things, so i thought it can't
be that bad, otherwise it would have the same Bugs).

I was hoping to let the sign run it's course/sign extend and only
cut at the right point, and i figured that was a point to cut, i should
prop. sign extend.

But if that is not feasible, i could also sprinkle everything with zero
extends.

>> +		case BPF_S_ALU_RSH_X: /* A >>=3D X; */
>> +			ctx->seen |=3D SEEN_XREG;
>> +			ALPHA_SRL(r_A, r_X, r_A);
>> +			ALPHA_ZEXTL(r_A, r_A);
>> +			break;
>=20
> Like here.  You must zero-extend first to avoid shifting in
> garbage.  Afterward you can reason that the value is already
> zero-extended.
>=20

Oh, thanks!
Yes, the shift operations are only logical shifts, so it has to be prop=
erly
zero extended.

[snip - bpf_flush_icache]
>=20
> imb() is all that is needed.
>=20

Thanks! I guess i will stick to the flush_icache_range, which is define=
d to
an imb()/smp_imb(), so should do the right thing(TM).

[snip - comment about pases]
>=20
> I should think you could do this in exactly one pass, given that ther=
e's
> absolutely no need for ultra-long branches.

The first pass is called with image =3D=3D NULL, so all calls have a ve=
ry long
displacement + we have to make other worst case/wrong assumptions becau=
se
addrs is not properly filled and the exit points are unknown.
The second pass with image =3D=3D NULL will settle some jumps, because =
addrs is
now mostly properly populated _and_ the exit points are set.
This is done to get a real good estimate when allocating mem, so not to=
 much
is allocated (saw a thread on lkml where Eric was talking with Ingo abo=
ut
module_realloc, so the memusage is of concern, it is pinned kernel memo=
ry
for the user space).
The other passes are only to make things really slick with image !=3D N=
ULL,
and stop if there is no change.
If i knew some kind of base address where module_alloc will allocate, i
could feed that in early...

> If you're going to scan the
> body for SEEN_MEM etc, you might as well look for your A and X initia=
lization
> at the same time and clean up that hack in the prologue.
>=20

I was working on a patch for that, but it was more complicated, esp. it=
 may
cost some RAM and/or CPU time just to remove one/two instructions, so i=
 left
it out for the moment till i revisit it.

>> +++ b/arch/alpha/net/bpf_jit_helper.S
>=20
> It would be helpful to use '$' prefixes here for local variables.
>=20

???
Sorry, i don't understand what you mean. What variables? Or do you mean
register? It uses the same register as the compiler. So to not confuse
things i made the names from the compiler usable in asm. You can change=
 one
define and the compiler and the helper will use another reg.

>=20
> r~
>=20

Greetings
	Jan

--=20
Anyone can build a fast processor. The trick is to build a fast system.
(Seymour Cray)
--
To unsubscribe from this list: send the line "unsubscribe linux-alpha" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
