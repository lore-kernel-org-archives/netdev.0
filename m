From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net] bpf: disallow arithmetic operations on context
 pointer
Date: Mon, 16 Oct 2017 17:47:45 +0100
Message-ID: <e2c4322a-301f-47f9-d102-725138d1bf67@solarflare.com>
References: <20171016154552.30640-1-jakub.kicinski@netronome.com>
 <44a8fb95-298b-8715-ce4e-60df60c86343@solarflare.com>
 <20171016093043.36fcfedc@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <oss-drivers@netronome.com>,
        <alexei.starovoitov@gmail.com>, <daniel@iogearbox.net>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:59678 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755180AbdJPQrx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 12:47:53 -0400
In-Reply-To: <20171016093043.36fcfedc@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/10/17 17:30, Jakub Kicinski wrote:
> On Mon, 16 Oct 2017 17:16:24 +0100, Edward Cree wrote:
>> On 16/10/17 16:45, Jakub Kicinski wrote:
>>> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
>>> index 8b8d6ba39e23..8499759d0c7a 100644
>>> --- a/kernel/bpf/verifier.c
>>> +++ b/kernel/bpf/verifier.c
>>> @@ -1116,7 +1116,12 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
>>>  		/* ctx accesses must be at a fixed offset, so that we can
>>>  		 * determine what type of data were returned.
>>>  		 */
>>> -		if (!tnum_is_const(reg->var_off)) {
>>> +		if (reg->off) {
>>> +			verbose("derefence of modified ctx ptr R%d off=%d+%d, ctx+const is allowed, ctx+const+const is not\n",  
>> This is slightly unclear, it's not that two adds is bad (e.g. r1 += 8;
>>  r0 = *(u32 *)r1 is bad too), it's that the offset must be in the load,
>>  not the register; your message might be accurate for some compilers but
>>  not in full generality (especially for assemblers without compiling).
> I'm happy to hear better suggestions :)  I've spent quite a bit of time
> scratching my head thinking how to phrase this best.  The first
> part of the message is general enough IMHO, the second is targeted
> mostly at C developers.
Hmm, what really bugs me is that if e.g. the compiler turned
   *(ctx + 4 + 4)
 or
   ctx[4 + 4]
 or even
   ctx->arraymemb[4]
 into this kind of arithmetic on ctx, arguably that would be a bug in the
 compiler — if it's doing proper constexpr folding on its IR (or something
 along those lines) it should be able to turn them all into good LDX.  The
 same even goes for if (ctx + 4) got stored in a local, because there's no
 reason that has to map to a register.
So it's not even that "your C source breaks the rules", it's that "your C
 compiler did something silly that we don't handle".
Maybe the message should be "compiler maybe mishandled ctx+const+const"?

-Ed
