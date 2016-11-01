From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel
 encapsulation
Date: Tue, 1 Nov 2016 23:12:40 +0100
Message-ID: <3f9e7de1-1e61-2fb5-9529-c46343ac39c9@stressinduktion.org>
References: <cover.1477959702.git.tgraf@suug.ch>
 <c220b6b2-3f20-09ff-2068-6ecfe0b47b9e@stressinduktion.org>
 <CACby=pmK9Pj00LYx9PQrgWe95xmy=qFhpjSYZT=QDnLQ55J=8w@mail.gmail.com>
 <1478030932.3136562.774196097.1F1AD6FB@webmail.messagingengine.com>
 <CACby=p=sSPfh0Lxr2qqk+wQ1=LVQvDU785Z9eTnT1GcKK=RoxA@mail.gmail.com>
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
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:40540 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751134AbcKAWMn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 18:12:43 -0400
In-Reply-To: <CACby=p=sSPfh0Lxr2qqk+wQ1=LVQvDU785Z9eTnT1GcKK=RoxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.11.2016 21:59, Thomas Graf wrote:
> On 1 November 2016 at 13:08, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On Tue, Nov 1, 2016, at 19:51, Thomas Graf wrote:
>>> If I understand you correctly then a single BPF program would be
>>> loaded which then applies to all dst_output() calls? This has a huge
>>> drawback, instead of multiple small BPF programs which do exactly what
>>> is required per dst, a large BPF program is needed which matches on
>>> metadata. That's way slower and renders one of the biggest advantages
>>> of BPF invalid, the ability to generate a a small program tailored to
>>> a particular use. See Cilium.
>>
>> I thought more of hooks in the actual output/input functions specific to
>> the protocol type (unfortunately again) protected by jump labels? Those
>> hook get part of the dst_entry mapped so they can act on them.
> 
> This has no advantage over installing a BPF program at tc egress and
> enabling to store/access metadata per dst. The whole point is to
> execute bpf for a specific route.

The advantage I saw here was that in your proposal the tc egress path
would have to be chosen by a route. Otherwise I would already have
proposed it. :)

>> Another idea would be to put the eBPF hooks into the fib rules
>> infrastructure. But I fear this wouldn't get you the hooks you were
>> looking for? There they would only end up in the runtime path if
>> actually activated.
> 
> Use of fib rules kills performance so it's not an option. I'm not even
> sure that would be any simpler.

It very much depends on the number of rules installed. If there are just
several very few rules, it shouldn't hurt performance that much (but
haven't verified).

>> Dumping and verifying which routes get used might actually already be
>> quite complex on its own. Thus my fear.
> 
> We even have an API to query which route is used for a tuple. What
> else would you like to see?

I am not sure here. Some ideas I had were to allow tcpdump (pf_packet)
sockets sniff at interfaces and also gather and dump the metadata to
user space (this would depend on bpf programs only doing the
modifications in metadata and not in the actual packet).

Or maybe just tracing support (without depending on the eBPF program
developer to have added debugging in the BPF program).

>>> If it's based on metadata then you need to know the program logic and
>>> associate it with the metadata in the dst. It actually doesn't get
>>> much easier than to debug one of the samples, they are completely
>>> static once compiled and it's very simple to verify if they do what
>>> they are supposed to do.
>>
>> At the same time you can have lots of those programs and you e.g. would
>> also need to verify if they are acting on the same data structures or
>> have the identical code.
> 
> This will be addressed with signing AFAIK.

This sounds a bit unrealistic. Signing lots of small programs can be a
huge burden to the entity doing the signing (if it is not on the same
computer). And as far as I understood the programs should be generated
dynamically?

>> It all reminds me a bit on grepping in source code which makes heavy use
>> of function pointers with very generic and short names.
> 
> Is this statement related to routing? I don't get the reference to
> function pointers and generic short names.

No, just an anecdotal side note how I felt when I saw the patchset. ;)

>>> If you like the single program approach, feel free to load the same
>>> program for every dst. Perfectly acceptable but I don't see why we
>>> should force everybody to use that model.
>>
>> I am concerned having 100ths of BPF programs, all specialized on a
>> particular route, to debug. Looking at one code file and its associated
>> tables seems still easier to me.
> 
> 100 programs != 100 source files. A lot more realistic is a single or
> a handful of programs which get compiled for a particular route with
> certain pieces enabled/disabled.
> 
>> E.g. imaging we have input routes and output routes with different BPF
>> programs. We somehow must make sure all nodes kind of behave accordingly
>> to "sane" network semantics. If you end up with an input route doing bpf
> 
> As soon as we have signing, you can verify your programs in testing,
> sign the programs and then quickly verify on all your nodes whether
> you are running the correct programs.
> 
> Would it help if we allow to store the original source used for
> bytecode generation. What would make it clear which program was used.

I would also be fine with just a strong hash of the bytecode, so the
program can be identified accurately. Maybe helps with deduplication
later on, too. ;)

>> processing and the according output node, which e.g. might be needed to
>> reflect ICMP packets, doesn't behave accordingly you at least have two
>> programs to debug already instead of a switch- or if-condition in one
>> single code location. I would like to "force" this kind of symmetry to
>> developers using eBPF, thus I thought meta-data manipulation and
>> verification inside the kernel would be a better attack at this problem,
>> no?
> 
> Are you saying you want a single gigantic program for both input and output?

Even though I read through the patchset I am not absolutely sure which
problem it really solves. Especially because lots of things can be done
already at the ingress vs. egress interface (I looked at patch 4 but I
am not sure how realistic they are).

> That's not possible. The BPF program has different limitations
> depending on where it runs. On input, any write action on the packet
> is not allowed, extending the header is only allowed on xmit, and so
> on.
> 
> I also don't see how this could possibly scale if all packets must go
> through a single BPF program. The overhead will be tremendous if you
> only want to filter a couple of prefixes.

In case of hash table lookup it should be fast. llvm will probably also
generate jump table for a few 100 ip addresses, no? Additionally the
routing table lookup could be not done at all.

Thanks,
Hannes
