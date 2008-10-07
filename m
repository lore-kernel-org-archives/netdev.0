From: Tim Mann <mann@vmware.com>
Subject: bnx2 driver can't enable/disable wake-on-lan on HP DL585 G2 onboard
 NICs
Date: Mon, 6 Oct 2008 19:48:45 -0700
Message-ID: <20081006194845.4e18705f@manzanita>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mann@vmware.com, netdev@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:47852 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753629AbYJGCss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 22:48:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Michael.  The subject line summarizes the problem; more details
below. I'm emailing you to ask (if you know) whether this is something
that should work in the bnx2 driver, or if HP has done something
peculiar in their hardware/firmware that the driver can't be expected
to deal with.

Here's the deal.  The HP DL585 G2 has an onboard dual-port NIC based on
the bcm5706.  Both ports support wake-on-lan, but WOL works if and only
if you enable it using an option in the HP BIOS setup screens.  If you
disable it from there, ethtool still thinks WOL is supported and that
it's enabled by default, but the machine won't wake.  Conversely (and
this part surprises me more), if you enable WOL from the BIOS setup
screen, the machine always wakes on a WOL magic packet *even* if you
try to disable WOL using ethtool.  Again ethtool thinks that WOL is
supported and that it's enabled by default, and it thinks that it can
disable WOL, but disabling it through ethtool has no effect -- the
machine wakes anyway.

I don't have this problem with other NICs that use the bnx2 driver.  In
particular, I just retested one that I have in a box in my office, and
the bnx2 driver can both enable and disable WOL on that NIC fine.

So far I've tried this only with a bnx2 driver that advertises itself
as 1.6.9 with release date December 8, 2007.  I could try with a newer
one, but I looked at the diffs between 1.6.9 and 1.8.0 and I didn't see
anything that looks like it should affect this.  Let me know if I
should try it anyway, though.

In case it helps, here's lspci output from the HP box with the misbehaving NIC:

[root@drm121 ~]# lspci -s 41:01.0 -v 
41:01.0 Ethernet controller: Broadcom Corporation NetXtreme II 5706 Gigabit Ethernet (rev 02)
        Subsystem: Hewlett-Packard Company Unknown device 1709
        Flags: bus master, 66MHz, medium devsel, latency 120, IRQ 23
        Memory at fa000000 (64-bit, non-prefetchable) [size=32M]
        [virtual] Expansion ROM at 88200000 [disabled] [size=2K]
        Capabilities: [40] PCI-X non-bridge device
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
[root@drm121 ~]# lspci -s 41:01.0 -v -n
41:01.0 0200: 14e4:164a (rev 02)
        Subsystem: 103c:1709
        Flags: bus master, 66MHz, medium devsel, latency 120, IRQ 23
        Memory at fa000000 (64-bit, non-prefetchable) [size=32M]
        [virtual] Expansion ROM at 88200000 [disabled] [size=2K]
        Capabilities: [40] PCI-X non-bridge device
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data

Here's output from my test machine:

[root@moppet ~]# lspci -s 41:04.0 -v 
41:04.0 Ethernet controller: Broadcom Corporation NetXtreme II 5706 Gigabit Ethernet (rev 02)
        Subsystem: Hewlett-Packard Company Unknown device 3101
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 16
        Memory at f0000000 (64-bit, non-prefetchable) [size=32M]
        [virtual] Expansion ROM at 88000000 [disabled] [size=64K]
        Capabilities: [40] PCI-X non-bridge device
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-

[root@moppet ~]# lspci -s 41:04.0 -v -n
41:04.0 0200: 14e4:164a (rev 02)
        Subsystem: 103c:3101
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 16
        Memory at f0000000 (64-bit, non-prefetchable) [size=32M]
        [virtual] Expansion ROM at 88000000 [disabled] [size=64K]
        Capabilities: [40] PCI-X non-bridge device
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable


-- 
Tim Mann  work: mann@vmware.com  home: tim@tim-mann.org
          http://www.vmware.com  http://tim-mann.org
