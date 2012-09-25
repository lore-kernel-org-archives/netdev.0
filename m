From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] inet_diag: fix panic when unload inet_diag
Date: Tue, 25 Sep 2012 15:20:16 +0800
Message-ID: <50615B30.80901@cn.fujitsu.com>
References: <1348541310-31913-1-git-send-email-gaofeng@cn.fujitsu.com> <1348555011.26828.2031.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, stephen.hemminger@vyatta.com, jengelh@inai.de,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59718 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751097Ab2IYHUV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 03:20:21 -0400
In-Reply-To: <1348555011.26828.2031.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8825=E6=97=A5 14:36, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Tue, 2012-09-25 at 10:48 +0800, Gao feng wrote:
>> when inet_diag being compiled as module, inet_diag_handler_dump
>> set netlink_dump_control.dump to inet_diag_dump,so if module
>> inet_diag is unloaded,netlink will still try to call this function
>> in netlink_dump. this will cause kernel panic.
>>
>> fix this by adding a reference of inet_diag module before
>> setting netlink_callback, and release this reference in
>> netlink_callback.done.
>>
>> Thanks for all help from Stephen,Jan and Eric.
> ...
>=20
>> =20
>> @@ -1001,8 +1025,26 @@ static int inet_diag_handler_dump(struct sk_b=
uff *skb, struct nlmsghdr *h)
>>  		{
>>  			struct netlink_dump_control c =3D {
>>  				.dump =3D inet_diag_dump,
>> +				.done =3D inet_diag_done,
>>  			};
>> -			return netlink_dump_start(net->diag_nlsk, skb, h, &c);
>> +			int err;
>> +			/*
>> +			 * netlink_dump will call inet_diag_dump,
>> +			 * so we need a reference of THIS_MODULE.
>> +			 */
>> +			if (!try_module_get(THIS_MODULE))
>> +				return -EPROTONOSUPPORT;
>> +
>> +			err =3D netlink_dump_start(net->diag_nlsk, skb, h, &c);
>> +
>> +			if ((err !=3D -EINTR) && (err !=3D -ENOBUFS)) {
>> +				/*
>> +				 * netlink_callback set failed, release the
>> +				 * referenct of THIS_MODULE.
>> +				 */
>> +				module_put(THIS_MODULE);
>> +			}
>> +			return err;
>>  		}
>>  	}
>> =20
>=20
> Hmm... this seems error prone...
>=20
> In the future, netlink_dump_start() could be changed to return other
> errors than EINTR or ENOBUFS that need the module_put()
>=20

EINTR and ENOBUFS is returned by netlink_dump, netlink_dump is called b=
y
netlink_dump_start after netlink_callback being set successfully.
so this checking of EINTR and ENOBUFS here is to determinate if we set
netlink_callback successfully.

I think in order to reduce error prone,we have to change netlink_dump_s=
tart
to determinate if we set netlink_callback successfully.

> I would change netlink_dump_start() to __netlink_dump_start() and add=
 a
> module param to it, so that this module stuff is centralized in
> __netlink_dump_start()
>=20
> Then, instead of calling (from inet_diag)
>=20
> netlink_dump_start(net->diag_nlsk, skb, nlh, &c);
>=20
> you would use :
>=20
> __netlink_dump_start(net->diag_nlsk, skb, nlh, &c, THIS_MODULE);
>=20
> I wonder if this fix is not needed elsewhere eventually
> (net/unix/af_unix.c for example ?)
>=20

do you mean net/unix/unix_diag.c ?
I test nfnetlink module,it has the same problem.

It's need to modify netlink_dump_start not only wrap netlink_dump_start=
=2E
