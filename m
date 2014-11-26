From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: dsa: bcm_sf2: fix unmapping registers in case of errors
Date: Tue, 25 Nov 2014 18:08:48 -0800
Message-ID: <1416967729-717-2-git-send-email-f.fainelli@gmail.com>
References: <1416967729-717-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:52190 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaKZCIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 21:08:53 -0500
Received: by mail-pa0-f45.google.com with SMTP id lj1so1806398pab.32
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 18:08:53 -0800 (PST)
In-Reply-To: <1416967729-717-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we fail to ioremap() one of our registers, we would be leaking
existing mappings, unwind those accordingly on errors.

Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index b9625968daac..46632e8b6336 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -404,7 +404,8 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 		*base = of_iomap(dn, i);
 		if (*base == NULL) {
 			pr_err("unable to find register: %s\n", reg_names[i]);
-			return -ENODEV;
+			ret = -ENOMEM;
+			goto out_unmap;
 		}
 		base++;
 	}
@@ -484,7 +485,8 @@ out_free_irq0:
 out_unmap:
 	base = &priv->core;
 	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
-		iounmap(*base);
+		if (*base)
+			iounmap(*base);
 		base++;
 	}
 	return ret;
-- 
2.1.0
