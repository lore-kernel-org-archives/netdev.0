From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Mon, 16 Jan 2012 09:57:39 +0100
Message-ID: <1326704259.3510.3.camel@jlt3.sipsolutions.net>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
	 <1326621743.3448.1.camel@jlt3.sipsolutions.net>
	 <CAPXgP13b0uu3DgOGRL-_WKx-aSQN-f0xL6OmjNPBGf9fg0satA@mail.gmail.com>
	 (sfid-20120115_163411_716244_29DE7A13)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>, Andy Whitcroft <apw@canonical.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:49780 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675Ab2API5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 03:57:47 -0500
In-Reply-To: <CAPXgP13b0uu3DgOGRL-_WKx-aSQN-f0xL6OmjNPBGf9fg0satA@mail.gmail.com> (sfid-20120115_163411_716244_29DE7A13)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-01-15 at 16:33 +0100, Kay Sievers wrote:

> > Will udev now also return the async load only after root is booted if it
> > can't be satisfied earlier?
> 
> Not sure, let me explain what happens here, maybe it contains the answer:
> 
> Udev gets an event for a pci device:
>   /devices/pci0000:00/0000:00:1c.1/0000:03:00.0
> 
> This device has a modalias, which let's udev load the matching module
> into the kernel. The module_init() syscall triggers the firmware
> loading request, which causes another event:
>   /devices/pci0000:00/0000:00:1c.1/0000:03:00.0/firmware/0000:03:00.0
> 
> This event is a direct child of the pci device and udev delays the
> execution of child devices until the parent devices return from
> handling. This dependency logic is needed for many things to ensure a
> proper operation, like partitions which need to make sure the events
> for the disk devices are handled before the partition events are
> started.
> 
> Now the problem, the pcidev event is blocking in modprobe and waits
> for the child event it has generated to finish, but udev does not
> start the event because the parent still blocks in modprobe ->
> deadlock until default firmware timeout of 60 sec. What we want here,
> for several reasons not only udev's dependency logic, is that modprobe
> never waits for userspace transactions to finish.

Ok, thanks for the description. I guess to me that means nothing really
changes much in the situation I'm thinking of.

> If userspace is not responding, the firmware request times out after
> 60 seconds and the driver is not associated with any hardware. To
> retry the firmware loading, the module needs to be unloaded and
> reloaded, or the driver needs to be asked to bind to a device again by
> writing to the 'bind' in file in the sysfs driver directory.

Right.

> Firmware requests stay around in the system for by default 60 seconds.
> If the driver would be built-in the request would be issued long
> before userspace is ready, but udev's coldplug step during bootup will
> cause all events to be replayed, so it would catch also the
> outstanding firmware requests, and would be able to handle them.

Hmm, right, but I don't think that matters for the issue I'm asking
about. Let's say you have iwlwifi, built into the kernel, and an
initramfs that doesn't contain the iwlwifi firmware.
What will happen (last I checked anyway) is this: iwlwifi will do an
async firmware request, and the udev in initramfs will say "don't have
it", thus unbinding and you have to sysfs bind or module reload.

What I'm was asking then is this: Can udev know that it is running from
initramfs (presumably that can't be too hard) and simply not reply to
async requests it doesn't have firmware for? Then once the real root is
mounted it could satisfy (or not) firmware requests from the real root.

johannes
