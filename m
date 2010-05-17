From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH net-next-2.6] can: sja1000 platform data fixes
Date: Mon, 17 May 2010 16:25:22 +0200
Message-ID: <4BF151D2.5030906@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The member "clock" of struct "sja1000_platform_data" is documented as
"CAN bus oscillator frequency in Hz" but it's actually used as the CAN
clock frequency, which is half of it. To avoid further confusion, this
patch fixes it by renaming the member to "osc_freq". That way, also
non mainline users will notice the change. The platform code for the
relevant boards is updated accordingly. Furthermore, pre-defined
values are now used for the members "ocr" and "cdr".

Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
CC: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

diff --git a/arch/arm/mach-mx2/pcm970-baseboard.c b/arch/arm/mach-mx2/pcm970-baseboard.c
index 4aafd5b..f490a40 100644
--- a/arch/arm/mach-mx2/pcm970-baseboard.c
+++ b/arch/arm/mach-mx2/pcm970-baseboard.c
@@ -201,9 +201,9 @@ static struct resource pcm970_sja1000_resources[] = {
 };
 
 struct sja1000_platform_data pcm970_sja1000_platform_data = {
-	.clock		= 16000000 / 2,
-	.ocr		= 0x40 | 0x18,
-	.cdr		= 0x40,
+	.osc_freq	= 16000000,
+	.ocr		= OCR_TX1_PULLDOWN | OCR_TX0_PUSHPULL,
+	.cdr		= CDR_CBP,
 };
 
 static struct platform_device pcm970_sja1000 = {
diff --git a/arch/arm/mach-mx3/mach-pcm037.c b/arch/arm/mach-mx3/mach-pcm037.c
index 2df1ec5..78ecd75 100644
--- a/arch/arm/mach-mx3/mach-pcm037.c
+++ b/arch/arm/mach-mx3/mach-pcm037.c
@@ -530,9 +530,9 @@ static struct resource pcm970_sja1000_resources[] = {
 };
 
 struct sja1000_platform_data pcm970_sja1000_platform_data = {
-	.clock		= 16000000 / 2,
-	.ocr		= 0x40 | 0x18,
-	.cdr		= 0x40,
+	.osc_freq	= 16000000,
+	.ocr		= OCR_TX1_PULLDOWN | OCR_TX0_PUSHPULL,
+	.cdr		= CDR_CBP,
 };
 
 static struct platform_device pcm970_sja1000 = {
diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index b65cabb..d9fadc4 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -111,7 +111,8 @@ static int sp_probe(struct platform_device *pdev)
 	dev->irq = res_irq->start;
 	priv->irq_flags = res_irq->flags & (IRQF_TRIGGER_MASK | IRQF_SHARED);
 	priv->reg_base = addr;
-	priv->can.clock.freq = pdata->clock;
+	/* The CAN clock frequency is half the oscillator clock frequency */
+	priv->can.clock.freq = pdata->osc_freq / 2;
 	priv->ocr = pdata->ocr;
 	priv->cdr = pdata->cdr;
 
diff --git a/include/linux/can/platform/sja1000.h b/include/linux/can/platform/sja1000.h
index 01ee2ae..96f8fcc 100644
--- a/include/linux/can/platform/sja1000.h
+++ b/include/linux/can/platform/sja1000.h
@@ -26,7 +26,7 @@
 #define OCR_TX_SHIFT      2
 
 struct sja1000_platform_data {
-	u32 clock;	/* CAN bus oscillator frequency in Hz */
+	u32 osc_freq;	/* CAN bus oscillator frequency in Hz */
 
 	u8 ocr;		/* output control register */
 	u8 cdr;		/* clock divider register */
