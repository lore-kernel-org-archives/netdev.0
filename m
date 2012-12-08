From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH 2/2] netfilter: add xt_bpf xtables match
Date: Sat, 8 Dec 2012 17:02:46 +0100
Message-ID: <CAD6jFUTKyNL3jJaok12BmTaLHWR2Wm4QeuO6FL8ZWX6KqPb+=A@mail.gmail.com>
References: <1354735339-13402-1-git-send-email-willemb@google.com>
	<1354735339-13402-3-git-send-email-willemb@google.com>
	<20121205194854.GB28730@1984>
	<CA+FuTSfoYmTNyJnUW4shzb7V1TXpSunbOOORdViXw4DoZ4aibA@mail.gmail.com>
	<20121207131638.GA3019@1984>
	<CA+FuTSdq0Mfpw6QRaa6LMBYAOcMfc8dGcSwWZBa7rvW1e89qQA@mail.gmail.com>
	<20121208033111.GB28114@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Willem de Bruijn <willemb@google.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, kaber <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48596 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933088Ab2LHQCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2012 11:02:55 -0500
In-Reply-To: <20121208033111.GB28114@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 8, 2012 at 4:31 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Fri, Dec 07, 2012 at 11:56:05AM -0500, Willem de Bruijn wrote:
>> On Fri, Dec 7, 2012 at 8:16 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> > On Wed, Dec 05, 2012 at 03:10:13PM -0500, Willem de Bruijn wrote:
>> >> On Wed, Dec 5, 2012 at 2:48 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> >> > Hi Willem,
>> >> >
>> >> > On Wed, Dec 05, 2012 at 02:22:19PM -0500, Willem de Bruijn wrote:
>> >> >> A new match that executes sk_run_filter on every packet. BPF filters
>> >> >> can access skbuff fields that are out of scope for existing iptables
>> >> >> rules, allow more expressive logic, and on platforms with JIT support
>> >> >> can even be faster.
>> >> >>
>> >> >> I have a corresponding iptables patch that takes `tcpdump -ddd`
>> >> >> output, as used in the examples below. The two parts communicate
>> >> >> using a variable length structure. This is similar to ebt_among,
>> >> >> but new for iptables.
>> >> >>
>> >> >> Verified functionality by inserting an ip source filter on chain
>> >> >> INPUT and an ip dest filter on chain OUTPUT and noting that ping
>> >> >> failed while a rule was active:
>> >> >>
>> >> >> iptables -v -A INPUT -m bpf --bytecode '4,32 0 0 12,21 0 1 $SADDR,6 0 0 96,6 0 0 0,' -j DROP
>> >> >> iptables -v -A OUTPUT -m bpf --bytecode '4,32 0 0 16,21 0 1 $DADDR,6 0 0 96,6 0 0 0,' -j DROP
>> >> >
>> >> > I like this BPF idea for iptables.
>> >> >
>> >> > I made a similar extension time ago, but it was taking a file as
>> >> > parameter. That file contained in BPF code. I made a simple bison
>> >> > parser that takes BPF code and put it into the bpf array of
>> >> > instructions. It would be a bit more intuitive to define a filter and
>> >> > we can distribute it with iptables.
>> >>
>> >> That's cleaner, indeed. I actually like how tcpdump operates as a
>> >> code generator if you pass -ddd. Unfortunately, it generates code only
>> >> for link layer types of its supported devices, such as DLT_EN10MB and
>> >> DLT_LINUX_SLL. The network layer interface of basic iptables
>> >> (forgetting device dependent mechanisms as used in xt_mac) is DLT_RAW,
>> >> but that is rarely supported.
>> >
>> > Indeed, you'll have to hack on tcpdump to select the offset. In
>> > iptables the base is the layer 3 header. With that change you could
>> > use tcpdump for generate code automagically from their syntax.
>> >
>> >> > Let me check on my internal trees, I can put that user-space code
>> >> > somewhere in case you're interested.
>> >>
>> >> Absolutely. I'll be happy to revise to get it in. I'm also considering
>> >> sending a patch to tcpdump to make it generate code independent of the
>> >> installed hardware when specifying -y.
>> >
>> > I found a version of the old parser code I made:
>> >
>> > http://1984.lsi.us.es/git/nfbpf/
>> >
>> > It interprets a filter expressed in a similar way to tcpdump -dd but
>> > it's using the BPF constants. It's quite preliminary and simple if you
>> > look at the code.
>> >
>> > Extending it to interpret some syntax similar to tcpdump -d would even
>> > make more readable the BPF filter.
>> >
>> > Time ago I also thought about taking the kernel code that checks that
>> > the filter is correct. Currently you get -EINVAL if you pass a
>> > handcrafted filter which is incorrect, so it's hard task to debug what
>> > you made wrong.
>> >
>> > It could be added to the iptables tree. Or if generic enough for BPF
>> > and the effort is worth, just provide some small library that iptables
>> > can link with and a small compiler/checker to help people develop BPF
>> > filters.
>>
>> Or use pcap_compile? I went with the tcpdump output to avoid
>> introducing a direct dependency on pcap to iptables. One possible
>> downside I see to pcap_compile vs. developing from scratch is that it
>> might lag in supporting the LSF ancillary data fields.
>
> I suggest to put the code of that preliminary nfbpf utility into
> iptables to allow to read the BPF filters from a file and put them
> into the BPF array of instructions. I can help with that.
>
>> > Back to your xt_bpf thing, we can use the file containing the code
>> > instead:
>> >
>> > iptables -v -A INPUT -m bpf --bytecode-file filter1.bpf -j DROP
>> > iptables -v -A OUTPUT -m bpf --bytecode-file filter2.bpf -j DROP
>> >
>> > We can still allow the inlined filter via --bytecode if you want.
>>
>> I'll add that. I'd like to keep --bytecode to able to generate the
>> code inline using backticks.
>
> As said, I'm fine with that, but I'll be really happy if we can
> provide some utility to generate that code using backticks for the
> masses (in case they want to pass it inlined in that format).

If it helps, you could use "bpfc", or rip-off its code to not have a
dependency; it's part of the netsniff-ng toolkit.

It can be used like:

bpfc examples/bpfc/arp.bpf
{ 0x28, 0, 0, 0x0000000c },
{ 0x15, 0, 1, 0x00000806 },
{ 0x6, 0, 0, 0xffffffff },
{ 0x6, 0, 0, 0x00000000 },

where arp.bpf is, for instance:

_main:
  ldh [12]
  jeq #0x806, keep, drop
keep:
  ret #0xffffffff
drop:
  ret #0

"Core" files are: src/bpf_lexer.l, src/bpf_parser.y

It also supports all Linux ANC-operations that were added to the
kernel (like VLAN, XOR and so on). I started but didn't have time to
continue a higher-level language for that, that would translate to
such an example above (which then translates again to opcodes).
