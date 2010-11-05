From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/2] ixgb: Don't check for vlan group on transmit.
Date: Fri, 5 Nov 2010 12:56:30 -0700
Message-ID: <AANLkTin62WWL+cnLVNaOYmcvL28rfkUDVCVqiimSPZ=e@mail.gmail.com>
References: <1288464591-31528-1-git-send-email-jesse@nicira.com>
	<1288984304.3091.11.camel@jtkirshe-MOBL1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:55334 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286Ab0KET4c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 15:56:32 -0400
Received: by ewy7 with SMTP id 7so2024703ewy.19
        for <netdev@vger.kernel.org>; Fri, 05 Nov 2010 12:56:31 -0700 (PDT)
In-Reply-To: <1288984304.3091.11.camel@jtkirshe-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 5, 2010 at 12:11 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Sat, 2010-10-30 at 11:49 -0700, Jesse Gross wrote:
>> On transmit, the ixgb driver will only use vlan acceleration if a
>> vlan group is configured. =A0This can lead to tags getting dropped
>> when bridging because the networking core assumes that a driver
>> that claims vlan acceleration support can do it at all times. =A0Thi=
s
>> change should have been part of commit eab6d18d "vlan: Don't check f=
or
>> vlan group before vlan_tx_tag_present." but was missed.
>>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> CC: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
>> ---
>> =A0drivers/net/ixgb/ixgb_main.c | =A0 =A02 +-
>> =A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_ma=
in.c
>> index caa8192..d18194e 100644
>> --- a/drivers/net/ixgb/ixgb_main.c
>> +++ b/drivers/net/ixgb/ixgb_main.c
>> @@ -1498,7 +1498,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct ne=
t_device *netdev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DESC_NEEDED)))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_BUSY;
>>
>> - =A0 =A0 if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
>> + =A0 =A0 if (vlan_tx_tag_present(skb)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_flags |=3D IXGB_TX_FLAGS_VLAN;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_id =3D vlan_tx_tag_get(skb);
>> =A0 =A0 =A0 }
>
> After further review, NAK because this will cause a bug. =A0With this
> patch it would be possible to overrun the buffers, so the correct fix=
 is
> to increase max_frame_size by VLAN_TAG_SIZE in ixgb/igb_change_mtu.

Hmm, I didn't see any other place where it made changes to the
handling of packets on transmit if a vlan group is configured.  Maybe
the buffer is extended when a group is registered and stripping is
enabled?

In any case, you might want to check the other Intel drivers for
similar problems.  I did a pass and made a mass conversion of this
type a little while ago.  Those changes have already been merged, I
just missed this one by accident.
