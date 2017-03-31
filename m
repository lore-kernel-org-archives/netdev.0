From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: udp: add socket option to report RX queue level
Date: Fri, 31 Mar 2017 09:13:43 -0700
Message-ID: <1490976823.8750.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170317211312.38117-1-ckuiper@google.com>
         <1489788070.28631.322.camel@edumazet-glaptop3.roam.corp.google.com>
         <CA+BVk2evqfsaG68AUKFm-j6JfeYVYT7tJSxrDkPc3PQZ=kmLMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Josh Hunt <johunt@akamai.com>, netdev@vger.kernel.org,
        Petri Gynther <pgynther@google.com>
To: Chris Kuiper <ckuiper@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34248 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933126AbdCaQNq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 12:13:46 -0400
Received: by mail-pg0-f65.google.com with SMTP id o123so18387563pga.1
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 09:13:45 -0700 (PDT)
In-Reply-To: <CA+BVk2evqfsaG68AUKFm-j6JfeYVYT7tJSxrDkPc3PQZ=kmLMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please do not top post on netdev

On Mon, 2017-03-27 at 18:08 -0700, Chris Kuiper wrote:
> Sorry, I have been transferring jobs and had no time to look at this.
> 
> Josh Hunt's change seems to solve a different problem. I was looking
> for something that works the same way as SO_RXQ_OVERFL, providing
> information as ancillary data to the recvmsg() call. The problem with
> SO_RXQ_OVERFL alone is that it tells you when things have already gone
> wrong (you dropped data), so the new option SO_RX_ALLOC acts as a
> leading indicator to check if you are getting close to hitting such
> problem.

SO_RXQ_OVERFL gives a very precise info for every skb that was queued.

This is a different indicator, because it can tell you where is the
discontinuity point at the time skb were queued, not at the time they
are dequeued.

Just tune SO_RCVBUF to not even have to care about this.

By the time you sample the queue occupancy, the information might be
completely stale and queue already overflowed.

There is very little point having a super system call gathering all kind
of (stale) info

> 
> Regarding only UDP being supported, it is only meaningful for UDP. TCP
> doesn't drop data and if its buffer gets full it just stops the sender
> from sending more. The buffer level in that case doesn't even tell you
> the whole picture, since it doesn't include any information on how
> much additional buffering is done at the sender side.
> 

We have more protocols than UDP and TCP in linux kernel.

> In terms of "a lot overhead", logically the overhead of adding
> additional getsockopt() calls after each recvmsg() is significantly
> larger than just getting the information as part of recvmsg(). If you
> don't need it, then don't enable this option. Admitted you can reduce
> the frequency of calling getsockopt() relative to recvmsg(), but that
> also increases your risk of missing the point where data is dropped.

Your proposal adds overhead for all UDP recvmsg() calls, while most of
them absolutely not care about overruns. There is little you can do if
you are under attack or if your SO_RCVBUF is too small for the workload.

Some people work hard to reach 2 Millions UDP recvmsg() calls per second
on a single UDP socket, so everything added in fast path will be
scrutinized.
