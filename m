From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH net-next v2] net: filter: add insn for loading internal
 transport header offset
Date: Fri, 2 May 2014 17:53:01 -0700
Message-ID: <CA+ZOOTP88BJ-keuR5NznCgbDVPyzugWkdsVYjKkk5yGOBbkddQ@mail.gmail.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<1398969880-8007-1-git-send-email-chema@google.com>
	<20140502.174928.1555908531689473830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34484 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbaECAxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 20:53:03 -0400
Received: by mail-ig0-f169.google.com with SMTP id h18so2515480igc.4
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 17:53:02 -0700 (PDT)
In-Reply-To: <20140502.174928.1555908531689473830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 2, 2014 at 2:49 PM, David Miller <davem@davemloft.net> wrote:
> From: Chema Gonzalez <chema@google.com>
> Date: Thu,  1 May 2014 11:44:40 -0700
>
>> Patch adds an ANC_TRA_OFFSET insn that loads the internal transport
>> header of a packet ("internal" meaning after decapsulation by the
>> flow dissector).
>>
>> Signed-off-by: Chema Gonzalez <chema@google.com>
>
> I'm not so convinced of this change.
>
> What are the use cases?
Any BPF filtering that depends on the inner-most L3/L4 header. In
particular, I want to write a BPF filter that depends on some fields
in the inner-most IP/L4 headers (currently the L4 ports, but at some
point I'll need to add the IP ToS field). I want my filter to support
both GRE and VLAN traffic. I started writing the filter
(ethernet-based L2):

start:
ldh [12]
jne #0x0800, ipv4parsing
jne #0x86dd, ipv6parsing
jne #0x88a8, vlanparsing
jne #0x8100, vlanparsing

ipv4parsing:
ldb [23]
jeq #6, tcpparsing
jeq #17, udpparsing
jeq #47, greparsing
...

vlanparsing:
...get new proto...
jne #0x0800, ipv4parsing2
jne #0x86dd, ipv6parsing2
jne #0x88a8, vlanparsing2
jne #0x8100, vlanparsing2
...

tcpparsing:
ldh [X+2]  ; dst port
...now we take a decision...

You get the issue: I found myself effectively rewriting the flow
dissector, using BPF syntax (no loops). Not fun. I'd like to use the
actual flow dissector. "ld #poff" already uses it, to get the snaplen
it should return. We should be able to access the transport (and
network) header itself. Something around the lines of:

ldh #toff  ; now A has the inner-most L4 header offset
ldh [A+2]  ; dst port
...now we take a decision...

ldh #noff  ; now A has the inner-most IP header offset
ldb [A+1]  ; ToS
...now we take a decision...

We probably want the proto (to differentiate IPv4 from IPv6) of the L3 header.

> If the use cases are to simply pull the ports out of the transport
> header for filter matching or hashing, don't just make a half-step
> like this.
I thought about that, but at some point I'll want to use other fields
(the ToS) to take filtering decisions. That means I'll have to do "ld
#noff". I started with #toff because it's straightforward (noff
requires adding the value in flow_keys). But, the fact that I need a
field other than the L3 fields that flow_keys export made me suspect
that somebody will need the same for the L4 fields at some point. I
find that more flexible than just providing the inner-most IP
addrs/ports from flow_keys.

> We can probably add an extension to AF_PACKET which provides the flow
> key at the end of the tpacket3_hdr if a certain socket option is set.
>
> That would provide the transport header as well as a side effect, and
> be much more powerful and efficient than this particular BPF
> instruction.
Once you get the L3 proto and noff/toff, you get everything. The
rationale of adding toff/noff is that it's very similar to poff, which
we already have.

-Chema
