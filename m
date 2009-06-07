From: Anders Eriksson <aeriksson@fastmail.fm>
Subject: WoL and r8169
Date: Sun, 07 Jun 2009 23:42:20 +0200
Message-ID: <20090607214220.5101B33C013@tippex.mynet.homeunix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch-smtp02.sth.basefarm.net ([80.76.149.213]:37408 "EHLO
	ch-smtp02.sth.basefarm.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754105AbZFGVma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 17:42:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

I've got an issue with Wake on Lan on my r8169 equipped ASUS M2A-VM HDMI
motherboard. For all I can tell, I've done what it takes to enable WoL ("Wake
on PCI/PCIe" is enabled in the bios), but it fails to restart.

checking ethtool, wol sohould be enabled:
tv ~ # ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000033 (51)
        Link detected: yes

The little documentation I've found suggests that these are relevant to:
tv ~ # cat /proc/acpi/wakeup 
Device  S-state   Status   Sysfs node
PCI0      S5     disabled  no-bus:pci0000:00
USB0      S5     enabled   pci:0000:00:13.0
USB1      S5     enabled   pci:0000:00:13.1
USB2      S5     enabled   pci:0000:00:13.2
USB3      S5     enabled   pci:0000:00:13.3
USB4      S5     enabled   pci:0000:00:13.4
USB5      S5     enabled   pci:0000:00:13.5
AZAL      S3     disabled  pci:0000:00:14.2
P2P       S5     disabled  pci:0000:00:14.4
PCE2      S4     disabled  
PCE3      S4     disabled  
PCE4      S4     disabled  
PCE5      S4     disabled  
PCE6      S4     disabled  
PCE7      S4     disabled  pci:0000:00:07.0
PCE8      S4     disabled  
UAR1      S5     disabled  pnp:00:08

I've tried setting them all to enabled, to no avail.

Futher investigations suggests that the sysfs interface and the device tree 
need to be told to do the right thing:
Out of the box, I get:
tv ~ # find /sys/ -name wakeup  | xargs grep led          
/sys/devices/pci0000:00/power/wakeup:disabled
/sys/devices/pci0000:00/0000:00:07.0/power/wakeup:disabled
/sys/devices/pci0000:00/0000:00:07.0/0000:02:00.0/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.0/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.0/usb2/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.1/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.1/usb3/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.2/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.2/usb4/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.3/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.3/usb5/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.4/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.4/usb6/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.5/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:13.5/usb1/power/wakeup:enabled
/sys/devices/pci0000:00/0000:00:14.2/power/wakeup:disabled
/sys/devices/pci0000:00/0000:00:14.4/power/wakeup:disabled
/sys/devices/pci0000:00/0000:00:14.4/0000:03:07.0/power/wakeup:disabled
/sys/devices/pnp0/00:03/power/wakeup:enabled
/sys/devices/pnp0/00:08/power/wakeup:disabled
/sys/class/tty/ttyS0/power/wakeup:disabled
/sys/class/tty/ttyS1/power/wakeup:disabled
/sys/class/tty/ttyS2/power/wakeup:disabled
/sys/class/tty/ttyS3/power/wakeup:disabled

comparing this with lspci:
tv ~ # lspci
00:00.0 Host bridge: ATI Technologies Inc RS690 Host Bridge
00:01.0 PCI bridge: ATI Technologies Inc RS690 PCI to PCI Bridge (Internal gfx)
00:07.0 PCI bridge: ATI Technologies Inc RS690 PCI to PCI Bridge (PCI Express Port 3)
00:12.0 SATA controller: ATI Technologies Inc SB600 Non-Raid-5 SATA
00:13.0 USB Controller: ATI Technologies Inc SB600 USB (OHCI0)
00:13.1 USB Controller: ATI Technologies Inc SB600 USB (OHCI1)
00:13.2 USB Controller: ATI Technologies Inc SB600 USB (OHCI2)
00:13.3 USB Controller: ATI Technologies Inc SB600 USB (OHCI3)
00:13.4 USB Controller: ATI Technologies Inc SB600 USB (OHCI4)
00:13.5 USB Controller: ATI Technologies Inc SB600 USB Controller (EHCI)
00:14.0 SMBus: ATI Technologies Inc SBx00 SMBus Controller (rev 14)
00:14.1 IDE interface: ATI Technologies Inc SB600 IDE
00:14.2 Audio device: ATI Technologies Inc SBx00 Azalia (Intel HDA)
00:14.3 ISA bridge: ATI Technologies Inc SB600 PCI to LPC Bridge
00:14.4 PCI bridge: ATI Technologies Inc SBx00 PCI to PCI Bridge
00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
01:05.0 VGA compatible controller: ATI Technologies Inc RS690 [Radeon X1200 Series]
01:05.2 Audio device: ATI Technologies Inc Radeon X1200 Series Audio Controller
02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 01)
03:06.0 Multimedia controller: Philips Semiconductors SAA7131/SAA7133/SAA7135 Video Broadcast Decoder (rev d1)
03:07.0 FireWire (IEEE 1394): VIA Technologies, Inc. VT6306 Fire II IEEE 1394 OHCI Link Layer Controller (rev c0)

I've gotten the impression that my eth controller lives behind a pci bridge and
behaps a pci bus, neither of which are enabled (the controller _does_ appear to
be enabled!). However, enabling the bridge and the bus (and all other devices)
of the above devices in /sys, still leaves me without WoL.

Am I missing something obvious here? Enabling USB stuff in /sys got wake on USB
working ok, so the ethernet stuff should be similar, I'd assume.

The two leds by the wire go black when the machine suspends, should they be 
lit?

I'm pretty certain the WoL packet is coming to the box (tried both network 
broadcast and unicast with a prepared arp cache at the sender).

Any insight in the appreciated.
-Anders

