From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH 1/2] asix: fix setting custom MAC address on Asix 88772 devices
Date: Tue, 10 Jan 2012 18:40:17 +0200
Message-ID: <20120110164017.24658.9965.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@chromium.org>,
	Allan Chou <allan@asix.com.tw>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-02.sanoma.fi ([158.127.18.162]:52390 "EHLO
	sd-mail-sa-02.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932114Ab2AJQkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 11:40:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In kernel v3.2 initialization sequence for Asix 88772 devices was changed so
that hardware is reseted on every time interface is brought up (ifconfig up),
instead just at USB probe time. This causes problem with setting custom MAC
address to device as ax88772_reset causes reload of MAC address from EEPROM.

This patch fixes the issue by rewriting MAC address at end of ax88772_reset.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Acked-by: Grant Grundler <grundler@chromium.org>
Cc: Allan Chou <allan@asix.com.tw>
Cc: stable <stable@vger.kernel.org>
---
 drivers/net/usb/asix.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index e95f0e6..eb6b4c1 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -974,6 +974,7 @@ static int ax88772_link_reset(struct usbnet *dev)
 
 static int ax88772_reset(struct usbnet *dev)
 {
+	struct asix_data *data = (struct asix_data *)&dev->data;
 	int ret, embd_phy;
 	u16 rx_ctl;
 
@@ -1051,6 +1052,13 @@ static int ax88772_reset(struct usbnet *dev)
 		goto out;
 	}
 
+	/* Rewrite MAC address */
+	memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
+							data->mac_addr);
+	if (ret < 0)
+		goto out;
+
 	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
 	ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL);
 	if (ret < 0)
