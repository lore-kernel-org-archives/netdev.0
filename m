From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Tue, 13 Oct 2009 10:29:03 +0200
Message-ID: <4AD43A4F.1090800@gmail.com>
References: <20091013050705.GA2194@1wt.eu> <4AD42B0F.8010809@gmail.com> <20091013073410.GA3792@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58284 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbZJMIaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 04:30:15 -0400
In-Reply-To: <20091013073410.GA3792@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau a =E9crit :
> On Tue, Oct 13, 2009 at 09:23:59AM +0200, Eric Dumazet wrote:
>> Willy Tarreau a =E9crit :
>>> Hello,
>>>
>>> I was trying to use TCP_DEFER_ACCEPT and noticed that if the
>>> client does not talk, the connection is never accepted and
>>> remains in SYN_RECV state until the retransmits expire, where
>>> it finally is deleted. This is bad when some firewall such as
>>> netfilter sits between the client and the server because the
>>> firewall sees the connection in ESTABLISHED state while the
>>> server will finally silently drop it without sending an RST.
>>>
>>> This behaviour contradicts the man page which says it should
>>> wait only for some time :
>>>
>>>        TCP_DEFER_ACCEPT (since Linux 2.4)
>>>           Allows a listener to be awakened only when data arrives
>>>           on the socket.  Takes an integer value  (seconds), this
>>>           can  bound  the  maximum  number  of attempts TCP will
>>>           make to complete the connection. This option should not
>>>           be used in code intended to be portable.
>>>
>>> Also, looking at ipv4/tcp.c, a retransmit counter is correctly
>>> computed :
>>>
>>>         case TCP_DEFER_ACCEPT:
>>>                 icsk->icsk_accept_queue.rskq_defer_accept =3D 0;
>>>                 if (val > 0) {
>>>                         /* Translate value in seconds to number of
>>>                          * retransmits */
>>>                         while (icsk->icsk_accept_queue.rskq_defer_a=
ccept < 32 &&
>>>                                val > ((TCP_TIMEOUT_INIT / HZ) <<
>>>                                        icsk->icsk_accept_queue.rskq=
_defer_accept))
>>>                                 icsk->icsk_accept_queue.rskq_defer_=
accept++;
>>>                         icsk->icsk_accept_queue.rskq_defer_accept++=
;
>>>                 }
>>>                 break;
>>>
>>> =3D=3D> rskq_defer_accept is used as a counter of retransmits.
>>>
>>> But in tcp_minisocks.c, this counter is only checked. And in
>>> fact, I have found no location which updates it. So I think
>>> that what was intended was to decrease it in tcp_minisocks
>>> whenever it is checked, which the trivial patch below does :
>>>
>>> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
>>> index f8d67cc..1b443b0 100644
>>> --- a/net/ipv4/tcp_minisocks.c
>>> +++ b/net/ipv4/tcp_minisocks.c
>>> @@ -645,6 +645,7 @@ struct sock *tcp_check_req(struct sock *sk, str=
uct sk_buff *skb,
>>>  	if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
>>>  	    TCP_SKB_CB(skb)->end_seq =3D=3D tcp_rsk(req)->rcv_isn + 1) {
>>> +		inet_csk(sk)->icsk_accept_queue.rskq_defer_accept--;
>>>  		inet_rsk(req)->acked =3D 1;
>>>  		return NULL;
>>>  	}
>>> =20
>>
>> I dont understand why you want to decrement rskq_defer_accept here.
>=20
> Because the "timeout" as set by setsockopt() is converted into number
> of retransmits.
>=20
>> We receive a pure ACK (wihout DATA).
>> We should receive exactly one such ACK.
>=20
> No, we will receive other ones because the socket remains in SYN_RECV
> and since the local system ignores this ACK, it will send a SYN-ACK
> again, triggering a new ACK from the client.
>=20
> Although the concept looks strange at first, I think its implementati=
on
> is in fact very smart because it manages to defer acceptation with an
> approximate timeout without using another timer.
>=20
> The most common requirement should only be to wait for an HTTP reques=
t
> to come in, and setting the timeout to anything non-zero is enough to
> just drop the first empty ACK and immediately accept on the data
> segment, so this method fits this purpose perfectly.
>=20

Indeed, thanks for this detailed explanation, I missed the SYN-ACK time=
r
and retransmits.

I played some years ago with TCP_DEFER_ACCEPT and got some unexpected r=
esults
on transmitted packets (server was consuming more bandwidth), and I kno=
w understand
it was very broken until today !

Thanks again Willy
