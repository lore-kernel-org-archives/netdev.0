From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: tg3: regression of netdev stats
Date: Sat, 02 Mar 2013 15:10:42 +0900
Message-ID: <87y5e6wcv1.fsf@devron.myhome.or.jp>
References: <878v67xnkr.fsf@devron.myhome.or.jp>
	<1362152836.6212.27.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nsujir@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:42418 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756Ab3CBGKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Mar 2013 01:10:51 -0500
In-Reply-To: <1362152836.6212.27.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	(Michael Chan's message of "Fri, 1 Mar 2013 07:47:16 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael Chan" <mchan@broadcom.com> writes:

> On Fri, 2013-03-01 at 22:21 +0900, OGAWA Hirofumi wrote: 
>> Hi,
>> 
>> f4a46d1f46a8fece34edd2023e054072b02e110d (tg3: Prevent spurious tx
>> timeout by setting carrier off before tx disable.) seems to add the bug.
>> 
>> On 3.8.1 (I didn't use 3.7.x series), "ifconfig" commands doesn't show
>> any stats, i.e. all stats are zero.
>
> No stats on an active device transmitting and receiving packets?  I
> don't seem to see the same problem, but we'll look into this further.
> Thanks.

Yes, /proc/net/dev didn't show any packet traffic stats (always
zero). But, e.g. ping/nfs itself works fine.

BTW, chip is

02:00.0 Ethernet controller [0200]: Broadcom Corporation NetLink BCM57788 Gigabit Ethernet PCIe [14e4:1691] (rev 01)

tg3 0000:02:00.0 eth0: Tigon3 [partno(BCM57788) rev 57780001] (PCI Express) MAC address d4:be:d9:a6:a3:3b
tg3 0000:02:00.0 eth0: attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=200:01)

>> And bisect points the above commit.
>> In fact, reverting the above patch fixes the regression of netdev stats.
>> 
>> This patch looks like strange, and I'm not sure what this want to do.
>> Any ideas?
>
> Every time we reset the device (ethtool, MTU change, etc), we need to
> turn off all the tx queues before resetting.  As soon as we turn off
> these queues, if we don't turn off carrier, a tx timeout may be
> triggered if it's been more than 5 seconds since the last transmit on
> any of the tx queues.  These tx timeouts cause unnecessary concern to
> the user.

Hmm...  I'm not reading codes almost, so this might be wrong
though. tg3_phy_reset() set off if ->link_up, so this seems to be not
saving original state, and I'm not sure what want to do with ->link_up.

I felt the following pesudo code might be work and simple...

	ok = netif_carrier_ok()
        netif_carrier_off()

	[reconfigure...]

        if (ok)
        	netif_carrier_on()

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
