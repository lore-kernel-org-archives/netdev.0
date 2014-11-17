From: "Roland Kletzing" <devzero@web.de>
Subject: [PATCH] fix #51791 - bug? mac 00:00:00:00:00:00 with natsemi
 DP83815 after driver load
Date: Mon, 17 Nov 2014 01:17:47 +0100
Message-ID: <trinity-9c3b63ff-f474-4d99-84d8-29034921bb3c-1416183467662@3capp-webde-bs06>
References: <trinity-1cec0308-6242-413f-a63f-b09cded30a4f-1416096326518@3capp-webde-bs03>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:64290 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800AbaKQARu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 19:17:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one should fix Bugzilla #51791 (details below).=20

Natsemi driver does not read MAC correctly from eeprom, while natsemi-d=
iag from nictools-pci does. Apparently, tt`s a timing issue in the kern=
el driver.

According to ftp://ftp.gwdg.de/pub/linux/misc/donald.becker/diag/natsem=
i-diag.c , eeprom_delay(ee_addr) is defined as follows:

/* Delay between EEPROM clock transitions.
   This flushes the write buffer to prevent quick double-writes.
*/
#define eeprom_delay(ee_addr) 	inl(ee_addr); inl(ee_addr)

while in the natsemi linux kernel driver, the delay is done this way :

#define eeprom_delay(ee_addr)   readl(ee_addr)

, which results in the MAC being all zero`s.

