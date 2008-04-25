From: Mandeep Singh Baines <msb@google.com>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Thu, 24 Apr 2008 18:15:40 -0700
Message-ID: <20080425011540.GA30152@google.com>
References: <20080414180338.GA18335@google.com> <20080415.003153.30044057.davem@davemloft.net> <cc96a5040804151007q6008355cl2cc85242b81f3918@mail.gmail.com> <20080415.192330.29185957.davem@davemloft.net> <4810CEB6.60707@linux.vnet.ibm.com> <20080424190148.GA19511@google.com> <4810EBC5.4060508@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thockin@google.com,
	netdev@vger.kernel.org, jeff@garzik.org, joe@perches.com,
	nil@google.com, matthew@wil.cx
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:35362 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbYDYBQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 21:16:15 -0400
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m3P1G8lc029227
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 02:16:08 +0100
Received: from el-out-1112.google.com (eley26.prod.google.com [10.126.176.26])
	by zps18.corp.google.com with ESMTP id m3P1G6wI014687
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 18:16:07 -0700
Received: by el-out-1112.google.com with SMTP id y26so1392046ele.16
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 18:16:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4810EBC5.4060508@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Breno,

My bad. You are correct. There is a bug. In the ethtool user-space app,=
 tg3
and natsemi over-ride the default implementation of dump_eeprom(). In b=
oth
tg3_dump_eeprom() and natsemi_dump_eeprom(), there is a magic number ch=
eck
which is not present in the default implementation.

When fixing the ethtool interface to read large EEPROMs, I snipped the =
code
which copied the ethtool_eeprom structure back to user-space. I thought=
 it
was read-only. Oops. Looks like tg3 and natsemi are over-writing the ma=
gic
number field and then checking it in user-space.

The fix is simple. Add the ethtool_eeprom copy back. I will test and se=
nd out
a patch shortly.

Thanks much for finding this:)

Regards,
Mandeep

Breno Leitao (leitao@linux.vnet.ibm.com) wrote:
> Mandeep,
>=20
> Mandeep Singh Baines wrote:
> >I suspect you may have mis-applied the patch. The patch changes both
> >set_eeprom and get_eeprom. I think you may have modified get_eeprom =
to call
> >ops->set_eeprom instead of ops->get_eeprom. If not, please send me=20
> >ethtool.c
> >and tg3.c and I can take a look.
>=20
> Well, IMHO the patch is correctly applied as I could see. I just got =
the=20
> David's tree and run a diff between the ethtool.c files (from David's=
=20
> tree and mine), and I get the following differences. Note that I just=
=20
> add a printk() there to "debug" what was going on.
>=20
> static int ethtool_get_eeprom(struct net_device *dev, void __user *us=
eraddr)
> {
>        struct ethtool_eeprom eeprom;
> -       const struct ethtool_ops *ops =3D dev->ethtool_ops;
> +       struct ethtool_ops *ops =3D dev->ethtool_ops;
>        void __user *userbuf =3D useraddr + sizeof(eeprom);
>        u32 bytes_remaining;
>        u8 *data;
>        int ret =3D 0;
>=20
> +       printk("<1> ethtool_get_eeprom()\n");
>        if (!ops->get_eeprom || !ops->get_eeprom_len)
>                return -EOPNOTSUPP;
>=20
> @@ -330,12 +330,13 @@ static int ethtool_get_eeprom(struct net
> static int ethtool_set_eeprom(struct net_device *dev, void __user=20
> *useraddr)
> {
>        struct ethtool_eeprom eeprom;
> -       const struct ethtool_ops *ops =3D dev->ethtool_ops;
> +       struct ethtool_ops *ops =3D dev->ethtool_ops;
>        void __user *userbuf =3D useraddr + sizeof(eeprom);
>        u32 bytes_remaining;
>        u8 *data;
>        int ret =3D 0;
>=20
> +       printk("<1> ethtool_set_eeprom()\n");
>        if (!ops->set_eeprom || !ops->get_eeprom_len)
>                return -EOPNOTSUPP;
>=20
>=20
> The patched ethtool.c is at  http://rafb.net/p/fWXNwk28.html and tg3.=
c=20
> is at http://rapidshare.com/files/110139941/tg3.c.html
>=20
> --
> Breno Leit=E3o
> leitao@linux.vnet.ibm.com
