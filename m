From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: "ADDRCONF(NETDEV_UP): eth0: link is not ready" with IPv6
Date: Tue, 3 Jul 2012 18:15:21 +0200
Message-ID: <4FF31A99.9010806@atmel.com>
References: <4FED14C2.9020200@xdin.com> <1340983473.3066.6.camel@bwh-desktop.uk.solarflarecom.com> <4FF313F6.7010600@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@vyatta.com>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Arvid Brodin <Arvid.Brodin@xdin.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:33937 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339Ab2GCQPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 12:15:30 -0400
In-Reply-To: <4FF313F6.7010600@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/2012 05:47 PM, Arvid Brodin :
> (Added MACB "patch" contact Nicolas Ferre to CC list.)

Hi,

(adding linux-arm-kernel)

> On 2012-06-29 17:24, Ben Hutchings wrote:
>> On Fri, 2012-06-29 at 02:36 +0000, Arvid Brodin wrote:
>>> Hi,
>>>
>>> After 'ip link set eth0 up' on an avr32 board (network driver macb), the device ends up in
>>> operational mode "UNKNOWN":
>>>
>>> # ip link
>>> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
>>>     link/ether 00:24:74:00:17:9d brd ff:ff:ff:ff:ff:ff
>>>
>>> Unplugging and plugging in the network cable gets the device to mode "UP".
>>>
>>> This is a problem for me because I'm trying to use this device as a "slave" device (for a
>>> virtual HSR device*) and I need to be able to decide if the slave device is operational or
>>> not.
>>>
>>> Following Stephen's advice here:
>>> http://kerneltrap.org/mailarchive/linux-netdev/2008/9/24/3398834 I checked the macb.c code
>>> and noticed they do not call netif_carrier_off() neither before register_netdev() nor in
>>> dev_open().
>
>> It should be called after register_netdev() and before the driver's
>> ndo_open implementation returns.

After having read several drivers, it seems that some are calling
netif_carrier_off() *before* register_netdev() and some *after*... What
is the proper way?


> I'm guessing this allows linkwatch to do netif_carrier_on() some time after the dev_open()?
> 
> Besides not calling netif_carrier_off() in dev_open(), the Cadence/MACB driver calls
> netif_carrier_off() in dev_close(). Is this correct?
> 
> 
> How should I handle carrier state for a virtual device? The device should have "carrier"
> as long as at least one of the underlying physical interfaces is operational (which I
> guess means operational state UP). Would it be correct to watch NETDEV_CHANGE and DOWN/UP
> events of the slaves and call netif_carrier_on()/off() on the virtual device depending on
> the slaves' states? 
>>
>>> I added the call before register_netdev(), which fixed the problem. However, if I then
>>> enable IPv6:
>>>
>>> # ip link set eth0 up
>>> ADDRCONF(NETDEV_UP): eth0: link is not ready
>>> eth0: link up (100/Full)
>>> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>>
>> This looks normal.
> 
> Good, that narrows it down a bit.
> 
>>
>>> Any idea what is happening / what I'm doing wrong? (This is not just cosmetic; is some
>>> situations this seems to kill the interface - e.g. ping does not work, down/up does not
>>> help...) Things work fine without IPv6 configured.
>>
>> Perhaps some packets sent automatically by IPv6 are triggering a driver
>> bug?  Or there is a bug in multicast support, which IPv6 always uses.

Sorry, I have no clue on this topic. But I am eager to know if you find
something. I can queue your patch for netif_carrier_off() at least...

Best regards,
-- 
Nicolas Ferre
