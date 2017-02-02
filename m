From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH/RFC net-next 1/2] flow dissector: ND support
Date: Thu, 2 Feb 2017 09:24:40 -0800
Message-ID: <CALx6S37b00GfUBQ5imVfOhg2Rbp_GtDntkwqyj3cN8kzt6gG0w@mail.gmail.com>
References: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
 <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
 <1486038693.13103.20.camel@edumazet-glaptop3.roam.corp.google.com> <20170202155849.GA28482@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33236 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752127AbdBBRYl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 12:24:41 -0500
Received: by mail-qt0-f195.google.com with SMTP id n13so5375691qtc.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 09:24:41 -0800 (PST)
In-Reply-To: <20170202155849.GA28482@penelope.horms.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 7:58 AM, Simon Horman <simon.horman@netronome.com> wrote:
> [Repost due to gmail account problem]
>
> On Thu, Feb 02, 2017 at 04:31:33AM -0800, Eric Dumazet wrote:
>> On Thu, 2017-02-02 at 11:37 +0100, Simon Horman wrote:
>> > Allow dissection of Neighbour Discovery target IP, and source and
>> > destination link-layer addresses for neighbour solicitation and
>> > advertisement messages.
>> >
>> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
>> > ---
>>
>> Hi Simon
>>
>> Why is this needed ?
>>
>> Any code added in flow dissector needs to be extra careful,
>> we had various packet of deaths errors recently in this area.
>
> Hi Eric,
>
> there some activity to allow programming of OvS flows in hardware via TC
> with the flower classifier. As the ND fields in this patch are part of the
> OvS flow key I would like them considered for additions to flower and thus
> the dissector to allow compatibility with OvS.
>
Given that ARP is already there it seems only "fair" to have ND also.
But Eric is correct, this is quite a sensitive area of code.

> I apologise if any 'deaths' have resulted from my recent work on the
> dissector. I am of course very open to ideas on how to avoid any future
> incidents.

That's a tough problem. flow_dissector started off as simple mechanism
to just identify actual flows (really just TCP and UDP packets) for
the purposes of packet steering. But given the benefits of its
location low in the stack and the open ended capabilities for parsing
it seems to have mushroomed into a general catchall to parse a whole
bunch of different protocols. A lot of these go beyond simply
identifying flows (ICMP parsing, ARP, or ND as in your patches). These
new use cases may be valid, but the result is a convoluted function (>
500 LOC by my count) and it seems to be quite easy to have subtle bugs
mostly in edge cases, several of which could have been exploited in
DDOS attacks.

At some point we need to stop adding new protocols to parse in
__skb_flow_dissect and push the processing back into the protocol
modules with a callout interface from flow_dissector (for instance if
we ever want VXLAN parsing in flow dissector this is the only
reasonable way to do it). That moves the complexity but doesn't solve
the problem of buggy code in this critical path. An alternative might
be to put a cap on flow_dissector and add a hook to BPF program to
allow parsing of new protocols. This has the advantage of providing an
constrained interface that could eliminate possibility of some types
of bugs we've seen. Also, this allows adding support for "user"
protocols that the kernel might not even know about (QUIC comes to
mind).

Tom
