From: Ondrej Zary <linux@rainbow-software.org>
Subject: e100: Laptop battery drain and WoL settings from EEPROM
Date: Sun, 9 Nov 2014 00:15:41 +0100
Message-ID: <201411090015.41446.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: e1000-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
there is long-standing problem with battery drain after turning off at least
some Toshiba laptops, see
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/110784

I have the same problem with Toshiba Portege R100. When I shut it down in
Linux, the battery is drained to zero in a couple of days. I noticed that the
LAN port is still active, even when AC disconnected.

The WoL is enabled by default by e100 driver:

# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised pause frame use: Symmetric
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Half
        Link partner advertised pause frame use: No
        Link partner advertised auto-negotiation: No
        Speed: 10Mb/s
        Duplex: Half
        Port: MII
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: g
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: yes

By this code:
        /* Wol magic packet can be enabled from eeprom */
        if ((nic->mac >= mac_82558_D101_A4) &&
           (nic->eeprom[eeprom_id] & eeprom_id_wol)) {
                nic->flags |= wol_magic;
                device_set_wakeup_enable(&pdev->dev, true);
        }

because the WoL bit is set in EEPROM ID word:

# ethtool -e eth0
Offset          Values
------          ------
0x0000:         xx xx xx xx xx xx 03 1b 00 00 01 02 01 47 00 00
0x0010:         00 00 00 00 a2 49 01 00 79 11 7f 00 00 00 00 00
                            ^^ bit 5 here
0x0020:         00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0030:         00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0040:         00 00 00 00 00 00 3d 10 00 00 00 00 00 00 00 00
0x0050:         00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0060:         e4 00 3f 40 09 41 00 00 00 00 00 00 00 00 00 00
0x0070:         00 00 00 00 00 00 00 00 00 00 00 00 00 00 f7 fe

Looks like this laptop is probably WoL-capable even on battery.

Measured the current from AC adapter:
around 20mA with WoL inactive (shut down from Windows or by power button in GRUB)
around 40mA with WoL active (shut down from Linux)

So to work-around this problem, users must disable WoL manually on each boot.

Maybe the driver should ignore the EEPROM WoL bit on Toshiba susbsystem IDs?
Or completely, like Windows driver does?

Ethernet controller details:
02:08.0 Ethernet controller [0200]: Intel Corporation 82801DB PRO/100 VE (MOB) Ethernet Controller [8086:103d] (rev 83)
        Subsystem: Toshiba America Info Systems Device [1179:0001]
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (2000ns min, 14000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at dfdff000 (32-bit, non-prefetchable) [size=4K]
        Region 1: I/O ports at cf40 [size=64]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME-
        Kernel driver in use: e100

-- 
Ondrej Zary
