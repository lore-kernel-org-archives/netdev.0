From: Jonathan Marler <johnnymarler@gmail.com>
Subject: Re: epoll, missed opportunity?
Date: Sat, 19 Sep 2015 09:30:47 -0600
Message-ID: <CACKT+Ap2n7d0C06=1bq=qvJ9o-6X+-EUNcGdLreszL=fABTguQ@mail.gmail.com>
References: <CACKT+AqSZS+o-C2osio7PWy+2bKuveT-uU2znSOHBjNRKxc0-A@mail.gmail.com>
	<1442676118.29850.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:34081 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952AbbISPar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 11:30:47 -0400
Received: by oiev17 with SMTP id v17so40193699oie.1
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 08:30:47 -0700 (PDT)
In-Reply-To: <1442676118.29850.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The data field holds the file descriptor you are waiting on, it has to
be the file descriptor, otherwise, how would the kernel know which
file descriptor you are trying to wait on?

On Sat, Sep 19, 2015 at 9:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2015-09-18 at 22:51 -0600, Jonathan Marler wrote:
>> I'm curious why there wasn't another field added to the epoll_event
>> struct for the application to store the descriptor's context. Any
>> useful multi-plexing application will have a context that will need to
>> be retrieved every time a descriptor needs to be serviced. Since the
>> epoll api has no way of storing this context, it has to be looked up
>> using the descriptor, which will take more time/memory as the number
>> of descriptors increase. The memory saved from omitting this context
>> can't be worth it since you'll have to allocate the memory in the
>> application anyway, plus you're now adding the extra lookup.
>>
>> This "lookup" problem has always existed in multi-plexed applications.
>> It was impossible to fix with older polling interfaces, however, since
>> epoll is stateful, it provides an opportunity to fix this problem by
>> storing the descriptor context in epoll's "state". What was the reason
>> for not doing this?  Was it an oversight or am I missing something?
>
>
> typedef union epoll_data
> {
>   void *ptr;
>   int fd;
>   uint32_t u32;
>   uint64_t u64;
> } epoll_data_t;
>
> struct epoll_event
> {
>   uint32_t events;      /* Epoll events */
>   epoll_data_t data;    /* User data variable */
> } __EPOLL_PACKED;
>
>
>
> Application is free to use whatever is needed in poll_data_t
>
> You can store a pointer to your own data (ptr)
> Or a 32 bit cookie (u32)
> Or a 64 bit cookie (u64)
>
> (But is an union, you have to pick one of them)
>
> Nothing forces you to use 'fd', kernel does not care.
>
>
>
>
