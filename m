From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] sparc64: Improve 64-bit constant loading in eBPF
 JIT.
Date: Mon, 24 Apr 2017 20:18:56 -0700
Message-ID: <74973b5c-5380-b27b-3cf6-7b1444cade02@fb.com>
References: <20170424.225334.898469015162314835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <sparclinux@vger.kernel.org>, <daniel@iogearbox.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170424.225334.898469015162314835.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/24/17 7:53 PM, David Miller wrote:
>
> Doing a full 64-bit decomposition is really stupid especially for
> simple values like 0 and -1.
>
> But if we are going to optimize this, go all the way and try for all 2
> and 3 instruction sequences not requiring a temporary register as
> well.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> This one is dedicated to all the bit twiddlers out there.
>
> First we do the easy cases where it's a zero or sign extended
> 32-bit number (sethi+or, sethi+xor, respectively).
>
> Then we try to find a range of set bits we can load simply then shift
> up into place, in various ways.
>
> Then we try negating the constant and see if we can do a simple
> sequence using that with a xor at the end.  (f.e. the range of set
> bits can't be loaded simply, but for the negated value it can)
>
> The final optimized strategy involves 4 instructions sequences not
> needing a temporary register.
>
> Otherwise we sadly fully decompose using a temp..
>
> Example, from ALU64_XOR_K: 0x0000ffffffff0000 ^ 0x0 = 0x0000ffffffff0000:
>
> 0000000000000000 <foo>:
>    0:   9d e3 bf 50     save  %sp, -176, %sp
>    4:   01 00 00 00     nop
>    8:   90 10 00 18     mov  %i0, %o0
>    c:   13 3f ff ff     sethi  %hi(0xfffffc00), %o1
>   10:   92 12 63 ff     or  %o1, 0x3ff, %o1     ! ffffffff <foo+0xffffffff>
>   14:   93 2a 70 10     sllx  %o1, 0x10, %o1
>   18:   15 3f ff ff     sethi  %hi(0xfffffc00), %o2
>   1c:   94 12 a3 ff     or  %o2, 0x3ff, %o2     ! ffffffff <foo+0xffffffff>
>   20:   95 2a b0 10     sllx  %o2, 0x10, %o2
>   24:   92 1a 60 00     xor  %o1, 0, %o1
>   28:   12 e2 40 8a     cxbe  %o1, %o2, 38 <foo+0x38>
>   2c:   9a 10 20 02     mov  2, %o5
>   30:   10 60 00 03     b,pn   %xcc, 3c <foo+0x3c>
>   34:   01 00 00 00     nop
>   38:   9a 10 20 01     mov  1, %o5     ! 1 <foo+0x1>
>   3c:   81 c7 e0 08     ret
>   40:   91 eb 40 00     restore  %o5, %g0, %o0

all of the above is very useful info that can be in commit log.

> Last optimization tonight, I promise :-)
>
>  arch/sparc/net/bpf_jit_comp_64.c | 249 ++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 245 insertions(+), 4 deletions(-)
>
> diff --git a/arch/sparc/net/bpf_jit_comp_64.c b/arch/sparc/net/bpf_jit_comp_64.c
> index 2b2f3c3..6869ec0 100644
> --- a/arch/sparc/net/bpf_jit_comp_64.c
> +++ b/arch/sparc/net/bpf_jit_comp_64.c
> @@ -28,6 +28,11 @@ static inline bool is_simm5(unsigned int value)
>  	return value + 0x10 < 0x20;
>  }
>
> +static inline bool is_sethi(unsigned int value)
> +{
> +	return (value & ~0x3fffff) == 0;
> +}
> +
>  static void bpf_flush_icache(void *start_, void *end_)
>  {
>  	/* Cheetah's I-cache is fully coherent.  */
> @@ -367,16 +372,252 @@ static void emit_loadimm_sext(s32 K, unsigned int dest, struct jit_ctx *ctx)
>  	}
>  }
>
> +static void analyze_64bit_constant(u32 high_bits, u32 low_bits,
> +				   int *hbsp, int *lbsp, int *abbasp)
> +{
> +	int lowest_bit_set, highest_bit_set, all_bits_between_are_set;
> +	int i;
> +
> +	lowest_bit_set = highest_bit_set = -1;
> +	i = 0;
> +	do {
> +		if ((lowest_bit_set == -1) && ((low_bits >> i) & 1))
> +			lowest_bit_set = i;
> +		if ((highest_bit_set == -1) && ((high_bits >> (32 - i - 1)) & 1))
> +			highest_bit_set = (64 - i - 1);
> +	}  while (++i < 32 && ((highest_bit_set == -1) ||
> +			       (lowest_bit_set == -1)));

copy pasta from gcc ? ;)
the number of extra () looks excessive.

> +static bool const64_is_2insns (unsigned long high_bits,
> +			       unsigned long low_bits)

extra space before (

> +{
> +	int highest_bit_set, lowest_bit_set, all_bits_between_are_set;
> +
> +	if (high_bits == 0 || high_bits == 0xffffffff)
> +		return true;
> +
> +	analyze_64bit_constant (high_bits, low_bits,

another space

> +				&highest_bit_set, &lowest_bit_set,
> +				&all_bits_between_are_set);
> +
> +	if ((highest_bit_set == 63 || lowest_bit_set == 0) &&
> +	    all_bits_between_are_set != 0)
> +		return true;
> +
> +	if ((highest_bit_set - lowest_bit_set) < 21)
> +		return true;

extra ()

> +static void sparc_emit_set_const64_quick2 (unsigned long high_bits,

extra space

> +	/* Now a range of 22 or less bits set somewhere.
> +	 * 1) sethi	%hi(focus_bits), %reg
> +	 *    sllx	%reg, shift, %reg
> +	 * 2) sethi	%hi(focus_bits), %reg
> +	 *    srlx	%reg, shift, %reg
> +	 */

was thinking whether any of these optimizations can be generalized to
other JITs. Probably not. sethi semantic is too sparc specific.

> +	if (const64_is_2insns ((~high_bits) & 0xffffffff,
> +			       (~low_bits) & 0xfffffc00)) {

all gcc-ism actually gives confidence that most likely
it's all good and battle proven logic :)

