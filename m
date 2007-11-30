From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 3/11] ibm_newemac: Fix ZMII refcounting bug
Date: Fri, 30 Nov 2007 16:40:25 +1100
Message-ID: <20071130054127.D15F2DDE18@ozlabs.org>
References: <1196401223.5661.297518056501.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48281 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751608AbXK3Fl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 00:41:28 -0500
In-Reply-To: <1196401223.5661.297518056501.qpush@grosgo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using ZMII for MDIO only (such as 440GX with RGMII for data and ZMII for
MDIO), the ZMII code would fail to properly refcount, thus triggering a
BUG_ON().

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Acked-by: Stefan Roese <sr@denx.de>
---

 drivers/net/ibm_newemac/zmii.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux-work/drivers/net/ibm_newemac/zmii.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/zmii.c	2007-11-08 15:45:32.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/zmii.c	2007-11-08 15:46:21.000000000 +1100
@@ -83,12 +83,14 @@ int __devinit zmii_attach(struct of_devi
 
 	ZMII_DBG(dev, "init(%d, %d)" NL, input, *mode);
 
-	if (!zmii_valid_mode(*mode))
+	if (!zmii_valid_mode(*mode)) {
 		/* Probably an EMAC connected to RGMII,
 		 * but it still may need ZMII for MDIO so
 		 * we don't fail here.
 		 */
+		dev->users++;
 		return 0;
+	}
 
 	mutex_lock(&dev->lock);
 
