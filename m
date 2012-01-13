From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 1/5][STABLE] bcma: invalidate the mapped core over suspend/resume
Date: Fri, 13 Jan 2012 23:58:38 +0100
Message-ID: <1326495522-6024-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	stable@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37946 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab2AMW6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 17:58:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This clears the currently mapped core when suspending, to force
re-mapping after resume. Without that we were touching default core
registers believing some other core is mapped. Such a behaviour
resulted in lockups on some machines.

Cc: stable@vger.kernel.org
Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
We don't call drivers suspend/resume handlers with this patch but this
at least fixes lockup. Having non-working driver after resume is still
better than having locked up machine.
---
 drivers/bcma/host_pci.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
index 443b83a..c1ca9e3 100644
--- a/drivers/bcma/host_pci.c
+++ b/drivers/bcma/host_pci.c
@@ -237,11 +237,14 @@ static void bcma_host_pci_remove(struct pci_dev *=
dev)
 #ifdef CONFIG_PM
 static int bcma_host_pci_suspend(struct pci_dev *dev, pm_message_t sta=
te)
 {
+	struct bcma_bus *bus =3D pci_get_drvdata(dev);
+
 	/* Host specific */
 	pci_save_state(dev);
 	pci_disable_device(dev);
 	pci_set_power_state(dev, pci_choose_state(dev, state));
=20
+	bus->mapped_core =3D NULL;
 	return 0;
 }
=20
--=20
1.7.7
