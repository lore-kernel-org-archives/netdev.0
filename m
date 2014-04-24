From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 5/5] net: filter: optimize BPF migration for
 ARG1/CTX handling
Date: Thu, 24 Apr 2014 07:56:34 +0200
Message-ID: <5358A792.2080102@redhat.com>
References: <1398286621-3591-1-git-send-email-dborkman@redhat.com> <1398286621-3591-6-git-send-email-dborkman@redhat.com> <CAMEtUux3YZW9G80Da2B3pBB2Sq7C7eC62ntnrVifN8_RJugzHw@mail.gmail.com> <53583CEB.3040203@redhat.com> <CAMEtUuzboCLpVXNd+6NQVco=NbX4wcKHt1F+ZkD7DYVpMbBxEw@mail.gmail.com> <5358453E.4050005@redhat.com> <CAMEtUuzT6smejsgoKP5c_NCw8mQw39xfPR+hsfV1Oh77ZeG3bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbaDXF4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 01:56:40 -0400
In-Reply-To: <CAMEtUuzT6smejsgoKP5c_NCw8mQw39xfPR+hsfV1Oh77ZeG3bA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2014 01:14 AM, Alexei Starovoitov wrote:
...
>> Well, I just don't understand the concerns of ABI here. Given that we do not
>> have any native BPF code to maintain in the kernel tree and given that we
>> currently do not expose the instruction set to user space, we're free to do
>> what we want, no? Eventually what's in mainline kernel is that dictates an
>> ABI, so far we have it only in kernel space and the only current user of the
>> ABI is the conversion function from user BPF programs. Given that helper
>
> well, all the patches for llvm and the rest were posted.
> Obviously they cannot go in at once, but breaking this ABI right now
> makes it impossible to continue working on them.
> I want to make ebpf engine to be useful for tracing filters and so on.
> Are you saying forget it, this is classic bpf engine only?

Nope, I'm not saying that at all! As tracing has something similar, yes,
I already stated that it would probably be a good idea, i.e. when we could
JIT compile it.

>> function calls may happen less often than executing instructions from the
>> rest of the code, why can't your llvm/gcc backend emit the load of ctx into
>> arg1? JITs don't need to treat that differently in any way, imho. Simply
>
> I don't think we're on the same page here. compiler at the end is just
> a piece of sw and can do everything, but imbalanced ebpf ABI is really
> out of normal compiler work flow.
> Pretty much compiler somehow need to generate one way of passing
> arguments into a function, but inside the function it needs to expect
> them in different registers?! That is practically impossible to do
> in normal gcc/llvm.
> Even without any compiler insight.
> If you insist on ctx to be in R6 only, then please kill the whole
> concept of ABI in the doc. It doesn't make sense to pass a value
> into a function in R1, but the function will see in R6?!

Sorry, I don't think that this is what I claimed. I don't have a strong
opinion on this particular patch, just wanted to have clarified what we
have with ABI here as there's no particular freeze from the code we have
in the kernel. Anyway, I'll change it into the other variant and respin
the set, as that will already spare us a bit unnecessary of work in
fast-path.

>> the one who is generating the BPF insns needs to emit ctx into arg1 just as
>> he prepares the other argX registers. Btw, since we know a priori that
>> __skb_get_pay_offset() and __get_raw_cpu_id() are not making use of all
>> prepared registers, we could even go that far and avoid preparing loads for
>> the two.
