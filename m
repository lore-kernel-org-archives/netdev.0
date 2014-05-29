From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v6 net-next 1/4] net: flow_dissector: avoid multiple calls
 in eBPF
Date: Fri, 30 May 2014 01:54:21 +0200
Message-ID: <5387C8AD.6000909@redhat.com>
References: <1398882591-30422-1-git-send-email-chema@google.com> <1401389758-13252-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753930AbaE2Xy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 19:54:28 -0400
In-Reply-To: <1401389758-13252-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2014 08:55 PM, Chema Gonzalez wrote:
> This patch makes __skb_get_pay_offset() (the function called by
> the eBPF call generated from "ld #poff") store the output of the flow
> dissector (a flow_keys structure) in the eBPF stack. This way, multiple
> invocations of this eBPF call in the same BPF filter will only require
> one single call to the flow dissector.
>
> Note that other eBPF calls that use the flow dissector can use the same
> approach, and share the results, so at the end there is only one single
> call to the flow dissector per packet.
>
> Tested:
>
> $ cat tools/net/ipv4_tcp_poff2.bpf
> ldh [12]
> jne #0x800, drop
> ldb [23]
> jneq #6, drop
> ld poff
> ld poff
> ld poff
> ld poff
> ret #-1
> drop: ret #0
> $ ./tools/net/bpf_asm tools/net/ipv4_tcp_poff2.bpf
> 10,40 0 0 12,21 0 7 2048,48 0 0 23,21 0 5 6,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,6 0 0 4294967295,6 0 0 0,
>
> And then, in a VM, we ran:
>
> $ tcpdump -n -i eth0 -f "10,40 0 0 12,21 0 7 2048,48 0 0 23,21 0 5 6,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,6 0 0 4294967295,6 0 0 0,"
>
> This tcpdump is github's tcpdump HEAD with pull request #353, which
> allows using raw filters in tcpdump.
>
> Debugging the kernel, we can see that there only the first "ld poff" call
> does invoke the flow dissector. The other calls reuse the value in the
> eBPF stack.
>
> Also tested the test_bpf module.
>
> Signed-off-by: Chema Gonzalez <chema@google.com>

I actually liked [1] most ... ;)

Just an idea ...

Have you taken into account the following: since thoff is u16 and ip_proto
is u8 and you clearly seem to want to have the value of these two in your
patch set (or even plus the poff value), why not squashing all these into
one extension e.g. SKF_AD_DISSECT where you call the external skb_flow_dissect()
helper or similar on?

I could imagine that either these offsets are squashed into the return or
stored if you really need them from the struct flow_keys into M[] itself. So
you would end up with one e.g. 'ld #keys' call that e.g. fills out/overwrites
your M[] with the dissected metadata. Then, you'd only have a reason to call
that once and do further processing based on these information. Whether you
also need poff could e.g. be determined if the user does e.g. 'ldx #1' or so
to indicate to the function it eventually calls, that it would further do
the dissect and also give you poff into fixed defined M[] slots back.

Thus if someone really only cares about headers, a use case like 'ld #poff +
ret a' is sufficient, but if you need much more and don't want to do this in
BPF like in your case, you go with 'ld #keys' and process your BPF program
further via M[].

Thanks,

Daniel

  [1] http://patchwork.ozlabs.org/patch/344271/
