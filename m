From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel encapsulation
Date: Tue, 1 Nov 2016 11:51:18 -0700
Message-ID: <CALx6S34ZVK1uHu_dYyh2w=k+8gP-H-nSPw-OgsMk9D2f4uE7jA@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <CALx6S35BhiY7DVPetEDrLwgsR3sKTcm-bJ6og-6N329Znavkww@mail.gmail.com>
 <CACby=pkPQC92t3Y9-p9RRUv1_WL2uZMM6DRJFUc5-KP4B41hAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        roopa <roopa@cumulusnetworks.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36297 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbcKASvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:51:20 -0400
Received: by mail-qk0-f194.google.com with SMTP id z190so12615046qkc.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 11:51:19 -0700 (PDT)
In-Reply-To: <CACby=pkPQC92t3Y9-p9RRUv1_WL2uZMM6DRJFUc5-KP4B41hAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2016 at 11:20 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 1 November 2016 at 09:17, Tom Herbert <tom@herbertland.com> wrote:
>> On Mon, Oct 31, 2016 at 5:37 PM, Thomas Graf <tgraf@suug.ch> wrote:
>>> {Open question:
>>>  Tom brought up the question on whether it is safe to modify the packet
>>>  in artbirary ways before dst_output(). This is the equivalent to a raw
>>>  socket injecting illegal headers. This v2 currently assumes that
>>>  dst_output() is ready to accept invalid header values. This needs to be
>>>  verified and if not the case, then raw sockets or dst_output() handlers
>>>  must be fixed as well. Another option is to mark lwtunnel_output() as
>>>  read-only for now.}
>>>
>> The question might not be so much about illegal headers but whether
>> fields in the skbuff related to the packet contents are kept correct.
>> We have protocol, header offsets, offsets for inner protocols also,
>> encapsulation settings, checksum status, checksum offset, checksum
>
> The headers cannot be extended or reduced so the offsets always remain
> correct. What can happen is that the header contains invalid data.
>
If we can't add/remove headers then doesn't that really limit the
utility of these patches? My assumption was that BPF+LWT is needed to
allow users to define and implement their own encapsulations, EH
insertion, packet modification, etc.

>> complete value, vlan information. Any or all of which I believe could
>> be turned into being incorrect if we allow the packet to be
>> arbitrarily modified by BPF. This problem is different than raw
>> sockets because LWT operates in the middle of the stack, the skbuff
>> has already been set up which such things.
>
> You keep saying this "middle in the stack" but the point is exactly
> the same as a raw socket with IPPROTO_RAW and hdrincl, see
> rawv6_sendmsg() and rawv6_send_hdrincl(). An IPv6 raw socket can feed
> arbitrary garbage into dst_output(). IPv4 does some minimal sanity
> checks.
>
What I mean is that an admin can create a BPF program that run on any
user packets (for instance default route could be set). This would be
in the path of TCP, UDP, and other protocols tightly integrated with
the stack. Packets being routed may be encapsulated, VLAN, have
checksum offload, GORed set etc. They also might be looped back in
which case the settings in skbuff become receive parameters.

> If this is a concern I'm fine with making the dst_output path read-only for now.
>
The might be good. The ramifications around allowing an open ended
method for users to modify L3/L2 packets needs more consideration.

>>> This series implements BPF program invocation from dst entries via the
>>> lightweight tunnels infrastructure. The BPF program can be attached to
>>> lwtunnel_input(), lwtunnel_output() or lwtunnel_xmit() and sees an L3
>>> skb as context. input is read-only, output can write, xmit can write,
>>> push headers, and redirect.
>>>
>>> Motiviation for this work:
>>>  - Restricting outgoing routes beyond what the route tuple supports
>>>  - Per route accounting byond realms
>>>  - Fast attachment of L2 headers where header does not require resolving
>>>    L2 addresses
>>>  - ILA like uses cases where L3 addresses are resolved and then routed
>>>    in an async manner
>>>  - Fast encapsulation + redirect. For now limited to use cases where not
>>>    setting inner and outer offset/protocol is OK.
>>>
>> Is checksum offload supported? By default, at least for Linux, we
>> offload the outer UDP checksum in VXLAN and the other UDP
>> encapsulations for performance.
>
> No. UDP encap is done by setting a tunnel key through a helper and
> letting the encapsulation device handle this. I don't currently see a
> point in replicating all of that logic.
