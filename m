From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: Regression in bonding driver - devices without set_mac
Date: Fri, 06 Nov 2015 14:46:00 -0800
Message-ID: <6968.1446849960@famine>
References: <CABEgq95FYdt86-KEgkarUr-9g_mHoesV6B7OtrFut4pBR0UGcQ@mail.gmail.com>
Cc: netdev@vger.kernel.org, Veaceslav Falico <vfalico@gmail.com>
To: Toby Corkindale <tjc@wintrmute.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:39578 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757697AbbKFWqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 17:46:04 -0500
In-reply-to: <CABEgq95FYdt86-KEgkarUr-9g_mHoesV6B7OtrFut4pBR0UGcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Toby Corkindale <tjc@wintrmute.net> wrote:

>I originally reported this in Dec 2014, as:
>https://bugzilla.kernel.org/show_bug.cgi?id=89161
>
>The bug is still present in the 4.2 Linux kernel.

	I had some time to look into this today, and there is a related
code path that panics the kernel, so I'm working on a patch to resolve
things, and will be posting that shortly.

>If you look at the code, here:
>https://github.com/torvalds/linux/commit/f54424412b6b2f64cae4d7c39d981ca14ce0052c
>
>Then you see that the intention is for devices without set_mac support
>to be supported. Although in older code they DID work, and that
>ability died sometime near this commit. And has never returned since.

	Unfortunately, I believe the referenced commit is in error.  The
change log states:

	[...] It's wrong because we
    only require ndo_set_mac_address in case bonding is in active-backup mode
    and FOM isn't FOM_ACTIVE.

	This assertion is incorrect; ndo_set_mac_address is necessary
for all modes with the only exception being active-backup with
fail_over_mac enabled.

	All of the load balance modes (everything except active-backup)
will change the MAC of the slave devices at some point, and thus require
ndo_set_mac_address support.

	PPP devices should function in active-backup mode, and should
enable fail_over_mac automatically (if the PPP device is the first
slave) if f_o_m is not already enabled.

	The prior discussion on this patch can be found here:

http://www.spinics.net/lists/netdev/msg289311.html

>The code path in current kernels does allow devices through that block
>of code, but it fails somewhere else -- the devices are not
>successfully added as slaves, but the only error printed is the
>warning about not supporting MAC address setting.

	What is happening in the current code is that, for load balance
modes, e.g., balance-rr, the test for ndo_set_mac_address support
passes, but, later, bond_enslave attempts to actually set the MAC of the
new slave, and this fails (because there is no ndo_set_mac).

>Is there anything I can do to try and sort this regression out, with you?

	As I said, I do not believe this is a regression.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
