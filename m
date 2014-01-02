From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: IrDA woes..
Date: Thu, 2 Jan 2014 11:11:42 -0800
Message-ID: <CA+55aFz_qDYP_P0PLUNv0wotoy=5PcS+7Qtt=U6EzvL4h4E69A@mail.gmail.com>
References: <CA+55aFz2CQ4B1JSpQ75TuQrrd9sUnhV+u=T2dWZY2NTTT5OmpQ@mail.gmail.com>
	<20140102.034653.1968429090467668489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:62859 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaABTLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 14:11:44 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so5502109eek.13
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 11:11:42 -0800 (PST)
In-Reply-To: <20140102.034653.1968429090467668489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 12:46 AM, David Miller <davem@davemloft.net> wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Tue, 31 Dec 2013 12:08:43 -0800
>
>> One of the oopses seems simple: irda_attach() will do
>
> I assume you mean irda_connect().

Yup, sorry, mindfart.

>>         if (sk->sk_prot->disconnect(sk, flags))
>>                 sock->state = SS_DISCONNECTING;
>>
>> if the connection fails. But sk_prot->disconnect is NULL for IrDA, so
>> that will just oops. Apparently real devices don't end up ever
>> triggering that, but I don't think it can ever have worked.
>
> That sk_prot should be irda_proto, which doesn't provide any non-NULL
> operations ?!?!

That was how I read it too. I'm just surprised by how google doesn't
seem to find any matching oopses with irda_connect(). Admittedly I'm
doing odd things, so..

> I think the thing to do for now is to simply remove those two lines.

Ack, that was my feeling too. I added just a test for NULL for my
further testing, but I can't see how it could ever *not* be NULL.

> I don't believe that anyone has looked closely at this code for
> a long time except with automated tools like semantic checkers.

So looking at the code, the locking seems to be entirely lacking too,
which is what I *think* is the source of my other oops. It traverses
the internal irda wx_list at softirq time, and as far as I can tell,
there is no locking anywhere. And the irda code ends up being called
from timers, from the network receive function, and presumably from
process context.

I get the feeling that the code was written back in the bad old days
when we had the big kernel lock, and timers and network bottom half
handling were all mutually exclusive.

Is anybody actually really using or maintaining irda any more? Because
nothing seems to work. I think the following is *supposed* to work as
a way to emulate having two irda dongles without actually having the
hardware:

 - in terminal 1:

        socat PTY,link=/tmp/ttyS0 PTY,link=/tmp/ttyS1

 - terminal 2:

        irattach $(readlink /tmp/ttyS0) -s
        irattach $(readlink /tmp/ttyS1) -s

 - in terminal 3:

        echo "Duh" > /dev/ircomm0

 - in terminal 4:

        cat /dev/ircomm1

(expecting to see "Duh" in terminal 4) but it really doesn't work for me.

The odd thing is that I *have* seen it work, a couple of times, so
it's not like it *never* works (in which case I'd just think that the
above simply isn't even supposed to work at all), but the "it actually
worked" is a very rare occurrence. Most of the time opening the ircomm
blocks. But sometimes it works after a few seconds. Very odd.

Samuel is listed as maintainer, but I'm getting the feeling he has
long since moved on.

               Linus
