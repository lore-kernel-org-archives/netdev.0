From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v3 net-next 1/3] net: flow_dissector: avoid multiple calls
 in BPF
Date: Fri, 16 May 2014 11:41:28 -0700
Message-ID: <CA+ZOOTMk50MOPXHEcZRBwUVR9Fp7VHM1K=S76+8fALkH69dnZA@mail.gmail.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<1400093480-498-1-git-send-email-chema@google.com>
	<CAMEtUuxOC3krRcwcuUaMHwBOC_7pGckVFmpU0f_NsMs-5j586w@mail.gmail.com>
	<CA+ZOOTOiPAAXR18ZVYyE8czk7CPTNjCFaVcNssWXxYvXfeCs3A@mail.gmail.com>
	<CAMEtUuyQOHe4sAn=pPtKUpGdy2GTApff+7ghDfuj1G3=4s68rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:45145 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068AbaEPSl2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 14:41:28 -0400
Received: by mail-ig0-f179.google.com with SMTP id hn18so1164805igb.6
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 11:41:28 -0700 (PDT)
In-Reply-To: <CAMEtUuyQOHe4sAn=pPtKUpGdy2GTApff+7ghDfuj1G3=4s68rQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 3:44 PM, Alexei Starovoitov <ast@plumgrid.com> =
wrote:
> please try 'modprobe test_bpf'=E2=80=A6 you'll see most ld_proto, ld_=
vlan, =E2=80=A6
> tests failing..
=46ixed.

>>> sk_run_filter() is a generic interpreter that should be suitable fo=
r
>>> sockets, seccomp, tracing, etc. Adding one use case specific data
>>> structure to interpreter is not desirable.
>> That's an interesting point, which you'd agree does apply to "ld pof=
f"
>> right now. There's a tradeoff here between making the BPF VM as
>> generic as possible, and having to reimplement in BPF VM code
>> functions that already exist in the kernel (the flow dissector
>> itself). I think not having 2 flow dissectors in the kernel (one in =
C,
>> one in BPF VM code) is a win.
>
> You misunderstood. That's not at all what I said. See the diff below.
OK. Fixed using the extended eBPF stack (EES). Note that I added an
explicit struct to put stuff in the EES (instead of assuming what's
there).

>>> Doing memset(&flow,0...) every invocation is not performance
>>> friendly either. Majority of filters will suffer.
>> Will fix. In retrospect, I should have just added an flow_keys_is_in=
it
>> field instead of mapping {0, 0, {0}, 0, 0} to "not inited."
Done.

>>> You can do the same without touching sk_run_filter().
>>> For example, you can tweak sk_convert_filter() to pass
>>> R10(frame pointer) as arg4 to helper functions
>>> (__skb_get_pay_offset() and others)
>>> then inside those functions cast 'arg4 - appropriate offset'
>>> to struct flow_keys and use it.
>>> BPF was extended from 16 spill/fill only slots to generic
>>> stack space exactly for this type of use cases.
>> I tried several implementations, including the one you propose:
>
> nope. see the diff of what I'm proposing.
Done.

>
>> 1. add flow_keys to skb CB (packet_skb_cb)
>> The problem here is that struct flow_keys (15 bytes) does not fit in
>> AF_PACKET's 48-byte skb CB. I also tried to create a small_flow_keys
>> struct that only contains L3 info (nhoff/proto, which is the minimum
>> output you need from the flow dissector to be able to get the rest
>> without having to rewalk the packet), or maybe L3 and L4
>> (thoff/ip_proto). The problem is that the packet CB is completely fu=
ll
>> already. packet_skb_cb is 4 (origlen) + 20 (sockaddr_ll) and
>> MAX_ADDR_LEN=3D32, so the net/packet/af_packet.c:1822 check is 4+20+=
32-8
>> =3D 48, which is already the size of the sk_buff->CB.
>>
>> 2. add flow_keys using the stack in the 3 BPF filter runners
>> (original, eBPF, JIT)
>>   - (-) there are 6x BPF engines (1x non-JIT and 5x JIT)
>>   - (+) we can just do the non-JIT version, and let JITs implement i=
t
>> when they want)
>>   - (+) very simple
>>
>> 3. add FLOW, BPF_REG_FLOW, map it to a register, and then pass it as
>> R4. This is what you're proposing, IIIC. I found the implementation
>> way more complicated (in fact I gave up trying to make it not crash
>> ;), but I guess this is my own taste. What really convinced me to
>> extend the context is that, if you think about it, both the skb and
>> the flow_keys are part of the context that the bpf_calls use to run.
>> If we pass flow_keys in R4, and we ever want to add more context
>> parameters to a call, that means using R5. And then what?
>>
>>> Key point: you can add pretty much any feature to classic BPF
>>> by tweaking converter from classic to internal without changing
>>> interpreter and causing trainwreck for non-socket use cases.
>> Again, the patch is not breaking the current functionality. We alrea=
dy
>> provide "ld poff" as a recognition that packet processing is a first
>> class citizen of the BPF VM. If you run a seccomp filter containing =
a
>> "ld poff" right now, you're probably causing issues anyway.
>
> 'ld poff' is not first class citizen of interpreter. There is no such=
 eBPF insn.
