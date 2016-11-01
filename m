From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel encapsulation
Date: Tue, 1 Nov 2016 11:20:31 -0700
Message-ID: <CACby=pkPQC92t3Y9-p9RRUv1_WL2uZMM6DRJFUc5-KP4B41hAA@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <CALx6S35BhiY7DVPetEDrLwgsR3sKTcm-bJ6og-6N329Znavkww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        roopa <roopa@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:33970 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752297AbcKASUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:20:33 -0400
Received: by mail-vk0-f52.google.com with SMTP id x186so77695777vkd.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 11:20:32 -0700 (PDT)
In-Reply-To: <CALx6S35BhiY7DVPetEDrLwgsR3sKTcm-bJ6og-6N329Znavkww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 November 2016 at 09:17, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Oct 31, 2016 at 5:37 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> {Open question:
>>  Tom brought up the question on whether it is safe to modify the packet
>>  in artbirary ways before dst_output(). This is the equivalent to a raw
>>  socket injecting illegal headers. This v2 currently assumes that
>>  dst_output() is ready to accept invalid header values. This needs to be
>>  verified and if not the case, then raw sockets or dst_output() handlers
>>  must be fixed as well. Another option is to mark lwtunnel_output() as
>>  read-only for now.}
>>
> The question might not be so much about illegal headers but whether
> fields in the skbuff related to the packet contents are kept correct.
> We have protocol, header offsets, offsets for inner protocols also,
> encapsulation settings, checksum status, checksum offset, checksum

The headers cannot be extended or reduced so the offsets always remain
correct. What can happen is that the header contains invalid data.

> complete value, vlan information. Any or all of which I believe could
> be turned into being incorrect if we allow the packet to be
> arbitrarily modified by BPF. This problem is different than raw
> sockets because LWT operates in the middle of the stack, the skbuff
> has already been set up which such things.

You keep saying this "middle in the stack" but the point is exactly
the same as a raw socket with IPPROTO_RAW and hdrincl, see
rawv6_sendmsg() and rawv6_send_hdrincl(). An IPv6 raw socket can feed
arbitrary garbage into dst_output(). IPv4 does some minimal sanity
checks.

If this is a concern I'm fine with making the dst_output path read-only for now.

>> This series implements BPF program invocation from dst entries via the
>> lightweight tunnels infrastructure. The BPF program can be attached to
>> lwtunnel_input(), lwtunnel_output() or lwtunnel_xmit() and sees an L3
>> skb as context. input is read-only, output can write, xmit can write,
>> push headers, and redirect.
>>
>> Motiviation for this work:
>>  - Restricting outgoing routes beyond what the route tuple supports
>>  - Per route accounting byond realms
>>  - Fast attachment of L2 headers where header does not require resolving
>>    L2 addresses
>>  - ILA like uses cases where L3 addresses are resolved and then routed
>>    in an async manner
>>  - Fast encapsulation + redirect. For now limited to use cases where not
>>    setting inner and outer offset/protocol is OK.
>>
> Is checksum offload supported? By default, at least for Linux, we
> offload the outer UDP checksum in VXLAN and the other UDP
> encapsulations for performance.

No. UDP encap is done by setting a tunnel key through a helper and
letting the encapsulation device handle this. I don't currently see a
point in replicating all of that logic.
