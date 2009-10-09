From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Ath5k data aborts
Date: Fri, 09 Oct 2009 21:16:49 +0200
Message-ID: <m3tyy8fkda.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59838 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760089AbZJITR2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 15:17:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have done a small investigation. IXP425 (ARM) in big-endian mode,
EABI, mini-PCI atk5k wifi card, hostapd.

Atheros Communications Inc. Atheros AR5001X+ Wireless Network Adapter (=
rev 01)
Subsystem: Wistron NeWeb Corp. CM9 Wireless a/b/g MiniPCI Adapter
168c:0013 subsystem 185f:1012


Results:
Bad mode in data abort handler detected
Internal error: Oops - bad mode: 0 [#1]
LR is at ath5k_beacon_config+0x150/0x1d4 [ath5k]

This means the PCI device didn't respond on the bus or something
like that. Obviously the card is then unusable and the system needs to
be restarted.

Bisecting (I had to modify the procedure a bit since it only started to
show up after other unrelated code was merged) shows the guilty commit:
e8f055f0c3ba226ca599c14c2e5fe829f6f57cbb (ath5k: Update reset code).

The problem exists with 2.6.30, 2.6.31 and current Linus' tree.

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

----------------------------------------------
2.6.30 appears to be fixed by:

--- a/drivers/net/wireless/ath5k/reset.c
+++ b/drivers/net/wireless/ath5k/reset.c
@@ -476,7 +476,7 @@ static void ath5k_hw_set_sleep_clock(struct ath5k_h=
w *ah, bool enable)
 		(ah->ah_mac_version =3D=3D (AR5K_SREV_AR2417 >> 4))) {
 			ath5k_hw_reg_write(ah, 0x26, AR5K_PHY_SLMT);
 			ath5k_hw_reg_write(ah, 0x0d, AR5K_PHY_SCAL);
-			ath5k_hw_reg_write(ah, 0x07, AR5K_PHY_SCLOCK);
+			ath5k_hw_reg_write(ah, 0x0C, AR5K_PHY_SCLOCK);
 			ath5k_hw_reg_write(ah, 0x3f, AR5K_PHY_SDELAY);
 			AR5K_REG_WRITE_BITS(ah, AR5K_PCICFG,
 				AR5K_PCICFG_SLEEP_CLOCK_RATE, 0x02);
@@ -490,8 +490,10 @@ static void ath5k_hw_set_sleep_clock(struct ath5k_=
hw *ah, bool enable)
 		}
=20
 		/* Enable sleep clock operation */
+#if 0
 		AR5K_REG_ENABLE_BITS(ah, AR5K_PCICFG,
 				AR5K_PCICFG_SLEEP_CLOCK_EN);
+#endif
=20
 	} else {
=20


The AR5K_PHY_SCLOCK brings the old value (before the commit in question=
)
back, I have no idea what is it. Leaving the new value causes the secon=
d
run of hostapd to make the driver fail, the chip seems to not respond.
It seems the value itself may be correct (as it works with 2.6.31+) but
there is some additional bug fixed after 2.6.30, gitk show several
candidate patches for this.


Only disabling AR5K_PCICFG write makes the data abort go away.

----------------------------------------------
2.6.31 and Linus-current only need the AR5K_PCICFG change:

--- a/drivers/net/wireless/ath/ath5k/reset.c
+++ b/drivers/net/wireless/ath/ath5k/reset.c
@@ -489,9 +489,10 @@ static void ath5k_hw_set_sleep_clock(struct ath5k_=
hw *ah, bool enable)
 		}
=20
 		/* Enable sleep clock operation */
+#if 0
 		AR5K_REG_ENABLE_BITS(ah, AR5K_PCICFG,
 				AR5K_PCICFG_SLEEP_CLOCK_EN);
