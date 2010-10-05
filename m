From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 19492] New: sky2 wake on line stopped working
 in 2.6.34/2.6.35
Date: Tue, 5 Oct 2010 09:10:21 +0900
Message-ID: <20101005091021.2da6cd1d@s6510>
References: <bug-19492-10286@https.bugzilla.kernel.org/>
	<20101004151404.df90d70b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: arekm@maven.pl, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42757 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005Ab0JEALH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 20:11:07 -0400
In-Reply-To: <20101004151404.df90d70b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Oct 2010 15:14:04 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Sat, 2 Oct 2010 08:30:14 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=19492
> > 
> >            Summary: sky2 wake on line stopped working in 2.6.34/2.6.35
> >            Product: Drivers
> >            Version: 2.5
> >     Kernel Version: 2.6.34, 2.6.35
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: drivers_network@kernel-bugs.osdl.org
> >         ReportedBy: arekm@maven.pl
> >         Regression: Yes
> > 
> 
> A regression.
> 
> > sky2 WOL feature stopped working in 2.6.34 kernel. It was working fine in
> > 2.6.33. ethtool 2.6.35 (and some earlier version before).
> > 
> > # ethtool -s eth0 wol g
> > # ethtool eth0|grep Wake
> >         Supports Wake-on: pg
> >         Wake-on: g
> > # ethtool -i eth0
> > driver: sky2
> > version: 1.28
> > firmware-version: N/A
> > bus-info: 0000:05:00.0
> > # poweroff
> > 
> > When googling for solution I found /sys/class/net/eth0/device/power/wakeup
> > which contains "disabled" before AND after I run ethtool. So I echoed "enabled"
> > there, too but it didn't help. The machine doesn't wake up on magick packet.
> > 
> > ...
> >
> 
> I can't immediately see any recent changes to the driver in that area
> apart from "ethtool: Change ethtool_op_set_flags to validate flags". 
> Perhaps you could run
> 
> 	strace -f ethtool -s eth0 wol g
> 
> and see if it's getting an error when setting WOL mode.  If so, ethtool
> is broken ;)
> 

There have been changes in the core power management layer, that is
where I would look. Usually the problem is the incorrectly BIOS marks the device
as unable to do PM. Probably the old kernel ignored the BIOS, and newer
kernels look at it more closely?

Last WoL changes were to make driver follow vendor driver which happened
between 2.6.33 and 2.6.34

commit 5f8ae5c537d937bab9cfeb83a30a9b670c3cfb35
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Fri Feb 12 06:57:59 2010 +0000

    sky2: WoL changes
    
    Change Wake On Lan code to be similar to vendor driver. The definition
    of Y2_HW_WOL_ON is confusing; what it means is transition to firmware SPI
    setting when doing power change.
    
    Since same code is done for both shutdown and suspend, use common
    code path.
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 87b09f1f25cd1e01d7c50bf423c7fe33027d7511
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Fri Feb 12 06:58:00 2010 +0000

    sky2: dont enable PME legacy mode
    
    This bit is not changed by vendor driver, and should be left alone.
    The documentation implies this a debug bit.
      0 = WAKE# only asserted when VMAIN not available
      1 = WAKE# is depend on wake events and independent of VMAIN.
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

