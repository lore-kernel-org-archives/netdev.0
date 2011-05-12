From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 1/3] zorro8390: Fix regression caused during
	net_device_ops conversion
Date: Thu, 12 May 2011 19:11:38 +0000
Message-ID: <1305227500-15595-2-git-send-email-geert@linux-m68k.org>
References: <1305227500-15595-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-m68k@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Finn Thain <fthain@telegraphics.com.au>,
        Geert Uytterhoeven <geert@linux-m68k.org>, stable@kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <shemminger@vyatta.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <1305227500-15595-1-git-send-email-geert@linux-m68k.org>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

Changeset b6114794a1c394534659f4a17420e48cf23aa922 ("zorro8390: convert to
net_device_ops") broke zorro8390 by adding 8390.o to the link. That
meant that lib8390.c was included twice, once in zorro8390.c and once in
8390.c, subject to different macros. This patch reverts that by
avoiding the wrappers in 8390.c.

Fix based on commits 217cbfa856dc1cbc2890781626c4032d9e3ec59f ("mac8390:
fix regression caused during net_device_ops conversion") and
4e0168fa4842e27795a75b205a510f25b62181d9 ("mac8390: fix build with
NET_POLL_CONTROLLER").

Reported-by: Christian T. Steigies <cts@debian.org>
Suggested-by: Finn Thain <fthain@telegraphics.com.au>
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Tested-by: Christian T. Steigies <cts@debian.org>
Cc: stable@kernel.org
---
 drivers/net/Makefile    |    2 +-
 drivers/net/zorro8390.c |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 01b604a..c64675f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -219,7 +219,7 @@ obj-$(CONFIG_SC92031) += sc92031.o
 obj-$(CONFIG_LP486E) += lp486e.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
-obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
+obj-$(CONFIG_ZORRO8390) += zorro8390.o
 obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
 obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
 obj-$(CONFIG_EQUALIZER) += eql.o
diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
index b78a38d..8c7c522 100644
--- a/drivers/net/zorro8390.c
+++ b/drivers/net/zorro8390.c
@@ -126,7 +126,7 @@ static int __devinit zorro8390_init_one(struct zorro_dev *z,
 
     board = z->resource.start;
     ioaddr = board+cards[i].offset;
-    dev = alloc_ei_netdev();
+    dev = ____alloc_ei_netdev(0);
     if (!dev)
 	return -ENOMEM;
     if (!request_mem_region(ioaddr, NE_IO_EXTENT*2, DRV_NAME)) {
@@ -146,15 +146,15 @@ static int __devinit zorro8390_init_one(struct zorro_dev *z,
 static const struct net_device_ops zorro8390_netdev_ops = {
 	.ndo_open		= zorro8390_open,
 	.ndo_stop		= zorro8390_close,
-	.ndo_start_xmit		= ei_start_xmit,
-	.ndo_tx_timeout		= ei_tx_timeout,
-	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_start_xmit		= __ei_start_xmit,
+	.ndo_tx_timeout		= __ei_tx_timeout,
+	.ndo_get_stats		= __ei_get_stats,
+	.ndo_set_multicast_list = __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= ei_poll,
+	.ndo_poll_controller	= __ei_poll,
 #endif
 };
 
-- 
1.7.0.4

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
