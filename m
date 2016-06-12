From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: ebpf: issue with clang
Date: Sun, 12 Jun 2016 20:35:46 +0200
Message-ID: <575DAB82.5020608@iogearbox.net>
References: <1465506605.23482.10.camel@regit.org>	 <20160610003416.GA70641@ast-mbp.thefacebook.com> <1465753068.29807.14.camel@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Leblond <eric@regit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33074 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081AbcFLSfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 14:35:52 -0400
In-Reply-To: <1465753068.29807.14.camel@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2016 07:37 PM, Eric Leblond wrote:
> On Thu, 2016-06-09 at 17:34 -0700, Alexei Starovoitov wrote:
>> On Thu, Jun 09, 2016 at 11:10:05PM +0200, Eric Leblond wrote:
>>> Hello,
>>>
>>> I'm working on integrating ebpf cluster load balancing for
>>> AF_PACKET
>>> and I've got some problem to get real code inside the EBPF filter.
>>>
>>> I've tried different command lines in the build process. One of
>>> them
>>> is:
>>> clang-3.9 -Wall -O2 -emit-llvm -c hash_ports.c -o - | llc-3.9
>>> -march=bpf -filetype=obj -o hash_ports.bpf
>>>
>>> If I use that one, then the generated code is almost void. If I
>>> remove
>>> the -O2 then I've got a generated code that fails during load. When
>>> not
>>> using -O2, I manage to load a trivial filter (return of static
>>> value).
>>>
>>> The C code is the following (a derivative of http-simple-filter.c
>>> used
>>> for testing):
>>>
>>> int filter(struct __sk_buff *skb) {
>>> 	uint8_t *cursor = 0;
>>> 	struct ethernet_t *ethernet = cursor_advance(cursor,
>>> sizeof(*ethernet));
>>
>> this is bcc C syntax that is hiding the explicit load_byte/half/word
>> operations
>> we have to do when using plain C.
>> If you want to compile C code with clang -O2 -target bpf file.c -c -o
>> file.o
>> and copy .o around to be used in tc like:
>> tc filter add dev eth0 ingress bpf da obj file.o
>> then plain C should be used like in all samples/bpf/*_kern.c
>> examples.
>> Other folks like the convenience of bcc that hides clang/llvm
>> invocation.
>> It mostly applicable to tracing tools where both bcc-C and
>> corresponding python or lua bits are in the same file
>> like in iovisor/bcc/tools/* scripts.
>> The iovisor/bcc/examples/networking/* (where this http-simple-
>> filter.c came from)
>> are also suitable for networking and relying on pyroute2 to talk to
>> kernel to create netns, veth and to attach bpf to qdisc.
>>
>> In summary there are several ways to write bpf C code:
>> 1. plain C syntax as in samples/bpf/*_kern.c
>> Pro: compiles with clang into .o
>> Con: .o requires elf loader (integrated into tc already for
>> networking),
>
> Yes, that's not an easy part. I've devel one loader for suricata but I
> will check the one in tc to see if I can take advantage of it.

Sure, feel free to rip it out and adapt it.

With AF_PACKET load balancing you mean a packet fanout eBPF demuxing or
something else controlled via tc ingress?

If packet fanout, then you also need to adapt the program type into
BPF_PROG_TYPE_SOCKET_FILTER.

Thanks!

>> but not friendly for tracing that needs recompile for every kernel
>> due to unstable kprobes
>> 2. bcc C syntax that compiles C on the fly in memory and loads
>> directly
>> Pro: there is no .o, no extra files, no need to install clang/llvm
>> Con: bcc is not widely available yet. ubuntu and others already have
>> it in apt.
>> python and lua may not be for everyone. c++ api is not stable yet.
>
> I need to include it into suricata which is C code. I've played with
> bcc and it is a great tool but installation on the different platform
> may be complicated for our users.
>
>> 3. perf+bpf, it is similar to samples/pbf/ C style with few
>> extensions.
>> If .c file is passed, the perf calls external clang and loads .o
>> eventually
>> Pro: out-of-the-box perf and clang work well
>> Con: not available for networking
>
> Out of scope for me then.
>
>> Sounds like you want to use it with af_packet then
>> tools/testing/selftests/net/reuseport_bpf.c
>> could be a good start too, but there bpf is written in asm.
>
> Yes, bad point, asm is not really what I want. I want "normal advanced"
> users to be able to edit the load balancing function.
>
>> If you pick bcc style then iovisor-dev@lists.iovisor.org mailing list
>> is a good place to ask questions. Be sure to subscribe first, since
>> it rejects non-subscriber emails to reduce spam.
>
> Thanks a lot for all these explanations. You saved me days!
>
> BR,
>
