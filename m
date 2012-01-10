From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH 2/2] asix: fix setting custom MAC address on Asix 88178 devices
Date: Tue, 10 Jan 2012 18:40:23 +0200
Message-ID: <20120110164023.24658.76719.stgit@localhost6.localdomain6>
References: <20120110164017.24658.9965.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@chromium.org>,
	Allan Chou <allan@asix.com.tw>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-01.sanoma.fi ([158.127.18.161]:51376 "EHLO
	sd-mail-sa-01.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932114Ab2AJQkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 11:40:25 -0500
In-Reply-To: <20120110164017.24658.9965.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Note: only compile tested, I don't have 88178 device to confirm that this
patch works. Please, test.)

---

In kernel v3.2 initialization sequence for Asix 88178 devices was changed so
that hardware is reseted on every time interface is brought up (ifconfig up),
instead just at USB probe time. This causes problem with setting custom MAC
address to device as ax88178_reset causes reload of MAC address from EEPROM.

This patch fixes the issue by rewriting MAC address at end of ax88178_reset.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Cc: Grant Grundler <grundler@chromium.org>
Cc: Allan Chou <allan@asix.com.tw>
Cc: stable <stable@vger.kernel.org>
---
 drivers/net/usb/asix.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index eb6b4c1..4736425 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1324,6 +1324,13 @@ static int ax88178_reset(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
+	/* Rewrite MAC address */
+	memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
+							data->mac_addr);
+	if (ret < 0)
+		return ret;
+
 	ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL);
 	if (ret < 0)
 		return ret;
