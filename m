From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH] net: Require socket to allow XPS to set queue mapping
Date: Thu, 25 Aug 2016 14:08:33 -0700
Message-ID: <CAKgT0Ud0_3-1V1ykTSDYfPPJVqTjfW_ipuffcx1bd0RJxDiyMg@mail.gmail.com>
References: <147215300812.3936.8031402062962283044.stgit@ahduyck-desk.amr.corp.intel.com>
 <1472154564.14381.160.camel@edumazet-glaptop3.roam.corp.google.com> <3fd7a334-c660-6e31-1466-27b08a2c983f@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:35889 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbcHYVQ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 17:16:28 -0400
Received: by mail-it0-f45.google.com with SMTP id e63so296942213ith.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 14:16:28 -0700 (PDT)
In-Reply-To: <3fd7a334-c660-6e31-1466-27b08a2c983f@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 1:32 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 08/25/2016 12:49 PM, Eric Dumazet wrote:
>>
>> On Thu, 2016-08-25 at 12:23 -0700, Alexander Duyck wrote:
>>>
>>> A simpler approach is provided with this patch.  With it we disable XPS
>>> any
>>> time a socket is not present for a given flow.  By doing this we can
>>> avoid
>>> using XPS for any routing or bridging situations in which XPS is likely
>>> more of a hinderance than a help.
>>
>>
>> Yes, but this will destroy isolation for people properly doing VM cpu
>> pining.
>
>
> Why not simply stop enabling XPS by default. Treat it like RPS and RFS
> (unless I've missed a patch...). The people who are already doing the extra
> steps to pin VMs can enable XPS in that case.  It isn't clear that one
> should always pin VMs - for example if a (public) cloud needed to
> oversubscribe the cores.
>
> happy benchmarking,
>
> rick jones

The big motivation for most of the drivers to have it is because XPS
can provide very good savings when you end up aligning the entire
transmit path by also controlling the memory allocations and IRQ
affinity.  What most of these devices try to do by default is isolate
all of a given flow to a single CPU so you can get as close to linear
scaling as possible.  The problem is with XPS disabled by default you
take a pretty serious performance hit for all of the
non-virtualization cases since you can easily end up crossing CPUs or
worse yet NUMA nodes when processing Tx traffic.

Really if anything I still think we need to do something to enforce
ordering of flows in regards to things that make use of netif_rx
instead of using a NAPI processing path.  From what I can tell we will
always end up running into reordering issues as long as you can have a
single thread bouncing between CPUs and spraying packets on to the
various backlogs.  It is one of the reasons why I had mentioned
possibly enabling RPS for these type of interfaces as without it you
will still get some reordering, it just varies in the degree as to how
much.  Essentially all that is happening when you disable XPS is that
you shorten the queues, but there are still multiple queues in play.
You still can end up with packets getting reordered between the
various per_cpu backlogs.

- Alex
