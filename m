From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] ixgb: Convert to new vlan model.
Date: Tue, 14 Dec 2010 13:29:34 -0800
Message-ID: <AANLkTimnSedKQhhL8xXQVKnEm3FpbfRQ_Nd9hPmGbHLJ@mail.gmail.com>
References: <1292298163-30343-1-git-send-email-jesse@nicira.com>
	<1292344315.20458.6.camel@bwh-desktop>
	<EA929A9653AAE14F841771FB1DE5A136602D675056@rrsmsx501.amr.corp.intel.com>
	<1292350359.20458.8.camel@bwh-desktop>
	<EA929A9653AAE14F841771FB1DE5A136602D6751C1@rrsmsx501.amr.corp.intel.com>
	<1292354121.20458.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f45.google.com ([209.85.215.45]:42736 "EHLO
	mail-ew0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760158Ab0LNV3g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 16:29:36 -0500
Received: by ewy10 with SMTP id 10so750655ewy.4
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 13:29:34 -0800 (PST)
In-Reply-To: <1292354121.20458.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 11:15 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Tue, 2010-12-14 at 12:08 -0700, Tantilov, Emil S wrote:
>> Ben Hutchings wrote:
>> > On Tue, 2010-12-14 at 11:09 -0700, Tantilov, Emil S wrote:
>> >> Ben Hutchings wrote:
>> >>> On Mon, 2010-12-13 at 19:42 -0800, Jesse Gross wrote:
>> >>>> This switches the ixgb driver to use the new vlan interfaces.
>> >>>> In doing this, it completes the work begun in
>> >>>> ae54496f9e8d40c89e5668205c181dccfa9ecda1 allowing the use of
>> >>>> hardware vlan insertion without having a vlan group configured.
>> >>>> [...] diff --git a/drivers/net/ixgb/ixgb_ethtool.c
>> >>>> b/drivers/net/ixgb/ixgb_ethtool.c
>> >>>> index 43994c1..0e4c527 100644
>> >>>> --- a/drivers/net/ixgb/ixgb_ethtool.c
>> >>>> +++ b/drivers/net/ixgb/ixgb_ethtool.c
>> >>>> @@ -706,6 +706,45 @@ ixgb_get_strings(struct net_device *netdev=
,
>> >>>> u32 =A0stringset, u8 *data) =A0 =A0 =A0 =A0} }
>> >>>>
>> >>>> +static int ixgb_set_flags(struct net_device *netdev, u32 data)=
 +{
>> >>>> + =A0 =A0 =A0 =A0struct ixgb_adapter *adapter =3D netdev_priv(n=
etdev); + =A0 bool
>> >>>> need_reset; + =A0 =A0int rc; +
>> >>>> + =A0 =A0 =A0 =A0/* The hardware requires that RX vlan strippin=
g and TX vlan
>> >>>> insertion + =A0 =A0 =A0 * be configured together. =A0Therefore,=
 if one setting
>> >>>> changes adjust the + =A0 =A0 =A0* other one to match. + =A0 =A0=
 =A0 =A0 */
>> >>>> + =A0 =A0 =A0 =A0if (!!(data & ETH_FLAG_RXVLAN) !=3D !!(data & =
ETH_FLAG_TXVLAN)) {
>> >>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((data & ETH_FLAG_RXVLAN) !=
=3D
>> >>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(netdev->features & NE=
TIF_F_HW_VLAN_RX))
>> >>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data ^=3D ETH_=
=46LAG_TXVLAN;
>> >>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else if ((data & ETH_FLAG_TXVL=
AN) !=3D
>> >>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(netdev->features & NE=
TIF_F_HW_VLAN_TX))
>> >>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data ^=3D ETH_=
=46LAG_RXVLAN;
>> >>>> + =A0 =A0 =A0 =A0}
>> >>> [...]
>> >>>
>> >>> I think this should reject attempts to change just one flag with
>> >>> -EINVAL, rather than quietly 'fixing' the setting.
>> >>>
>> >>> Ben.
>> >>
>> >> I'm not sure this is a good idea. At least not without some sort =
of
>> >> explanation. Since there is no way for the user to know that he n=
eeds
>> >> to disable both.
>> >
>> > Document the limitation in Documentation/networking/ixgb.txt. =A0Y=
ou
>> > could also send a patch for the ethtool manual page stating that t=
his
>> > restriction might exist.
>> >
>> > Ben.
>>
>> Just to make sure it's clear - there is no hard requirement for both
>> settings to be set at the same time. So setting:
>> ethtool -K eth0 rxvlan off
>>
>> Is a valid setting and will disable stripping on Rx, but because of
>> the design, stripping on Tx will also be disabled.
>
> Then it's *not* a valid setting for your hardware/driver.

Ben, I agree that limiting the settings to what is actually supported
is conceptually cleaner but in practice it's not very intuitive.  If
you try to turn something off and the response is that it's invalid,
most people are going to assume that you just can't do it.  This is
especially true since you actually can't turn these settings off in
most drivers.

There's a precedent for this type of thing: turn off TX checksum
offloading and watch scatter/gather and TSO be automatically disabled
as well.  It makes sense - the user requested a change, we do what is
necessary to make that happen without requiring them to understand why
these features are interrelated.

Emil, I realized afterwards that, as you pointed out, TX vlan
offloading can be disabled without requiring RX offloading to be
disabled.  Feel free to make the modification yourself or I can
resubmit, whichever is easier.
