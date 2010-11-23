From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH 4/9] AF_UNIX: find the recipients for multicast messages
Date: Tue, 23 Nov 2010 15:03:15 +0000
Message-ID: <20101123150315.4e67a139@chocolatine.cbg.collabora.co.uk>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
	<1290450982-17480-4-git-send-email-alban.crequy@collabora.co.uk>
	<20101122.110519.39205345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com, gorcunov@openvz.org,
	adobriyan@gmail.com, lennart@poettering.net, kay.sievers@vrfy.org,
	ian.molton@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101122.110519.39205345.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Mon, 22 Nov 2010 11:05:19 -0800 (PST),
David Miller <davem@davemloft.net> a =C3=A9crit :

> From: Alban Crequy <alban.crequy@collabora.co.uk>
> Date: Mon, 22 Nov 2010 18:36:17 +0000
>=20
> > unix_find_multicast_recipients() builds an array of recipients. It
> > can either find the peers of a specific multicast address, or find
> > all the peers of all multicast group the sender is part of.
> >=20
> > Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
>=20
> You really should use RCU to lock this stuff, this way sends run
> lockless and have less worries wrt. the memory allocation.  You'll
> also only take a spinlock in the write paths which change the
> multicast groups, which ought to be rare.

I understand the benefit to use RCU in order to have lockless sends.

But with RCU I will still have worries about the memory allocation:

- I cannot allocate inside a rcu_read_lock()-rcu_read_unlock() block.

- If I iterate locklessly over the multicast group members with=20
  hlist_for_each_entry_rcu(), new members can be added, so the
  array can be allocated with the wrong size and I have to try again
  ("goto try_again") when this rare case occurs.

- Another idea would be to avoid completely the allocation by inlining
  unix_find_multicast_recipients() inside unix_dgram_sendmsg() and
  delivering the messages to the recipients as long as the list is
  being iterated locklessly. But I want to provide atomicity of
  delivery: the message must be delivered with skb_queue_tail() either
  to all the recipients or to none of them in case of interruption or
  memory pressure. I don't see how I can achieve that without
  iterating several times on the list of recipients, hence the
  allocation and the copy in the array. I also want to guarantee the
  order of delivery as described in multicast-unix-sockets.txt and for
  this, I am taking lots of spinlocks anyway. I don't see how to avoid
  that, but I would be happy to be wrong and have a better solution.

> Although to be honest you should optimize the case of small numbers o=
f
> recipients, in the same way we optimize small numbers of iovecs on
> sends.  Have an on-stack array that holds a small number of entries
> and use that if the set fits, otherwise dynamic allocation.

To give an idea of the number of members in a multicast group for the
D-Bus use case, I have 90 D-Bus connections on my session bus:

$ dbus-send --print-reply --dest=3Dorg.freedesktop.DBus \
/org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep '":'|wc -l
90

In common cases, there should be only a few real recipients (1 or 2?)
after the socket filters eliminate most of them, but
unix_find_multicast_recipients() will still allocate an array of
about that size.
