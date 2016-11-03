From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel
 encapsulation
Date: Thu, 3 Nov 2016 15:52:20 +0100
Message-ID: <c24f3ad9-764a-0ffa-51bf-2b42fb3ae585@stressinduktion.org>
References: <cover.1477959702.git.tgraf@suug.ch>
 <c220b6b2-3f20-09ff-2068-6ecfe0b47b9e@stressinduktion.org>
 <CACby=pmK9Pj00LYx9PQrgWe95xmy=qFhpjSYZT=QDnLQ55J=8w@mail.gmail.com>
 <1478030932.3136562.774196097.1F1AD6FB@webmail.messagingengine.com>
 <CACby=p=sSPfh0Lxr2qqk+wQ1=LVQvDU785Z9eTnT1GcKK=RoxA@mail.gmail.com>
 <3f9e7de1-1e61-2fb5-9529-c46343ac39c9@stressinduktion.org>
 <CACby=pnSX15XGuKBcw2FJkLz_qZt6XE+JS4ySN1Z6OZ=+w_eoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tom Herbert <tom@herbertland.com>,
        roopa <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35432 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755785AbcKCOw1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 10:52:27 -0400
In-Reply-To: <CACby=pnSX15XGuKBcw2FJkLz_qZt6XE+JS4ySN1Z6OZ=+w_eoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.11.2016 23:54, Thomas Graf wrote:
> On 1 November 2016 at 16:12, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 01.11.2016 21:59, Thomas Graf wrote:
>>>> Dumping and verifying which routes get used might actually already be
>>>> quite complex on its own. Thus my fear.
>>>
>>> We even have an API to query which route is used for a tuple. What
>>> else would you like to see?
>>
>> I am not sure here. Some ideas I had were to allow tcpdump (pf_packet)
>> sockets sniff at interfaces and also gather and dump the metadata to
>> user space (this would depend on bpf programs only doing the
>> modifications in metadata and not in the actual packet).
> 
> Not sure I understand. Why does this depend on BPF?

It doesn't. My hope was, if BPF merely tries to modify meta-data, we can
provide better debugging tools as if we mangle the packet directly.

>> Or maybe just tracing support (without depending on the eBPF program
>> developer to have added debugging in the BPF program).
> 
> Absolutely in favour of that.
> 
>>> This will be addressed with signing AFAIK.
>>
>> This sounds a bit unrealistic. Signing lots of small programs can be a
>> huge burden to the entity doing the signing (if it is not on the same
>> computer). And as far as I understood the programs should be generated
>> dynamically?
> 
> Right, for generated programs, a hash is a better fit and still sufficient.
> 
>>> Would it help if we allow to store the original source used for
>>> bytecode generation. What would make it clear which program was used.
>>
>> I would also be fine with just a strong hash of the bytecode, so the
>> program can be identified accurately. Maybe helps with deduplication
>> later on, too. ;)
> 
> OK, I think we all already agreed on doing this.
> 
>> Even though I read through the patchset I am not absolutely sure which
>> problem it really solves. Especially because lots of things can be done
>> already at the ingress vs. egress interface (I looked at patch 4 but I
>> am not sure how realistic they are).
> 
> Filtering at egress requires to attach the BPF program to all
> potential outgoing interface and then pass every single packet through
> the program whereas with LWT BPF, I'm only taking the cost where
> actually needed.

I do certainly see this point as a big plus. I definitely also thought
about this a lot when thinking about how flower can/should be used with
multiple interfaces and how to keep its flow tables synchronized.

>>> I also don't see how this could possibly scale if all packets must go
>>> through a single BPF program. The overhead will be tremendous if you
>>> only want to filter a couple of prefixes.
>>
>> In case of hash table lookup it should be fast. llvm will probably also
>> generate jump table for a few 100 ip addresses, no? Additionally the
>> routing table lookup could be not done at all.
> 
> Why would I want to accept the overhead if I simply avoid it? Just
> parsing the header and doing the hash lookup will add cost, cost for
> each packet.

That is true, but in case you are outside of the namespace, you still
have to calculate the cost of doing the FIB lookup for the BPF program
each time, too.

E.g. given the lookup cost in a hash for a netnwork namespace pointer
vs. the cost of doing a FIB lookup to get a program that does a specific
transformation sounds at least in the big O-notiation to be in a better
place. ;)

If you have to do both anyway, probably your patchset will perform
better, I agree.

Bye,
Hannes
