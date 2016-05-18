From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: rather use get_random_int for randomizations
Date: Wed, 18 May 2016 16:14:16 +0200
Message-ID: <573C78B8.2050400@iogearbox.net>
References: <24461974e8402395c12b3e36b9ac7935b88ef1c2.1463572456.git.daniel@iogearbox.net> <1463577634.18194.100.camel@edumazet-glaptop3.roam.corp.google.com> <e478c91f-28ec-e07a-6afd-0757ac72d1f3@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42758 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932107AbcEROOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 10:14:23 -0400
In-Reply-To: <e478c91f-28ec-e07a-6afd-0757ac72d1f3@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2016 03:28 PM, Hannes Frederic Sowa wrote:
> On 18.05.2016 15:20, Eric Dumazet wrote:
>> On Wed, 2016-05-18 at 14:14 +0200, Daniel Borkmann wrote:
>>> Start address randomization and blinding in BPF currently use
>>> prandom_u32(). prandom_u32() values are not exposed to unpriviledged
>>> user space to my knowledge, but given other kernel facilities such as
>>> ASLR, stack canaries, etc make use of stronger get_random_int(), we
>>> better make use of it here as well given blinding requests successively
>>> new random values. get_random_int() has minimal entropy pool depletion,
>>> is not cryptographically secure, but doesn't need to be for our use
>>> cases here.
>>
>> Well, if it is not crypto secure, what is the point using it instead of
>> prandom_u32() ?
>
> Leaks of prandom_u32 allows an attacker to find the whole sequence of
> generated random numbers or the other way around.
>
>> I do not think changing this is fundamentally changing something, it
>> looks like code churn or magic incantation to me.
>
> I saw this during the review of the blinding patches. I was afraid, that
> by extracting or dumping the ebpf program, a user could find out the
> blinding constant and after some retries could find out the coefficients
> to the taus rng, thus being able to infer the whole sequence generated
> by prandom_u32.

Note that dumping/extraction is normally not possible: cBPF progs hold the
original insns before they were even transformed into eBPF, and eBPF cannot
be dumped back today, so the rewrites stay kernel internal. Only when an
admin is not careful and accidentally sets things like bpf_jit_enable > 1,
where we have JIT debug mode and the generated image goes to dmesg (I don't
consider this the case normally, but what do I know).

>> There is little amount of entropy since the hole is constrained by
>> PAGE_SIZE.
>
> True.
>
> I don't consider this a big thing, I just mentioned that we probably
> shouldn't use prandom_u32 if the value somehow could leak to user space
> and should be used for security.

Agree here which is why I decided to send it.

Thanks,
Daniel
