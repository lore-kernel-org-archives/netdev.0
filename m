From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH net-next 7/8] net: ipv4: listified version of ip_rcv
Date: Tue, 19 Apr 2016 08:46:39 -0700
Message-ID: <CALx6S34ZFFFZVn2_ugp+eQg6QhdHj=CWPuvW3s9aC2dg75nqiQ@mail.gmail.com>
References: <5716338E.4050003@solarflare.com>
	<5716347D.3030808@solarflare.com>
	<1461077434.10638.189.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	linux-net-drivers@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37860 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932598AbcDSPqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 11:46:42 -0400
Received: by mail-ig0-f182.google.com with SMTP id g8so20490499igr.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 08:46:42 -0700 (PDT)
In-Reply-To: <1461077434.10638.189.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 7:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-04-19 at 14:37 +0100, Edward Cree wrote:
>> Also involved adding a way to run a netfilter hook over a list of packets.
>> Rather than attempting to make netfilter know about lists (which would be
>> horrendous) we just let it call the regular okfn (in this case
>> ip_rcv_finish()) for any packets it steals, and have it give us back a list
>> of packets it's synchronously accepted (which normally NF_HOOK would
>> automatically call okfn() on, but we want to be able to potentially pass
>> the list to a listified version of okfn().)
>>
>> There is potential for out-of-order receives if the netfilter hook ends up
>> synchronously stealing packets, as they will be processed before any accepts
>> earlier in the list.  However, it was already possible for an asynchronous
>> accept to cause out-of-order receives, so hopefully I haven't broken
>> anything that wasn't broken already.
>>
>> Signed-off-by: Edward Cree <ecree@solarflare.com>
>> ---
>
> We have hard time to deal with latencies already, and maintaining some
> sanity in the stack(s)
>
Right, this is significant complexity for a fairly narrow use case.
One alternative might be to move early type demux like functionality
to the GRO layer. There's a lot of work done by GRO to parse and
identify packets of the same flow, even if we can't aggregate such
packets it might be nice if we can at least provide a cached route so
that we avoid doing a full route lookup on each one later on.

Tom

> This is not going to give us a 10x or even 2x improvement factor, so
> what about working on something that would really lower cache line
> misses and use pipelines to amortize the costs ?
>
> The main problem in UDP stack today is having to lock the socket because
> of the dumb forward allocation problem. Are you really going to provide
> a list of skbs up to _one_ UDP socket ?
>
>
>
