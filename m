From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] sock: consistent errqueue errors and signals
Date: Tue, 2 Sep 2014 22:34:18 -0400
Message-ID: <CA+FuTSdg+fQt+iFqCq7foXwZ00qyq-1vYOKmYzvAv0AF1uh0mg@mail.gmail.com>
References: <1409534896-372-1-git-send-email-willemb@google.com>
 <1409606744.21965.37.camel@localhost> <CA+FuTScAYY1ZhQPwY=pqW9hXf3UYB70Dxq5+aPH4D4pB7QRPbg@mail.gmail.com>
 <1409692691.15984.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:58302 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbaICCet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 22:34:49 -0400
Received: by mail-qc0-f177.google.com with SMTP id i8so7944184qcq.22
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 19:34:48 -0700 (PDT)
In-Reply-To: <1409692691.15984.16.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I agree, in that it is hard to verify that this does not overwrite
>> an existing error. This patch only makes the behavior
>> consistent between enqueue and dequeue, but perhaps a
>> better way to achieve that is to change the dequeue side:
>> remove the assignment to sk->sk_err there. If so, then all
>> locations that currently check the state of sk->sk_err should
>> be changed to also check the qlen of the error queue and
>> if non-zero return the embedded error of the first skb. I'll
>> take a look whether that is feasible without adding locks
>> or atomics in the common path.
>
> That would be great.

This looks feasible, though the patch is considerably longer.
If we can be sure that in skb_dequeue_err_skb in this patch

+       sk->sk_err = SKB_EXT_ERR(skb)->ee.ee_errno;

never overwrites an existing error, I think that this short
patch is preferable.

I wrote a preliminary alternative patch that modifies
sock_error to check the queue and converts other
code that manually tests sk->sk_err to instead call a new
function sock_has_error that similarly tests both. The patch
is rough and minimally tested, but I will send it out as rfc.

>>
>> > It also depends on socket state bits (e.g. np->recverr) if
>> > the update happens. So we still cannot get rid of the protocol dependent
>> > sk->sk_err updates.
>> >
>> > It looks like we have to check all error handling functions in the
>> > protocols. Maybe timestamp code needs to adapt?
>>
>> Does the above sound okay, or did you mean something else?
>
> Best thing would be to not keep the error status two times per socket.

I agree in principle, but this may be hard to achieve.

> Maybe it would make sense to always synchronize on the error queue and
> don't check for sk->sk_err at all?

sk->sk_err is set in many locations. I don't think that we can change all
those sites.

>It seems to get very hairy without
> taking any locks though.

To fix this particular issue, I prefer to leave it sk->sk_err as is, instead
separate the error queue logic from it and make sure that that has
consistent semantics.

> I even don't know what the semantics for sk_err should be.

Neither do I. That's one reason I'd rather not touch it :)

> Should we
> leave the oldest error in place until it got fetched? Then we could use
> cmpxchg in slow path with 0 as the old value. They could easily become
> unsynchronized if the user switches off recverr setsockopt. But I don't
> think we need to handle that.
>
> I think best effort should would be ok, too. Not having locked
> instructions in fast path is much more important.

We can optimistically test the qlen without a lock and only take the
lock and peek into the queue in the unlikely case that qlen is non-zero.
This is racy, but already done in various poll routines. It seems to be
protected some other way, or the race is deemed benign. Either way,
the patch does not change these callers. For recv/send, which it does
change, best effort seems acceptable to me, too. Perhaps we can do
better, but I'll send out the patch as is for now.

On a related note, a comment in net/core/sock.c states that
sk->sk_err is only changed under lock. This is not currently
true. skb_dequeue_err_skb does not take the socket lock,
for one.

> Thanks,
> Hannes

Thanks for having a look at the patch!
>
>
