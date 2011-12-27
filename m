From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet: fix dev refcnt leak when bind fail
Date: Tue, 27 Dec 2011 13:15:59 -0500 (EST)
Message-ID: <20111227.131559.2197088758418537543.davem@davemloft.net>
References: <20111226.151547.564743129441895726.davem@davemloft.net>
	<CAPgLHd8ZX6eh+SOoE7CXJXTAsq3F8biQYSKcN-owfj_jBsZ_tg@mail.gmail.com>
	<CAPgLHd9DPsxBnhH_xvuApjy32X--jxYiDn4DmxmR-Uqq8wJP+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662Ab1L0SQC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 13:16:02 -0500
In-Reply-To: <CAPgLHd9DPsxBnhH_xvuApjy32X--jxYiDn4DmxmR-Uqq8wJP+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 27 Dec 2011 12:28:31 +0800

> cc netdev@vger.kernel.org
>=20
>> From: Wei Yongjun <weiyj.lk@gmail.com>
>> Date: Mon, 26 Dec 2011 17:02:59 +0800
>>
>>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>>
>>> If bind is fail such as bind is called after set PACKET_FANOUT
>>> sock option, the dev refcnt will leak.
>>>
>>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>
>> The device pointer is stored in ->prot_hook.dev
>>
>> Therefore, it will be released at the latest in packet_release() or
>> earlier if another bind() attempt is done on the socket.
>>
>> There is no leak here as far as I can see.
>=20
> Hi David,
>=20
> In packet_do_bind(), if po->fanout is set, the device pointer may not=
 be
> stored in ->prot_hook.dev, see the following code:
>=20
> static int packet_do_bind(struct sock *sk, struct net_device *dev, ..=
=2E)
> {
> =A0 =A0struct packet_sock *po =3D pkt_sk(sk);
>=20
> =A0 =A0if (po->fanout)
> =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0...
> =A0 =A0po->prot_hook.dev =3D dev;
> =A0 =A0...
> }
>=20
> The leak is exists only if po->fanout is set.

Then it sounds a lot simpler for packet_do_bind() (one location) to
manage this reference drop, rather than every single call site of
packet_do_bind().

Look how complicated you had to make the tests in those call sites
to get the logic right, it's must easier to just add the dev_put()
right at that po->fanout test.
