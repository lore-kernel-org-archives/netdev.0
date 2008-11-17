From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6
Date: Mon, 17 Nov 2008 15:45:23 -0800
Message-ID: <17663.1226965523@death.nxdomain.ibm.com>
References: <491FEAD5.4090205@krogh.cc>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:37089 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751938AbYKQXpi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 18:45:38 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAHNjKZG011834
	for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 18:45:20 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAHNjSLd144058
	for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 18:45:28 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAHNjRia008824
	for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 18:45:27 -0500
In-reply-to: <491FEAD5.4090205@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh <jesper@krogh.cc> wrote:

>I have something that looks like a regression in bonding between 2.6.26.8
>and 2.6.27.6 (I'll try the mid-steps later).
>
>Setup: LACP bond(mode=4,mmimon=100) with 3 NIC's and dhcp on top (static
>ip didn't work either).
>
>Problem: The bond doesn't get up after bootup. Subsequence ifdown/ifup
>brings it up.

	What exactly does "doesn't get up" mean?  If you configure with
a static IP, and it doesn't come up, what's in /proc/net/bonding/bond0?
When it's broken, does it stay broken if you wait a minute or two?

>I suspect it it timing related. The interface being configured before it's
>ready:
>root@quad01:~# dmesg | egrep '(dhc|bond)'
>[   12.421963] bonding: MII link monitoring set to 100 ms
>[   12.483370] bonding: bond0: enslaving eth0 as a backup interface with
>an up link.
>[   12.523372] bonding: bond0: enslaving eth1 as a backup interface with
>an up link.
>[   12.611731] bonding: bond0: enslaving eth2 as a backup interface with a
>down link.
>[   12.780816] warning: `dhclient3' uses 32-bit capabilities (legacy
>support in use)
>[   15.720491] bonding: bond0: link status definitely up for interface eth2.
>[   87.800324] bond0: no IPv6 routers present

	This looks like one of the slaves (eth2) took longer to assert
carrier up (slower autoneg, perhaps) than the other two (eth0 and eth1).
That wouldn't necessarily cause DHCP to fail; 802.3ad is allowed to
aggregate eth0 and eth1 and use them independently of eth2.

	However, if eth0 and eth1 are incorrectly asserting carrier up
(before autoneg is complete), then that could cause problems.  If that's
the case, then checking /proc/net/bonding/bond0 should show the actual
aggregation status.  If lacp is set to slow (the default), then it
should try to reaggregate 30 seconds later, and that would clear up the
aggregation.  DHCP would still need to restart, though.

	What distro are you using?  I just tried the bonding driver from
the current net-next-2.6 mainline on recent SuSE and 802.3ad + DHCP
works fine for me.  I'm using BCM 5704s (tg3).

>The setup is a 3 NIC bond on a Sun X2200 dual-cpu Quad-core server.
>I have similar bond on a X4600 where they works with 2.6.27.6 so I suspect
>that the difference is that the X4600 has all NIC's from the
>same vendor where as the X2200 has 2 Broadcom NIC's and 2 NVidia nics.

	Which flavor (Broadcom or Nvidia) are the 3 devices that are the
same?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