So i simply added a second readl() to increase delay (instead of turnin=
g into inl() as proposed before). This may look a little bit ugly, but =
it`s fixing the problem for me.

I=C2=B4m not sure how many natsemi users being left on this planet (pro=
bably few), but i guess this change does not do any harm on platforms w=
here the driver does not behave buggy, so please consider adding it to =
mainline/stable/longterm.

Signed-off-by: Roland Kletzing <devzero@web.de>

---
 drivers/net/ethernet/natsemi/natsemi.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ether=
net/natsemi/natsemi.c
index b83f7c0..246bb91 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -987,7 +987,7 @@ static int natsemi_probe1(struct pci_dev *pdev, con=
st struct pci_device_id *ent)
    The old method of using an ISA access as a delay, __SLOW_DOWN_IO__,=
 is
    deprecated.
 */
-#define eeprom_delay(ee_addr)  readl(ee_addr)
+#define eeprom_delay(ee_addr)  readl(ee_addr); readl(ee_addr)

 #define EE_Write0 (EE_ChipSelect)
 #define EE_Write1 (EE_ChipSelect | EE_DataIn)
--


regards
Roland


> Gesendet: Sonntag, 16. November 2014 um 01:05 Uhr
> Von: devzero@web.de
> An: linux-kernel@vger.kernel.org
> Betreff: re: bug? mac 00:00:00:00:00:00 with natsemi DP83815 after dr=
iver load
>
> forwarding to lkml, as no response on netdev list so far.
> =20
> maybe someone has a clue how to properly fix this timing issue.  the =
remaining question is about how to correctly replace readl() with inl()=
 to make it compile cleanly or how eeprom_delay() is being done correct=
ly.  inl() seems to be slower to complete which seems to make the drive=
r work, but it seems it needs an I/O port as param but not an memory-ad=
ress.=20
>=20
> sorry, i`m not good at programming, but now as the problem is "basica=
lly" fixed there are just some tiny bits missing for a proper fix. i=C2=
=B4m unsure if typecasting ee_addr is the right thing to do (i think it=
`s not) and if a patch with such typecast would have any chance for bei=
ng accepted.
>=20
> ----------------------------
> hi,
> as i`m doing a little project with this older devices, i have come ac=
ross this issue again and had some fun to dig deeper into it.
>=20
> it`s a little bit academic, as i can do ifconfig eth0 hw ether..... a=
s a workaround, but it sucks to hack that into startup scripts and i al=
so have seen udev not playing nicely with it.
>=20
> apparently the problem is being caused by a timing issue in the natse=
mi driver.
>=20
> i added some debug printk`s in natsemi.c -> eeprom_read() after each =
occurrence of eeprom_delay(ee_addr); , and the problem went away.=20
>=20
> there is a hint about timing sensitivity in the code:
>=20
> /* Delay between EEPROM clock transitions.
>    No extra delay is needed with 33Mhz PCI, but future 66Mhz access m=
ay need
>    a delay.  Note that pre-2.0.34 kernels had a cache-alignment bug t=
hat
>    made udelay() unreliable.
>    The old method of using an ISA access as a delay, __SLOW_DOWN_IO__=
, is
>    deprecated.
> */
>=20
> looking at the source of natsemi-diag.c made me wonder why that utili=
ty is using=20
>=20
> #define eeprom_delay(ee_addr)   inl(ee_addr)
>=20
> instead of=20
>=20
> #define eeprom_delay(ee_addr)   readl(ee_addr)
>=20
> and apparently, that also fixes the problem (but gives a compile warn=
ing):
>=20
> drivers/net/ethernet/natsemi/natsemi.c: In function =C3=A2eeprom_read=
=C3=A2:
> drivers/net/ethernet/natsemi/natsemi.c:1019:3: warning: passing argum=
ent 1 of =C3=A2inl=C3=A2 makes integer from pointer without a cast [ena=
bled by default]
> In file included from include/linux/io.h:22:0,
>                  from include/linux/pci.h:54,
>                  from drivers/net/ethernet/natsemi/natsemi.c:38:
>=20
>=20
> looking at a more recent version of natsemi-diag.c ,  i even found th=
is one:
>=20
> ftp://ftp.gwdg.de/pub/linux/misc/donald.becker/diag/natsemi-diag.c
>=20
> /* Delay between EEPROM clock transitions.
>    This flushes the write buffer to prevent quick double-writes.
> */
> #define eeprom_delay(ee_addr)	inl(ee_addr); inl(ee_addr)
>=20
> The question is how to make a proper fix, as i don`t know what to pas=
s to inl() , as it seems it should not get an mmapped adress but an i/o=
 port instead !?
>=20
> "The  in*() functions return data read from the specified I/O port"
>=20
> "The read*() functions read data from device memory previously mapped=
 by map_memory()"
>=20
> regards
> roland
>=20
> ps: CC driver maintainer from Kernel Maintainers file.
>=20
>=20
>=20
> Roland Kletzing | 17 Dec 13:38 2012
> bug? mac 00:00:00:00:00:00 with natsemi DP83815 after driver load
>=20
> Hello,
> i recently played with my older evo t20/wyse 3235le thin clients and =
flashed
> a linux kernel into those, apparently there seems an issue with the n=
atsemi
> driver.
>=20
> after driver load (natsemi.ko) eth0 has no valid mac adress, dmesg an=
d
> ifconfig shows just zero`s: 00:00:00:00:00:00.
>=20
> despite that , the nic is working fine for me (in this test setup i s=
et the
> mac manually: ifconfig eth0 hw ether de:ad:be:ef:be:ef )
>=20
> apparently, the driver fails to read the proper mac from the eeprom, =
as
> "natsemi-diag -ee" (from nictools-pci in debian squeeze) shows, that =
there
> is a valid "Ethernet MAC Station Address" stored inside the eeprom. (=
see
> below)
>=20
> looks like a driver bug !?
> does anybody have a clue what`s going wrong here?
>=20
> regards
> roland
>=20
> #lspci
>=20
> 00:00.0 Host bridge: Cyrix Corporation PCI Master
> 00:0f.0 Ethernet controller: National Semiconductor Corporation DP838=
15
> (MacPhyter) Ethernet Controller
> 00:12.0 ISA bridge: Cyrix Corporation 5530 Legacy [Kahlua] (rev 30)
> 00:12.1 Bridge: Cyrix Corporation 5530 SMI [Kahlua]
> 00:12.2 IDE interface: Cyrix Corporation 5530 IDE [Kahlua]
> 00:12.3 Multimedia audio controller: Cyrix Corporation 5530 Audio [Ka=
hlua]
> 00:12.4 VGA compatible controller: Cyrix Corporation 5530 Video [Kahl=
ua]
> 00:13.0 USB Controller: Compaq Computer Corporation ZFMicro Chipset U=
SB (rev
> 06)
>=20
> #dmesg |egrep "natsemi|eth"
> natsemi dp8381x driver, version 2.1, Sept 11, 2006
> natsemi 0000:00:0f.0: setting latency timer to 64
> natsemi eth0: NatSemi DP8381[56] at 0x4010000 (0000:00:0f.0),
> 00:00:00:00:00:00, IRQ 10, port TP.
> eth0: DSPCFG accepted after 0 usec.
> eth0: link up.
> eth0: Setting full-duplex based on negotiated link capability.
>=20
> #natsemi-diag -aa
> natsemi-diag.c:v2.08 2/28/2005 Donald Becker (becker <at> scyld.com)
>  http://www.scyld.com/diag/index.html
> Index #1: Found a NatSemi DP83815 adapter at 0xf800.
>  Natsemi 83815 series with station address de:ad:be:ef:be:ef
>  Transceiver setting Autonegotation advertise 10/100 Mbps half and fu=
ll
> duplex.
>  This device appears to be active, so some registers will not be read=
=2E
>  To see all register values use the '-f' flag.
> NatSemi DP83815 chip registers at 0xf800
>  0x000: 00000004 e805e000 00000002 00000000 ******** 00f1cd65 0000000=
1
> 00000000
>  0x020: 03abd200 d0f01002 00000000 00000000 03abd000 18700010 0000000=
0
> 00000000
>  0x040: ******** 00200000 00000004 0000efbe ffff000b 30303030 0000040=
3
> 00000000
>  0x060: ******** ******** ******** ******** ******** ******** *******=
*
> ********
>  0x080: 00003100 0000786d 00002000 00005c21 000005e1 000045e1 0000000=
5
> 00002801
>  0x0A0: ******** ******** ******** ******** ******** ******** *******=
*
> ********
>  0x0C0: 00000615 00000002 00000000 00000000 00000000 00000000 0000010=
0
> 00000030
>  0x0E0: 00000000 000000bf 00000804 00008200 00000000 00000000 0000000=
0
> 00000000
>   Interrupt sources are pending (00000200).
>    Tx queue emptied indication.
>   Receive mode is 0xc8200000: Normal unicast and hashed multicast.
>   Rx filter contents:   adde efbe efbe 0000 0000 0000 0000 0000
>=20
> #natsemi-diag -ee
> natsemi-diag.c:v2.08 2/28/2005 Donald Becker (becker <at> scyld.com)
>  http://www.scyld.com/diag/index.html
> Index #1: Found a NatSemi DP83815 adapter at 0xf800.
>  Natsemi 83815 series with station address de:ad:be:ef:be:ef
>  Transceiver setting Autonegotation advertise 10/100 Mbps half and fu=
ll
> duplex.
>  EEPROM address length 6, 64 words.
> EEPROM contents (64 words):
> 0x00:  100b 0020 0b34 41fb 0000 0000 0000 4000
> 0x08:  0d32 dff4 1905 aa48 0000 0000 129c 4c4c
> 0x10:  ca52 2ccc 0cb2 9c6c 0c6c 8c0c 2020 6080
> 0x18:  0800 0000 0000 0000 0000 0000 0000 0000
> 0x20:  0000 0000 0000 0000 0000 0000 0000 0000
> 0x28:  0000 0000 0000 0000 0000 0000 0000 0000
> 0x30:  0000 0000 0000 0000 0000 0000 0000 0000
> 0x38:  0000 0000 0000 0000 0000 0000 0000 e418
> Decoded EEPROM contents:
>   PCI Subsystem IDs -- Vendor 0x100b, Device 0x0020.
>   PCI timer settings -- minimum grant 11, maximum latency 52.
>   Ethernet MAC Station Address 00:80:64:1a:e8:bf.
>   Wake-On-LAN password 00:00:00:00:00:00.
>   Transceiver setting 0x--f-: advertise 10/100 Mbps half and full dup=
lex.
>    Flow control enabled.
>   EEPROM active region checksum read as aa48, vs aa48 calculated valu=
e.
