From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: softing: Fix potential memory leak in softing_load_fw()
Date: Fri, 24 Aug 2012 11:30:42 +0200
Message-ID: <1345800643-29456-2-git-send-email-mkl@pengutronix.de>
References: <1345800643-29456-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1345800643-29456-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>

Do not leak memory by updating pointer with potentially NULL realloc return value.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/softing/softing_fw.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/softing/softing_fw.c b/drivers/net/can/softing/softing_fw.c
index 3105961..b595d34 100644
--- a/drivers/net/can/softing/softing_fw.c
+++ b/drivers/net/can/softing/softing_fw.c
@@ -150,7 +150,7 @@ int softing_load_fw(const char *file, struct softing *card,
 	const uint8_t *mem, *end, *dat;
 	uint16_t type, len;
 	uint32_t addr;
-	uint8_t *buf = NULL;
+	uint8_t *buf = NULL, *new_buf;
 	int buflen = 0;
 	int8_t type_end = 0;
 
@@ -199,11 +199,12 @@ int softing_load_fw(const char *file, struct softing *card,
 		if (len > buflen) {
 			/* align buflen */
 			buflen = (len + (1024-1)) & ~(1024-1);
-			buf = krealloc(buf, buflen, GFP_KERNEL);
-			if (!buf) {
+			new_buf = krealloc(buf, buflen, GFP_KERNEL);
+			if (!new_buf) {
 				ret = -ENOMEM;
 				goto failed;
 			}
+			buf = new_buf;
 		}
 		/* verify record data */
 		memcpy_fromio(buf, &dpram[addr + offset], len);
-- 
1.7.10

