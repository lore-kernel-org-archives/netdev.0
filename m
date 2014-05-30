From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v6 net-next 1/4] net: flow_dissector: avoid multiple calls
 in eBPF
Date: Fri, 30 May 2014 10:12:19 -0700
Message-ID: <CA+ZOOTNobzzJPgQnVVZ+b6rRD=0_pdjUB8q5FQVkbO+dob0BSg@mail.gmail.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<1401389758-13252-1-git-send-email-chema@google.com>
	<5387C8AD.6000909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:39554 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933196AbaE3RMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 13:12:19 -0400
Received: by mail-ie0-f181.google.com with SMTP id rp18so1931254iec.26
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 10:12:19 -0700 (PDT)
In-Reply-To: <5387C8AD.6000909@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 4:54 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> I actually liked [1] most ... ;)
>
> Just an idea ...
>
> Have you taken into account the following: since thoff is u16 and ip_proto
> is u8 and you clearly seem to want to have the value of these two in your
> patch set (or even plus the poff value), why not squashing all these into
Note that I not only want thoff and ip_proto (the ones in patch #1 and
#2), but also nhoff and nproto. I could use the other flow_keys fields
(saddr, daddr, sport, dport), but they're one proto
comparison+indirect load away from [tn]hoff/[ip_|n]proto, so I don't
think it's worth to change BPF for them. Now, nhoff and proto are not
kept by the flow dissector. We cannot just add them to flow_keys as
the struct is used in some skb CB's that don't have any space left. I
have a patch that replaces thoff/ip_proto with nhof/proto (as the L4
info is easily obtainable from the L3 one, but not the other way
around), plus a fix of the couple of places where the L4 info is
actually used. I'll post it after these patches (and after your
code/decode cleaning goes through).

> one extension e.g. SKF_AD_DISSECT where you call the external
> skb_flow_dissect()
> helper or similar on?
>
> I could imagine that either these offsets are squashed into the return or
> stored if you really need them from the struct flow_keys into M[] itself. So
> you would end up with one e.g. 'ld #keys' call that e.g. fills
> out/overwrites
> your M[] with the dissected metadata. Then, you'd only have a reason to call
> that once and do further processing based on these information. Whether you
> also need poff could e.g. be determined if the user does e.g. 'ldx #1' or so
> to indicate to the function it eventually calls, that it would further do
> the dissect and also give you poff into fixed defined M[] slots back.

IIUC, you're suggesting to have the classic BPF user writes "ld #keys"
to load flow_keys in the stack and then *explicitly* adds "ld
mem[<offset>]" to access the field she's interested on. Note that if
the "ld mem[]" is implicit, then the user must use "ld #thoff" to let
the compiler know she wants "ld #keys" and then "ld
mem[<thoff_offset>]" (and not "ld mem[<other_offset>]"), which is
equivalent to what we're doing right now*.

The only advantage I can see is that we're only adding one new
ancillary load, which is more elegant. I can see some issues with this
approach:

- usability. The user has to actually know what's the right offset of
the thoff, which is cumbersome and may change with kernels. We'd be
effectively exporting the flow_keys struct layout to the users.
- have to take care that the classic BPF filter does not muck with
mem[] between the "ld #keys" and all of the the "ld* mem[]" that
access to it. Note that we're currently storing the flow_keys struct
in the stack outside of the mem[] words, so this is not a problem
here. (It is only accessible using ebpf insns.)

*Now, if your comment is ebpf-only, that could be ok. That would mean:

- a. the user writes "ld #thoff"
- b. the BPF->eBPF compiler generates one common BPF_CALL
(__skb_get_flow_dissect) plus a "ebpf_ldx stack[right_offset]". This
would not include payload_offset (which needs to run its own function
to get the poff from flow_keys).

Is this what you are proposing?

-Chema


> Thus if someone really only cares about headers, a use case like 'ld #poff +
> ret a' is sufficient, but if you need much more and don't want to do this in
> BPF like in your case, you go with 'ld #keys' and process your BPF program
> further via M[].
>
> Thanks,
>
> Daniel
>
>  [1] http://patchwork.ozlabs.org/patch/344271/