> It's a classic BPF instruction. It is converted into a sequence of eB=
PF
> insns including bpf_call.
>
> Just to reduce the number of back and forth emails here is the diff
> of what you want to do that doesn't break things:
> (sorry for whitespace mangling)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 7a9beeb1c458..10f580e44a33 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3065,7 +3065,7 @@ bool skb_partial_csum_set(struct sk_buff *skb,
> u16 start, u16 off);
>
>  int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
>
> -u32 __skb_get_poff(const struct sk_buff *skb);
> +u32 __skb_get_poff(const struct sk_buff *skb, struct flow_keys *keys=
);
>
>  /**
>   * skb_head_is_locked - Determine if the skb->head is locked down
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 32c5b44c537e..1179f2fb4c95 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -602,7 +602,12 @@ static unsigned int pkt_type_offset(void)
>
>  static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r=
5)
>  {
> -       return __skb_get_poff((struct sk_buff *)(unsigned long) ctx);
> +       /* top BPF_MEMWORDS * 4 bytes are used to represent classic B=
PF
> +        * mem[0-15] slots, use next sizeof(struct flow_keys) bytes
> +        * of stack to share flow_dissect-ed data
> +        */
> +       struct flow_keys *keys =3D (void *) r4 - BPF_MEMWORDS * 4 - s=
izeof(*keys);
> +       return __skb_get_poff((struct sk_buff *)(unsigned long) ctx, =
keys);
>  }
>
>  static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
> @@ -783,6 +788,10 @@ static bool convert_bpf_extensions(struct sock_f=
ilter *fp,
>                 *insn =3D BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG3, BPF_RE=
G_X);
>                 insn++;
>
> +               /* arg4 =3D FP */
> +               *insn =3D BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG4, BPF_RE=
G_FP);
> +               insn++;
> +
>                 /* Emit call(ctx, arg2=3DA, arg3=3DX) */
>                 insn->code =3D BPF_JMP | BPF_CALL;
>                 switch (fp->k) {
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 107ed12a5323..c8d9f16e4872 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -275,16 +275,15 @@ EXPORT_SYMBOL(__skb_tx_hash);
>   * truncate packets without needing to push actual payload to the us=
er
>   * space and can analyze headers only, instead.
>   */
> -u32 __skb_get_poff(const struct sk_buff *skb)
> +u32 __skb_get_poff(const struct sk_buff *skb, struct flow_keys *keys=
)
>  {
> -       struct flow_keys keys;
>         u32 poff =3D 0;
>
> -       if (!skb_flow_dissect(skb, &keys))
> +       if (!skb_flow_dissect(skb, keys))
>                 return 0;
>
> -       poff +=3D keys.thoff;
> -       switch (keys.ip_proto) {
> +       poff +=3D keys->thoff;
> +       switch (keys->ip_proto) {
>         case IPPROTO_TCP: {
>
> now just use the same 'keys' address in your new get_off calls.
> First word can be used to indicate whether flow_dissector() was calle=
d
> or not.
>
> Above is tested with and without JIT with BPF testsuite.

Patches now.
-Chema
