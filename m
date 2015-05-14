From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: fix warnings in rollover lock
 contention
Date: Thu, 14 May 2015 12:59:22 -0400 (EDT)
Message-ID: <20150514.125922.1722914809373007896.davem@davemloft.net>
References: <1431617634.27831.60.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+FuTSfQ3xuTjJk-oSDvT0o67vY34Y68zVjuTByhNaGfaNPagg@mail.gmail.com>
	<1431620686.27831.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbENQ7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 12:59:24 -0400
In-Reply-To: <1431620686.27831.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 May 2015 09:24:46 -0700

> On Thu, 2015-05-14 at 11:53 -0400, Willem de Bruijn wrote:
> 
>> I principally want to avoid the lock contention on sk_receive_queue.lock,
>> which is held for a lot longer while probing frames. But yes, I'd prefer to
>> avoid the cacheline contention as well.
>> 
>> The alternative is to keep the race and just replace the xchg with a
>> straight assignment.
> 
> Please describe the race. It seems quite innocent at first look.
> 
> Clearly putting xchg() gives a false sense of security in this context.
> 
> Atomic ops should be reserved for cases we cannot avoid them,
> not to give false hopes ;)

Basically, ->pressure seems to exist merely to optimize the scanner
in fanout_demux_rollover().  It makes it so that we don't check
sockets we already know lack space.

It is set (in an unlocked context) by packet_rcv_has_room() calls
which calculate that the socket lacks space.

It is cleared either in non-tpacket recvmsg() or poll(), the latter
of which holds the socket receive queue spinlock.

This kind of variable and conditional locking is crummy, at best.

Since non-tpacket recvmsg already has to hold the receive queue lock
to pull out the SKB (via skb_recv_datagram()), there is no value to
the conditional locking done by packet_rcv_has_room().

Just take the receive queue lock always, and then you can guarantee
that all ->pressure updates occur under that lock.

Tests can be done asynchronously without locking in the
fanout_demux_rollover() code, and that's fine.  It's a heuristic
after all.

Like this:

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 31d5856..0947895 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1301,17 +1301,14 @@ static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 	int ret;
 	bool has_room;
 
-	if (po->prot_hook.func == tpacket_rcv) {
-		spin_lock(&po->sk.sk_receive_queue.lock);
-		ret = __packet_rcv_has_room(po, skb);
-		spin_unlock(&po->sk.sk_receive_queue.lock);
-	} else {
-		ret = __packet_rcv_has_room(po, skb);
-	}
+	spin_lock(&po->sk.sk_receive_queue.lock);
 
+	ret = __packet_rcv_has_room(po, skb);
 	has_room = ret == ROOM_NORMAL;
 	if (po->pressure == has_room)
-		xchg(&po->pressure, !has_room);
+		po->pressure = !has_room;
+
+	spin_unlock(&po->sk.sk_receive_queue.lock);
 
 	return ret;
 }
@@ -3814,7 +3811,7 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
 			mask |= POLLIN | POLLRDNORM;
 	}
 	if (po->pressure && __packet_rcv_has_room(po, NULL) == ROOM_NORMAL)
-		xchg(&po->pressure, 0);
+		po->pressure = 0;
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	spin_lock_bh(&sk->sk_write_queue.lock);
 	if (po->tx_ring.pg_vec) {
