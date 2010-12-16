From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] ixgb: Convert to new vlan model.
Date: Wed, 15 Dec 2010 20:29:50 -0800
Message-ID: <AANLkTiktskrP+wEnRHRED8ubtfVfu419_MpK67EVgOVx@mail.gmail.com>
References: <1292298163-30343-1-git-send-email-jesse@nicira.com>
	<1292344315.20458.6.camel@bwh-desktop>
	<EA929A9653AAE14F841771FB1DE5A136602D675056@rrsmsx501.amr.corp.intel.com>
	<1292350359.20458.8.camel@bwh-desktop>
	<EA929A9653AAE14F841771FB1DE5A136602D6751C1@rrsmsx501.amr.corp.intel.com>
	<1292354121.20458.11.camel@bwh-desktop>
	<AANLkTimnSedKQhhL8xXQVKnEm3FpbfRQ_Nd9hPmGbHLJ@mail.gmail.com>
	<EA929A9653AAE14F841771FB1DE5A136602D675D4E@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:58991 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022Ab0LPE3v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 23:29:51 -0500
Received: by fxm18 with SMTP id 18so2874918fxm.2
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 20:29:50 -0800 (PST)
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A136602D675D4E@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 15, 2010 at 10:09 AM, Tantilov, Emil S
<emil.s.tantilov@intel.com> wrote:
> Jesse Gross wrote:
>> On Tue, Dec 14, 2010 at 11:15 AM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>>> On Tue, 2010-12-14 at 12:08 -0700, Tantilov, Emil S wrote:
>>>> Ben Hutchings wrote:
>>>>> On Tue, 2010-12-14 at 11:09 -0700, Tantilov, Emil S wrote:
>>>>>> Ben Hutchings wrote:
>>>>>>> On Mon, 2010-12-13 at 19:42 -0800, Jesse Gross wrote:
>>>>>>>> This switches the ixgb driver to use the new vlan interfaces.
>>>>>>>> In doing this, it completes the work begun in
>>>>>>>> ae54496f9e8d40c89e5668205c181dccfa9ecda1 allowing the use of
>>>>>>>> hardware vlan insertion without having a vlan group configured=
=2E
>>>>>>>> [...] diff --git a/drivers/net/ixgb/ixgb_ethtool.c
>>>>>>>> b/drivers/net/ixgb/ixgb_ethtool.c
>>>>>>>> index 43994c1..0e4c527 100644
>>>>>>>> --- a/drivers/net/ixgb/ixgb_ethtool.c
>>>>>>>> +++ b/drivers/net/ixgb/ixgb_ethtool.c
>>>>>>>> @@ -706,6 +706,45 @@ ixgb_get_strings(struct net_device *netde=
v,
>>>>>>>> u32 =A0stringset, u8 *data) =A0 =A0 =A0 =A0} }
>>>>>>>>
>>>>>>>> +static int ixgb_set_flags(struct net_device *netdev, u32 data=
)
>>>>>>>> +{ + =A0 =A0 =A0 =A0struct ixgb_adapter *adapter =3D netdev_pr=
iv(netdev);
>>>>>>>> + =A0 bool need_reset; + =A0 =A0int rc; + + =A0 =A0 =A0 =A0/* =
The hardware
>>>>>>>> requires that RX vlan stripping and TX vlan insertion + =A0 =A0=
 =A0 *
>>>>>>>> be configured together. =A0Therefore, if one setting changes
>>>>>>>> adjust the + =A0 =A0 =A0* other one to match. + =A0 =A0 =A0 =A0=
 */ +
>>>>>>>> if (!!(data & ETH_FLAG_RXVLAN) !=3D !!(data & ETH_FLAG_TXVLAN)=
) {
>>>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((data & ETH_FLAG_RXVLAN) =
!=3D +
>>>>>>>> (netdev->features & NETIF_F_HW_VLAN_RX)) +
>>>>>>>> data ^=3D ETH_FLAG_TXVLAN; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0el=
se if ((data &
>>>>>>>> ETH_FLAG_TXVLAN) !=3D + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
(netdev->features &
>>>>>>>> NETIF_F_HW_VLAN_TX)) + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0data ^=3D
>>>>>>>> ETH_FLAG_RXVLAN; + =A0 =A0 =A0 =A0}
>>>>>>> [...]
>>>>>>>
>>>>>>> I think this should reject attempts to change just one flag wit=
h
>>>>>>> -EINVAL, rather than quietly 'fixing' the setting.
>>>>>>>
>>>>>>> Ben.
>>>>>>
>>>>>> I'm not sure this is a good idea. At least not without some sort
>>>>>> of explanation. Since there is no way for the user to know that
>>>>>> he needs to disable both.
>>>>>
>>>>> Document the limitation in Documentation/networking/ixgb.txt. =A0=
You
>>>>> could also send a patch for the ethtool manual page stating that
>>>>> this restriction might exist.
>>>>>
>>>>> Ben.
>>>>
>>>> Just to make sure it's clear - there is no hard requirement for bo=
th
>>>> settings to be set at the same time. So setting:
>>>> ethtool -K eth0 rxvlan off
>>>>
>>>> Is a valid setting and will disable stripping on Rx, but because o=
f
>>>> the design, stripping on Tx will also be disabled.
>>>
>>> Then it's *not* a valid setting for your hardware/driver.
>>
>> Ben, I agree that limiting the settings to what is actually supporte=
d
>> is conceptually cleaner but in practice it's not very intuitive. =A0=
If
>> you try to turn something off and the response is that it's invalid,
>> most people are going to assume that you just can't do it. =A0This i=
s
>> especially true since you actually can't turn these settings off in
>> most drivers.
>>
>> There's a precedent for this type of thing: turn off TX checksum
>> offloading and watch scatter/gather and TSO be automatically disable=
d
>> as well. =A0It makes sense - the user requested a change, we do what=
 is
>> necessary to make that happen without requiring them to understand w=
hy
>> these features are interrelated.
>>
>> Emil, I realized afterwards that, as you pointed out, TX vlan
>> offloading can be disabled without requiring RX offloading to be
>> disabled. =A0Feel free to make the modification yourself or I can
>> resubmit, whichever is easier.
>
> If it's OK with you I can make whatever changes are needed since I ne=
ed
> to test this first, so I don't want to go back and forth in case we f=
ind
> other issues in testing.

Yes, please go ahead and make the necessary changes - I'm really just
interested in the end result.
