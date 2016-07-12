From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: eBPF tunable max instructions or max tail call?
Date: Tue, 12 Jul 2016 09:17:50 -0700
Message-ID: <CAMp4zn9diJnvcuXWfxao4-+UkOQ2AerBPjU5_H6br9yq718_aA@mail.gmail.com>
References: <CAMp4zn-6G+41PrsAHH3ZuKcKa-o16_d7ZEuRE517v42iA=Y-Ug@mail.gmail.com>
 <20160712031446.GA49510@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35331 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbcGLQSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 12:18:31 -0400
Received: by mail-oi0-f44.google.com with SMTP id r2so29942617oih.2
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 09:18:30 -0700 (PDT)
In-Reply-To: <20160712031446.GA49510@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 8:14 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Jul 11, 2016 at 05:56:07PM -0700, Sargun Dhillon wrote:
>> It would be nice to have eBPF programs that are longer than 4096
>> instructions. I'm trying to implement XSalsa20 in eBPF, and
>> unfortunately, it doesn't fit into 4096 instructions since I'm
>> unrolling all of the loops. Further than that, doing tail calls to
>> process each block results in me hitting the tail call limit.
>
> a cipher in bpf? wow. that's pushing it :)
> we've been discussing various way of adding 'bounded loop' instruction
> to avoid manual unrolling, but it will be still limited to the 4k
> instruction per program, so probably won't help this use case.
> Are you trying to do it in the networking context?

Yeah, I'm trying to do this as a TC filter. Instruction wise, each 64
byte chunk is about 5000 instructions using LLVM's automatic loop
unrolling. I need the first and last invocation to be for finishing
and initializing the key schedule, setting checksums, etc.. So, I'm
pretty close -- this implementation wasn't actually XSalsa20, it was a
port of the Kernel's implementation of Salsa20. I think bumping the
instruction limit to 8k would do the trick.

>
>> It don't think that it makes much sense to expose the crypto API as
>> BPF helpers, as I'm not sure if we can ensure safety, and timely
>> execution with it. I may be wrong here, and if there is a sane, safe
>> way to expose the crypto API, I'm all ears.
>
> we had the patches to connect crypto api with bpf, but they were
> too hacky to upstream, since then we redesigned the approach
> and the latest should be much cleaner. The keys will be managed
> through normal xfrm api and bpf will call into crypto with
> mechanism similar to tail-call. The program will specify the
> offset/length within the packet to encrypt/decrypt and next
> program to execute when crypto operation completes.
> Root only for xdp and tc only.
>
This is really interesting to me. Right now, I'm passing the key via
embedding it in the code itself. It allows LLVM to do a bit more
optimization. The crypto APIs are really nice and well fleshed out.
XFRM on the other hand introduces a lot of complexity that I'm trying
to avoid. It'd be nice if we could treat cryptographic state as just
another type of BPF map.

>> Other than that, it would be nice to make the max instructions a knob,
>> and I don't think that it has much downside, given it's only checked
>> on load time. It would be nice to make the tail call limit a tunable
>> as well, but I'm unsure of the performance impact it might have given
>> that it's checked at runtime.
>>
>> What do y'all think is reasonable? Make them both tunable? Just one? None?
>
> It is preferred to achieve the goal without introducing a knob.
> Also sounds like that increasing 4k to 8k won't really solve it anyway.
>
