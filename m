From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] net: can: Disable flexcan driver build for big endian CPU on ARM
Date: Tue, 14 Jan 2014 11:44:09 +0100
Message-ID: <3157541.PQSkPAVrH7@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On 01/06/2014 02:21 PM, Guenter Roeck wrote:
> > Building arm:allmodconfig fails with
> > 
> > flexcan.c: In function 'flexcan_read':
> > flexcan.c:243:2: error: implicit declaration of function 'in_be32'
> > flexcan.c: In function 'flexcan_write':
> > flexcan.c:248:2: error: implicit declaration of function 'out_be32'
> > 
> > in_be32 and out_be32 do not (or no longer) exist for ARM targets.
> > Disable the build for ARM on big endian CPUs.
> > 
> > Signed-off-by: Guenter Roeck <linux@xxxxxxxxxxxx>
> 
> Applied to can-next.

Sorry, this patch was wrong.

There is no reason to disallow building the driver on big-endian
ARM kernels. Furthermore, the current behavior is actually broken
on little-endian PowerPC as well.
The choice of register accessor functions must purely depend
on the CPU architecture, not which endianess the CPU is running
on. Note that we nowadays allow both big-endian ARM and little-endian
PowerPC kernels.
With this patch applied, we will do the right thing in all four
combinations.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index aaed97b..320bef2 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -235,9 +235,12 @@ static const struct can_bittiming_const flexcan_bittiming_const = {
 };
 
 /*
- * Abstract off the read/write for arm versus ppc.
+ * Abstract off the read/write for arm versus ppc. This
+ * assumes that PPC uses big-endian registers and everything
+ * else uses little-endian registers, independent of CPU
+ * endianess.
  */
-#if defined(__BIG_ENDIAN)
+#if defined(CONFIG_PPC)
 static inline u32 flexcan_read(void __iomem *addr)
 {
 	return in_be32(addr);

