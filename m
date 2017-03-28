From: Chris Kuiper <ckuiper@google.com>
Subject: Re: [PATCH] net: udp: add socket option to report RX queue level
Date: Mon, 27 Mar 2017 18:08:17 -0700
Message-ID: <CA+BVk2evqfsaG68AUKFm-j6JfeYVYT7tJSxrDkPc3PQZ=kmLMw@mail.gmail.com>
References: <20170317211312.38117-1-ckuiper@google.com> <1489788070.28631.322.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Josh Hunt <johunt@akamai.com>, netdev@vger.kernel.org,
        Petri Gynther <pgynther@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:32848 "EHLO
        mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753413AbdC1BIT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 21:08:19 -0400
Received: by mail-yw0-f176.google.com with SMTP id v76so43784980ywg.0
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 18:08:18 -0700 (PDT)
In-Reply-To: <1489788070.28631.322.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I have been transferring jobs and had no time to look at this.

Josh Hunt's change seems to solve a different problem. I was looking
for something that works the same way as SO_RXQ_OVERFL, providing
information as ancillary data to the recvmsg() call. The problem with
SO_RXQ_OVERFL alone is that it tells you when things have already gone
wrong (you dropped data), so the new option SO_RX_ALLOC acts as a
leading indicator to check if you are getting close to hitting such
problem.

Regarding only UDP being supported, it is only meaningful for UDP. TCP
doesn't drop data and if its buffer gets full it just stops the sender
from sending more. The buffer level in that case doesn't even tell you
the whole picture, since it doesn't include any information on how
much additional buffering is done at the sender side.

In terms of "a lot overhead", logically the overhead of adding
additional getsockopt() calls after each recvmsg() is significantly
larger than just getting the information as part of recvmsg(). If you
don't need it, then don't enable this option. Admitted you can reduce
the frequency of calling getsockopt() relative to recvmsg(), but that
also increases your risk of missing the point where data is dropped.

-Chris


On Fri, Mar 17, 2017 at 3:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-03-17 at 14:13 -0700, Chris Kuiper wrote:
>> This adds a new socket option "SO_RXQ_ALLOC" that enables providing
>> the RX queue buffer allocation as ancillary data from the recvmsg()
>> system call. The value reported is a byte number and together with
>> the RX queue size (obtained via getsockopt(SO_RCVBUF) can be used to
>> calculate a percentage value on how full the socket buffer is.
>> ---
>
> Seems a lot of overhead, and only UDP would be supported.
>
> I very much prefer Josh Hunt proposal
> ( https://patchwork.ozlabs.org/patch/738250/ )
>
> Ie using a separate getsockopt() call instead of adding code to UDP fast
> path ?
>
>
>
