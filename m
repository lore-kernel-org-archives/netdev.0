From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC patch 1/1] large netlink dumps
Date: Sat, 15 Apr 2017 20:08:57 -0700
Message-ID: <1492312137.10587.87.camel@edumazet-glaptop3.roam.corp.google.com>
References: <e17f52a6-b2ad-6b39-a655-2e8779a5d192@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33859 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754704AbdDPDJA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 23:09:00 -0400
Received: by mail-pf0-f194.google.com with SMTP id g23so5288473pfj.1
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 20:08:59 -0700 (PDT)
In-Reply-To: <e17f52a6-b2ad-6b39-a655-2e8779a5d192@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-15 at 13:07 -0400, Jamal Hadi Salim wrote:
> Eric,
> 
> How does attached look instead of the 32K?
> I found it helps to let user space suggest something
> larger.
> 
> cheers,
> jamal

Looks dangerous to me, for various reasons.

1) Memory allocations might not like it

Have you tried your change after user does a
setsockopt(    SO_RCVBUFFORCE,  256 Mbytes), and a 
recvmsg ( .. 64 Mbytes) ?

Presumably, we could replace 32768 by (PAGE_SIZE <<
PAGE_ALLOC_COSTLY_ORDER), but this will not matter on x86.

2) We might have paths in the kernel filling a potential big skb without
yielding cpu or a spinlock or a mutex. -> latency source.


What perf numbers do you have, using 1MB buffers instead of 32KB ?

The syscall overhead seems tiny compared to the actual cost of filling
the netlink message, accessing thousands of cache lines all over the
places.
