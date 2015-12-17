From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net 2/2] udp: restrict offloads to one namespace
Date: Thu, 17 Dec 2015 09:32:38 -0800
Message-ID: <CALx6S36B5LFgJqJB7Q98Z2KF74Ee3UDiqva6fm+8HEo_KFfTMA@mail.gmail.com>
References: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
	<1450209714-26037-2-git-send-email-hannes@stressinduktion.org>
	<20151216.190417.1337922066819496682.davem@davemloft.net>
	<56727731.2010605@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:32833 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbbLQRcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 12:32:39 -0500
Received: by mail-io0-f170.google.com with SMTP id 186so63638684iow.0
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 09:32:39 -0800 (PST)
In-Reply-To: <56727731.2010605@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 12:49 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi all,
>
> On 17.12.2015 01:04, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Tue, 15 Dec 2015 21:01:54 +0100
>>
>>> udp tunnel offloads tend to aggregate datagrams based on inner
>>> headers. gro engine gets notified by tunnel implementations about
>>> possible offloads. The match is solely based on the port number.
>>>
>>> Imagine a tunnel bound to port 53, the offloading will look into all
>>> DNS packets and tries to aggregate them based on the inner data found
>>> within. This could lead to data corruption and malformed DNS packets.
>>>
>>> While this patch minimizes the problem and helps an administrator to find
>>> the issue by querying ip tunnel/fou, a better way would be to match on
>>> the specific destination ip address so if a user space socket is bound
>>> to the same address it will conflict.
>>>
>>> Cc: Tom Herbert <tom@herbertland.com>
>>> Cc: Eric Dumazet <edumazet@google.com>
>>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>
>> It looks this issue is still being hashed out so I've marked this
>> patch as deferred for now.
>
>
> I think we need this patch. We later can decide to add more
> classification attributes, like dst ip down to gro, but the netns marks
> are important.
>
> With user namespaces a normal user can start a new network namespace
> with all privileges and thus add new offloads, letting the other stack
> interpret this garbage. Because the user namespace can also add
> arbitrary ip addresses to its interface, solely matching those is not
> enough.
>
> Tom any further comments?
>
I still don't think this addresses the core problem. If we're just
worried about offloads being added in a user namespace that conflict
with the those in the root space, it might be just as easy to disallow
setting offloads except in default namespace.

The core problem is that UDP port numbers don't have global meaning,
and don't really have any meaning to anyone except the sender and
receiver. This is different from IP protocol numbers, where IP
protocol number 6 is always interpreted as TCP anywhere in the
network. From RFC7605:

"It is important to recognize that any interpretation of port numbers
-- except at the endpoints -- may be incorrect, because port numbers
are meaningful only at the endpoints."

In the case of device offloads the device is not an endpoint so
interpretation of port numbers may be incorrect. This is also true in
GRO since it happens before it has been determined that packet is
being received at the local endpoint. The possibility of
misinterpretation based on destination port in the stack occurs when
we process packets that are later be forwarded as opposed to received
which can happen with netns or even with just forwarding enabled. If
the misinterpretation causes corruption or mis-delivery the fault lies
in the *implementation* not the protocol!

To address this in the host stack the solution is pretty
straightforward, we need to decide that the packet is going to be
received before applying any offloads. Essentially we want to do an
early_demux _really_ early. If we demux and get UDP socket for
instance, then the protocol specific GRO function can be retrieved
from the socket. So this will work with single listener port like
encaps do today,  and also if encapsulation is being used over a
connected socket. This also works if we want to support a user defined
GRO function like I mentioned we might want to do for QUIC etc.

For hardware offloads the problem is harder to solve to be completely
correct (or a least correct approaching 100% probability).
Possibilities are:
1) Use protocol agnostic offloads since they don't care about UDP or
port numbers (we've already discussed this!)
2) Use magic numbers in the protocol
(https://www.ietf.org/id/draft-herbert-udp-magic-numbers-01.txt).
3) Use ntuple filters identify the packets to be subject to offload
based on more than just. This really should have been the interface
for VXLAN offload from the beginning anyway!

Tom

> Thanks,
> Hannes
>
