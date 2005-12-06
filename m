From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 12/14] spidernet: check if firmware was loaded correctly
Date: Mon, 05 Dec 2005 22:52:32 -0500
Message-ID: <20051206040645.193163000@localhost>
References: <20051206035220.097737000@localhost>
Cc: linuxppc64-dev@ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arndb@de.ibm.com>, Jens.Osterkamp@de.ibm.com
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: paulus@samba.org
Content-Disposition: inline; filename=spidernet-programcheck.diff
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

Uploading the device firmware may fail if wrong input data
was provided by the user. This checks for the condition.

From: Jens.Osterkamp@de.ibm.com
Cc: netdev@vger.kernel.org
Signed-off-by: Arnd Bergmann <arndb@de.ibm.com>

Index: linux-2.6.15-rc/drivers/net/spider_net.c
===================================================================
--- linux-2.6.15-rc.orig/drivers/net/spider_net.c
+++ linux-2.6.15-rc/drivers/net/spider_net.c
@@ -1836,7 +1836,7 @@ spider_net_setup_phy(struct spider_net_c
  * spider_net_download_firmware loads the firmware opened by
  * spider_net_init_firmware into the adapter.
  */
-static void
+static int 
 spider_net_download_firmware(struct spider_net_card *card,
 			     const struct firmware *firmware)
 {
@@ -1857,8 +1857,13 @@ spider_net_download_firmware(struct spid
 		}
 	}
 
+	if (spider_net_read_reg(card, SPIDER_NET_GSINIT))
+		return -EIO;
+	
 	spider_net_write_reg(card, SPIDER_NET_GSINIT,
 			     SPIDER_NET_RUN_SEQ_VALUE);
+
+	return 0;
 }
 
 /**
@@ -1909,9 +1914,8 @@ spider_net_init_firmware(struct spider_n
 		goto out;
 	}
 
-	spider_net_download_firmware(card, firmware);
-
-	err = 0;
+	if (!spider_net_download_firmware(card, firmware))
+		err = 0;
 out:
 	release_firmware(firmware);
 
Index: linux-2.6.15-rc/drivers/net/spider_net.h
===================================================================
--- linux-2.6.15-rc.orig/drivers/net/spider_net.h
+++ linux-2.6.15-rc/drivers/net/spider_net.h
@@ -155,7 +155,7 @@ extern char spider_net_driver_name[];
 /* set this first, then the FRAMENUM_VALUE */
 #define SPIDER_NET_GFXFRAMES_VALUE	0x00000000
 
-#define SPIDER_NET_STOP_SEQ_VALUE	0x00000000
+#define SPIDER_NET_STOP_SEQ_VALUE	0x007e0000
 #define SPIDER_NET_RUN_SEQ_VALUE	0x0000007e
 
 #define SPIDER_NET_PHY_CTRL_VALUE	0x00040040

--
