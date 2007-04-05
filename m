From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: pci-e e1000 not responding to ARPs sometimes?
Date: Thu, 5 Apr 2007 14:49:39 -0700
Message-ID: <08FE5CC30C9A3F41BF819A502CF7BF6E010A654D@fmsmsx411.amr.corp.intel.com>
References: <46155967.1040904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Ben Greear" <greearb@candelatech.com>,
	"NetDev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30502 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767350AbXDEVuA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 17:50:00 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46155967.1040904@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the top post.

I believe this is a known issue and it was fixed in the kernel driver as
well (maybe it didn't make it into FC5 kernel?). 

See the following:
http://article.gmane.org/gmane.linux.network/52168/match=e1000+factps+mn
gcg

If I'm not mistaken, the part relevant to your problem is this:

--- linux-2.6.orig/drivers/net/e1000/e1000_hw.c
+++ linux-2.6/drivers/net/e1000/e1000_hw.c
 @@ -7817,9 +7817,8 @@  e1000_enable_mng_pass_thru(struct e1000_
             fwsm = E1000_READ_REG(hw, FWSM);
             factps = E1000_READ_REG(hw, FACTPS);

-            if (((fwsm & E1000_FWSM_MODE_MASK) ==
-                (e1000_mng_mode_pt << E1000_FWSM_MODE_SHIFT)) &&
-                (factps & E1000_FACTPS_MNGCG))
+            if ((((fwsm & E1000_FWSM_MODE_MASK) >>
E1000_FWSM_MODE_SHIFT) ==
+                   e1000_mng_mode_pt) && !(factps &
E1000_FACTPS_MNGCG))
                 return TRUE;
         } else
             if ((manc & E1000_MANC_SMBUS_EN) && !(manc &
E1000_MANC_ASF_EN))

Emil

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Ben Greear
Sent: Thursday, April 05, 2007 1:18 PM
To: NetDev
Subject: pci-e e1000 not responding to ARPs sometimes?


We're seeing some strange behavior on several systems with onboard
PCI-e pro/1000 NICs.  The behavior is generally that we cannot connect
into a system until we ping from that system out.  It often happens
with our tainted 2.6.18.2 kernel, but we also see similar problems on
the 2.6.20.? FC5 kernel.  It appears to me that the NIC gets into some
funky state where it will not receive traffic until a packet is sent
out of the interface.  After that, it works fine, at least for a while.

At this point, I am just curious if anyone else is seeing anything
similar, or if there are any known problems of this nature
with the 2.6.18 e1000 driver.

Here is lspci for one of the affected systems:


00:00.0 Host bridge: Intel Corporation Server Memory Contoller Hub (rev
b1)
00:02.0 PCI bridge: Intel Corporation Server PCI Express x8 Port 2-3
(rev b1)
00:08.0 System peripheral: Intel Corporation Server DMA Controller (rev
b1)
00:10.0 Host bridge: Intel Corporation Server Error Reporting Registers
(rev b1)
00:10.1 Host bridge: Intel Corporation Server Error Reporting Registers
(rev b1)
00:10.2 Host bridge: Intel Corporation Server Error Reporting Registers
(rev b1)
00:11.0 Host bridge: Intel Corporation Reserved Registers (rev b1)
00:13.0 Host bridge: Intel Corporation Reserved Registers (rev b1)
00:15.0 Host bridge: Intel Corporation Server FBD Registers (rev b1)
00:16.0 Host bridge: Intel Corporation Server FBD Registers (rev b1)
00:1c.0 PCI bridge: Intel Corporation Enterprise Southbridge PCI Express
Root Port 1 (rev 09)
00:1d.0 USB Controller: Intel Corporation Enterprise Southbridge UHCI
USB #1 (rev 09)
00:1d.1 USB Controller: Intel Corporation Enterprise Southbridge UHCI
USB #2 (rev 09)
00:1d.2 USB Controller: Intel Corporation Enterprise Southbridge UHCI
USB #3 (rev 09)
00:1d.3 USB Controller: Intel Corporation Enterprise Southbridge UHCI
USB #4 (rev 09)
00:1d.7 USB Controller: Intel Corporation Enterprise Southbridge EHCI
USB (rev 09)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d9)
00:1f.0 ISA bridge: Intel Corporation Enterprise Southbridge LPC (rev
09)
00:1f.2 IDE interface: Intel Corporation Enterprise Southbridge SATA
cc=IDE (rev 09)
00:1f.3 SMBus: Intel Corporation Enterprise Southbridge SMBus (rev 09)
01:00.0 PCI bridge: Intel Corporation Enterprise Southbridge PCI Express
Upstream Port (rev 01)
01:00.3 PCI bridge: Intel Corporation Enterprise Southbridge PCI Express
to PCI-X Bridge (rev 01)
02:00.0 PCI bridge: Intel Corporation Enterprise Southbridge PCI Express
Downstream Port E1 (rev 01)
02:02.0 PCI bridge: Intel Corporation Enterprise Southbridge PCI Express
Downstream Port E3 (rev 01)
04:00.0 Ethernet controller: Intel Corporation Enterprise Southbridge
DPT LAN Copper (rev 01)
04:00.1 Ethernet controller: Intel Corporation Enterprise Southbridge
DPT LAN Copper (rev 01)
05:01.0 PCI bridge: IBM PCI-X to PCI-X Bridge (rev 03)
06:04.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
Controller (rev 03)
06:04.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
Controller (rev 03)
06:06.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
Controller (rev 03)
06:06.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
Controller (rev 03)
08:01.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
