From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 1/2] r8152: add RTL8152_EARLY_AGG_TIMEOUT_SUPER
Date: Thu, 13 Mar 2014 11:34:07 +0800
Message-ID: <1394681648-7321-2-git-send-email-albertk@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394681648-7321-1-git-send-email-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394681648-7321-1-git-send-email-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For slow CPU, the frequent bulk transfer would cause poor throughput.
One solution is to increase the timeout of the aggregation. It let
the hw could complete the bulk transfer later and fill more packets
into the buffer. Besides, it could reduce the frequency of the bulk
transfer efficiently and improve the performance.

However, the optimization value of the timeout depends on the
capability of the hardware, especially the CPU. For example, according
to the experiment, the timeout 164 us is better than the default
value for the chromebook with the ARM CPU.

Now add RTL8152_EARLY_AGG_TIMEOUT_SUPER to let someone could choose
desired timeout value if he wants to get the best performance.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/Kconfig | 12 ++++++++++++
 drivers/net/usb/r8152.c |  7 +++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 7e7269f..a8639b8 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -102,6 +102,18 @@ config USB_RTL8152
 	  To compile this driver as a module, choose M here: the
 	  module will be called r8152.
 
+	menu "Aggregation Settings"
+		depends on USB_RTL8152
+
+	config RTL8152_EARLY_AGG_TIMEOUT_SUPER
+		int "rx early agg timeout for super speed (unit: us)"
+		default 85
+		help
+		  This is the rx early agg timeout for USB super speed.
+		  The vaild value is 1 ~ 525 us.
+
+	endmenu
+
 config USB_USBNET
 	tristate "Multi-purpose USB Networking Framework"
 	select MII
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index aa1d5b2..293b4d8 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -316,7 +316,10 @@
 #define PCUT_STATUS		0x0001
 
 /* USB_RX_EARLY_AGG */
-#define EARLY_AGG_SUPPER	0x0e832981
+#define EARLY_AGG_SUPER	((((rx_buf_sz - 1522) / 4) << 16) | \
+	(u32)(CONFIG_RTL8152_EARLY_AGG_TIMEOUT_SUPER <= 0 ? 0x2981 : \
+	((CONFIG_RTL8152_EARLY_AGG_TIMEOUT_SUPER * 125) < 0xffff ? \
+	CONFIG_RTL8152_EARLY_AGG_TIMEOUT_SUPER * 125 : 0xffff)))
 #define EARLY_AGG_HIGH		0x0e837a12
 #define EARLY_AGG_SLOW		0x0e83ffff
 
@@ -1978,7 +1981,7 @@ static void r8153_set_rx_agg(struct r8152 *tp)
 			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_BUF_TH,
 					RX_THR_SUPPER);
 			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_EARLY_AGG,
-					EARLY_AGG_SUPPER);
+					EARLY_AGG_SUPER);
 		} else {
 			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_BUF_TH,
 					RX_THR_HIGH);
-- 
1.8.4.2
