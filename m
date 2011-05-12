From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Thu, 12 May 2011 10:12:51 +0200
Message-ID: <BANLkTimAisv82ZbFb8D1AkL8vuK1V5zAXw@mail.gmail.com>
References: <20110512054318.241733700@de.ibm.com> <20110512054415.435611676@de.ibm.com>
 <BANLkTinO4Hity5++152Ff-RuACFDtoAV2Q@mail.gmail.com> <20110512072132.GA31817@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:36674 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795Ab1ELINM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 04:13:12 -0400
In-Reply-To: <20110512072132.GA31817@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 12 maja 2011 09:21 u=BFytkownik Frank Blaschka
<blaschka@linux.vnet.ibm.com> napisa=B3:
> On Thu, May 12, 2011 at 07:59:45AM +0200, Micha=B3 Miros=B3aw wrote:
>> 2011/5/12 =A0<frank.blaschka@de.ibm.com>:
>> > Set rx csum default to hw checksumming again.
>> > Remove sysfs interface for rx csum (checksumming) and TSO (large_s=
end).
>> > With the new hw_features it does not work to keep the old sysfs
>> > interface in parallel. Convert options.checksum_type to new hw_fea=
tures.
>> [...]
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* hw may have changed during offlin=
e or recovery */
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!qeth_is_supported(card, IPA_INB=
OUND_CHECKSUM)) {
>> [...]
>>
>> This check should go to ndo_fix_features callback. If it fails then
>> just return features &~NETIF_F_RXCSUM from there ...
>>
>> > +update_feature:
>> > + =A0 =A0 =A0 rtnl_lock();
>> > + =A0 =A0 =A0 card->dev->hw_features &=3D ~NETIF_F_RXCSUM;
>> > + =A0 =A0 =A0 card->dev->features &=3D ~NETIF_F_RXCSUM;
>> > + =A0 =A0 =A0 netdev_update_features(card->dev);
>> > + =A0 =A0 =A0 rtnl_unlock();
>>
>> ... and then this should be just:
>> rtnl_lock();
>> netdev_update_features(card->dev);
>> rtnl_unlock();
>>
> This code is part of the recovery, assuming the recovery detects the =
hw
> has lost it's rx csum capability I still don't understand how ndo_fix=
_features
> come into play?

ndo_fix_features is always called before ndo_set_features to alter
features that are to be enabled. So in this case, it should check if
checksumming is available and remove NETIF_F_RXCSUM from the set if it
isn't. The resulting set (after further cleanup by core code) is
passed to ndo_set_features if the features had changed. hw_features
only control what can be requested by user.

I assume that if the device can loose the checksumming capability
during runtime, it can also regain it. Above solution will
automatically reenable checksumming if its requested and the
capability comes back.

Best Regards,
Micha=B3 Miros=B3aw
