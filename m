From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth: mac address fix
Date: Mon, 31 Mar 2008 21:39:00 -0500
Message-ID: <47F1A044.6070200@nvidia.com>
References: <47F1534A.7020402@nvidia.com> <20080401000502.GB7423@atjola.homenet> <47F180B8.6010801@nvidia.com> <20080402002459.GA22649@atjola.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F6rn_Steinbrink?= <B.Steinbrink@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:7515 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017AbYDBByb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 21:54:31 -0400
In-Reply-To: <20080402002459.GA22649@atjola.homenet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Bj=F6rn Steinbrink wrote:
> On 2008.03.31 19:24:24 -0500, Ayaz Abdulla wrote:
>=20
>>
>>Bj=F6rn Steinbrink wrote:
>>
>>>On 2008.03.31 16:10:34 -0500, Ayaz Abdulla wrote:
>>>
>>>
>>>>This critical patch fixes a mac address issue recently introduced. =
If=20
>>>>=20
>>>
>>>
>>>Does "recently" mean my commit 2e3884b5b16795c03a7bf295797c1b2402885=
b88?
>>>If so, I like to be told directly when I break stuff ;-)
>>>
>>
>>Thats why I cc'd you. :)
>=20
>=20
> OK, it's just that "recently broken" can mean about anything ;-) So I
> would have welcomed a "broken by xxx" in the commit message, or a sma=
ll
> note below the --- line. :-)
>=20
>=20
>>>>the device's mac address was in correct order and the flag  =20
>>>>NVREG_TRANSMITPOLL_MAC_ADDR_REV was set, during nv_remove the flag=20
>>>>would  get cleared. During next load, the mac address would get=20
>>>>reversed  because the flag is missing.
>>>
>>>
>>>Hm, but nv_remove also writes back the reversed mac address. I don't=
 see
>>>how a plain remove/probe cycle would mess things up.
>>>
>>>
>>
>>For example, NVREG_TRANSMITPOLL_MAC_ADDR_REV is set. That would mean =
=20
>>that orig_mac will be stored with correct address. Then you call =20
>>nv_remove (via ifdown) which set orig_mac back into the register and =
=20
>>will clear the flag. On the next nv_probe (via ifup), you would perfo=
rm =20
>>the logic to reverse the mac address. But it is still in correct orde=
r.
>=20
>=20
> OK, that's the case when we had two consecutive nv_probe calls, witho=
ut
> a call to nv_remove in between, right? So yeah, kexec + rmmod + modpr=
obe
> breaks. AFAICT.
>=20
Actually, I just realized the case I am looking at is different then=20
ifdown/ifup. But it looks like you got it: kexec (nv_probe) + rmmod=20
(nv_remove) + modprobe(nv_probe). I have seen it with=20
insmod/rmmod/insmod since I don't know how kexec works.

=46or clarity, here is the data path.

On the first insmod, it will copy the mac address and store it in orig_=
mac:

	np->orig_mac[0] =3D readl(base + NvRegMacAddrA);
	np->orig_mac[1] =3D readl(base + NvRegMacAddrB);

Then, it will go into the "if" block because=20
NVREG_TRANSMITPOLL_MAC_ADDR_REV is set:

	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
	    (id->driver_data & DEV_HAS_CORRECT_MACADDR)) {
		/* mac address is already in correct order */
		dev->dev_addr[0] =3D (np->orig_mac[0] >>  0) & 0xff;
		dev->dev_addr[1] =3D (np->orig_mac[0] >>  8) & 0xff;
		dev->dev_addr[2] =3D (np->orig_mac[0] >> 16) & 0xff;
		dev->dev_addr[3] =3D (np->orig_mac[0] >> 24) & 0xff;
		dev->dev_addr[4] =3D (np->orig_mac[1] >>  0) & 0xff;
		dev->dev_addr[5] =3D (np->orig_mac[1] >>  8) & 0xff;


Now, if you do a rmmod, nv_remove gets called. You store the correct=20
address back into the hw register (since orig_mac was correct) but clea=
r=20
the "correct" flag:

	writel(np->orig_mac[0], base + NvRegMacAddrA);
	writel(np->orig_mac[1], base + NvRegMacAddrB);
	writel(readl(base + NvRegTransmitPoll) & ~NVREG_TRANSMITPOLL_MAC_ADDR_=
REV,
	       base + NvRegTransmitPoll);

Now, on next insmod, it will save the mac address into orig_mac (which=20
is the correct one). But, this time it will take the "else" path becaus=
e=20
the previous nv_remove cleared the flag:


		/* need to reverse mac address to correct order */
		dev->dev_addr[0] =3D (np->orig_mac[1] >>  8) & 0xff;
		dev->dev_addr[1] =3D (np->orig_mac[1] >>  0) & 0xff;
		dev->dev_addr[2] =3D (np->orig_mac[0] >> 24) & 0xff;
		dev->dev_addr[3] =3D (np->orig_mac[0] >> 16) & 0xff;
		dev->dev_addr[4] =3D (np->orig_mac[0] >>  8) & 0xff;
		dev->dev_addr[5] =3D (np->orig_mac[0] >>  0) & 0xff;
		writel(txreg|NVREG_TRANSMITPOLL_MAC_ADDR_REV, base + NvRegTransmitPol=
l);

This will cause the mac address to be reversed! That is how your patch=20
has had some negative effect.



>=20
>>>>As it has been indicated previously, the flag is cleared across a l=
ow=20
>>>> power transition. Therefore, the driver should set the mac address=
=20
>>>>back  into the reversed order when clearing the flag.
>>>
>>>
>>>That's what nv_remove is supposed to do. Is there a case where nv_re=
move
>>>is not called?
>>>
>>
>>Sorry for the confusion. I was merely stating what needs to be done a=
s =20
>>the full solution. This logic was already in place by your patch.
>>
>>
>>>>Also, the driver should set back the flag after a low power=20
>>>>transition  to protect against kexec command calling nv_probe a=20
>>>>second time.
>>>
>>>
>>>Sounds like suspend stopped calling nv_remove? That would make sense
>>>then. I never checked whether suspend ever actually did call nv_remo=
ve
>>>(I think), but as my patch worked, it basically must have done so, a=
t
>>>least in the past, right?
>>>
>>
>>My understanding is that nv_suspend will call nv_close and then =20
>>nv_resume will call nv_open. I don't think nv_probe/nv_remove is call=
ed =20
>>during the low power transitions.
>=20
>=20
> Hm, then I fail to see why my patch had any effect. I only touched
> nv_probe and nv_remove, and it solved the mac reversal on suspend
> problem... *confused*
>=20
AFAICT nv_remove is not called during the power transitions.

>=20
>>We want to set back the flag in nv_resume in case kexec is call after=
 =20
>>anytime nv_resume is called. Otherwise, nv_probe (via kexec ?) will =20
>>think it needs to reverse the address.
>=20
>=20
> Hmhm, that also somehow conflicts with the fact that my patch did
> anything... I think.=20
>=20
> Bj=F6rn
