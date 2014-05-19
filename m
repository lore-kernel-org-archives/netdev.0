From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v5 net-next 1/3] net: flow_dissector: avoid multiple calls
 in BPF
Date: Mon, 19 May 2014 15:23:53 -0700
Message-ID: <CA+ZOOTPmSPeBrSHAsJtyxkAUnZDpgdhhw2PkrCJ3LhmG+ZSRYA@mail.gmail.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<1400265701-10333-1-git-send-email-chema@google.com>
	<CAMEtUuxBCNqbYctdxvWiJbp0mY__dKjP-RU8Ao-x3osVbFkxVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:37971 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbaESWXy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 18:23:54 -0400
Received: by mail-ie0-f176.google.com with SMTP id rl12so3005131iec.35
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 15:23:54 -0700 (PDT)
In-Reply-To: <CAMEtUuxBCNqbYctdxvWiJbp0mY__dKjP-RU8Ao-x3osVbFkxVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 3:00 PM, Alexei Starovoitov <ast@plumgrid.com> =
wrote:
> this is way too long for commit log. These details can go after '---'=
 line.
This can be fixed easily ;). I must admit I'm surprised by this
request: The way I see it, a commit log is not part of the code, but
text that justifies a patch. Therefore, being extremely descriptive is
a good thing. But it's got an easy solution.

>> +        * such field has been inited)
>> +        */
>> +       context =3D (void *)FP - BPF_MEMWORDS * 4 - sizeof(*context)=
;
>> +       context->flow_initted =3D false;
>> +
>
> Neither this code nor comment belong in interpreter which is striving=
 to
> be generic. Both have a meaning only for your new instructions in
> socket filters. They do not apply to seccomp and to tracing.
> Calling it 'struct sk_run_filter_ctx' is equally misleading.
> 'struct flow_keys' has nothing to do with seccomp and even with
> normal tcpdump filters.
I'd argue specificity already pervades the BPF filter. Almost all the
ancillary loads (now bpf_calls) assume a sk_buff in the ctx field (all
but the get_cpu and random). If the user's filter has a "ld #nla"
insn, the eBPF filter ends up having "mov(ctx, arg1); mov(A, arg2);
=2E..; call(__skb_get_nlattr)", which assumes ctx has an skb, and runs
"nla_find((struct nlattr *) &skb->data[a], ...)".

Now, this specificity is needed: We're using BPF filters to filter
packets. It would make no sense not to use all the packet-related
functions in the kernel.

> We've spent so much time to generalize it and now you want to take
> it back into socket specific territory. As I said in the previous ema=
il
> it's totally not ok to customize eBPF just for one use case especiall=
y
> when you're not sharing final usage scenario.
Sorry if I haven't mentioned it before.

Right now I use the following filter to detect some packets I'm
interested on ('ip[1] =3D=3D 0x03 and tcp and dst port 80' in tcpdump
expression-ish):

$ cat tools/net/tos_and_tcp_and_dport.bpf
ldh [12]
jne #0x800, drop
ldb [15]
jne #0x3, drop
ldb [23]
jne #0x6, drop
ldh [20]
jset #0x1fff, drop
ldxb 4*([14]&0xf)
ldh [x + 16]
jne #0x50, drop
ret #-1
drop: ret #0

Now, I want to do the same filtering in encapsulated traffic (vlan and
gre). I'd like to be able to write something like:

$ cat tools/net/tos_and_tcp_and_dport_generic.bpf
ld #nproto
jne #0x800, drop
ld #nhoff
ldh [x + 1]
jne #0x3, drop
=2E..

This will automatically support all the de-encapsulation performed by
the flow dissector.

> Any uapi change must be strongly justified.
I hope I have managed to convince you with the example above. Still,
my proposal only add a couple of ancillary loads.

> Other than design issue there is technical problem too.
> You're not updating eBPF JIT and context->flow_initted will have junk=
,
> so ld_poff will be returning junk too.
> JITs and interpreter must match. That was always the case even in
> old days of classic BPF. Interpreter initialized A and X to zero,
> JITs had to do the same. If you add stuff like this to interpreter,
> JITs would have to follow. Fast forward few years and this is not sca=
lable.
> You have several JITs around and adding custom stuff to interpreter
> may not even be possible to do in JITs.
This is a fair point. In fact my patch is breaking "ld poff."

