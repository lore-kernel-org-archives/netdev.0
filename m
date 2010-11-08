From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/2] ixgb: Don't check for vlan group on transmit.
Date: Mon, 8 Nov 2010 11:59:07 -0800
Message-ID: <AANLkTin5YMqpq0h-2HQ8XgaheYYDeMUFv8Qo6fZdWhxB@mail.gmail.com>
References: <1288464591-31528-1-git-send-email-jesse@nicira.com>
	<1288984304.3091.11.camel@jtkirshe-MOBL1>
	<AANLkTin62WWL+cnLVNaOYmcvL28rfkUDVCVqiimSPZ=e@mail.gmail.com>
	<1288987609.3091.16.camel@jtkirshe-MOBL1>
	<80769D7B14936844A23C0C43D9FBCF0F25BD180E03@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52557 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883Ab0KHT7J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 14:59:09 -0500
Received: by wwb18 with SMTP id 18so313733wwb.1
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 11:59:08 -0800 (PST)
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F25BD180E03@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 5, 2010 at 3:30 PM, Duyck, Alexander H
<alexander.h.duyck@intel.com> wrote:
>
>
>>-----Original Message-----
>>From: Kirsher, Jeffrey T
>>Sent: Friday, November 05, 2010 1:07 PM
>>To: Jesse Gross
>>Cc: David Miller; netdev@vger.kernel.org; Brandeburg, Jesse; Duyck,
>>Alexander H
>>Subject: Re: [PATCH 1/2] ixgb: Don't check for vlan group on transmit=
=2E
>>
>>On Fri, 2010-11-05 at 12:56 -0700, Jesse Gross wrote:
>>> On Fri, Nov 5, 2010 at 12:11 PM, Jeff Kirsher
>>> <jeffrey.t.kirsher@intel.com> wrote:
>>> > On Sat, 2010-10-30 at 11:49 -0700, Jesse Gross wrote:
>>> >> On transmit, the ixgb driver will only use vlan acceleration if =
a
>>> >> vlan group is configured. =A0This can lead to tags getting dropp=
ed
>>> >> when bridging because the networking core assumes that a driver
>>> >> that claims vlan acceleration support can do it at all times.
>>This
>>> >> change should have been part of commit eab6d18d "vlan: Don't
>>check for
>>> >> vlan group before vlan_tx_tag_present." but was missed.
>>> >>
>>> >> Signed-off-by: Jesse Gross <jesse@nicira.com>
>>> >> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> >> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>> >> CC: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
>>> >> ---
>>> >> =A0drivers/net/ixgb/ixgb_main.c | =A0 =A02 +-
>>> >> =A01 files changed, 1 insertions(+), 1 deletions(-)
>>> >>
>>> >> diff --git a/drivers/net/ixgb/ixgb_main.c
>>b/drivers/net/ixgb/ixgb_main.c
>>> >> index caa8192..d18194e 100644
>>> >> --- a/drivers/net/ixgb/ixgb_main.c
>>> >> +++ b/drivers/net/ixgb/ixgb_main.c
>>> >> @@ -1498,7 +1498,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struc=
t
>>net_device *netdev)
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DESC_NEEDED)))
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_BUSY;
>>> >>
>>> >> - =A0 =A0 if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
>>> >> + =A0 =A0 if (vlan_tx_tag_present(skb)) {
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_flags |=3D IXGB_TX_FLAGS_VLAN;
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_id =3D vlan_tx_tag_get(skb);
>>> >> =A0 =A0 =A0 }
>>> >
>>> > After further review, NAK because this will cause a bug. =A0With
>>this
>>> > patch it would be possible to overrun the buffers, so the correct
>>fix is
>>> > to increase max_frame_size by VLAN_TAG_SIZE in
>>ixgb/igb_change_mtu.
>>>
>>> Hmm, I didn't see any other place where it made changes to the
>>> handling of packets on transmit if a vlan group is configured.
>>Maybe
>>> the buffer is extended when a group is registered and stripping is
>>> enabled?
>>>
>>> In any case, you might want to check the other Intel drivers for
>>> similar problems. =A0I did a pass and made a mass conversion of thi=
s
>>> type a little while ago. =A0Those changes have already been merged,=
 I
>>> just missed this one by accident.
>>
>>I will get with Alex and review the other Intel drivers, thanks Jesse=
=2E
>
> Just to make things clear. =A0The ixgb patch is fine. =A0There isn't =
anything wrong with it.
>
> The patch with the bug is the other patch, "2/2 igb: Don't depend on =
VLAN group for receive size". =A0The problem is it was updating the RLP=
ML register, but not updating the buffer sizes as such there were a few=
 cases where we could receive a buffer larger the SKB head room. =A0The=
 bug itself probably won't come up very often since there are only a co=
uple of very specific MTU sizes where it will be an issue.
>

OK, that makes more sense.  It seems that the other drivers already
account for this, so they should be fine.

> The quick fix for your patch is to move the addition of VLAN_TAG_SIZE=
 to the max_frame in igb_change_mtu instead of in the set_rlpml call. =A0=
Otherwise I will see about submitting an updated patch in the next few =
days.

I happy to let you take care of it - obviously you know the
driver/hardware much better than I.
