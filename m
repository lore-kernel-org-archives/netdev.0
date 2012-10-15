From: enh <enh@google.com>
Subject: Re: listen(2) backlog changes in or around Linux 3.1?
Date: Mon, 15 Oct 2012 10:26:41 -0700
Message-ID: <CAJgzZoqhw6HJxa6uRbekLMaVTDVOo92YDtzqHnZoRiQ8tq6G2g@mail.gmail.com>
References: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com>
 <507C4401.7050500@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:51128 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183Ab2JOR1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 13:27:02 -0400
Received: by mail-qc0-f174.google.com with SMTP id o22so262330qcr.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 10:27:01 -0700 (PDT)
In-Reply-To: <507C4401.7050500@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 15, 2012 at 10:12 AM, Venkat Venkatsubra
<venkat.x.venkatsubra@oracle.com> wrote:
> On 10/12/2012 6:40 PM, enh wrote:
>>
>> i used to use the following hack to unit test connect timeouts: i'd
>> call listen(2) on a socket and then deliberately connect (backlog + 3)
>> sockets without accept(2)ing any of the connections. (why 3? because
>> Stevens told me so, and experiment backed him up. see figure 4.10 in
>> his UNIX Network Programming.)
>>
>> with "old" kernels, 2.6.35-ish to 3.0-ish, this worked great. my next
>> connect(2) to the same loopback port would hang indefinitely. i could
>> even unblock the connect by calling accept(2) in another thread. this
>> was awesome for testing.
>>
>> in 3.1 on ARM, 3.2 on x86 (Ubuntu desktop), and 3.4 on ARM, this no
>> longer works. it doesn't seem to be as simple as "the constant is no
>> longer 3". my tests are now flaky. sometimes they work like they used
>> to, and sometimes an extra connect(2) will succeed. (or, if i'm in
>> non-blocking mode, my poll(2) will return with the non-blocking socket
>> that's trying to connect now ready.)
>>
>> i'm guessing if this changed in 3.1 and is still changed in 3.4,
>> whatever's changed wasn't an accident. but i haven't been able to find
>> the right search terms to RTFM. i also finally got around to grepping
>> the kernel for the "+ 3", but wasn't able to find that. (so i'd be
>> interested to know where the old behavior came from too.)
>>
>> my least worst workaround at the moment is to use one of RFC5737's
>> test networks, but that requires that the device have a network
>> connection, otherwise my connect(2)s fail immediately with
>> ENETUNREACH, which is no use to me. also, unlike my old trick, i've
>> got no way to suddenly "unblock" a slow connect(2) (this is useful for
>> unit testing the code that does the poll(2) part of the usual
>> connect-with-timeout implementation).
>> https://android-review.googlesource.com/#/c/44563/
>>
>> hopefully someone here can shed some light on this? ideally someone
>> will have a workaround as good as my old trick. i realize i was
>> relying on undocumented behavior, and i'm happy to have to check
>> /proc/version and behave appropriately, but i'd really like a way to
>> keep my unit tests!
>>
>> thanks,
>>   elliott
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> Hi Elliott,
>
> In BSD I think the backlog used to be reset to 3/2 times that passed by the
> user. So, 2 becomes 3.
> Probably the 1/2 times increase was to accommodate the ones in
> partial/incomplete queue.
> In Linux is it possible you were getting the same behavior before the below
> commit ?
> Since the check used to be "backlog+1" a 2 will behave as 3 ?

i don't think so, because with <= 3.0 kernels i used to have a backlog
of 1 and be able to make _4_ connections before my next connect would
hang. but this > to >= change is at least something for me to
investigate...

> commit 8488df894d05d6fa41c2bd298c335f944bb0e401
> Author: Wei Dong <weid@np.css.fujitsu.com>
> Date:   Fri Mar 2 12:37:26 2007 -0800
>
>     [NET]: Fix bugs in "Whether sock accept queue is full" checking
>
>         when I use linux TCP socket, and find there is a bug in function
> sk_acceptq_is_full().
>
>         When a new SYN comes, TCP module first checks its validation. If
> valid,
>     send SYN,ACK to the client and add the sock to the syn hash table. Next
>     time if received the valid ACK for SYN,ACK from the client. server will
>     accept this connection and increase the sk->sk_ack_backlog -- which is
>     done in function tcp_check_req().We check wether acceptq is full in
>     function tcp_v4_syn_recv_sock().
>
>     Consider an example:
>
>      After listen(sockfd, 1) system call, sk->sk_max_ack_backlog is set to
>     1. As we know, sk->sk_ack_backlog is initialized to 0. Assuming accept()
>     system call is not invoked now.
>
>     1. 1st connection comes. invoke sk_acceptq_is_full().
>      sk->sk_ack_backlog=0 sk->sk_max_ack_backlog=1, function return 0 accept
> this connection.
>      Increase the sk->sk_ack_backlog
>     2. 2nd connection comes. invoke sk_acceptq_is_full().
>      sk->sk_ack_backlog=1 sk->sk_max_ack_backlog=1, function return 0 accept
> this connection.
>      Increase the sk->sk_ack_backlog
>     3. 3rd connection comes. invoke sk_acceptq_is_full().
>      sk->sk_ack_backlog=2 sk->sk_max_ack_backlog=1, function return 1.
> Refuse this connection.
>
>     I think it has bugs. after listen system call. sk->sk_max_ack_backlog=1
>     but now it can accept 2 connections.
>
>     Signed-off-by: Wei Dong <weid@np.css.fujitsu.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> Venkat
