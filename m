From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
Date: Thu, 08 Oct 2009 16:45:48 +0200
Message-ID: <4ACDFB1C.4090107@gmail.com>
References: <20091007180835.GB20524@hmsreliant.think-freely.org> <4ACD3AC8.608@gmail.com> <20091008135435.GA23928@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, socketcan@hartkopp.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54454 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757655AbZJHOqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 10:46:34 -0400
In-Reply-To: <20091008135435.GA23928@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
>>> +	if (check_drops) {
>>> +		skb =3D skb_recv_datagram(sk, flags|MSG_PEEK,
>>> +				flags & MSG_DONTWAIT, &err);
>> 	Ouch, this is too expensive, please find another way :)
>>
>>> +		if (skb) {
>>> +			gap =3D skb->dropcount;
>>> +			consume_skb(skb);
>>> +		}
>>> +	}
>>> +
> I'm not sure that I see the expense here, and what expense there is, =
I don't see
> how it avoidable.  In order to do this reporting at the socket level,=
 we need to
> look at the skb at the head of the receive queue.  But we need to do =
so in a way
> thats consistent with the flags being passed in (i.e. if this is a bl=
ocking
> socket, we need to block here until something is available to read). =
 Then its
> just an atomic_inc on skb->users, followed by a dec in the consume_sk=
b.  I could
> implement the logic for DONTWAIT myself, and skip the atomic_inc/dec,=
 but I'm
> not sure thats much of a savings.  If you have another thought, I'm c=
ertainly
> open to it.

The expense is a lot of atomic ops. You forgot the lock, so thats four =
atomic ops.

You can do all this with no extra atomics.

All you need is some function with (struct msghdr *msg, struct sock *sk=
, struct sk_buff *skb)
triplet.

hint : sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct =
sk_buff *skb)

Could be renamed to something else if you want...

sock_recv_ts_or_drops() or whatever
