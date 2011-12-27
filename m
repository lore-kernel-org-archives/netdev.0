From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Fwd: [PATCH] packet: fix dev refcnt leak when bind fail
Date: Tue, 27 Dec 2011 12:28:31 +0800
Message-ID: <CAPgLHd9DPsxBnhH_xvuApjy32X--jxYiDn4DmxmR-Uqq8wJP+A@mail.gmail.com>
References: <CAPgLHd9KNN81cPYv3bGzoBwUtnJSAoX4NN0Fh+wNgoHE_t7d=w@mail.gmail.com>
	<20111226.151547.564743129441895726.davem@davemloft.net>
	<CAPgLHd8ZX6eh+SOoE7CXJXTAsq3F8biQYSKcN-owfj_jBsZ_tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:45896 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881Ab1L0E2c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 23:28:32 -0500
Received: by qadb15 with SMTP id b15so7538957qad.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 20:28:31 -0800 (PST)
In-Reply-To: <CAPgLHd8ZX6eh+SOoE7CXJXTAsq3F8biQYSKcN-owfj_jBsZ_tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cc netdev@vger.kernel.org

> From: Wei Yongjun <weiyj.lk@gmail.com>
> Date: Mon, 26 Dec 2011 17:02:59 +0800
>
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>
>> If bind is fail such as bind is called after set PACKET_FANOUT
>> sock option, the dev refcnt will leak.
>>
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> The device pointer is stored in ->prot_hook.dev
>
> Therefore, it will be released at the latest in packet_release() or
> earlier if another bind() attempt is done on the socket.
>
> There is no leak here as far as I can see.

Hi David,

In packet_do_bind(), if po->fanout is set, the device pointer may not b=
e
stored in ->prot_hook.dev, see the following code:

static int packet_do_bind(struct sock *sk, struct net_device *dev, ...)
{
=A0 =A0struct packet_sock *po =3D pkt_sk(sk);

=A0 =A0if (po->fanout)
=A0 =A0 =A0 =A0return -EINVAL;
=A0 =A0...
=A0 =A0po->prot_hook.dev =3D dev;
=A0 =A0...
}

The leak is exists only if po->fanout is set.
