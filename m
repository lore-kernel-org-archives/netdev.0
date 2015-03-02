From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Mon, 2 Mar 2015 22:38:50 +0200
Message-ID: <CAHsH6Gt=WjRb99SrDNo7YLBqXu=p+GsOEFF6O4dhRApfF7fAxw@mail.gmail.com>
References: <20150302132925.GB7418@breakpoint.cc>
	<CAHsH6Gu+ZHSdnnritKk5cjTg4NuKppYjffXjNpou2i+uVeykYA@mail.gmail.com>
	<20150302143647.GC7418@breakpoint.cc>
	<20150302.150556.807426896557970379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:41074 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbbCBUiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:38:51 -0500
Received: by yhaf10 with SMTP id f10so15955006yha.8
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 12:38:50 -0800 (PST)
In-Reply-To: <20150302.150556.807426896557970379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 10:05 PM, David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Mon, 2 Mar 2015 15:36:47 +0100
>
>> Eyal Birger <eyal.birger@gmail.com> wrote:
>>> On Mon, Mar 2, 2015 at 3:29 PM, Florian Westphal <fw@strlen.de> wrote:
>>> > Eyal Birger <eyal.birger@gmail.com> wrote:
>>> >> This patch set introduces a new socket option for fetching the mark
>>> >> of skbs passed to sockets as ancillary data.
>>> >>
>>> >> A userspace program may wish to receive the mark of packets it
>>> >> receives, for example for distinguishing between different TPROXY
>>> >> diversion rules to the same userspace proxy socket.
>>> >
>>> > Hmm... Whats the use case?
>>> > Even if you cannot use multiple sockets for every divert rule,
>>> > TPROXY doesn't mangle payload; applications could use sockaddrs
>>> > returned by accept, getpeername, getsockname etc.  to figure out
>>> > which original port/address the packet was sent to?
>>>
>>> Right. But that would mean the criteria for traffic diversion would need to
>>> be known to the application receiving the traffic.
>>
>> For your solution to work the application needs to know about the TPROXY
>> rule set and how that is structured, no?
>>
>> I don't see how that is 'better' than e.g. looking at dst port number.
>  ...
>>> For example, a user space daemon can receive traffic from multiple
>>> applications using a single socket and distinguish between different traffic groups
>>> according to the packet mark.
>>
>> Right, but it might as well use SO_PEERCRED to identify the other pid, right?
>
> Also, this points out that this socket option if accepted probably needs to
> be privileged.
>
> I can see administrators not being happy with applications being able to see
> the marks used by their rulesets.

Thanks. I'll add that.

>
> I'm backing out this series, Florian makes a lot of good points.

I can sum up the motivation for this feature as follows:

- skb->mark is set by user-space policy. It would make sense for
user-space to be
  able to query the resolution of that policy on a per packet basis -
even if solely for the
  purpose of debugging (e.g. fetching this meta-data on packet sockets
on the xmit path
  in order to debug tc behavior)

- skb->mark allows decoupling between match criteria and flow
semantics in TPROXY
  et al. For example, in cases where the match criteria is based on
deep packet inspection
  or a combination of packet parameters, the matching logic has to be
duplicated in an
  application receiving several flows in a single socket

- It allows the use of skb->mark for light-weight segmentation of
traffic groups within
  a single namespace. skb->mark can be used in route rules and may be
set from an
  application. A missing piece is receiving the skb->mark in
interested applications.
  Granted, such use-case mandates a moderated environment.