-
+#endif
 	} else {
=20
 		/* Disable sleep clock operation and


The question is, obviously, how to fix that for good. I can test the
result.


=46ull error message, not sure why the backtrace isn't printed.

Bad mode in data abort handler detected
Internal error: Oops - bad mode: 0 [#1]
Modules linked in: ohci_hcd ehci_hcd usbcore nls_base ixp4xx_hss ath5k =
ath ixp4x
x_eth
CPU: 0    Not tainted  (2.6.32-rc3 #123)
PC is at 0xffff01fc
LR is at ath5k_beacon_config+0x150/0x1d4 [ath5k]
pc : [<ffff01fc>]    lr : [<bf028db0>]    psr: a0000092
sp : c7dbfb90  ip : 00008050  fp : c78aa000
r10: c7dbfbd8  r9 : c78ac1c0  r8 : 00003304
r7 : c78aa000  r6 : c78aa000  r5 : 00000013  r4 : c78ac900
r3 : c88e0000  r2 : c88d0024  r1 : c88d0048  r0 : 800924b5
=46lags: NzCv  IRQs off  FIQs on  Mode IRQ_32  ISA ARM  Segment user
Control: 000039ff  Table: 067e0000  DAC: 00000015
Process hostapd (pid: 258, stack limit =3D 0xc7dbe278)
Stack: (0xc7dbfb90 to 0xc7dc0000)
fb80:                                     800924b5 c88d0048 c88d0024 c8=
8e0000=20
fba0: c78ac900 00000013 c78aa000 c78aa000 00003304 c78ac1c0 c7dbfbd8 c7=
8aa000=20
fbc0: 00008050 c7dbfb90 bf028db0 ffff01fc a0000092 ffffffff 00000003 00=
000000=20
fbe0: 00080000 00000000 00000000 00000000 00000000 00000000 00000000 00=
000000=20
fc00: c78ac924 c78ac900 c78ac924 c7d34628 00000300 c7d34620 00000013 bf=
028ec8=20
fc20: c78ac1c0 c7d52980 c0487e90 c7d342c0 c78ac1c0 c67e7140 c7caef20 00=
00001a=20
fc40: 00000004 00000000 00000024 c0391694 c67e7140 c7caef20 0000001a c7=
dbfc88=20
fc60: c7d342c0 c039e974 c7d52440 00000033 c7dbfcc0 c039e998 c7dbfc88 c0=
487d30=20
fc80: c7c6e810 c0384640 00000000 00000000 00000000 00000002 00000000 00=
000000=20
fca0: c7d34000 c78ac000 c0487bb0 c7c6e800 c7d52440 c02c5448 c0488184 00=
000102=20
fcc0: 00000080 00000102 c7c6e800 c7c6e810 c7c6e814 c788d000 c7c6e800 c7=
d52440=20
fce0: c02c5258 c7c54600 c04a0710 00000038 c7dbfd1c c02c42dc c047f6ac c7=
d52440=20
fd00: c7d52440 c02c5244 c788d200 00000000 c7d52440 c02c3f14 00000024 7f=
ffffff=20
fd20: 00000000 c7dbff5c c7c54600 c7d52440 c7dbfe18 00000024 00000000 00=
000000=20
fd40: 00000000 c02c47cc c7dbfe38 c7c54600 00000102 00000000 00000000 00=
000000=20
fd60: 00000000 c7dbff5c c7dbfe18 00000000 00000000 00000024 c7dbfefc 00=
000000=20
fd80: 00000008 c0282298 00000000 c7dbff1c 00000000 00000001 ffffffff 00=
000000=20
fda0: 00000000 00000000 00000000 00000000 c7839080 00000001 00000000 00=
000000=20
fdc0: 00000000 c7839080 c0185ccc c7dbfdcc c7dbfdcc 0000092a c7dbfec8 c0=
38eae4=20
fde0: c7dbfe18 00008b24 c7dbfec8 c037ab88 c7dbfdec c7dbfe0c c67d7360 c0=
1aaf9c=20
fe00: c7dbfe38 c0161cfc 00000000 c67da1a4 00000040 00000000 00000000 c7=
4231bc=20
fe20: 00000015 00000024 c7489380 0001d000 c7dbfd50 c7dbff5c c7dbfe7c c7=
dbfefc=20
fe40: c7dbfe7c c7dbfefc c015a048 c7dbfefc 00000008 00000000 c7dbff5c c7=
dbff5c=20
fe60: c7489380 00000000 c7dbfefc c02823ec c7dbff3c c7dbff3c 00000000 00=
100000=20
fe80: 00000000 00000000 00000020 00000000 00008933 c02941a4 c67e4380 c6=
7e4000=20
fea0: 0000000a c67e4380 c7dbe000 c047bc28 c786d940 c024df48 776c616e 30=
000000=20
fec0: 00000000 00000000 00000006 00000000 00000000 0e000000 c67e40e0 c6=
7e4084=20
fee0: 00000000 c028171c c786d340 00008933 00000000 60000013 00000007 00=
05c754=20
ff00: 00000000 00000000 00000000 00000000 c74890e8 c0472750 00200200 00=
100100=20
ff20: c7497338 c7401498 00200200 00100100 ffffffff ffffffff c780d5a0 c0=
1ce3a0=20
ff40: c7497338 c0472750 00200200 c01cea04 c786d340 00000000 c7497338 c7=
dbfe7c=20
ff60: 0000000c c7dbfefc 00000001 00000000 00000000 00000000 00000000 ff=
ffff97=20
ff80: c786d340 000598f8 400722b0 000598a0 00000128 c015a048 c7dbe000 00=
000000=20
ffa0: 00000001 c0159ea0 000598f8 400722b0 00000004 be9dfb24 00000000 00=
000000=20
ffc0: 000598f8 400722b0 000598a0 00000128 00000000 00000000 00000001 00=
000001=20
ffe0: be9dfb24 be9dfaf8 40039c84 402b022c 60000010 00000004 00000000 00=
000000=20
Code: 00000000 00000000 00000000 00000000 (00000000)=20
---[ end trace ff977de942e87c2d ]---

--=20
Krzysztof Halasa
