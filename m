From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Thu, 26 Feb 2015 10:26:32 -0800
Message-ID: <CAE4R7bAiSH9j=F3VFeGJ6ThDVcv8UmFzULPpA55EwcDWdZV2EQ@mail.gmail.com>
References: <54ED017E.6000902@gmail.com>
	<20150225001534.GB15633@lunn.ch>
	<54ED19AB.7020003@gmail.com>
	<CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
	<20150225140356.GB17992@lunn.ch>
	<CACna6ryQzXQn4Gxn701pXCU6MrZje+w-5B0htM+-PukMbq7ZFQ@mail.gmail.com>
	<20150225141945.GC17992@lunn.ch>
	<CACna6ryUgu3wmQGmU1EomY-CDpBfh2BN8_K+V-XD_3mj4txLDw@mail.gmail.com>
	<20150226151830.GD8806@lunn.ch>
	<CACna6rwVRB2q89EOKNK=5iQogE6_LBGUo1=M1ED0OaR7UqLAAg@mail.gmail.com>
	<20150226153605.GE8806@lunn.ch>
	<CACna6rxsu8Dmzm8wy9c50=qT7te8Du0Rg27N8BN8-M6h06uLMw@mail.gmail.com>
	<54EF5ED6.6000904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:55349 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285AbbBZS0d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 13:26:33 -0500
Received: by mail-qg0-f43.google.com with SMTP id i50so10147545qgf.2
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 10:26:32 -0800 (PST)
In-Reply-To: <54EF5ED6.6000904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 9:58 AM, Florian Fainelli <f.fainelli@gmail.com=
> wrote:
> On 26/02/15 07:49, Rafa=C5=82 Mi=C5=82ecki wrote:
>> On 26 February 2015 at 16:36, Andrew Lunn <andrew@lunn.ch> wrote:
>>>> It doesn't really answer my question as I don't see functionality =
I'm
>>>> looking for in bcm_sf2. I don't see it handling (un)tagging or PVI=
D
>>>> anywhere. It makes me believe such features are not implemented (a=
nd
>>>> not configurable) using bridges/dsa at all. Can you any API relate=
d to
>>>> untagging / PVID?
>>>
>>> The (un)tagging code is in net/dsa/tag_brcm.c This is generic code,=
 so
>>> you would not expect to find it in bcm_sf2. All you need to do is s=
et
>>>
>>>         .tag_protocol           =3D DSA_TAG_PROTO_BRCM,
>>>
>>> in your dsa_switch_driver structure and the core DSA code will ensu=
re
>>> the packets gets the header applied/removed.
>>
>> Sorry, I wasn't clear enough. I don't mean Broadcom proto tagging, b=
ut
>> a 802.1Q VLAN header including e.g. VID.
>>
>> I'd like to have control over VLAN ID ports are using. The hardware
>> allows me to define VLAN with a number and also if:
>> 1) Packets incoming on port X should be modified (by hw) to include
>> 802.11Q header
>> 2) Packets leaving port Y should be stripped out of 802.11Q header o=
r not
>>
>> Above allows me to create some fun setups. For example I can configu=
re
>> my Linux interface to send packets with VID N. Then I can tell
>> hardware to:
>> 1) Send packets with VID N untagged to port 1
>> 2) Send packets with VID N still tagged to port 2
>>
>> I don't see any way to achieve that with dsa. On the other hand this
>> is what my proposed b53 driver allows. I could achieve above setup
>> using:
>> bridge vlan add vid N dev sw0p1 pvid untagged
>> bridge vlan add vid N dev sw0p2
>> bridge vlan add vid N dev sw0p8
>>
>
> What we are currently missing today in DSA, which is on my TODO list =
as
> well, is to add support for precisely this, using the existing:
>
> ndo_add_vlan_rx_add_vid, ndo_vlan_rx_kill_vid, ndo_bridge_getlink and
> ndo_bridge_setlink. Essentialy the same thing same your driver does,
> just one level above, at the DSA layer, so we can have all DSA driver=
s
> advertise/report that feature.

Yes, with rocker we also used ndo_add_vlan_rx_add_vid,
ndo_vlan_rx_kill_vid to figure out the VLAN assignments on a bridge
port, and it works great.  What we haven't got to yet (on our TODO
list) is get access to the PVID of the bridge and use that for the
internal VLAN ID of the chip rather than reserving a portion of the
VLAN space for internal VLAN IDs.  You can use ndo_bridge_getlink and
ndo_bridge_setlink to get same VLAN info, but I think
ndo_add_vlan_rx_add_vid, ndo_vlan_rx_kill_vid is a better choice
because those will also work for the non-bridged port that is assigned
a VLAN, using vconfig for example.
