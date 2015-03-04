From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH net] af_unix: don't poll dead peers
Date: Wed, 4 Mar 2015 21:39:52 +0100
Message-ID: <CA+rthh85wArTd9w7S_GhzbzMxrMRjWBym-4cEzc3MmkkUx+bsg@mail.gmail.com>
References: <1425499629-15223-1-git-send-email-minipli@googlemail.com>
	<1425500502.5130.232.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Olivier Mauras <olivier@mauras.ch>,
	Rainer Weikusat <rweikusat@mssgmbh.com>,
	PaX Team <pageexec@freemail.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:38493 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbbCDUjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 15:39:53 -0500
Received: by wiwh11 with SMTP id h11so33865184wiw.3
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 12:39:52 -0800 (PST)
In-Reply-To: <1425500502.5130.232.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 March 2015 at 21:21, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-03-04 at 21:07 +0100, Mathias Krause wrote:
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index 526b6edab018..0da9d7eeed17 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -2233,10 +2233,14 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>>       writable = unix_writable(sk);
>>       other = unix_peer_get(sk);
>>       if (other) {
>> -             if (unix_peer(other) != sk) {
>> +             unix_state_lock(other);
>> +             if (!sock_flag(other, SOCK_DEAD) && unix_peer(other) != sk) {
>> +                     unix_state_unlock(other);
>>                       sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
>>                       if (unix_recvq_full(other))
>>                               writable = 0;
>> +             } else {
>> +                     unix_state_unlock(other);
>>               }
>>               sock_put(other);
>>       }
>
>
> Using locks in _poll() is going to be tremendously expensive for some
> applications still using poll() or select() ?

I've no idea but we're already taking this very lock in the
unix_peer_get() call a few lines above.
My tests survived ~12 hours of stress testing without taking the lock,
too. But I'm not at all familiar with the locking semantics here, but
quite a few other locations in af_unix.c take the lock prior testing
the flag.
I'm happy either way -- with or without lock.

>
> This might be find for a stable candidate, but...
>I I
> It seems RCU locking might be more appropriate in this fast path.
>
> Please take a look at struct socket" and its "struct socket_wq __rcu
> *wq;"
>
> (commit 43815482370c510c569fd18edb57afcb0fa8cab6 for details)

I guess that would require more intrusive rewrites of the code I'm,
unfortunately, incapable to do right now. Maybe you are?

Thanks,
Mathias
