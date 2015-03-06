From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 2/2] mv88e6131: bonding: implement single device trunking
Date: Fri, 6 Mar 2015 14:43:55 -0800
Message-ID: <CAE4R7bBXbNNJ8VyCJ_01Ht4gWhCaYOGv3f_pUS_2grcU3i3OJw@mail.gmail.com>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
	<1424429473-4601-3-git-send-email-jonasj76@gmail.com>
	<20150220152644.GD13797@lunn.ch>
	<54F9DEAA.50606@gmail.com>
	<20150306192359.GA582@lunn.ch>
	<54FA125E.6050605@gmail.com>
	<20150306214723.GB582@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Jonas Johansson <jonasj76@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Jonas Johansson <jonas.johansson@westermo.se>,
	Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:43402 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbbCFWn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 17:43:56 -0500
Received: by qcxr5 with SMTP id r5so54343402qcx.10
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 14:43:55 -0800 (PST)
In-Reply-To: <20150306214723.GB582@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 6, 2015 at 1:47 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> Hi Florian
>
>> Most Broadcom switches, either SF2 or roboswitch (b53) have a limit of 2
>> trunking groups, without limitations on the number of ports included in
>> any of these two groups.
>
> O.K, so maybe we want the basic resource management in the DSA layer,
> not the switch drivers.
>
>> The larger question is once we start advertising capabilities, where
>> does that stop, right? It would probably be simpler for now to e.g:
>> allow 2 trunking groups to be configured, and when trying to configure a
>> 3rd one, return -ENOSPC and act upon that to either take the software
>> slow path (which is probably not possible) or just return a hard error
>> condition.
>
> This is more than a DSA question. It applies to all the hardware
> acceleration being discussed at the moment. As you hinted to above, i
> suppose we have two different situations:
>
> 1) We can fall back to a software slow path.
>
> 2) There is no software fallback, we have to error out, and it would
>    be nice to have a well defined error code for out of hardware
>    resources.
>
> We also should think about how we tell user space we have fallen back
> to a slow path. I'm sure users want to know why it works, but works
> much slower.

For the general hardware acceleration of bonds, my thoughts for switchdev are:

(Assume 802.3ad LAG setup for discussion sake, other bonding modes are similar).

1. The driver has access to port membership notification via netevent,
so driver knows which ports are in which bonds.  This notification is
passive; there is no way to signal to user that when port was put in a
bond if it was programmed into a device LAG group or not.  It's
totally up to the driver and device resources to make that decision.

2. The driver can know port active status via netevent as well.  If
device has the port in a LAG group, then reflect the active status
down to device port.  Again, a passive notification.

3. CPU-originating egress traffic would be LAGed by bonding (or team)
driver.  (This is true regardless if the device LAG group was setup or
not).

4a. If device LAG group setup, forwarded traffic would be LAG egressed
by device (fast path).

4b. If no device LAG group, ingress traffic is sent to CPU (slow path)
for bonding (or team) to LAG egress.

So software fall-back (4b) is the default case if driver/device can't
setup LAG group for forwarding.

So the question is: how does user know which bonds are accelerated?
So far, we've used the label "external" to mark L2 bridge FDB which
are offloaded to the device and "external" to mark L3 routes offloaded
to the device.  Do we mark bonds as "external" if the LAG path is
offloaded to the device?

-scott
