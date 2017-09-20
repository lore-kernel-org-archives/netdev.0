From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: hold bind lock when rebinding to fanout
 hook
Date: Wed, 20 Sep 2017 14:03:27 -0700 (PDT)
Message-ID: <20170920.140327.2188227671204769350.davem@davemloft.net>
References: <20170914211441.67326-1-willemb@google.com>
        <CAF=yD-J3PYMsZXxogr_9-fbDXHnTT-LBq0TXjbFbhSHXKeA65w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org, nixiaoming@huawei.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37694 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbdITVD2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 17:03:28 -0400
In-Reply-To: <CAF=yD-J3PYMsZXxogr_9-fbDXHnTT-LBq0TXjbFbhSHXKeA65w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri, 15 Sep 2017 10:07:46 -0400

> On Thu, Sep 14, 2017 at 5:14 PM, Willem de Bruijn <willemb@google.com> wrote:
>> Packet socket bind operations must hold the po->bind_lock. This keeps
>> po->running consistent with whether the socket is actually on a ptype
>> list to receive packets.
>>
>> fanout_add unbinds a socket and its packet_rcv/tpacket_rcv call, then
>> binds the fanout object to receive through packet_rcv_fanout.
>>
>> Make it hold the po->bind_lock when testing po->running and rebinding.
>> Else, it can race with other rebind operations, such as that in
>> packet_set_ring from packet_rcv to tpacket_rcv. Concurrent updates
>> can result in a socket being added to a fanout group twice, causing
>> use-after-free KASAN bug reports, among others.
>>
>> Reported independently by both trinity and syzkaller.
>> Verified that the syzkaller reproducer passes after this patch.
>>
> 
> I forgot to add the Fixes tag, sorry.
> 
> Fixes: dc99f600698d ("packet: Add fanout support.")

Applied and queued up for stable as it fixes this race and I can't
see any new problems it introduces.

But boy is this one messy area.

The scariest thing to me now is the save/restore sequence done by
packet_set_ring(), for example.

	spin_lock(&po->bind_lock);
	was_running = po->running;
	num = po->num;
	if (was_running) {
		po->num = 0;
		__unregister_prot_hook(sk, false);
	}
	spin_unlock(&po->bind_lock);
 ...
	spin_lock(&po->bind_lock);
	if (was_running) {
		po->num = num;
		register_prot_hook(sk);
	}
	spin_unlock(&po->bind_lock);

The socket is also locked during this sequence but that doesn't
prevent parallel changes to the running state.

Since po->bind_lock is dropped, it's possible for another thread
to grab bind_lock and bind it meanwhile.

The above code seems to assume that can't happen, and that
register_prot_hook() will always see po->running set to zero
and rebind the socket.

If the race happens we'll have weird state, because we did not
rebind yet we modified po->num.

We seem to have a hierachy of sleeping and non-sleeping locks
that do not work well together.
