From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Wed, 04 Nov 2009 12:31:26 +0100
Message-ID: <4AF1660E.1080401@gmail.com>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>	 <4AEEFE2E.7090706@trash.net> <20091102125345.3c39c42e@nehalam>	 <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com>	 <4AF10B1D.4050604@gmail.com> <4AF110CE.8070701@gmail.com> <b30d1c3b0911040019q14a007d4lbd1b695db8884b27@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59706 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755450AbZKDLba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 06:31:30 -0500
In-Reply-To: <b30d1c3b0911040019q14a007d4lbd1b695db8884b27@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ryousei Takano a =E9crit :

>=20
> I tried iperf with 60 seconds samples. I got the almost same result.
>=20
> Here is the result:
>       sender	receiver
> 1.000 1.00	1.00
> 2.000 2.01	2.01
> 3.000 3.03	3.02
> 4.000 4.07	4.07
> 5.000 5.05	5.05
> 6.000 6.16	6.16
> 7.000 7.22	7.22
> 8.000 8.15	8.15
> 9.000 9.23	9.23
> 9.900 9.69	9.69
>=20

One thing to consider is the estimation error in qdisc_l2t(), rate tabl=
e has only 256 slots

static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int=
 pktlen)
{
	int slot =3D pktlen + rtab->rate.cell_align + rtab->rate.overhead;
	if (slot < 0)
		slot =3D 0;
	slot >>=3D rtab->rate.cell_log;
	if (slot > 255)
		return (rtab->data[255]*(slot >> 8) + rtab->data[slot & 0xFF]);
	return rtab->data[slot];
}


Maybe you can try changing class mtu to 40000 instead of 9000, and quan=
tum to 60000 too

tc class add dev $DEV parent 1: classid 1:1 htb rate ${rate}mbit mtu 40=
000 quantum 60000

(because your tcp stack sends large buffers ( ~ 60000 bytes) as your NI=
C can offload tcp segmentation)

