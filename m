From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] netdev: DM9000: Added typecasting to supress some
 warnings on Blackfin
Date: Mon, 13 Oct 2008 05:41:19 -0700
Message-ID: <20081013054119.7f360ee1@extreme>
References: <1223889009-31336-1-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ben@simtec.co.uk, s.hauer@pengutronix.de, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Javier Herrero <jherrero@hvsistemas.es>,
	Bryan Wu <cooloney@kernel.org>
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33530 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754771AbYJMMlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 08:41:22 -0400
In-Reply-To: <1223889009-31336-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Oct 2008 17:10:09 +0800
Bryan Wu <cooloney@kernel.org> wrote:

> From: Javier Herrero <jherrero@hvsistemas.es>
> 
> Signed-off-by: Javier Herrero <jherrero@hvsistemas.es>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
> ---
>  drivers/net/dm9000.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index f42c23f..c4737ca 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -188,35 +188,35 @@ iow(board_info_t * db, int reg, int value)
>  
>  static void dm9000_outblk_8bit(void __iomem *reg, void *data, int count)
>  {
> -	writesb(reg, data, count);
> +	writesb((int)reg, data, count);
>  }

You lose the sparse checking for misuse by doing this.

Why not this instead?


--- a/drivers/net/dm9000.c	2008-10-13 05:29:15.000000000 -0700
+++ b/drivers/net/dm9000.c	2008-10-13 05:40:13.000000000 -0700
@@ -47,14 +47,6 @@
 #define CARDNAME	"dm9000"
 #define DRV_VERSION	"1.31"
 
-#ifdef CONFIG_BLACKFIN
-#define readsb	insb
-#define readsw	insw
-#define readsl	insl
-#define writesb	outsb
-#define writesw	outsw
-#define writesl	outsl
-#endif
 
 /*
  * Transmit timeout, default 5 seconds.
@@ -185,7 +177,40 @@ iow(board_info_t * db, int reg, int valu
 }
 
 /* routines for sending block to chip */
+#ifdef CONFIG_BLACKFIN
+static void dm9000_outblk_8bit(void __iomem *reg, void *data, int count)
+{
+	outsb((unsigned long)reg, data, count);
+}
 
+static void dm9000_outblk_16bit(void __iomem *reg, void *data, int count)
+{
+	outsw((unsigned long)reg, data, (count+1) >> 1);
+}
+
+static void dm9000_outblk_32bit(void __iomem *reg, void *data, int count)
+{
+	outsl((unsigned long)reg, data, (count+3) >> 2);
+}
+
+/* input block from chip to memory */
+
+static void dm9000_inblk_8bit(void __iomem *reg, void *data, int count)
+{
+	insb((unsigned long)reg, data, count);
+}
+
+
+static void dm9000_inblk_16bit(void __iomem *reg, void *data, int count)
+{
+	insw((unsigned long)reg, data, (count+1) >> 1);
+}
+
+static void dm9000_inblk_32bit(void __iomem *reg, void *data, int count)
+{
+	insl((unsigned long)reg, data, (count+3) >> 2);
+}
+#else
 static void dm9000_outblk_8bit(void __iomem *reg, void *data, int count)
 {
 	writesb(reg, data, count);
@@ -218,6 +243,7 @@ static void dm9000_inblk_32bit(void __io
 {
 	readsl(reg, data, (count+3) >> 2);
 }
+#endif
 
 /* dump block from chip to null */
 
