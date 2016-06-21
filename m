From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Tue, 21 Jun 2016 09:56:57 -0700
Message-ID: <7d9a419a-2a35-7567-19f8-ca0ba4a08c06@stressinduktion.org>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <1202f4bd-ef27-8143-8067-2bba56b7355c@stressinduktion.org>
 <CALx6S34gNYs4ajDZv8My5auE9xyOpVKAT6qSf3-tc5EZdson0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:56990 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751922AbcFUQ5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 12:57:39 -0400
In-Reply-To: <CALx6S34gNYs4ajDZv8My5auE9xyOpVKAT6qSf3-tc5EZdson0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.06.2016 09:51, Tom Herbert wrote:
> On Thu, Jun 16, 2016 at 4:15 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 16.06.2016 19:51, Tom Herbert wrote:
>>> Transports over UDP is intended to encapsulate TCP and other transport
>>> protocols directly and securely in UDP.
>>>
>>> The goal of this work is twofold:
>>>
>>> 1) Allow applications to run their own transport layer stack (i.e.from
>>>    userspace). This eliminates dependencies on the OS (e.g. solves a
>>>    major dependency issue for Facebook on clients).
>>>
>>> 2) Make transport layer headers (all of L4) invisible to the network
>>>    so that they can't do intrusive actions at L4. This will be enforced
>>>    with DTLS in use.
>>>
>>> Note that #1 is really about running a transport stack in userspace
>>> applications in clients, not necessarily servers. For servers we
>>> intend to modified the kernel stack in order to leverage existing
>>> implementation for building scalable serves (hence these patches).
>>>
>>> This is described in more detail in the Internet Draft:
>>> https://tools.ietf.org/html/draft-herbert-transports-over-udp-00
>>>
>>> In Part I we implement a straightforward encapsulation of TCP in GUE.
>>> The implements the basic mechanics of TOU encapsulation for TCP,
>>> however does not yet implement the IP addressing interactions so
>>> therefore so this is not robust to use in the presence of NAT.
>>> TOU is enabled per socket with a new socket option. This
>>> implementation includes GSO, GRO, and RCO support.
>>>
>>> These patches also establish the baseline performance of TOU
>>> and isolate the performance cost of UDP encapsulation. Performance
>>> results are below.
>>>
>>> Tested: Various cases of TOU with IPv4, IPv6 using TCP_STREAM and
>>> TCP_RR. Also, tested IPIP for comparing TOU encapsulation to IP
>>> tunneling.
>>
>> Thinking about middleboxes again:
>>
>> E.g. https://tools.ietf.org/html/rfc6347#section-4.2.3 states that DTLS
>> packets are not allowed to be fragmented. Because of this and
>> furthermore because of the impossibility of clamp-mss-to-pmtu to work
>> anymore, do you have any idea on how reliable this can work?
>>
>> Or is your plan to use a smaller MSS on all paths by default?
>>
> Normal PMTU discovery mechanisms are applicable to prevent
> fragmentation. The overhead is accounted for in the MSS (similar to
> overhead of TCP options of IPv6 extension headers). Besides that,
> RFC6347 describes how fragmentation should be avoided, it does not
> explicitly forbid fragmentation, no IP protocol can outright forbid
> it. At most they could try to require DF bit is always set but that
> won't always be obeyed like when packets are tunneled in the network.

I agree, the specification is a bit unclear of what to do, but in terms
of not causing fragmentation it seems pretty clear to me:

"
   Each DTLS record MUST fit within a single datagram.  In order to
   avoid IP fragmentation, clients of the DTLS record layer SHOULD
   attempt to size records so that they fit within any PMTU estimates
   obtained from the record layer.
"

DTLS has invented its own fragmentation just to make sure that the
handshake actually doesn't depend on IP layer fragmentation.

Bye,
Hannes
