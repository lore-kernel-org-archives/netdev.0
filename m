From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] bpf: rather use get_random_int for randomizations
Date: Wed, 18 May 2016 15:28:01 +0200
Message-ID: <e478c91f-28ec-e07a-6afd-0757ac72d1f3@stressinduktion.org>
References: <24461974e8402395c12b3e36b9ac7935b88ef1c2.1463572456.git.daniel@iogearbox.net>
 <1463577634.18194.100.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:57148 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753011AbcERN2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 09:28:04 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 43A7F20D4E
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:28:03 -0400 (EDT)
In-Reply-To: <1463577634.18194.100.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.05.2016 15:20, Eric Dumazet wrote:
> On Wed, 2016-05-18 at 14:14 +0200, Daniel Borkmann wrote:
>> Start address randomization and blinding in BPF currently use
>> prandom_u32(). prandom_u32() values are not exposed to unpriviledged
>> user space to my knowledge, but given other kernel facilities such as
>> ASLR, stack canaries, etc make use of stronger get_random_int(), we
>> better make use of it here as well given blinding requests successively
>> new random values. get_random_int() has minimal entropy pool depletion,
>> is not cryptographically secure, but doesn't need to be for our use
>> cases here.
> 
> Well, if it is not crypto secure, what is the point using it instead of
> prandom_u32() ?

Leaks of prandom_u32 allows an attacker to find the whole sequence of
generated random numbers or the other way around.

> I do not think changing this is fundamentally changing something, it
> looks like code churn or magic incantation to me.

I saw this during the review of the blinding patches. I was afraid, that
by extracting or dumping the ebpf program, a user could find out the
blinding constant and after some retries could find out the coefficients
to the taus rng, thus being able to infer the whole sequence generated
by prandom_u32.

> There is little amount of entropy since the hole is constrained by
> PAGE_SIZE. 

True.

I don't consider this a big thing, I just mentioned that we probably
shouldn't use prandom_u32 if the value somehow could leak to user space
and should be used for security.

Bye,
Hannes
