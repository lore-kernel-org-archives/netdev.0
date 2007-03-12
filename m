From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: Re: [PATCH] skge: set mac address bonding fix
Date: Mon, 12 Mar 2007 15:39:56 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703121527320.25767@potato.cts.ucla.edu>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
 <20070308113427.6344a7f6@freekitty> <Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu>
 <20070308134811.38a8ec81@freekitty> <Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu>
 <23552.1173395045@death> <Pine.LNX.4.64.0703081509110.28233@potato.cts.ucla.edu>
 <Pine.LNX.4.64.0703121504590.25767@potato.cts.ucla.edu>
 <20070312151626.60d00e30@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-1.smtp.ucla.edu ([169.232.46.136]:40587 "EHLO
	smtp-1.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbXCLWkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 18:40:05 -0400
In-Reply-To: <20070312151626.60d00e30@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Mar 2007, Stephen Hemminger wrote:

> When bonding does fail over it calls set_mac_address.  When this happens 
> as the result of another port going down, the phy_mutex that is common 
> to both ports is held, so it deadlocks. Setting the address doesn't need 
> to do anything that needs the phy_mutex, it already has the RTNL to 
> protect against other admin actions.
>
> This change just disables the receiver to avoid any hardware confusion 
> while address is changing.

Applied, but no change.  For reference, all of the following test cases 
fail with skge:

* modprobe bonding miimon=100 mode=active-backup
   modprobe skge
   ip ad ad 10.0.0.2/24 brd + dev bond0
   ip ro ad 0.0.0.0/0 dev bond0 via 10.0.0.1

The link works fine at this point.

   ip link set bond0 mtu 9000

Causes the link to stop responding completely.  Setting mtu back to 1500 
does not change behavior.

* modprobe bonding miimon=100 mode=active-backup
   modprobe skge
   ifconfig bond0 up
   ifenslave bond0 eth2 eth3
   ifenslave -d bond0 eth2 eth3

That hangs the machine.  No output on serial console.  I have to power 
cycle to restore access.

* modprobe skge
   ifconfig eth2 up
   ifconfig eth3 up
   ifconfig eth3 down
   ifconfig eth2 down

As above, this hangs the machine, and is without the bonding driver 
loaded.



-Chris
