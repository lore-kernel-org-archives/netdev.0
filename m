From: =?iso-8859-1?Q?Jos=E9_Alexandre_Ventura?= <jose.ventura@efacec.com>
Subject: Re: SMSC LAN9512 PowerPC Linux Driver Problem
Date: Tue, 23 Oct 2012 09:56:35 +0000
Message-ID: <E7E8E31F-D443-44CC-98D1-3533312ECA5A@efacec.com>
References: <4A56411E-6E5F-489A-B6DA-4A527528B785@efacec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?An=EDbal_Almeida_Pinto?= <anibal.pinto@efacec.com>
To: "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.efacec.com ([213.58.230.66]:64162 "HELO mail3.efacec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932801Ab2JWKJL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 06:09:11 -0400
In-Reply-To: <4A56411E-6E5F-489A-B6DA-4A527528B785@efacec.com>
Content-Language: en-US
Content-ID: <39A982B07E345E49BB26A1282B006553@efacec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I have made a modification to the smsc95xx.c and apparently it has fixe=
d the tx checksum issue but I don't know if I have broken other things =
in the process.
I have also applied the MTU patch (9bbf556), because without it I could=
n't send large files.

I have made the following alteration on smsc95xx.c:

	if (csum) {
		if (skb->len <=3D 45) {
			/* workaround - hardware tx checksum does not work
			 * properly with extremely small packets */
			long csstart =3D skb_checksum_start_offset(skb);
			__wsum calc =3D csum_partial(skb->data + csstart,
				skb->len - csstart, 0);
			*((__sum16 *)(skb->data + csstart
				+ skb->csum_offset)) =3D csum_fold(calc);

			csum =3D false;
		} else {
-			u32 csum_preamble =3D smsc95xx_calc_csum_preamble(skb);
+			u32 csum_preamble =3D cpu_to_le32( smsc95xx_calc_csum_preamble(skb)=
 );
			skb_push(skb, 4);
			memcpy(skb->data, &csum_preamble, 4);
		}
	}

Could anyone please confirm that this fixes the problem without affecti=
ng the normal operation of the driver?

Best Regards,
Jos=E9


On 09/10/2012, at 12:01, Jos=E9 Ventura <jose.ventura@efacec.com> wrote=
:

>=20
> Hi,
>=20
> I'm having problems with an SMSC EVB9512, based on the LAN9512 chip, =
when using with a PowerPC Chip. The Driver I'm using is the one already=
 provided by Linux.
> I have tested the EVB9512 in two test configurations, both using a Po=
werPC:
>=20
> First Test Configuration:
> - Custom Board with PowerPC Fresscale MPC8378  @ 667MHz
> - Linux Kernel 3.0.0
> - EVB9512 connected via USB
>=20
> Problems with First Test Configuration:
> - nmap reports ports has filtered, even thought they are open
> - can't establish any connection, even a TCP socket
> - can ping the Board with other Devices without a problem
>=20
> I have made more tests and found out that even though I can receive a=
nd send packages, my TX packages had incorrect TCP checksum.
> I then used ethtool to disable TX Checksum offloading and all my prob=
lems were solved. The problem with this 'fix' is that it uses more CPU =
and when under heavy load, I get an error and the ethernet port is shut=
=2E
>=20
>=20
> Second Configuration:
> - PowerBook G4 1.5GHz, 1.25MB DDR333
> - Ubuntu Live CD 12.04 LTS
> - EVB9512 connected via USB
>=20
> Problems with second Configuration:
> - TX packets appears as errors in ifconfig
> - The powerbook is pinged from another machine without a problem but =
the PowerBook can't ping the other device
>=20
> I have also tested the EVB9512 with a Custom Card with an OMAP L138 a=
nd also tested with a Toshiba Notebook with an Intel Core i5, both with=
out any problems. This shows that it is not a problem with the EVB9512 =
itself because it works correctly with other architectures. I think the=
 problems lies in the PowerPC driver of the LAN95xx.
>=20
>=20
> Best Regards,
> Jos=E9 Ventura
>=20
