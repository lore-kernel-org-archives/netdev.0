From: Mark Lord <kernel@teksavvy.com>
Subject: Re: [PATCH] drivers/net/usb/asix:  resync from vendor's copy
Date: Wed, 09 Nov 2011 11:47:33 -0500
Message-ID: <4EBAAEA5.1060408@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com>   <20111026.194045.2019668159403582571.davem@davemloft.net>   <4EA8B283.3010105@teksavvy.com>   <20111026.221719.2216112919297458522.davem@davemloft.net>   <4EB19BBE.5050602@teksavvy.com> <1320266549.2782.21.camel@bwh-desktop>  <4EBAA967.10403@teksavvy.com> <1320856444.18929.78.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320856444.18929.78.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-11-09 11:34 AM, Ben Hutchings wrote:
> On Wed, 2011-11-09 at 11:25 -0500, Mark Lord wrote:
>> On 11-11-02 04:42 PM, Ben Hutchings wrote:
>>> On Wed, 2011-11-02 at 15:36 -0400, Mark Lord wrote:
>>> [...]
>>>> First cut (for review) at updating the in-kernel asix usb/network driver
>>>> from the latest vendor GPL version of the driver, obtained from here:
>>>>
>>>>   http://www.asix.com.tw/download.php?sub=searchresult&PItemID=84&download=driver
>> ..
>>>> --- linux-3.0/drivers/net/usb/asix.c	2011-10-12 17:59:03.000000000 -0400
>>>> +++ linux/drivers/net/usb/asix.c	2011-11-01 19:00:50.051289683 -0400
>>> [...]
>> ...
>>>> +	.set_tx_csum		= ax88772b_set_tx_csum,
>>>> +	.get_tx_csum		= ax88772b_get_tx_csum,
>>>> +	.get_rx_csum		= ax88772b_get_rx_csum,
>>>> +	.set_rx_csum		= ax88772b_set_rx_csum,
>>>> +};
>>>
>>> The various ethtool operations for offload flags are being (or have
>>> been) removed.  The driver must set net_device::hw_features and
>>> implement net_device_ops::ndo_set_features instead.
>>
>> Okay, I see what to do for the rx_csum stuff, based on other drivers.
>>
>> But is there anything to replace the tx_csum stuff,
>> or should I just remove it entirely without a substitute?
> 
> If TX checksum offload only needs to be requested in TX descriptors and
> not in a configuration register, then you don't need to do anything when
> it's enabled or disabled.

It's in a config register too.  But I've now just noticed "NETIF_F_HW_CSUM",
which seems to be what I was missing earlier.

So I can now treat the tx_csums similarly to the rx_csums again.

Note:  I'm looking at smsc95xx.c and smsc75xx.c for examples,
and they both have the same problem I'll have here:

How to update the csum settings atomically.
A spinlock is no good, because config register access is over USB.

Is it safe to use a mutex in set_features, or can that be invoked
from atomic code?  Or perhaps just not worry about it, since its only
an issue when somebody plays with two instances of ethtool simultaneously
on the same device?

Thanks for your help.
