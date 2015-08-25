From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Question] Usage of dev_hold()/dev_put()
Date: Tue, 25 Aug 2015 07:24:49 -0700
Message-ID: <1440512689.8932.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <60A73B7A161A82449A7DB7B382BFD155371410A6@SZXEMA504-MBS.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Qinchuanyu <qinchuanyu@huawei.com>, Yewudi <yewudi@huawei.com>,
	liuyongan 00175866 <l00175866@notesmail.huawei.com.cn>,
	Wangbicheng <wangbicheng@huawei.com>,
	Yan Chen <Y.Chen@huawei.com>
To: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:32858 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbbHYOYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 10:24:54 -0400
Received: by pacti10 with SMTP id ti10so52739465pac.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 07:24:54 -0700 (PDT)
In-Reply-To: <60A73B7A161A82449A7DB7B382BFD155371410A6@SZXEMA504-MBS.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-25 at 08:28 +0000, Zhangjie (HZ) wrote:
> Hi,
>=20
> The comment of function dev_hold() and dev_put() are really simple.
>=20
> Actually, I can=E2=80=99t find a rule to follow.
>=20
> Where should I call dev_hold()/dev_put()?
>=20
> Are they necessary during xmit or receive or only in register/release=
?
>=20
> I find that, for tap, it calls dev_hold()/dev_put() for every
> tun_sendmsg/tun_recvmsg:
>=20
> So, should I call dev_hold()/dev_put() for each quote, such like:
> =E2=80=9Cskb->dev =3D dev=E2=80=9D ?
>=20
> But, for physical nic, I can=E2=80=99t find dev_hold()/dev_put() duri=
ng xmit
> or receive.
>=20
> What kind of scene is it necessary to call dev_hold()/dev_put()?
>=20
> =20
>=20
> Look forward for your feedback.=20
>=20
> Thank you ! J
>=20
> Zhangjie
>=20
>=20
Please do not send HTML mails, otherwise they do not reach netdev
mailing list

In general, you need to use dev_hold() for every reference on 'dev'
stored in the object.

However they are some paths were you do not need that : For example in
transmit path, skb are stored either in a qdisc or device driver
internal queue/ring. At device dismantle we properly delete all these
skb, so we do not have to worry about used dev_hold()/dev_put() in
transmit.

In drivers/net/tun.c, the dev_hold()/dev_put() only is required so that
device doesnt disappear between tun_get() and actual use of it after a
potentially long copy from user space (that might trigger page faults)
