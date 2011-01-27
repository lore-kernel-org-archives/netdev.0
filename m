From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 08/12] ixgb: convert to new VLAN model
Date: Wed, 26 Jan 2011 19:53:13 -0800
Message-ID: <AANLkTi=RU11ibzd3c9sqCLL0pNowvx1_ow7C=qWVoPMt@mail.gmail.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1294360199-9860-9-git-send-email-jeffrey.t.kirsher@intel.com>
	<AANLkTik1rCFRtBWov5f8yfU+4JZnbzLHgcmRC1y_+TDP@mail.gmail.com>
	<EA929A9653AAE14F841771FB1DE5A136602DEE63CB@rrsmsx501.amr.corp.intel.com>
	<AANLkTikS7zw5OfPFTJBUeUyy39Tx26Wkg9FX3n77-v1G@mail.gmail.com>
	<EA929A9653AAE14F841771FB1DE5A136602DF59AA3@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bphilips@novell.com" <bphilips@novell.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:42597 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678Ab1A0DxO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 22:53:14 -0500
Received: by iyj18 with SMTP id 18so1058651iyj.19
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 19:53:14 -0800 (PST)
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A136602DF59AA3@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 25, 2011 at 10:20 AM, Tantilov, Emil S
<emil.s.tantilov@intel.com> wrote:
>>-----Original Message-----
>>From: Jesse Gross [mailto:jesse@nicira.com]
>>Sent: Tuesday, January 25, 2011 9:23 AM
>>To: Tantilov, Emil S
>>Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
>>bphilips@novell.com; Pieper, Jeffrey E
>>Subject: Re: [net-next 08/12] ixgb: convert to new VLAN model
>>
>>On Sun, Jan 23, 2011 at 4:25 PM, Tantilov, Emil S
>><emil.s.tantilov@intel.com> wrote:
>>> Jesse Gross wrote:
>>>> On Thu, Jan 6, 2011 at 7:29 PM, =A0<jeffrey.t.kirsher@intel.com> w=
rote:
>>>>> +static int ixgb_set_flags(struct net_device *netdev, u32 data) +=
{
>>>>> + =A0 =A0 =A0 struct ixgb_adapter *adapter =3D netdev_priv(netdev=
); +
>>>>> bool need_reset; + =A0 =A0 =A0 int rc;
>>>>> +
>>>>> + =A0 =A0 =A0 /*
>>>>> + =A0 =A0 =A0 =A0* TX vlan insertion does not work per HW design =
when Rx
>>>>> stripping is + =A0 =A0 =A0 =A0* disabled. =A0Disable txvlan when =
rxvlan is
>>>>> off. + =A0 =A0 =A0 =A0*/ + =A0 =A0 =A0 if ((data & ETH_FLAG_RXVLA=
N) !=3D
>>>>> (netdev->features & NETIF_F_HW_VLAN_RX)) + =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 data ^=3D
>>>>> ETH_FLAG_TXVLAN;
>>>>
>>>> Does this really do the right thing? =A0If the RX vlan setting is
>>>> changed, it will do the opposite of what the user requested for TX
>>>> vlan?
>>>>
>>>> So if I start with both on (the default) and turn them both off in=
 one
>>>> command (a valid setting), I will get RX off and TX on (an invalid
>>>> setting).
>>>>
>>>> Why not:
>>>>
>>>> if (!(data & ETH_FLAG_RXVLAN))
>>>> =A0 =A0 =A0 =A0 data &=3D ~ETH_FLAG_TXVLAN;
>>>
>>> Yeah that works for disabling rxvlan, but what if rxvlan is disable=
d, and
>>the user attempts to enable txvlan? At least our validation argued th=
at we
>>should make it work both ways. Perhaps something like the following?
>>>
>>> =A0 =A0 =A0 =A0if (!(data & ETH_FLAG_RXVLAN) &&
>>> =A0 =A0 =A0 =A0 =A0 (netdev->features & NETIF_F_HW_VLAN_TX))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data &=3D ~ETH_FLAG_TXVLAN;
>>> =A0 =A0 =A0 =A0else if (data & ETH_FLAG_TXVLAN)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data |=3D ETH_FLAG_RXVLAN;
>>
>>I think the logic above does what you describe and will always result
>>in a consistent state. =A0Turning dependent features on when needed i=
s a
>>little bit inconsistent with the rest of Ethtool (for example, turnin=
g
>>on TSO when checksum offloading is off will not enable checksum
>>offloading, it will produce an error). =A0However, I know that driver=
s
>
> That is the reason I asked, as I don't want to keep bouncing the patc=
h back and forth. Personally I like the idea of helping the user and ad=
justing the flags to something that works rather than a generic error m=
essage.

I think it is fine to adjust things, especially where the restrictions
are hardware specific and the user is less likely to know what
settings are related.  As long as it works, it doesn't matter too much
to me either way, so please do what you think is the most appropriate.

>
>>aren't completely consistent here and the most important part is that
>>it enforces valid states, so I don't have a strong opinion. =A0Ben's
>>previous suggestion of Ethtool querying again after the operation and
>>reporting any flags that were automatically changed would help a lot
>>here.
>
> Sure, but I think a savvy user would always check the result of an et=
htool command (ie. `ethtool -K` followed with `ethtool -k`, -A/-a, etc)=
=2E

Probably, but it seems the less savviness required from the user the
better.  Regardless, it doesn't affect anything here, it would just be
a change to the userspace tool.