I think the previous mechanism where a new insn added to BPF would
cause the BPF JIT engine to refuse to run was a more scalable: New
stuff always went in the non-jitted runner, and people interested in
the jitted version will port when they needed it. We definitely not
want to require people adding new features to provide 6 versions of
the code.

> Therefore I'm strongly against adding custom C code to interpreter.
> It's an interpreter of eBPF instructions. Nothing else.
> At the same time adding new eBPF instructions would be completely fin=
e.
> Like right now we don't have < and <=3D conditional jumps, which adds
> unnecessary complexity to tracing filters. So we may still expand
> interpreter and JITs in the future.
>
> Going back to your use case=E2=80=A6 assuming that you share how user
> space will use new anc loads=E2=80=A6 you can do equivalent initializ=
ation
> of 'flow_initted' by emitting extra eBPF insn while converting classi=
c
> to internal. Don't do it unconditionally though. tcpdump filters shou=
ld
> not suffer. You can scan program for presence of ld_poff, ld_toff,
> ld_tproto and if they're present, emit single eBPF 'st [fp - off], 0'
> ST_MEM instruction as a first instruction of converted filter. All eB=
PF
> JITs will compile it to native automatically. You'll have good
> performance and all existing filters will not regress.
Sounds fair. I'll think of a good mechanism to allow other
instructions "sharing" state among themselves.

-Chema


>
>>         /* Register for user BPF programs need to be reset first. */
>>         regs[BPF_REG_A] =3D 0;
>>         regs[BPF_REG_X] =3D 0;
>> @@ -602,7 +619,10 @@ static unsigned int pkt_type_offset(void)
>>
>>  static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 =
r5)
>>  {
>> -       return __skb_get_poff((struct sk_buff *)(unsigned long) ctx)=
;
>> +       struct sk_run_filter_ctx *context =3D (void *) r4 - BPF_MEMW=
ORDS * 4 -
>> +                       sizeof(*context);
>> +       return __skb_get_poff((struct sk_buff *)(unsigned long) ctx,
>> +                       &context->flow, &context->flow_initted);
>>  }
>>
>>  static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
>> @@ -783,6 +803,10 @@ static bool convert_bpf_extensions(struct sock_=
filter *fp,
>>                 *insn =3D BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG3, BPF_R=
EG_X);
>>                 insn++;
>>
>> +               /* arg4 =3D FP */
>> +               *insn =3D BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG4, BPF_R=
EG_FP);
>> +               insn++;
>> +
>>                 /* Emit call(ctx, arg2=3DA, arg3=3DX) */
>>                 insn->code =3D BPF_JMP | BPF_CALL;
>>                 switch (fp->k) {
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index 107ed12..cefe1d2 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -275,16 +275,20 @@ EXPORT_SYMBOL(__skb_tx_hash);
>>   * truncate packets without needing to push actual payload to the u=
ser
>>   * space and can analyze headers only, instead.
>>   */
>> -u32 __skb_get_poff(const struct sk_buff *skb)
>> +u32 __skb_get_poff(const struct sk_buff *skb, struct flow_keys *flo=
w,
>> +               bool *flow_initted)
>>  {
>> -       struct flow_keys keys;
>>         u32 poff =3D 0;
>>
>> -       if (!skb_flow_dissect(skb, &keys))
>> -               return 0;
>> +       /* check whether the flow dissector has already been run */
>> +       if (!*flow_initted) {
>> +               if (!skb_flow_dissect(skb, flow))
>> +                       return 0;
>> +               *flow_initted =3D true;
>> +       }
>>
>> -       poff +=3D keys.thoff;
>> -       switch (keys.ip_proto) {
>> +       poff +=3D flow->thoff;
>> +       switch (flow->ip_proto) {
>>         case IPPROTO_TCP: {
>>                 const struct tcphdr *tcph;
>>                 struct tcphdr _tcph;
>> --
>> 1.9.1.423.g4596e3a
>>
