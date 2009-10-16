From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 09:08:59 +0200
Message-ID: <4AD81C0B.90804@gmail.com>
References: <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <4AD7EDB4.7060907@gmail.com> <4AD7FE01.1010805@gmail.com> <20091016052913.GB5574@1wt.eu> <4AD80D1F.3090601@gmail.com> <20091016061806.GD5574@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50068 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755046AbZJPHKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 03:10:17 -0400
In-Reply-To: <20091016061806.GD5574@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau a =E9crit :
> On Fri, Oct 16, 2009 at 08:05:19AM +0200, Eric Dumazet wrote:
>>> Couldn't we just rely on the retrans vs rskq_defer_accept compariso=
n ?
>>>
>> In this case, we lose TCP_DEFER_ACCEPT advantage in case one SYN-ACK=
 was dropped
>> by the network : We wakeup the listening server when first ACK comes=
 from client,
>> instead of really wait the request.
>>
>> I think being able to count pure-acks would be slighly better, and c=
ost nothing.
>>
>>
>> retrans is the number of SYN-RECV (re)sent, while req_acks would cou=
nt number of
>> pure ACK received.
>>
>> Those numbers, in an ideal world should be related, but could differ=
 in real world ?
>=20
> Yes it could differ if a pure ACK is lost between the client and the =
server,
> but in my opinion what is important is not to precisely account the n=
umber
> of ACKs to ensure we wake up exactly after XXX ACKs received, but tha=
t in
> most common situations we avoid to wake up too early.
>=20

We basically same thing, but you misundertood me. I was concerning abou=
t
one lost (server -> client SYN-ACK), not a lost (client -> server ACK) =
which is fine
(even without playing with TCP_DEFER_ACCEPT at all)

In this case, if we do the retrans test, we'll accept the first (client=
 -> server ACK)
and wakeup the application, while most probably we'll receive the clien=
t request
 few milli second later.

> Also, keep in mind that the TCP_DEFER_ACCEPT parameter is passed in n=
umber
> of seconds by the application, which are in turn converted to a numbe=
r of
> retransmits based on our own timer, which means that our SYN-ACK coun=
ter
> is what most closely matches the application's expected delay, even i=
f an
> ACK from the client gets lost in between or if a client's stack retra=
nsmits
> pure ACKs very fast for any implementation-specific reason.
>=20

Well, this is why converting application delay (sockopt() argument) in =
second units
to a number of SYN-ACK counter is subobptimal and error prone.

This might be changed to be mapped to what documentation states : a num=
ber of seconds,
or even better a number of milli seconds (new TCP_DEFER_ACCEPT_MS setso=
ckopt cmd),
because a high performance server wont play with > 1 sec values anyway.
