From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: add a security check at install time
Date: Thu, 2 Dec 2010 10:30:48 +0800
Message-ID: <AANLkTikK=dy6U0QBjkJxZXeqYXVHwZqjmRhnmYBH-22r@mail.gmail.com>
References: <1291227893.2856.1039.camel@edumazet-laptop> <20101201.104450.183053379.davem@davemloft.net>
 <1291232937.2856.1042.camel@edumazet-laptop> <20101201.122312.229751364.davem@davemloft.net>
 <1291236342.2856.1057.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hagen@jauu.net,
	wirelesser@gmail.com, netdev@vger.kernel.org,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36596 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756098Ab0LBCbK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 21:31:10 -0500
Received: by fxm20 with SMTP id 20so720888fxm.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 18:31:09 -0800 (PST)
In-Reply-To: <1291236342.2856.1057.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 2, 2010 at 4:45 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 01 d=E9cembre 2010 =E0 12:23 -0800, David Miller a =E9cri=
t :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 01 Dec 2010 20:48:57 +0100
>>
>> > Le mercredi 01 d=E9cembre 2010 =E0 10:44 -0800, David Miller a =E9=
crit :
>> >> From: Eric Dumazet <eric.dumazet@gmail.com>
>> >> Date: Wed, 01 Dec 2010 19:24:53 +0100
>> >>
>> >> > A third work in progress (from my side) is to add a check in
>> >> > sk_chk_filter() to remove the memvalid we added lately to prote=
ct the
>> >> > LOAD M(K).
>> >>
>> >> I understand your idea, but the static checkers are still going t=
o
>> >> complain. =A0So better add a huge comment in sk_run_filter() expl=
aining
>> >> why the checker's complaint should be ignored :-)
>> >
>> > Sure, here is the patch I plan to test ASAP
>>
>> Looks good to me.
>
> Yes, it survives tests I did.
>
> I submit the patch and Cc Dan Rosenberg, I would like him to double
> check it if he likes.
>
> Thanks
>
> [PATCH net-next-2.6] filter: add a security check at install time
>
> We added some security checks in commit 57fe93b374a6
> (filter: make sure filters dont read uninitialized memory) to close a
> potential leak of kernel information to user.
>
> This added a potential extra cost at run time, while we can perform a
> check of the filter itself, to make sure a malicious user doesnt try =
to
> abuse us.
>
> This patch adds a check_loads() function, whole unique purpose is to
> make this check, allocating a temporary array of mask. We scan the
> filter and propagate a bitmask information, telling us if a load M(K)=
 is
> allowed because a previous store M(K) is guaranteed. (So that
> sk_run_filter() can possibly not read unitialized memory)
>
> Note: this can uncover application bug, denying a filter attach,
> previously allowed.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Dan Rosenberg <drosenberg@vsecurity.com>
> ---
> =A0net/core/filter.c | =A0 70 ++++++++++++++++++++++++++++++++++++++-=
-----
> =A01 file changed, 61 insertions(+), 9 deletions(-)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index a44d27f..00a0d50 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -166,11 +166,9 @@ unsigned int sk_run_filter(struct sk_buff *skb, =
const struct sock_filter *fentry
> =A0 =A0 =A0 =A0u32 A =3D 0; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
/* Accumulator */
> =A0 =A0 =A0 =A0u32 X =3D 0; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
/* Index Register */
> =A0 =A0 =A0 =A0u32 mem[BPF_MEMWORDS]; =A0 =A0 =A0 =A0 =A0/* Scratch M=
emory Store */
> - =A0 =A0 =A0 unsigned long memvalid =3D 0;
> =A0 =A0 =A0 =A0u32 tmp;
> =A0 =A0 =A0 =A0int k;
>
> - =A0 =A0 =A0 BUILD_BUG_ON(BPF_MEMWORDS > BITS_PER_LONG);
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Process array of filter instructions.
> =A0 =A0 =A0 =A0 */
> @@ -318,12 +316,10 @@ load_b:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0X =3D K;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_MEM:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D (memvalid & (1UL =
<< K)) ?
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem[K] =
: 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D mem[K];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LDX_MEM:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 X =3D (memvalid & (1UL =
<< K)) ?
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem[K] =
: 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 X =3D mem[K];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_MISC_TAX:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0X =3D A;
> @@ -336,11 +332,9 @@ load_b:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_RET_A:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return A;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ST:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memvalid |=3D 1UL << K;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem[K] =3D A;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_STX:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memvalid |=3D 1UL << K;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem[K] =3D X;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> @@ -419,6 +413,64 @@ load_b:
> =A0}
> =A0EXPORT_SYMBOL(sk_run_filter);
>
> +/*
> + * Security :
> + * A BPF program is able to use 16 cells of memory to store intermed=
iate
> + * values (check u32 mem[BPF_MEMWORDS] in sk_run_filter())
> + * As we dont want to clear mem[] array for each packet going throug=
h
> + * sk_run_filter(), we check that filter loaded by user never try to=
 read
> + * a cell if not previously written, and we check all branches to be=
 sure
> + * a malicious user doesnt try to abuse us.
> + */
> +static int check_loads(struct sock_filter *filter, int flen)
> +{
> + =A0 =A0 =A0 u16 *masks, memvalid =3D 0; /* one bit per cell, 16 cel=
ls */
> + =A0 =A0 =A0 int pc, ret =3D 0;
> +
> + =A0 =A0 =A0 BUILD_BUG_ON(BPF_MEMWORDS > 16);
> + =A0 =A0 =A0 masks =3D kmalloc(flen * sizeof(*masks), GFP_KERNEL);
> + =A0 =A0 =A0 if (!masks)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 memset(masks, 0xff, flen * sizeof(*masks));
> +
> + =A0 =A0 =A0 for (pc =3D 0; pc < flen; pc++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memvalid &=3D masks[pc];
> +

It seems wrong. Think about the following instructions:

/* m[1] isn't set */
   jeq jt jf
jt:
   st m[1]
   jmp ja
jf:
   jmp ja2 /* m[1] is invalidated by masks */
ja:
   ld m[1] /* -EINVAL is returned */
ja2:

So you need to search all the possible branches to validate the instruc=
tions.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (filter[pc].code) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ST:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_STX:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memvalid |=3D (1 << fil=
ter[pc].k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_MEM:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LDX_MEM:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(memvalid & (1 << =
filter[pc].k))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D=
 -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto er=
ror;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JA:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* a jump must set mask=
s on target */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 masks[pc + 1 + filter[p=
c].k] &=3D memvalid;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JEQ_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JEQ_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JGE_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JGE_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JGT_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JGT_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JSET_X:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_JMP_JSET_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* a jump must set mask=
s on targets */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 masks[pc + 1 + filter[p=
c].jt] &=3D memvalid;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 masks[pc + 1 + filter[p=
c].jf] &=3D memvalid;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +error:
> + =A0 =A0 =A0 kfree(masks);
> + =A0 =A0 =A0 return ret;
> +}
> +
> =A0/**
> =A0* =A0 =A0 sk_chk_filter - verify socket filter code
> =A0* =A0 =A0 @filter: filter to verify
> @@ -547,7 +599,7 @@ int sk_chk_filter(struct sock_filter *filter, int=
 flen)
> =A0 =A0 =A0 =A0switch (filter[flen - 1].code) {
> =A0 =A0 =A0 =A0case BPF_S_RET_K:
> =A0 =A0 =A0 =A0case BPF_S_RET_A:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return check_loads(filter, flen);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return -EINVAL;
> =A0}
>
>
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
