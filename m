From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth: mac address fix
Date: Mon, 31 Mar 2008 19:24:24 -0500
Message-ID: <47F180B8.6010801@nvidia.com>
References: <47F1534A.7020402@nvidia.com> <20080401000502.GB7423@atjola.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F6rn_Steinbrink?= <B.Steinbrink@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:10717 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbYDAXnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 19:43:06 -0400
In-Reply-To: <20080401000502.GB7423@atjola.homenet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Bj=F6rn Steinbrink wrote:
> On 2008.03.31 16:10:34 -0500, Ayaz Abdulla wrote:
>=20
>>This critical patch fixes a mac address issue recently introduced. If=
 =20
>=20
>=20
> Does "recently" mean my commit 2e3884b5b16795c03a7bf295797c1b2402885b=
88?
> If so, I like to be told directly when I break stuff ;-)
>=20
Thats why I cc'd you. :)

>=20
>>the device's mac address was in correct order and the flag =20
>>NVREG_TRANSMITPOLL_MAC_ADDR_REV was set, during nv_remove the flag wo=
uld =20
>>get cleared. During next load, the mac address would get reversed =20
>>because the flag is missing.
>=20
>=20
> Hm, but nv_remove also writes back the reversed mac address. I don't =
see
> how a plain remove/probe cycle would mess things up.
>=20
>=20

=46or example, NVREG_TRANSMITPOLL_MAC_ADDR_REV is set. That would mean=20
that orig_mac will be stored with correct address. Then you call=20
nv_remove (via ifdown) which set orig_mac back into the register and=20
will clear the flag. On the next nv_probe (via ifup), you would perform=
=20
the logic to reverse the mac address. But it is still in correct order.

>>As it has been indicated previously, the flag is cleared across a low=
 =20
>>power transition. Therefore, the driver should set the mac address ba=
ck =20
>>into the reversed order when clearing the flag.
>=20
>=20
> That's what nv_remove is supposed to do. Is there a case where nv_rem=
ove
> is not called?
>=20

Sorry for the confusion. I was merely stating what needs to be done as=20
the full solution. This logic was already in place by your patch.

>=20
>>Also, the driver should set back the flag after a low power transitio=
n =20
>>to protect against kexec command calling nv_probe a second time.
>=20
>=20
> Sounds like suspend stopped calling nv_remove? That would make sense
> then. I never checked whether suspend ever actually did call nv_remov=
e
> (I think), but as my patch worked, it basically must have done so, at
> least in the past, right?
>=20

My understanding is that nv_suspend will call nv_close and then=20
nv_resume will call nv_open. I don't think nv_probe/nv_remove is called=
=20
during the low power transitions.

We want to set back the flag in nv_resume in case kexec is call after=20
anytime nv_resume is called. Otherwise, nv_probe (via kexec ?) will=20
think it needs to reverse the address.

> Thanks,
> Bj=F6rn
>=20
>=20
>>Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
>>
>=20
>>--- old/drivers/net/forcedeth.c	2008-03-31 15:25:05.000000000 -0700
>>+++ new/drivers/net/forcedeth.c	2008-03-31 15:41:51.000000000 -0700
>>@@ -5317,8 +5317,7 @@
>>=20
>> 	/* check the workaround bit for correct mac address order */
>> 	txreg =3D readl(base + NvRegTransmitPoll);
>>-	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
>>-	    (id->driver_data & DEV_HAS_CORRECT_MACADDR)) {
>>+	if (id->driver_data & DEV_HAS_CORRECT_MACADDR) {
>> 		/* mac address is already in correct order */
>> 		dev->dev_addr[0] =3D (np->orig_mac[0] >>  0) & 0xff;
>> 		dev->dev_addr[1] =3D (np->orig_mac[0] >>  8) & 0xff;
>>@@ -5326,6 +5325,22 @@
>> 		dev->dev_addr[3] =3D (np->orig_mac[0] >> 24) & 0xff;
>> 		dev->dev_addr[4] =3D (np->orig_mac[1] >>  0) & 0xff;
>> 		dev->dev_addr[5] =3D (np->orig_mac[1] >>  8) & 0xff;
>>+	} else if (txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) {
>>+		/* mac address is already in correct order */
>>+		dev->dev_addr[0] =3D (np->orig_mac[0] >>  0) & 0xff;
>>+		dev->dev_addr[1] =3D (np->orig_mac[0] >>  8) & 0xff;
>>+		dev->dev_addr[2] =3D (np->orig_mac[0] >> 16) & 0xff;
>>+		dev->dev_addr[3] =3D (np->orig_mac[0] >> 24) & 0xff;
>>+		dev->dev_addr[4] =3D (np->orig_mac[1] >>  0) & 0xff;
>>+		dev->dev_addr[5] =3D (np->orig_mac[1] >>  8) & 0xff;
>>+		/*
>>+		 * Set orig mac address back to the reversed version.
>>+		 * This flag will be cleared during low power transition.
>>+		 * Therefore, we should always put back the reversed address.
>>+		 */
>>+		np->orig_mac[0] =3D (dev->dev_addr[5] << 0) + (dev->dev_addr[4] <<=
 8) +
>>+			(dev->dev_addr[3] << 16) + (dev->dev_addr[2] << 24);
>>+		np->orig_mac[1] =3D (dev->dev_addr[1] << 0) + (dev->dev_addr[0] <<=
 8);
>> 	} else {
>> 		/* need to reverse mac address to correct order */
>> 		dev->dev_addr[0] =3D (np->orig_mac[1] >>  8) & 0xff;
>>@@ -5596,7 +5611,9 @@
>> static int nv_resume(struct pci_dev *pdev)
>> {
>> 	struct net_device *dev =3D pci_get_drvdata(pdev);
>>+	u8 __iomem *base =3D get_hwbase(dev);
>> 	int rc =3D 0;
>>+	u32 txreg;
>>=20
>> 	if (!netif_running(dev))
>> 		goto out;
>>@@ -5607,6 +5624,11 @@
>> 	pci_restore_state(pdev);
>> 	pci_enable_wake(pdev, PCI_D0, 0);
>>=20
>>+	/* restore mac address reverse flag */
>>+	txreg =3D readl(base + NvRegTransmitPoll);
>>+	txreg |=3D NVREG_TRANSMITPOLL_MAC_ADDR_REV;
>>+	writel(txreg, base + NvRegTransmitPoll);
>>+
>> 	rc =3D nv_open(dev);
>> out:
>> 	return rc;
>=20
>=20
