From: Tom Herbert <tom@herbertland.com>
Subject: Re: epoll, missed opportunity?
Date: Sat, 19 Sep 2015 08:46:56 -0700
Message-ID: <CALx6S35cR5hwEyBT2zCg2PcFeOQQqr0Hek4bP=iG7aT7D5wMZw@mail.gmail.com>
References: <CACKT+AqSZS+o-C2osio7PWy+2bKuveT-uU2znSOHBjNRKxc0-A@mail.gmail.com>
	<1442676118.29850.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACKT+Ap2n7d0C06=1bq=qvJ9o-6X+-EUNcGdLreszL=fABTguQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jonathan Marler <johnnymarler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:36850 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbbISPq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 11:46:57 -0400
Received: by ioii196 with SMTP id i196so84025859ioi.3
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 08:46:56 -0700 (PDT)
In-Reply-To: <CACKT+Ap2n7d0C06=1bq=qvJ9o-6X+-EUNcGdLreszL=fABTguQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 19, 2015 at 8:30 AM, Jonathan Marler <johnnymarler@gmail.com> wrote:
> The data field holds the file descriptor you are waiting on, it has to
> be the file descriptor, otherwise, how would the kernel know which
> file descriptor you are trying to wait on?
>
fd is the third argument in epoll_ctl.

int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);

> On Sat, Sep 19, 2015 at 9:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2015-09-18 at 22:51 -0600, Jonathan Marler wrote:
>>> I'm curious why there wasn't another field added to the epoll_event
>>> struct for the application to store the descriptor's context. Any
>>> useful multi-plexing application will have a context that will need to
>>> be retrieved every time a descriptor needs to be serviced. Since the
>>> epoll api has no way of storing this context, it has to be looked up
>>> using the descriptor, which will take more time/memory as the number
>>> of descriptors increase. The memory saved from omitting this context
>>> can't be worth it since you'll have to allocate the memory in the
>>> application anyway, plus you're now adding the extra lookup.
>>>
>>> This "lookup" problem has always existed in multi-plexed applications.
>>> It was impossible to fix with older polling interfaces, however, since
>>> epoll is stateful, it provides an opportunity to fix this problem by
>>> storing the descriptor context in epoll's "state". What was the reason
>>> for not doing this?  Was it an oversight or am I missing something?
>>
>>
>> typedef union epoll_data
>> {
>>   void *ptr;
>>   int fd;
>>   uint32_t u32;
>>   uint64_t u64;
>> } epoll_data_t;
>>
>> struct epoll_event
>> {
>>   uint32_t events;      /* Epoll events */
>>   epoll_data_t data;    /* User data variable */
>> } __EPOLL_PACKED;
>>
>>
>>
>> Application is free to use whatever is needed in poll_data_t
>>
>> You can store a pointer to your own data (ptr)
>> Or a 32 bit cookie (u32)
>> Or a 64 bit cookie (u64)
>>
>> (But is an union, you have to pick one of them)
>>
>> Nothing forces you to use 'fd', kernel does not care.
>>
>>
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
