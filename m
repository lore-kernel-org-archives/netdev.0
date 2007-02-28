From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] Add support for Seeq 8003 on Challenge S Mezz board.
Date: Wed, 28 Feb 2007 01:18:35 +0000
Message-ID: <20070228011835.GA21643@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:44197 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbXB1BSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 20:18:49 -0500
Received: from localhost.localdomain ([127.0.0.1]:56450 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20039226AbXB1BSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 01:18:47 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ladislav Michl <ladis@linux-mips.org>

Thanks to J=F6 Fahlke for donating hardware.

Signed-off-by: Ladislav Michl <ladis@linux-mips.org>

=46orward porting of Ladis' 2.4 patch.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 52ed522..b881330 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -625,7 +625,7 @@ static inline void setup_rx_ring(struct sgiseeq_rx_=
desc *buf, int nbufs)
=20
 #define ALIGNED(x)  ((((unsigned long)(x)) + 0xf) & ~(0xf))
=20
-static int sgiseeq_init(struct hpc3_regs* hpcregs, int irq)
+static int sgiseeq_init(struct hpc3_regs* hpcregs, int irq, int has_ee=
prom)
 {
 	struct sgiseeq_init_block *sr;
 	struct sgiseeq_private *sp;
@@ -651,7 +651,9 @@ static int sgiseeq_init(struct hpc3_regs* hpcregs, =
int irq)
=20
 #define EADDR_NVOFS     250
 	for (i =3D 0; i < 3; i++) {
-		unsigned short tmp =3D ip22_nvram_read(EADDR_NVOFS / 2 + i);
+		unsigned short tmp =3D has_eeprom ?
+			ip22_eeprom_read(&hpcregs->eeprom, EADDR_NVOFS / 2+i) :
+			ip22_nvram_read(EADDR_NVOFS / 2+i);
=20
 		dev->dev_addr[2 * i]     =3D tmp >> 8;
 		dev->dev_addr[2 * i + 1] =3D tmp & 0xff;
@@ -684,6 +686,11 @@ static int sgiseeq_init(struct hpc3_regs* hpcregs,=
 int irq)
 	sp->hregs->dconfig =3D HPC3_EDCFG_FIRQ | HPC3_EDCFG_FEOP |
 			     HPC3_EDCFG_FRXDC | HPC3_EDCFG_PTO | 0x026;
=20
+	/* Setup PIO and DMA transfer timing */
+	sp->hregs->pconfig =3D 0x161;
+	sp->hregs->dconfig =3D HPC3_EDCFG_FIRQ | HPC3_EDCFG_FEOP |
+			     HPC3_EDCFG_FRXDC | HPC3_EDCFG_PTO | 0x026;
+
 	/* Reset the chip. */
 	hpc3_eth_reset(sp->hregs);
=20
@@ -730,8 +737,23 @@ err_out:
=20
 static int __init sgiseeq_probe(void)
 {
+	unsigned int tmp, ret1, ret2 =3D 0;
+
 	/* On board adapter on 1st HPC is always present */
-	return sgiseeq_init(hpc3c0, SGI_ENET_IRQ);
+	ret1 =3D sgiseeq_init(hpc3c0, SGI_ENET_IRQ, 0);
+	/* Let's see if second HPC is there */
+	if (!(ip22_is_fullhouse()) &&
+	    get_dbe(tmp, (unsigned int *)&hpc3c1->pbdma[1]) =3D=3D 0) {
+		sgimc->giopar |=3D SGIMC_GIOPAR_MASTEREXP1 |
+				 SGIMC_GIOPAR_EXP164 |
+				 SGIMC_GIOPAR_HPC264;
+		hpc3c1->pbus_piocfg[0][0] =3D 0x3ffff;
+		/* interrupt/config register on Challenge S Mezz board */
+		hpc3c1->pbus_extregs[0][0] =3D 0x30;
+		ret2 =3D sgiseeq_init(hpc3c1, SGI_GIO_0_IRQ, 1);
+	}
+
+	return (ret1 & ret2) ? ret1 : 0;
 }
=20
 static void __exit sgiseeq_exit(void)
