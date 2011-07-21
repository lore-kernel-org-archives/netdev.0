From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/2] igb: Allow extra 4 bytes on RX for vlan tags.
Date: Wed, 20 Jul 2011 17:18:46 -0700
Message-ID: <CAEP_g=_o7nP2FCnPufyT44JZZ+Z+jkcVpSa8Qj3mjPn+MwRhXA@mail.gmail.com>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
 <AANLkTinsWRAJ2bepa1NjQ4f0Wz46DaxWO6f_nEbmBAB0@mail.gmail.com> <4D5D5AD8.5000802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:39814 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab1GUATJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 20:19:09 -0400
Received: by gyh3 with SMTP id 3so373013gyh.19
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 17:19:08 -0700 (PDT)
In-Reply-To: <4D5D5AD8.5000802@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 17, 2011 at 9:28 AM, Ben Greear <greearb@candelatech.com> w=
rote:
> On 02/17/2011 03:04 AM, Jeff Kirsher wrote:
>>
>> On Thu, Feb 10, 2011 at 13:59,<greearb@candelatech.com> =C2=A0wrote:
>>>
>>> From: Ben Greear<greearb@candelatech.com>
>>>
>>> This allows the NIC to receive 1518 byte (not counting
>>> FCS) packets when MTU is 1500, thus allowing 1500 MTU
>>> VLAN frames to be received. =C2=A0Please note that no VLANs
>>> were actually configured on the NIC...it was just acting
>>> as pass-through device.
>>>
>>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>>> ---
>>> :100644 100644 58c665b... 30c9cc6... M =C2=A0drivers/net/igb/igb_ma=
in.c
>>> =C2=A0drivers/net/igb/igb_main.c | =C2=A0 =C2=A05 +++--
>>> =C2=A01 files changed, 3 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.=
c
>>> index 58c665b..30c9cc6 100644
>>> --- a/drivers/net/igb/igb_main.c
>>> +++ b/drivers/net/igb/igb_main.c
>>> @@ -2281,7 +2281,8 @@ static int __devinit igb_sw_init(struct igb_a=
dapter
>>> *adapter)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->rx_itr_setting =3D IGB_DEFAULT_=
ITR;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->tx_itr_setting =3D IGB_DEFAULT_=
ITR;
>>>
>>> - =C2=A0 =C2=A0 =C2=A0 adapter->max_frame_size =3D netdev->mtu + ET=
H_HLEN + ETH_FCS_LEN;
>>> + =C2=A0 =C2=A0 =C2=A0 adapter->max_frame_size =3D (netdev->mtu + E=
TH_HLEN + ETH_FCS_LEN
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0+ VLAN_HLEN);
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->min_frame_size =3D ETH_ZLEN + E=
TH_FCS_LEN;
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(&adapter->stats64_lock);
>>> @@ -4303,7 +4304,7 @@ static int igb_change_mtu(struct net_device
>>> *netdev, int new_mtu)
>>> =C2=A0{
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct igb_adapter *adapter =3D netdev_p=
riv(netdev);
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pci_dev *pdev =3D adapter->pdev;
>>> - =C2=A0 =C2=A0 =C2=A0 int max_frame =3D new_mtu + ETH_HLEN + ETH_F=
CS_LEN;
>>> + =C2=A0 =C2=A0 =C2=A0 int max_frame =3D new_mtu + ETH_HLEN + ETH_F=
CS_LEN + VLAN_HLEN;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 rx_buffer_len, i;
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((new_mtu< =C2=A068) || (max_frame> =C2=
=A0MAX_JUMBO_FRAME_SIZE)) {
>>
>> While testing this patch, validation found that the patch reduces th=
e
>> maximum mtu size
>> by 4 bytes (reduces it from 9216 to 9212). =C2=A0This is not a desir=
ed side
>> effect of this patch.
>
> You could add handling for that case and have it act as it used to wh=
en
> new_mtu is greater than 9212?
>
> I tested e1000e and it worked w/out hacking at 1500 MTU, so maybe
> check how it does it?

I just wanted to bring this up again to see if any progress had been
made.  We were looking at this driver and trying to figure out the
best way to convert it to use the new vlan model but I'm not familiar
enough with the hardware to know.  It seems that all of the other
Intel drivers unconditionally add space for the vlan tag to the
receive buffer (and would therefore have similar effects as this
patch), is there something different about this card?

I believe that Alex was working on something in this area (in the
context of one of my patches from a long time ago) but I'm not sure
what came of that.
