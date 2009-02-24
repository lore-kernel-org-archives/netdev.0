From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 3/8] can: CAN Network device driver and SYSFS interface
Date: Tue, 24 Feb 2009 17:29:59 +0100
Message-ID: <49A42087.8050503@grandegger.com>
References: <1235070082-7069-1-git-send-email-wg@grandegger.com> <1235070082-7069-2-git-send-email-wg@grandegger.com> <1235070082-7069-3-git-send-email-wg@grandegger.com> <1235070082-7069-4-git-send-email-wg@grandegger.com> <499E7B9B.6030603@trash.net> <49A01932.4090004@grandegger.com> <49A272A3.5040405@trash.net> <49A2B949.7060909@grandegger.com> <49A3C023.90001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:37545 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021AbZBXQaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 11:30:04 -0500
In-Reply-To: <49A3C023.90001@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Wolfgang Grandegger wrote:
>>>> 1. Set and get CAN device properties like bit-rate and controller mode.
>>>> 2. Show CAN bus state (active, error-passive or bus-off).
>>>> 3. Get device constants like clock frequency and bit-timing parameters.
>>>> 4. Dump CAN device statistics.
>>>> 5. Trigger device restart if CAN bus-off state has been detected.
>>>>
>>>> Not sure yet, if the interface if good for all purposes. Especially
>>>> point 5. might be better handled by an IOCTL.
>>> The first points sound pretty regular. The last one - just triggering
>>> it is no problem of course, but since I don't know how the detection
>>> works, I can't really tell whether its suitable.
>>
>> CAN errors and state changes might be delivered as CAN error messages to
>> the receiving socket/application, like normal messages. When the
>> application realizes the state change to CAN bus-off, it may want to
>> trigger a bus-off recovery (controller restart). The CAN controller HW
>> enters bus-off, when too much errors occurred on the bus. No more
>> messages can then be sent of received and therefore the driver calls
>> netif_carrier_off(). Is there already an interface for the user to
>> restart? An appropriate IOCTL request would be a simply option, but they
>> are generally deprecated, AFAIK. Using netlink would be more cumbersome,
>> as with SYSFS.
> 
> You could consider triggering the restart automatically, similar
> to the netdev watchdog. In fact, you could simply use that one.

Automatic restart is already support by this patch series but we do not
use the watchdog, because it would trigger on normal transmit timeouts
as well. But maybe we can suppress them by fiddling with the watchdog's
timeout value.

> If you really want to trigger this from userspace, setting the
> device DOWN and UP again seems like the most appropriate way to
> me (even though not very nice to use from an application POV).

That's an option, but it might be a bit heavy, though.

>>>> And we need a user space
>>>> tool, e.g. canconfig, to handle the user requests and communicate with
>>>> the kernel side.
>>> Thats pretty standard :)
>>
>> For the iproute2 utility "ip", mainliy a netlink_can.c would be
>> required. But a dedicated tool for CAN seems more appropriate to me.
> 
> I don't know the CAN specifics. One goal of the rtnl_link API
> was to reduce to amount of userspace tools for link configuration
> though, so please only create a new tool if there's really a good
> reason. From my POV it would be preferrable to have link configuration
> in iproute for direct use by users and possibly also support in
> libnl for use by other applications.

OK, it also depends on what we would like the tool finally to perform,
apart from setting and getting device properties. On idea is to move the
rather heavy calculation of bit-timing parameters out of the kernel to
the user-space configuration tool.

Wolfgang.


