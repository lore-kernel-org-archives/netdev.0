From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] Could we avoid touching dst->refcount in some cases ?
Date: Tue, 25 Nov 2008 05:43:32 +0100
Message-ID: <492B8274.6080609@cosmosbay.com>
References: <492A6C94.7030308@cosmosbay.com>	<87y6z9h33h.fsf@basil.nowhere.org>	<492A7E85.3060502@cosmosbay.com> <20081124.153954.215777060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:47680 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbYKYEnl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 23:43:41 -0500
In-Reply-To: <20081124.153954.215777060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 24 Nov 2008 11:14:29 +0100
>=20
>> So maybe we could make ip_append_data() (or its callers) a
>> litle bit smarter, avoiding increment/decrement if possible.
>=20
> These ideas are interesting but hard to make work.
>=20
> I think the receive path has more chance of getting gains
> from this, to be honest.
>=20
> One third (effectively) of TCP stream packets are ACKs and
> freed immediately.  This means that the looked up route does
> not escape the packet receive path.  So we could elide the
> counter increment in that case.
>=20
> In fact, once we queue even TCP data, there is no need for
> that cached skb->dst route any longer.
>=20
> So pretty much all TCP packets could avoid the dst refcounting
> on receive.

Very interesting. So we could try the following path :

1) First try to release dst when queueing skb to various queues
(UDP, TCP, ...) while its hot. Reader wont have to release it
while its cold.

2) Check if we can handle the input path without any refcount
   dirtying ?

To make the transition easy, we could use a bit on skb to mark
dst being not refcounted (ie no dst_release() should be done on it)


