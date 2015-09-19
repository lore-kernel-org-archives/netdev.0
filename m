From: Jonathan Marler <johnnymarler@gmail.com>
Subject: Re: epoll, missed opportunity?
Date: Sat, 19 Sep 2015 09:51:22 -0600
Message-ID: <CACKT+Ao8OLchwUHPn-PKebx3pi2opMg9LH+SGaj+xdghfbSVag@mail.gmail.com>
References: <CACKT+AqSZS+o-C2osio7PWy+2bKuveT-uU2znSOHBjNRKxc0-A@mail.gmail.com>
	<1442676118.29850.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACKT+Ap2n7d0C06=1bq=qvJ9o-6X+-EUNcGdLreszL=fABTguQ@mail.gmail.com>
	<CALx6S35cR5hwEyBT2zCg2PcFeOQQqr0Hek4bP=iG7aT7D5wMZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:34755 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755098AbbISPvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 11:51:23 -0400
Received: by obbda8 with SMTP id da8so57040650obb.1
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 08:51:22 -0700 (PDT)
In-Reply-To: <CALx6S35cR5hwEyBT2zCg2PcFeOQQqr0Hek4bP=iG7aT7D5wMZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wow how did I miss that?! This is perfect though, there is a context
pointer!  Finally my dream of a perfect polling interface exists in
linux.  Thanks so much for the quick response.

On Sat, Sep 19, 2015 at 9:46 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Sat, Sep 19, 2015 at 8:30 AM, Jonathan Marler <johnnymarler@gmail.com> wrote:
>> The data field holds the file descriptor you are waiting on, it has to
>> be the file descriptor, otherwise, how would the kernel know which
>> file descriptor you are trying to wait on?
>>
> fd is the third argument in epoll_ctl.
>
> int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
>
>> On Sat, Sep 19, 2015 at 9:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Fri, 2015-09-18 at 22:51 -0600, Jonathan Marler wrote:
>>>> I'm curious why there wasn't another field added to the epoll_event
>>>> struct for the application to store the descriptor's context. Any
>>>> useful multi-plexing application will have a context that will need to
>>>> be retrieved every time a descriptor needs to be serviced. Since the
>>>> epoll api has no way of storing this context, it has to be looked up
>>>> using the descriptor, which will take more time/memory as the number
>>>> of descriptors increase. The memory saved from omitting this context
>>>> can't be worth it since you'll have to allocate the memory in the
>>>> application anyway, plus you're now adding the extra lookup.
>>>>
>>>> This "lookup" problem has always existed in multi-plexed applications.
>>>> It was impossible to fix with older polling interfaces, however, since
>>>> epoll is stateful, it provides an opportunity to fix this problem by
>>>> storing the descriptor context in epoll's "state". What was the reason
>>>> for not doing this?  Was it an oversight or am I missing something?
>>>
>>>
>>> typedef union epoll_data
>>> {
>>>   void *ptr;
>>>   int fd;
>>>   uint32_t u32;
>>>   uint64_t u64;
>>> } epoll_data_t;
>>>
>>> struct epoll_event
>>> {
>>>   uint32_t events;      /* Epoll events */
>>>   epoll_data_t data;    /* User data variable */
>>> } __EPOLL_PACKED;
>>>
>>>
>>>
>>> Application is free to use whatever is needed in poll_data_t
>>>
>>> You can store a pointer to your own data (ptr)
>>> Or a 32 bit cookie (u32)
>>> Or a 64 bit cookie (u64)
>>>
>>> (But is an union, you have to pick one of them)
>>>
>>> Nothing forces you to use 'fd', kernel does not care.
>>>
>>>
>>>
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
