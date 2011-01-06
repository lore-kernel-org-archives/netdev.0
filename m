From: Leonardo Chiquitto <leonardo.lists@gmail.com>
Subject: Re: POLLPRI/poll() behavior change since 2.6.31
Date: Thu, 6 Jan 2011 16:10:23 -0200
Message-ID: <AANLkTi=iiT9rYobAzJgbd6SBwkOqDBHKTenmb+4xhs9=@mail.gmail.com>
References: <20110106155040.GA27769@libre.l.ngdn.org>
	<1294332929.3074.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57841 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab1AFSPS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 13:15:18 -0500
Received: by wwa36 with SMTP id 36so17670560wwa.1
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 10:15:12 -0800 (PST)
In-Reply-To: <1294332929.3074.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 6, 2011 at 2:55 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 06 janvier 2011 =E0 13:50 -0200, Leonardo Chiquitto a =E9cri=
t :
>> Hello,
>>
>> Since 2.6.31, poll() no longer returns when waiting exclusively for =
a
>> POLLPRI event. If we wait for POLLPRI | POLLIN, though, it will
>> correctly return POLLPRI as a received event.
>>
>> The reproducer (code below) will print the following when running on
>> 2.6.30:
>>
>> $ ./pollpri-oob
>> main: starting
>> main: setup_pipe ok (sfd[0] =3D 5, sfd[1] =3D 4)
>> parent: child <pid 3790> started
>> child: polling...
>> parent: sending the message
>> parent: waiting for child to exit
>> child: poll(): some data <1,2> has arrived!
>> child: done
>> parent: done
>>
>> ... and will block when running on 2.6.37-rc7:
>>
>> $ ./pollpri-oob
>> main: starting
>> main: setup_pipe ok (sfd[0] =3D 5, sfd[1] =3D 4)
>> parent: child <pid 14148> started
>> child: polling...
>> parent: sending the message
>> parent: waiting for child to exit
>> [hangs here]
>>
>> I've bisected this behavior change to the following commit:
>>
>> commit 4938d7e0233a455f04507bac81d0886c71529537
>> Author: Eric Dumazet <dada1@cosmosbay.com>
>> Date: =A0 Tue Jun 16 15:33:36 2009 -0700
>>
>> =A0 poll: avoid extra wakeups in select/poll
>>
>> =A0 After introduction of keyed wakeups Davide Libenzi did on epoll,=
 we are
>> =A0 able to avoid spurious wakeups in poll()/select() code too.
>>
>> =A0 For example, typical use of poll()/select() is to wait for incom=
ing
>> =A0 network frames on many sockets. =A0But TX completion for UDP/TCP=
 frames call
>> =A0 sock_wfree() which in turn schedules thread.
>>
>> =A0 When scheduled, thread does a full scan of all polled fds and ca=
n sleep
>> =A0 again, because nothing is really available. =A0If number of fds =
is large,
>> =A0 this cause significant load.
>>
>> =A0 This patch makes select()/poll() aware of keyed wakeups and usel=
ess
>> =A0 wakeups are avoided. =A0This reduces number of context switches =
by about 50%
>> =A0 on some setups, and work performed by sofirq handlers.
>>
>>
>> I don't know if the new behavior is correct, but we've got one repor=
t of
>> an application that broke due to the change.
>
> Hi Leonardo
>
> Hmm, this is because =A0 =A0sock_def_readable() uses :
>
> wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLRDNORM |
> POLLRDBAND);
>
> So POLLPRI bit is not signaled.
>
> I would just add POLLPRI flag in sock_def_readable()
>
> (Alternatively, define a tcp_def_readable() function to pass POLLPRI
> only if TCP_URG is set, but is it worth the pain for a seldom used
> feature ?)
>
> David, do you have an opinion on this ?
>
> Thanks
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index e5af8d5..7fd3541 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1907,7 +1907,7 @@ static void sock_def_readable(struct sock *sk, =
int len)
> =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0wq =3D rcu_dereference(sk->sk_wq);
> =A0 =A0 =A0 =A0if (wq_has_sleeper(wq))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up_interruptible_sync_poll(&wq->wa=
it, POLLIN |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up_interruptible_sync_poll(&wq->wa=
it, POLLIN | POLLPRI |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0POLLRDNORM | POLLRDBAND);
> =A0 =A0 =A0 =A0sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
> =A0 =A0 =A0 =A0rcu_read_unlock();

Eric,

Thanks for the quick reply. I tested your patch and confirm that it res=
olves the
problem.

Regards,
Leonardo
