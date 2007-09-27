From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 10/11] net: use numa_node in net_device->dev instead of
 parent
Date: Thu, 27 Sep 2007 01:50:31 -0400
Message-ID: <46FB44A7.3020506@garzik.org>
References: <200709270114.l8R1Eg14012964@imap1.linux-foundation.org> <20070926.223831.44964319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, Yinghai.Lu@Sun.COM,
	Andi Kleen <ak@suse.de>, Al Viro <viro@ftp.linux.org.uk>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43217 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752667AbXI0Fuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 01:50:39 -0400
In-Reply-To: <20070926.223831.44964319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(warning, adjusted CC's and added netdev mailing list)


David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Wed, 26 Sep 2007 18:14:42 -0700
> 
>> From: Yinghai Lu <Yinghai.Lu@Sun.COM>
>>
>> Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>
>> Cc: Christoph Lameter <clameter@sgi.com>
>> Cc: Andy Whitcroft <apw@shadowen.org>
>> Cc: Jeff Garzik <jeff@garzik.org>
>> Cc: Andi Kleen <ak@suse.de>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I'm not applying this, I'm still not convinced it is right.
> 
> The device of netdev->dev is a network subsystem pseudo device and
> it's not a real I/O device at all.  It's there for creating the
> class/net/name info under sysfs for the network device.
> 
> So pulling the NUMA node information out of there is completely

Agreed.


> illogical even if you do add some ugly hack to propagate the NUMA
> information from the I/O device parent into the device struct the
> netdev has embedded in it.

I don't think it's an ugly hack at all.  The following is the standard 
way to tell the net device your parent:

#define SET_NETDEV_DEV(net, pdev)       ((net)->dev.parent = (pdev))

so therefore reading the parent is the standard (only?) way to retrieve 
that same information.

Using IETF RFC language:  Every net driver SHOULD have an associated 
struct device via SET_NETDEV_DEV(), even if it's another pseudo-device 
in the case where the net_device is not associated with real hardware.


However, that said, the overall /system/ employed here is a hack, 
because SET_NETDEV_DEV() does not actually adjust any reference counts 
or anything, for the associated net_device or associated struct device.

Al Viro pointed out problems related to this, ISTR, when someone tried 
to convert net drivers over to using the new devres stuff.  That's why I 
haven't been merging the devres net driver conversions -- they 
exacerbate existing object lifetime-related problems.

	Jeff


