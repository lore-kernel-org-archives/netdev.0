From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH net-next 7/8] net: ipv4: listified version of ip_rcv
Date: Tue, 19 Apr 2016 11:38:48 -0700
Message-ID: <CALx6S35g5fo1dxEfzvCpUvCWYDmo2_fLXJuGj_LTiz7c_qqnNQ@mail.gmail.com>
References: <5716338E.4050003@solarflare.com>
	<5716347D.3030808@solarflare.com>
	<1461077434.10638.189.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALx6S34ZFFFZVn2_ugp+eQg6QhdHj=CWPuvW3s9aC2dg75nqiQ@mail.gmail.com>
	<57166719.4070209@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37704 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932251AbcDSSiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 14:38:50 -0400
Received: by mail-ig0-f177.google.com with SMTP id g8so25760225igr.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 11:38:49 -0700 (PDT)
In-Reply-To: <57166719.4070209@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 10:12 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 19/04/16 16:46, Tom Herbert wrote:
>> On Tue, Apr 19, 2016 at 7:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> We have hard time to deal with latencies already, and maintaining some
>>> sanity in the stack(s)
>> Right, this is significant complexity for a fairly narrow use case.
> Why do you say the use case is narrow?  This approach should increase
> packet rate for any (non-GROed) traffic, whether for local delivery or
> forwarding.  If you're line-rate limited, it'll save CPU time instead.
> The only reason I focused my testing on single-byte UDP is because the
> benefits are more easily measured in that case.
>
It's a narrow use case because of the intent to "suggested that having
multiple packets traverse the network stack together". Beyond queuing
to the backlog I don't understand what more processing can be done
without splitting the list up. We need to do a route lookup on each
packet, need to run each through IP tables, need to deliver each
packet individually to the application. For the queuing to backlog
that seems to me to be more of a localized bulk enqueue/dequeue
problem instead of a stack level infrastructure problem.

The general alternative to grouping packets together is to apply
cached values that were found in lookups for previous "similar"
packets. Since nearly all traffic fits some profile of a flow, we can
leverage the point that packets in a flow should have similar lookup
results. So, for example, the first time we see a flow we can create a
flow state and save any results of lookups found for that packets in
the flow (route lookup, IP tables etc.). For subsequent packets, if we
match the flow then we have the answers for all the lookups we would
need. Maintaining temporal flow states and performing fixed 5-tuple
flow state lookups in the hash table is easy for a host (and we can
often throw a lot of memory at it to size hash tables to avoid
collisions). VLP matching, open ended rule chains, multi table
lookups, crazy hashes over 35 fields in headers are the things we only
want to do when there is no other recourse. This illustrates one
reason why a host is not a switch, we have no hardware to do complex
lookups.

Tom

> If anything, the use case is broader than GRO, because GRO can't be used
> for datagram protocols where packet boundaries must be maintained.
> And because the listified processing is at least partly sharing code with
> the regular stack, it's less complexity than GRO which has to have
> essentially its own receive stack, _and_ code to coalesce the results
> back into a superframe.
>
> I think if we pushed bundled RX all the way up to the TCP layer, it might
> potentially also be faster than GRO, because it avoids the work of
> coalescing superframes; plus going through the GRO callbacks for each
> packet could end up blowing icache in the same way the regular stack does.
> If bundling did prove faster, we could then remove GRO, and overall
> complexity would be _reduced_.
>
> But I admit it may be a long shot.
>
> -Ed
