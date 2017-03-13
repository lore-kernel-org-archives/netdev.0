From: Alban <albeu@free.fr>
Subject: [PATCH 4/7] ath9k: Add support for reading the MAC address with nvmem
Date: Mon, 13 Mar 2017 22:05:12 +0100
Message-ID: <1489439116-4233-4-git-send-email-albeu@free.fr>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
Cc: John Crispin <john@phrozen.org>, Alban <albeu@free.fr>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:3109 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932149AbdCMVGt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 17:06:49 -0400
In-Reply-To: <1489439116-4233-1-git-send-email-albeu@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On embedded platforms the MAC address is often stored in flash,
use nvmem to read it if the platform data or DT didn't specify one.

Signed-off-by: Alban <albeu@free.fr>
---
 drivers/net/wireless/ath/ath9k/init.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 054f254..36b51a5 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -594,6 +594,35 @@ static int ath9k_of_init(struct ath_softc *sc)
 	return 0;
 }
 
+static int ath9k_get_nvmem_address(struct ath_softc *sc)
+{
+	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
+	struct nvmem_cell *cell;
+	size_t cell_size;
+	int err = 0;
+	void *mac;
+
+	cell = nvmem_cell_get(sc->dev, "address");
+	if (IS_ERR(cell))
+		return PTR_ERR(cell);
+
+	mac = nvmem_cell_read(cell, &cell_size);
+	nvmem_cell_put(cell);
+
+	if (IS_ERR(mac))
+		return PTR_ERR(mac);
+
+	if (cell_size == 6) {
+		ether_addr_copy(common->macaddr, mac);
+	} else {
+		dev_err(sc->dev, "nvmem 'address' cell has invalid size\n");
+		err = -EINVAL;
+	}
+
+	kfree(mac);
+	return err;
+}
+
 static int ath9k_init_softc(u16 devid, struct ath_softc *sc,
 			    const struct ath_bus_ops *bus_ops)
 {
@@ -656,6 +685,10 @@ static int ath9k_init_softc(u16 devid, struct ath_softc *sc,
 	if (ret)
 		return ret;
 
+	/* If no MAC address has been set yet try to use nvmem */
+	if (!is_valid_ether_addr(common->macaddr))
+		ath9k_get_nvmem_address(sc);
+
 	/* If the EEPROM hasn't been retrieved via firmware request
 	 * use the nvmem API insted.
 	 */
-- 
2.7.4
