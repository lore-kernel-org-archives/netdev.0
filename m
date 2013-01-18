From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: Wake on LAN for USB ethernet?
Date: Fri, 18 Jan 2013 10:53:38 +0200 (EET)
Message-ID: <alpine.DEB.2.02.1301181047290.3637@bender.nucleusys.com>
References: <20130118001214.GA21137@xanatos> <CACVXFVOtpzOFAGRJ74XP1NFD1ah_au9e9gqHFiBLuv1jAwZ6cQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Petko Manolov <petkan@users.sourceforge.net>,
	Alan Stern <stern@rowland.harvard.edu>,
	Greg KH <greg@kroah.com>, Oliver Neukum <oliver@neukum.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([78.83.248.164]:55058 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750759Ab3ARJcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 04:32:16 -0500
In-Reply-To: <CACVXFVOtpzOFAGRJ74XP1NFD1ah_au9e9gqHFiBLuv1jAwZ6cQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in the driver is based on the specs from ADMTek (later, 
Infineon).  Since i never suspend my machines this feature has not been 
tested by me.

However, if the proposed patch is the right thing to do i'd be happy to 
see it applied.


cheers,
Petko


On Fri, 18 Jan 2013, Ming Lei wrote:

> On Fri, Jan 18, 2013 at 8:12 AM, Sarah Sharp
> <sarah.a.sharp@linux.intel.com> wrote:
>> Is it reasonable to expect that Wake on LAN works if the target box is
>> connected via a USB-to-ethernet adapter?
>
> It is surely reasonable, and seems SMSC75xx or SMSC95xx can
> bring system out of suspend.
>
>>
>> One of my validation testers has a USB ethernet device that successfully
>> wakes up Windows from hibernate (S4), but it doesn't work under Linux.
>> Wake on LAN works fine with the hardwired ethernet port.  USB remote
>> wakeup from S3/S4 works fine with a USB keyboard.
>>
>> So I need to figure out if it's an issue with the kernel, their test
>> suite, or the USB host controller.
>>
>>
>> I've experimented with USB ethernet devices with the pegasus driver with
>> no success.  Here's what I've tried:
>>
>> 1. Connect the USB to ethernet adapter to the rootport under the xHCI
>> (USB 3.0) host controller. (lsusb for the two devices I've tried is
>> attached)
>>
>> 2. Enable remote wakeup for all devices (including the PCI host) by
>> echoing 'enabled' to power/wakeup. (script for that attached)
>>
>> 3. Use ethtool to turn on WOL:
>>    sudo ethtool -s ethX wol g
>
> Could you check here if the attribute 'power/wakeup' of the USB device
> has been enabled?  If so, and step 6 still can't wakeup system, the
> problem may be in the set_wol stetting on hardware of the driver since
> your USB wakeup works.
>
> Also, the wakeup enabling is missed in the pegasus_set_wol(), and
> the below patch is needed:
>
> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index a0b5807..d5304f1 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -1096,6 +1096,7 @@ pegasus_set_wol(struct net_device *dev, struct
> ethtool_wolinfo *wol)
> {
> 	pegasus_t	*pegasus = netdev_priv(dev);
> 	u8		reg78 = 0x04;
> +	int		ret;
>
> 	if (wol->wolopts & ~WOL_SUPPORTED)
> 		return -EINVAL;
> @@ -1110,7 +1111,11 @@ pegasus_set_wol(struct net_device *dev, struct
> ethtool_wolinfo *wol)
> 	else
> 		pegasus->eth_regs[0] &= ~0x10;
> 	pegasus->wolopts = wol->wolopts;
> -	return set_register(pegasus, WakeupControl, reg78);
> +
> +	ret = set_register(pegasus, WakeupControl, reg78);
> +	if (!ret)
> +		ret = device_set_wakeup_enable(&pegasus->usb->dev, 1);
> +	return ret;
> }
>
> static inline void pegasus_reset_wol(struct net_device *dev)
>
>
>>
>> 4. Find the MAC address by running ifconfig and looking at the HWaddr
>> field.
>>
>> 5. Verify with wireshark that I can see the Magic WOL packet when I run
>> this command on another machine:
>>    sudo etherwake -i ethX macaddr
>>
>> 6. Suspend or hibernate the target machine, and then send the Magic WOL
>> packet from a second machine.
>>
>>
>> Am I missing any steps in testing this?  Does WOL just not work for USB
>> ethernet devices under Linux?  Perhaps just the pegasus driver doesn't
>> support WOL?
>
> Probably the set_wol of pegasus is broken if wakeup has been enabled
> on the USB device.
>
> Thanks,
> --
> Ming Lei
>
