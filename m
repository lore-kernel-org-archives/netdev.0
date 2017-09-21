From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] packet: hold bind lock when rebinding to fanout hook
Date: Thu, 21 Sep 2017 17:10:33 -0400
Message-ID: <CAF=yD-Lgq1k6DwcEpD38pCTomaX7Ti_-_nGzdm+XCxv-ff1UQg@mail.gmail.com>
References: <20170914211441.67326-1-willemb@google.com> <CAF=yD-J3PYMsZXxogr_9-fbDXHnTT-LBq0TXjbFbhSHXKeA65w@mail.gmail.com>
 <20170920.140327.2188227671204769350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Willem de Bruijn <willemb@google.com>,
        Network Development <netdev@vger.kernel.org>,
        nixiaoming <nixiaoming@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:54314 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751793AbdIUVLO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 17:11:14 -0400
Received: by mail-io0-f173.google.com with SMTP id h66so13819093ioh.11
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 14:11:14 -0700 (PDT)
In-Reply-To: <20170920.140327.2188227671204769350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 5:03 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Fri, 15 Sep 2017 10:07:46 -0400
>
>> On Thu, Sep 14, 2017 at 5:14 PM, Willem de Bruijn <willemb@google.com> wrote:
>>> Packet socket bind operations must hold the po->bind_lock. This keeps
>>> po->running consistent with whether the socket is actually on a ptype
>>> list to receive packets.
>>>
>>> fanout_add unbinds a socket and its packet_rcv/tpacket_rcv call, then
>>> binds the fanout object to receive through packet_rcv_fanout.
>>>
>>> Make it hold the po->bind_lock when testing po->running and rebinding.
>>> Else, it can race with other rebind operations, such as that in
>>> packet_set_ring from packet_rcv to tpacket_rcv. Concurrent updates
>>> can result in a socket being added to a fanout group twice, causing
>>> use-after-free KASAN bug reports, among others.
>>>
>>> Reported independently by both trinity and syzkaller.
>>> Verified that the syzkaller reproducer passes after this patch.
>>>
>>
>> I forgot to add the Fixes tag, sorry.
>>
>> Fixes: dc99f600698d ("packet: Add fanout support.")
>
> Applied and queued up for stable as it fixes this race and I can't
> see any new problems it introduces.
>
> But boy is this one messy area.

Yeah, I've been staring at this code for a while now. But I don't see
an obvious way to simplify it. packet_notifier does not hold the socket
lock, so even if all of bind, set_ring and fanout_add do hold that,
bind_lock is still needed. packet_mmap may not take the socket lock,
so pg_vec_lock must remain to synchronize with packet_set_ring
even if for no other reason. I had a look at using rcu pointers for rx_ring
and tx_ring, to avoid taking that lock in the datapath and possibly updating
without the unbind/bind dance. But that update needs to be atomic with
purging the socket queue, so the socket must be properly quiesced.

> The scariest thing to me now is the save/restore sequence done by
> packet_set_ring(), for example.
>
>         spin_lock(&po->bind_lock);
>         was_running = po->running;
>         num = po->num;
>         if (was_running) {
>                 po->num = 0;
>                 __unregister_prot_hook(sk, false);
>         }
>         spin_unlock(&po->bind_lock);
>  ...
>         spin_lock(&po->bind_lock);
>         if (was_running) {
>                 po->num = num;
>                 register_prot_hook(sk);
>         }
>         spin_unlock(&po->bind_lock);
>
> The socket is also locked during this sequence but that doesn't
> prevent parallel changes to the running state.
>
> Since po->bind_lock is dropped, it's possible for another thread
> to grab bind_lock and bind it meanwhile.
>
> The above code seems to assume that can't happen, and that
> register_prot_hook() will always see po->running set to zero
> and rebind the socket.
>
> If the race happens we'll have weird state, because we did not
> rebind yet we modified po->num.

It appears that the only path that may try to bind without holding the
socket lock is packet_notifier. That skips register_prot_hook if !po->num.

> We seem to have a hierachy of sleeping and non-sleeping locks
> that do not work well together.

Given the number recent bugs that were fixed by locking the socket
inside a particular setsockopt case, I think that we should lock that
entire function, similar to other protocol families (after verifying that
all cases can indeed sleep).

Another issue that looks fragile is the test for po->fanout in
packet_do_bind before taking the socket lock.
