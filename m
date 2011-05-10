From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Tue, 10 May 2011 16:33:26 +0200
Message-ID: <BANLkTikSAt0G5gyMDaPrVKr=b4p0DScxoA@mail.gmail.com>
References: <20110510115013.363974020@de.ibm.com> <20110510115047.113084723@de.ibm.com>
 <BANLkTimUUXp5XiCtVoD+pJyQYcE_r25zyA@mail.gmail.com> <20110510140936.GA39624@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:52702 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab1EJOdr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 10:33:47 -0400
In-Reply-To: <20110510140936.GA39624@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 10 maja 2011 16:09 u=BFytkownik Frank Blaschka
<blaschka@linux.vnet.ibm.com> napisa=B3:
> On Tue, May 10, 2011 at 03:19:27PM +0200, Micha=B3 Miros=B3aw wrote:
>> From: Frank Blaschka <frank.blaschka@de.ibm.com>
>> > Set rx csum default to hw checksumming again.
>> > Remove sysfs interface for rx csum (checksumming) and TSO (large_s=
end).
>> > With the new hw_features it does not work to keep the old sysfs
>> > interface in parallel. Convert options.checksum_type to new hw_fea=
tures.
>> [...]
>> > @@ -1482,32 +1476,28 @@ static int qeth_l3_start_ipa_checksum(st
>> [...]
>> > - =A0 =A0 =A0 rc =3D qeth_l3_send_checksum_command(card);
>> > - =A0 =A0 =A0 if (!rc)
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&card->gdev->dev,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 card->dev->hw_featur=
es &=3D ~IPA_INBOUND_CHECKSUM;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 card->dev->features =
&=3D ~IPA_INBOUND_CHECKSUM;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
[...]
>> Don't modify hw_features. Limit currently available features in
>> ndo_fix_features callback instead when checksumming is (temporarily)
>> unavailable.
>>
> We have a recovery operation in our driver. What can we do in case th=
is
> recovery detects the checksumming is not available anymore (during ru=
ntime
> of the device). ndo_fix_features callback does not come into play at =
this time.
> How can we solve this?

Just call netdev_update_features() after recovery.

>> > =A0static int qeth_l3_set_features(struct net_device *dev, u32 fea=
tures)
>> > =A0{
>> > - =A0 =A0 =A0 enum qeth_checksum_types csum_type;
>> > =A0 =A0 =A0 =A0struct qeth_card *card =3D dev->ml_priv;
>> > =A0 =A0 =A0 =A0u32 changed =3D dev->features ^ features;
>> > + =A0 =A0 =A0 int on;
>> >
>> > =A0 =A0 =A0 =A0if (!(changed & NETIF_F_RXCSUM))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>> >
>> > =A0 =A0 =A0 =A0if (features & NETIF_F_RXCSUM)
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 csum_type =3D HW_CHECKSUMMING;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 on =3D 1;
>> > =A0 =A0 =A0 =A0else
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 csum_type =3D SW_CHECKSUMMING;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 on =3D 0;
>> >
>> > =A0 =A0 =A0 =A0dev->features =3D features ^ NETIF_F_RXCSUM;
>> > - =A0 =A0 =A0 return qeth_l3_set_rx_csum(card, csum_type);
>> > + =A0 =A0 =A0 return qeth_l3_set_rx_csum(card, on);
>> > =A0}
>>
>> Since you removed dev->features update from qeth_l3_set_rx_csum(), y=
ou
>> should also modify this code to match. On exit from ndo_fix_features=
,
>> dev->features should reflect what is currently set, even if part of
>> the request failed.
> Do you mean qeth_l3_set_rx_csum should set dev->features dependent of
> the result of the checksum hardware operation?

Yes. If it doesn't, then network core might pass packets needing
hardware checksumming for a device with TX checksumming disabled.

Best Regards,
Micha=B3 Miros=B3aw
