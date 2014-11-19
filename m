From: "Roland Kletzing" <devzero@web.de>
Subject: [PATCH RESEND] natsemi: fix timing issue for reading mac from
 eeprom via dp8381x
Date: Wed, 19 Nov 2014 23:26:11 +0100
Message-ID: <trinity-d8a7b1cb-ed12-4c9d-ab97-aeb44e03addf-1416435970952@3capp-webde-bs23>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:53712 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757269AbaKSW0O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 17:26:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Natsemi driver does not read MAC correctly from eeprom, while natsemi-d=
iag
from nictools-pci does. Apparently, it`s a timing issue in the kernel d=
river.

According to ftp://ftp.gwdg.de/pub/linux/misc/donald.becker/diag/natsem=
i-diag.c
, eeprom_delay(ee_addr) is defined as follows:

/* Delay between EEPROM clock transitions.
This flushes the write buffer to prevent quick double-writes.
*/
#define eeprom_delay(ee_addr) inl(ee_addr); inl(ee_addr)

while in the natsemi linux kernel driver, the delay is done this way :

#define eeprom_delay(ee_addr) readl(ee_addr)

, which results in the MAC being all zero`s on my systems (old Geode GX=
1 board=20
like being used in Compaq Evo T20 or Wyse WT3235LE Thin Clients).

So i simply added a second readl() to increase delay (instead of turnin=
g into=20
inl() as proposed before). This may look a little bit ugly, but it`s fi=
xing the
problem for me.

I=C2=B4m not sure how many natsemi users being left on this planet (pro=
bably few),
but i guess this change does not do any harm on platforms where the dri=
ver does
not behave buggy, so please consider adding it to mainline/stable/longt=
erm.


BugLink: https://bugzilla.kernel.org/show_bug.cgi?id=3D51791
Reported-by: Roland Kletzing <devzero@web.de>
Signed-off-by: Roland Kletzing <devzero@web.de>

---
drivers/net/ethernet/natsemi/natsemi.c | 2 +-
1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ether=
net/natsemi/natsemi.c
index b83f7c0..96f0029 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -987,7 +987,7 @@ static int natsemi_probe1(struct pci_dev *pdev, con=
st struct pci_device_id *ent)
    The old method of using an ISA access as a delay, __SLOW_DOWN_IO__,=
 is
    deprecated.
 */
-#define eeprom_delay(ee_addr)  readl(ee_addr)
+#define eeprom_delay(ee_addr)  readl(ee_addr);  readl(ee_addr)

 #define EE_Write0 (EE_ChipSelect)
 #define EE_Write1 (EE_ChipSelect | EE_DataIn)
--
