From: Grant Grundler <iod00d@hp.com>
Subject: [BUG] tg3 v3.26 patch and "FIBRE" partno(A7109-6)
Date: Wed, 17 Aug 2005 23:35:45 -0700
Message-ID: <20050818063545.GI11107@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Grant Grundler <iod00d@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, mchan@broadcom.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave, Michael,
I was looking at a new problem Matthew Wilcox reported:
	tg3 networking failed on rx8620 IOX Core LAN

He was testing 2.6.13-rc6 on an HP rx8620 (ia64).
The NIC gets no link when "ifconfig up" and ethtool says:
        Supported ports: [ FIBRE ]

when it should say "[ MII ]".

I worked backwards and found v3.25 is the last version that ethtool
reports "MII" and gets a link at 100BT (FDx and HDx).
We can't use 1000BT because of the brain damaged "bootcode"
on the "IOX Core LAN" fix wasn't committed until tg3 v3.30. :^(
Console output from modprobe and b57diag output are appended below.

This looks like further brain damage in the bootcode since both
3.25 and 3.26 read "0x25" (0x20 == FIBRE) from NIC_SRAM_DATA_CFG.
(ie nic_cfg == 0x25). But I don't understand why this commit causes
ethtool to report "FIBRE" when the previous code didn't:
	"[TG3]: Split tg3_phy_probe into 2 functions"

	http://www.kernel.org/git/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=7d0c41ef89dad9008edf1c3c0022721ebad39999

This commit causes tg3 to read NIC_SRAM_DATA_CFG *before* setting
the power state (see tg3_get_invariants()).  And tg3_set_power_state()
wants to know if the phy is SERDES (or not). The above patch sets
TG3_FLG2_PHY_SERDES before calling tg3_set_power_state() since nic_cfg
has 0x20 bit set.

Calling tg3_get_eeprom_hw_cfg() *after* tg3_set_power_state() didn't change
anything visible.  ethtool still reported FIBRE port.
I need to stare at the code some more tomorrow again to understand
why the older code happened to work despite the value of nic_cfg.
Or is it obvious to one of you?

I'm also hoping someone has a better idea how to fix this than to add
a hack based on subsystem id.

I expect HP would be willing to roll the "bootcode" for this NIC
since it's clearly broken.  This would be the easiest solution.
But I've not seen a recipe that will let an HP Integrity customer
update the bcm5701 chip bootcoode.  Broadcom and HP have been looking
at this since at least March, 2005 when I raised the previous bootcode
problem.  I'll poke folks about this again but I'm not optimistic. *sigh*


thanks,
grant


Console output seems the same for both:
temp:/usr/src/linux-2.6.12# modprobe tg3_325-orig
tg3.c:v3.25 (March 24, 2005)
GSI 28 (level, low) -> CPU 2 (0x0800) vector 83
ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 28 (level, low) -> IRQ 83
tg3: nic_cfg 0x25
eth0: Tigon3 [partno(A7109-6) rev 0105 PHY(5701)] (PCI:33MHz:64-bit) 10/100/1000BaseT Ethernet 00:30:6e:49:42:ca
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[0] 
...
temp:/usr/src/linux-2.6.12# modprobe tg3-326
tg3.c:v3.26 (April 24, 2005)
GSI 28 (level, low) -> CPU 0 (0x0000) vector 83
ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 28 (level, low) -> IRQ 83
eth0: Tigon3 [partno(A7109-6) rev 0105 PHY(5701)] (PCI:33MHz:64-bit) 10/100/1000
BaseT Ethernet 00:30:6e:49:42:ca
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[0]
...


b57diag output for the offending card:
C Brd:Rv    Bus   PCI Spd Base Irq EEP     MAC          Fmw     Configuration
- ------- ------- --- --- ---- -- ---- ------------ ----------- --------------
0 5701:A3 00:01:0  64  33 C000 181  64k 00306E4942CA 5701-v2.17  auto
1 5701:A3 00:01:0  64  33 C000 125  64k 00306E49327F 5701-v2.17  auto
0:>secfg
Reading current NVRAM ... OK
Validating content...
** Error: unknow field 00 found
Using Defualt VPD value, press any key to continue... (paused)

 1. MAC Address                                  : 00:30:6e:49:42:ca
 2. Power Dissipated (D3:D2:D1:D0)               : 10:0:0:100
 3. Power Consumed (D3:D2:D1:D0)                 : 10:0:0:100
 4. Vendor ID                                    : 14E4
 5. Vendor Device ID                             : 1645
 6. Subsystem Vendor ID                          : 103C
 7. Subsystem Device ID                          : 1300
...
10. Magic Packet WoL { Enable(1), Disable(2) }   : Disable
11. Product Name : A7109A COREIO10/100/1GBT ethernet controller
12. Part Number                                  : BCM95700A6
13. Engineering Change                           : 106679-15
14. Serial Number                                : 0123456789
15. Manufacturing ID                             : 14e4
16. Asset Tag                                    :
17. Part Revision                                : A3
18. Voltage  { 1.3V(0), 1.8V(1) }                : 1.8V
19. Force PCI Mode { Enable(1),Disable(2) }      : Disable
21. Led Mode { TripleLink(1), Link/Speed(2) }    : Triple Link
...
0:>seread 0x100-0x200
Current Mode: Legacy SEEPROM, Auto
000100: 822f0041 37313039 4120434f 5245494f 31302f31 30302f31 47425420 65746865
000120: 726e6574 20636f6e 74726f6c 6c657220 20209020 00504e07 41373130 392d3630
000140: 30303120 20534e41 35363230 31383734 3139304e 04313465 34525624 4c000000
000160: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
000180: 91990059 410b5859 5a303132 33343536 3752576b 00000000 00000000 00000000
0001a0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0001c0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
0001e0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000078
000200: 0e000003
