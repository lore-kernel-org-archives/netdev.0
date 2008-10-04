From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: [PATCH 0/2] r8169: WoL fixes
Date: Sat, 4 Oct 2008 18:05:21 +0200
Message-ID: <20081004180521.7aa7e232@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Len Brown <lenb@kernel.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As reported in bug #9512 [1], on my system, Commell LE-365 with
RTL-8169 NIC (02:08.0 Ethernet controller [0200]: Realtek
Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet [10ec:8169]
(rev 10)) reported as RTL8110s in dmesg, I need to do 3 steps to
get WoL working properly (the third step being new since 2.6.26
or 2.6.27):

  ethtool -s eth0 wol d > /dev/null && \
    ethtool -s eth0 wol g > /dev/null

  acpitool -w | grep 'P2PB.*enabled' > /dev/null || \
    acpitool -W 7 > /dev/null

  echo enabled > "/sys/bus/pci/devices/0000:02:08.0/power/wakeup"

The patches in reply to this message replace steps 1 and 3.

I'm not sure what is still missing as after shutdown (power-off)
WoL is not possible until a power-cycle. It seems like step 3
does slightly more that what the replacing patch does.


In an ideal world it looks like step 2 shall be done automatically
by PCI subsystem while processing call to pci_enable_wake() which
calls platform_pci_sleep_wake().

I have not analysed what platform_pci_sleep_wake() does and the
fact that on my machine there is no ACPI wake-up record for the
NIC itself but just one for the parent PCI brige (that one is
required for any WoL to effectively work) certainly does not help.

Bruno




[1] http://bugzilla.kernel.org/show_bug.cgi?id=9512

Output of `acpitool -w` with the PCI bridge enabled:
   Device       S-state   Status   Sysfs node
  ---------------------------------------
  1. SLPB         S5    *enabled   
  2. PCI0         S5     enabled   no-bus:pci0000:00
  3. USB1         S3     disabled  pci:0000:00:10.0
  4. USB2         S3     disabled  pci:0000:00:10.1
  5. USB3         S3     disabled  pci:0000:00:10.2
  6. EHCI         S3     disabled  pci:0000:00:10.4
  7. P2PB         S5     enabled   pci:0000:00:13.1
  8. UAR1         S5     disabled  pnp:00:07
  9. PS2K         S5     disabled  pnp:00:09
  10. AZAC        S5     disabled  pci:0000:80:01.0
)

Output of lspci -nn:
00:00.0 Host bridge [0600]: VIA Technologies, Inc. CX700 Host Bridge [1106:0324] (rev 03)
00:00.1 Host bridge [0600]: VIA Technologies, Inc. CX700 Host Bridge [1106:1324]
00:00.2 Host bridge [0600]: VIA Technologies, Inc. CX700 Host Bridge [1106:2324]
00:00.3 Host bridge [0600]: VIA Technologies, Inc. CX700 Host Bridge [1106:3324]
00:00.4 Host bridge [0600]: VIA Technologies, Inc. CX700 Host Bridge [1106:4324]
00:00.7 Host bridge [0600]: VIA Technologies, Inc. CX700 Host Bridge [1106:7324]
00:01.0 PCI bridge [0604]: VIA Technologies, Inc. VT8237 PCI Bridge [1106:b198]
00:0f.0 IDE interface [0101]: VIA Technologies, Inc. Device [1106:0581]
00:10.0 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller [1106:3038] (rev 90)
00:10.1 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller [1106:3038] (rev 90)
00:10.2 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller [1106:3038] (rev 90)
00:10.4 USB Controller [0c03]: VIA Technologies, Inc. USB 2.0 [1106:3104] (rev 90)
00:11.0 ISA bridge [0601]: VIA Technologies, Inc. CX700 PCI to ISA Bridge [1106:8324]
00:11.7 Host bridge [0600]: VIA Technologies, Inc. CX700 Internal Module Bus [1106:324e]
00:13.0 Host bridge [0600]: VIA Technologies, Inc. CX700 Host Bridge [1106:324b]
00:13.1 PCI bridge [0604]: VIA Technologies, Inc. CX700 PCI to PCI Bridge [1106:324a]
01:00.0 VGA compatible controller [0300]: VIA Technologies, Inc. CX700M2 UniChrome PRO II Graphics [1106:3157] (rev 03)
02:08.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet [10ec:8169] (rev 10)
80:01.0 Audio device [0403]: VIA Technologies, Inc. VIA High Definition Audio Controller [1106:3288] (rev 10)

Output of lspci -t:
-+-[0000:80]---01.0
 \-[0000:00]-+-00.0
             +-00.1
             +-00.2
             +-00.3
             +-00.4
             +-00.7
             +-01.0-[0000:01]----00.0
             +-0f.0
             +-10.0
             +-10.1
             +-10.2
             +-10.4
             +-11.0
             +-11.7
             +-13.0
             \-13.1-[0000:02]----08.0
