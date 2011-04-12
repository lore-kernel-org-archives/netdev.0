From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding/LACP on RTL8169sc/8110sc (R1869)
Date: Tue, 12 Apr 2011 15:47:45 -0700
Message-ID: <13118.1302648465@death>
References: <4DA45518.60407@navigue.com>
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Jonathan Thibault <jonathan@navigue.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:42968 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754147Ab1DLWrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 18:47:49 -0400
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3CMbHCF016805
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 18:37:17 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 0F6CB6E803C
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 18:47:48 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3CMllO0188920
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 18:47:47 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3CMllEf024696
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 19:47:47 -0300
In-reply-to: <4DA45518.60407@navigue.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Thibault <jonathan@navigue.com> wrote:
>I have a a pair of Jetway motherboards with an add-on 3Gbit LAN modules
>and have been doing some testing for a linux router project.  I found
>that I while I can get LACP working properly using eth0 and eth1, using
>the exact same setup with any of the other three lan fails.  Is this a
>known issue?

	Fails how, exactly?  If eth2/3/4 is part of the bond, then no
aggregation forms at all, or those devices don't join, or what?

>This is on Linux 2.6.32.10.  Here is a blurb of dmesg showing the NICs
>detected.

	That's a fairly old kernel; one relatively recent fix that comes
to mind is:

commit ab12811c89e88f2e66746790b1fe4469ccb7bdd9
Author: Andy Gospodarek <andy@greyhouse.net>
Date:   Fri Sep 10 11:43:20 2010 +0000

    bonding: correctly process non-linear skbs
    
    It was recently brought to my attention that 802.3ad mode bonds would no
    longer form when using some network hardware after a driver update.
    After snooping around I realized that the particular hardware was using
    page-based skbs and found that skb->data did not contain a valid LACPDU
    as it was not stored there.  That explained the inability to form an
    802.3ad-based bond.  For balance-alb mode bonds this was also an issue
    as ARPs would not be properly processed.

>eth0: RTL8168b/8111b at 0xf8adc000, 00:30:18:ac:a6:80, XID 0c200000 IRQ 24
>eth1: RTL8168b/8111b at 0xf8ae0000, 00:30:18:ac:a6:81, XID 0c200000 IRQ 25
>eth2: RTL8169sc/8110sc at 0xf8ae4c00, 00:30:18:ae:34:3a, XID 18000000 IRQ 18
>eth3: RTL8169sc/8110sc at 0xf8ae8800, 00:30:18:ae:34:3b, XID 18000000 IRQ 19
>eth4: RTL8169sc/8110sc at 0xf8aec400, 00:30:18:ae:34:3c, XID 18000000 IRQ 16

	The fix might apply if your eth2/3/4 hardware uses page based
skbs as mentioned in this commit.

	Also, what is your network topology?  Are all the devices
connected to the same switch?

>I can probably manage this project using only eth0 and eth1 in LACP
>configuration but I figured I'd give a heads up.
>
>The interfaces seem able to detect when the link is up or down, bonding
>removes and adds them to the LACP trunk but I can't get traffic through
>them.

	If the above commit doesn't resolve the problem, can you post
some sample output of /proc/net/bonding/bondX (with the appropriate
value for "X") when you've got the "bad" devices in the bond, along with
a description of exactly what doesn't work?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
