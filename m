From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v3 net-next 1/3] net: flow_dissector: avoid multiple calls
 in BPF
Date: Wed, 14 May 2014 14:51:34 -0700
Message-ID: <CA+ZOOTOiPAAXR18ZVYyE8czk7CPTNjCFaVcNssWXxYvXfeCs3A@mail.gmail.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<1400093480-498-1-git-send-email-chema@google.com>
	<CAMEtUuxOC3krRcwcuUaMHwBOC_7pGckVFmpU0f_NsMs-5j586w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:46793 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbaENVve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 17:51:34 -0400
Received: by mail-ig0-f174.google.com with SMTP id h3so7155845igd.13
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 14:51:34 -0700 (PDT)
In-Reply-To: <CAMEtUuxOC3krRcwcuUaMHwBOC_7pGckVFmpU0f_NsMs-5j586w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, May 14, 2014 at 1:05 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> I have a feeling that you didn't test this. Even basic "tcpdump port 22"
> will be broken,
Not sure whether you understood the use of this. I'm not trying to
change how to compile tcpdump expressions. The only way to access the
new features is using Daniel's bpf_asm code.

I did test the code:

$ cat tools/net/ipv4_tcp_poff2.bpf
ldh [12]
jne #0x800, drop
ldb [23]
jneq #6, drop
ld poff
ld poff
ld poff
ld poff
ld toff
ld toff
ld toff
ld tproto
ld tproto
ld tproto
ret #-1
drop: ret #0
$ ./tools/net/bpf_asm tools/net/ipv4_tcp_poff2.bpf
16,40 0 0 12,21 0 13 2048,48 0 0 23,21 0 11 6,32 0 0 4294963252,32 0 0
4294963252,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963260,32 0
0 4294963260,32 0 0 4294963260,32 0 0 4294963264,32 0 0 4294963264,32
0 0 4294963264,6 0 0 4294967295,6 0 0 0,

And then, in a VM, I ran:

$ tcpdump -n -i eth0 -f "16,40 0 0 12,21 0 13 2048,48 0 0 23,21 0 11
6,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,32 0 0
4294963252,32 0 0 4294963260,32 0 0 4294963260,32 0 0 4294963260,32 0
0 4294963264,32 0 0 4294963264,32 0 0 4294963264,6 0 0 4294967295,6 0
0 0,"

This tcpdump is github's tcpdump HEAD with
https://github.com/the-tcpdump-group/libpcap/pull/353.

Adding some labels let me see how the flow dissector was only called
for the first "ld poff":

[    7.003362] --------__skb_get_poff(): checking flow dissector: {0,
0, 0, 0, 0} inited returns 0
[    7.005618] --------__skb_get_poff(): after calling flow dissector:
{-26957632, 23374016, 369113781, 34, 6}
[    7.006821] --------__skb_get_poff(): checking flow dissector:
{-26957632, 23374016, 369113781, 34, 6} inited returns 1
[    7.008156] --------__skb_get_poff(): checking flow dissector:
{-26957632, 23374016, 369113781, 34, 6} inited returns 1
[    7.009485] --------__skb_get_poff(): checking flow dissector:
{-26957632, 23374016, 369113781, 34, 6} inited returns 1
[    7.010827] --------__skb_get_tra_offset(): checking flow
dissector: {-26957632, 23374016, 369113781, 34, 6} inited returns 1
[    7.013630] --------__skb_get_tra_offset(): checking flow
dissector: {-26957632, 23374016, 369113781, 34, 6} inited returns 1
[    7.015969] --------__skb_get_tra_offset(): checking flow
dissector: {-26957632, 23374016, 369113781, 34, 6} inited returns 1
[    7.017357] --------__skb_get_tra_protocol(): checking flow
dissector: {-26957632, 23374016, 369113781, 34, 6} inited returns 1
[    7.018749] --------__skb_get_tra_protocol(): checking flow
dissector: {-26957632, 23374016, 369113781, 34, 6} inited returns 1
[    7.020137] --------__skb_get_tra_protocol(): checking flow
dissector: {-26957632, 23374016, 369113781, 34, 6} inited returns 1

> let alone BPF testsuite. It also breaks seccomp, new JIT
> and tracing filter patches I've posted yesterday.
Note that the flow_keys field is only used by those functions actually
calling the flow dissector (originally __skb_get_poff(), and after
this set of patches __skb_get_tra_offset and __skb_get_tra_protocol).
If any non-packet user is calling any of these functions, you have an
issue there.

Sorry if I broke your patches from yesterday. I didn't see them. I'll
check them.

> sk_run_filter() is a generic interpreter that should be suitable for
> sockets, seccomp, tracing, etc. Adding one use case specific data
> structure to interpreter is not desirable.
That's an interesting point, which you'd agree does apply to "ld poff"
right now. There's a tradeoff here between making the BPF VM as
generic as possible, and having to reimplement in BPF VM code
functions that already exist in the kernel (the flow dissector
itself). I think not having 2 flow dissectors in the kernel (one in C,
one in BPF VM code) is a win.

> Doing memset(&flow,0...) every invocation is not performance
> friendly either. Majority of filters will suffer.
Will fix. In retrospect, I should have just added an flow_keys_is_init
field instead of mapping {0, 0, {0}, 0, 0} to "not inited."

> You can do the same without touching sk_run_filter().
> For example, you can tweak sk_convert_filter() to pass
> R10(frame pointer) as arg4 to helper functions
> (__skb_get_pay_offset() and others)
> then inside those functions cast 'arg4 - appropriate offset'
> to struct flow_keys and use it.
> BPF was extended from 16 spill/fill only slots to generic
> stack space exactly for this type of use cases.
I tried several implementations, including the one you propose:

1. add flow_keys to skb CB (packet_skb_cb)
The problem here is that struct flow_keys (15 bytes) does not fit in
AF_PACKET's 48-byte skb CB. I also tried to create a small_flow_keys
struct that only contains L3 info (nhoff/proto, which is the minimum
output you need from the flow dissector to be able to get the rest
without having to rewalk the packet), or maybe L3 and L4
(thoff/ip_proto). The problem is that the packet CB is completely full
already. packet_skb_cb is 4 (origlen) + 20 (sockaddr_ll) and
MAX_ADDR_LEN=32, so the net/packet/af_packet.c:1822 check is 4+20+32-8
= 48, which is already the size of the sk_buff->CB.

2. add flow_keys using the stack in the 3 BPF filter runners
(original, eBPF, JIT)
  - (-) there are 6x BPF engines (1x non-JIT and 5x JIT)
  - (+) we can just do the non-JIT version, and let JITs implement it
when they want)
  - (+) very simple

3. add FLOW, BPF_REG_FLOW, map it to a register, and then pass it as
R4. This is what you're proposing, IIIC. I found the implementation
way more complicated (in fact I gave up trying to make it not crash
;), but I guess this is my own taste. What really convinced me to
extend the context is that, if you think about it, both the skb and
the flow_keys are part of the context that the bpf_calls use to run.
If we pass flow_keys in R4, and we ever want to add more context
parameters to a call, that means using R5. And then what?

> Key point: you can add pretty much any feature to classic BPF
> by tweaking converter from classic to internal without changing
> interpreter and causing trainwreck for non-socket use cases.
Again, the patch is not breaking the current functionality. We already
provide "ld poff" as a recognition that packet processing is a first
class citizen of the BPF VM. If you run a seccomp filter containing a
"ld poff" right now, you're probably causing issues anyway.

> The idea itself I think is quite interesting. I'm only disliking its
> implementation.
Thanks a lot for the comments.

-Chema
