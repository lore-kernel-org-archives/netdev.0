From: Tom Herbert <tom@herbertland.com>
Subject: Re: Initial thoughts on TXDP
Date: Thu, 1 Dec 2016 12:39:04 -0800
Message-ID: <CALx6S35TA3==A=gCt0SR9af1pEHFAVTwS1rHoAeHcm8kEUYg6g@mail.gmail.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
 <20161201135508.GB24547@oracle.com> <CALx6S35DCyi_2z1pqCLaB1bVyNykP_J3YaYEXUT8xxmuzyBDwA@mail.gmail.com>
 <20161201201324.GJ24547@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:33630 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758439AbcLAUjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:39:06 -0500
Received: by mail-qt0-f173.google.com with SMTP id p16so232238045qta.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 12:39:06 -0800 (PST)
In-Reply-To: <20161201201324.GJ24547@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 12:13 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (12/01/16 11:05), Tom Herbert wrote:
>>
>> Polling does not necessarily imply that networking monopolizes the CPU
>> except when the CPU is otherwise idle. Presumably the application
>> drives the polling when it is ready to receive work.
>
> I'm not grokking that- "if the cpu is idle, we want to busy-poll
> and make it 0% idle"?  Keeping CPU 0% idle has all sorts
> of issues, see slide 20 of
>  http://www.slideshare.net/shemminger/dpdk-performance
>
>> > and one other critical difference from the hot-potato-forwarding
>> > model (the sort of OVS model that DPDK etc might aruguably be a fit for)
>> > does not apply: in order to figure out the ethernet and IP headers
>> > in the response correctly at all times (in the face of things like VRRP,
>> > gw changes, gw's mac addr changes etc) the application should really
>> > be listening on NETLINK sockets for modifications to the networking
>> > state - again points to needing a select() socket set where you can
>> > have both the I/O fds and the netlink socket,
>> >
>> I would think that that is management would not be implemented in a
>> fast path processing thread for an application.
>
> sure, but my point was that *XDP and other stack-bypass methods needs
> to provide a select()able socket: when your use-case is not about just
> networking, you have to snoop on changes to the control plane, and update
> your data path. In the OVS case (pure networking) the OVS control plane
> updates are intrinsic to OVS. For the rest of the request/response world,
> we need a select()able socket set to do this elegantly (not really
> possible in DPDK, for example)
>
I'm not sure that TXDP can be reconciled to help OVS. The point of
TXDP is to drive applications closer to bare metal performance, as I
mentioned this is only going to be worth it if the fast path can be
kept simple and not complicated by a requirement for generalization.
It seems like the second we put OVS in we're doubling the data path
and accepting the performance consequences of a complex path anyway.

TXDP can't over the whole system (any more than DPDK can) and needs to
work in concert with other mechanisms-- the key is how to steer the
work amongst the CPUs. For instance, if a latency critical thread is
running on some CPU we either a dedicated queue for the connections of
the thread (e.g. ntuple filtering or aRFS support) or we need a fast
way to get move unrelated packets received on a queue processed by
that CPU to other CPUs (less efficient, but no special HW support is
needed either).

Tom

>
>> The *SOs are always an interesting question. They make for great
>> benchmarks, but in real life the amount of benefit is somewhat
>> unclear. Under the wrong conditions, like all cwnds have collapsed or
>
> I think Rick's already bringing up this one.
>
> --Sowmini
>
