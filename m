From: Nikolay Borisov <kernel@kyup.com>
Subject: Re: kernel BUG at net/unix/garbage.c:149!"
Date: Tue, 27 Sep 2016 17:16:27 +0300
Message-ID: <57EA7F3B.3030801@kyup.com>
References: <57BDAE06.1040400@kyup.com>
 <9dde3145-9128-ffef-1b84-e3bd429dd4e8@stressinduktion.org>
 <CAOssrKddiaWQX+v7FZTJg9mwyhxHJCDQQMUJVwP17-z1ATrKWA@mail.gmail.com>
 <CAOssrKedUEAcZThhd2FB9UPzhr+5ErLjB=3+1z1XdnFeP6wvmg@mail.gmail.com>
 <CAOssrKcfncAYsQWkfLGFgoOxAQJVT2hYVWdBA6Cw7hhO8RJ_wQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Miklos Szeredi <mszeredi@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35212 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932189AbcI0OQc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 10:16:32 -0400
Received: by mail-wm0-f54.google.com with SMTP id l132so178972727wmf.0
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 07:16:30 -0700 (PDT)
In-Reply-To: <CAOssrKcfncAYsQWkfLGFgoOxAQJVT2hYVWdBA6Cw7hhO8RJ_wQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Added Dave Miller to see what's the status of this patch]

On 08/30/2016 12:18 PM, Miklos Szeredi wrote:
> On Tue, Aug 30, 2016 at 12:37 AM, Miklos Szeredi <mszeredi@redhat.com> wrote:
>> On Sat, Aug 27, 2016 at 11:55 AM, Miklos Szeredi <mszeredi@redhat.com> wrote:
> 
>> crash> list -H gc_inflight_list unix_sock.link -s unix_sock.inflight |
>> grep counter | cut -d= -f2 | awk '{s+=$1} END {print s}'
>> 130
>> crash> p unix_tot_inflight
>> unix_tot_inflight = $2 = 135
>>
>> We've lost track of a total of five inflight sockets, so it's not a
>> one-off thing.  Really weird...  Now off to sleep, maybe I'll dream of
>> the solution.
> 
> Okay, found one bug: gc assumes that in-flight sockets that don't have
> an external ref can't gain one while unix_gc_lock is held.  That is
> true because unix_notinflight() will be called before detaching fds,
> which takes unix_gc_lock.  Only MSG_PEEK was somehow overlooked.  That
> one also clones the fds, also keeping them in the skb.  But through
> MSG_PEEK an external reference can definitely be gained without ever
> touching unix_gc_lock.
> 
> Not sure whether the reported bug can be explained by this.  Can you
> confirm the MSG_PEEK was used in the setup?
> 
> Does someone want to write a stress test for SCM_RIGHTS + MSG_PEEK?
> 
> Anyway, attaching a fix that works by acquiring unix_gc_lock in case
> of MSG_PEEK also.  It is trivially correct, but I haven't tested it.
> 
> Thanks,
> Miklos
> 


Dave,

What's the status of https://patchwork.ozlabs.org/patch/664062/ , is
this going to be picked up ?

Regards,
Nikolay
