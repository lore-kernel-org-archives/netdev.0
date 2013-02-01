From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/2] wanrouter: completely decouple obsolete code from kernel.
Date: Fri,  1 Feb 2013 18:30:21 -0500
Message-ID: <1359761422-27629-2-git-send-email-paul.gortmaker@windriver.com>
References: <1359761422-27629-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40058 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758030Ab3BAXan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 18:30:43 -0500
In-Reply-To: <1359761422-27629-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original suggestion to delete wanrouter started earlier
with the mainline commit f0d1b3c2bcc5de8a17af5f2274f7fcde8292b5fc
("net/wanrouter: Deprecate and schedule for removal") in May 2012.

More importantly, Dan Carpenter found[1] that the driver had a
fundamental breakage introduced back in 2008, with commit
7be6065b39c3 ("netdevice wanrouter: Convert directly reference of
netdev->priv").  So we know with certainty that the code hasn't been
used by anyone willing to at least take the effort to send an e-mail
report of breakage for at least 4 years.

This commit does a decouple of the wanrouter subsystem, by going
after the Makefile/Kconfig and similar files, so that these mainline
files that we are keeping do not have the big wanrouter file/driver
deletion commit tied into their history.

Once this commit is in place, we then can remove the obsolete cyclomx
drivers and similar that have a dependency on CONFIG_WAN_ROUTER_DRIVERS.

[1] http://www.spinics.net/lists/netdev/msg218670.html

Originally-by: Joe Perches <joe@perches.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 Documentation/ioctl/ioctl-number.txt |  2 +-
 Documentation/magic-number.txt       |  2 +-
 Documentation/zh_CN/magic-number.txt |  2 +-
 drivers/isdn/i4l/isdn_x25iface.h     |  1 -
 drivers/net/wan/Kconfig              | 54 ------------------------------------
 drivers/net/wan/Makefile             |  5 ----
 net/Kconfig                          |  1 -
 net/Makefile                         |  1 -
 net/socket.c                         |  1 -
 9 files changed, 3 insertions(+), 66 deletions(-)

diff --git a/Documentation/ioctl/ioctl-number.txt b/Documentation/ioctl/ioctl-number.txt
index 2152b0e..3210540 100644
--- a/Documentation/ioctl/ioctl-number.txt
+++ b/Documentation/ioctl/ioctl-number.txt
@@ -179,7 +179,7 @@ Code  Seq#(hex)	Include File		Comments
 'V'	C0	media/davinci/vpfe_capture.h	conflict!
 'V'	C0	media/si4713.h		conflict!
 'W'	00-1F	linux/watchdog.h	conflict!
-'W'	00-1F	linux/wanrouter.h	conflict!
+'W'	00-1F	linux/wanrouter.h	conflict!		(pre 3.9)
 'W'	00-3F	sound/asound.h		conflict!
 'X'	all	fs/xfs/xfs_fs.h		conflict!
 		and fs/xfs/linux-2.6/xfs_ioctl32.h
diff --git a/Documentation/magic-number.txt b/Documentation/magic-number.txt
index 82761a3..76d80a6 100644
--- a/Documentation/magic-number.txt
+++ b/Documentation/magic-number.txt
@@ -122,7 +122,7 @@ SLAB_C_MAGIC          0x4f17a36d  kmem_cache        mm/slab.c
 COW_MAGIC             0x4f4f4f4d  cow_header_v1     arch/um/drivers/ubd_user.c
 I810_CARD_MAGIC       0x5072696E  i810_card         sound/oss/i810_audio.c
 TRIDENT_CARD_MAGIC    0x5072696E  trident_card      sound/oss/trident.c
-ROUTER_MAGIC          0x524d4157  wan_device        include/linux/wanrouter.h
+ROUTER_MAGIC          0x524d4157  wan_device        [in wanrouter.h pre 3.9]
 SCC_MAGIC             0x52696368  gs_port           drivers/char/scc.h
 SAVEKMSG_MAGIC1       0x53415645  savekmsg          arch/*/amiga/config.c
 GDA_MAGIC             0x58464552  gda               arch/mips/include/asm/sn/gda.h
diff --git a/Documentation/zh_CN/magic-number.txt b/Documentation/zh_CN/magic-number.txt
index 4263022..2ebe539 100644
--- a/Documentation/zh_CN/magic-number.txt
+++ b/Documentation/zh_CN/magic-number.txt
@@ -122,7 +122,7 @@ SLAB_C_MAGIC          0x4f17a36d  kmem_cache        mm/slab.c
 COW_MAGIC             0x4f4f4f4d  cow_header_v1     arch/um/drivers/ubd_user.c
 I810_CARD_MAGIC       0x5072696E  i810_card         sound/oss/i810_audio.c
 TRIDENT_CARD_MAGIC    0x5072696E  trident_card      sound/oss/trident.c
-ROUTER_MAGIC          0x524d4157  wan_device        include/linux/wanrouter.h
+ROUTER_MAGIC          0x524d4157  wan_device        [in wanrouter.h pre 3.9]
 SCC_MAGIC             0x52696368  gs_port           drivers/char/scc.h
 SAVEKMSG_MAGIC1       0x53415645  savekmsg          arch/*/amiga/config.c
 GDA_MAGIC             0x58464552  gda               arch/mips/include/asm/sn/gda.h
diff --git a/drivers/isdn/i4l/isdn_x25iface.h b/drivers/isdn/i4l/isdn_x25iface.h
index 0b26e3b..ca08e08 100644
--- a/drivers/isdn/i4l/isdn_x25iface.h
+++ b/drivers/isdn/i4l/isdn_x25iface.h
@@ -19,7 +19,6 @@
 #endif
 
 #include <linux/skbuff.h>
-#include <linux/wanrouter.h>
 #include <linux/isdn.h>
 #include <linux/concap.h>
 
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index d58431e..0c077b0 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -356,60 +356,6 @@ config SDLA
 	  To compile this driver as a module, choose M here: the
 	  module will be called sdla.
 
-# Wan router core.
-config WAN_ROUTER_DRIVERS
-	tristate "WAN router drivers"
-	depends on WAN_ROUTER
-	---help---
-	  Connect LAN to WAN via Linux box.
-
-	  Select driver your card and remember to say Y to "Wan Router."
-	  You will need the wan-tools package which is available from
-	  <ftp://ftp.sangoma.com/>.
-
-	  Note that the answer to this question won't directly affect the
-	  kernel except for how subordinate drivers may be built:
-	  saying N will just cause the configurator to skip all
-	  the questions about WAN router drivers.
-
-	  If unsure, say N.
-
-config CYCLADES_SYNC
-	tristate "Cyclom 2X(tm) cards (EXPERIMENTAL)"
-	depends on WAN_ROUTER_DRIVERS && (PCI || ISA)
-	---help---
-	  Cyclom 2X from Cyclades Corporation <http://www.avocent.com/> is an
-	  intelligent multiprotocol WAN adapter with data transfer rates up to
-	  512 Kbps. These cards support the X.25 and SNA related protocols.
-
-	  While no documentation is available at this time please grab the
-	  wanconfig tarball in
-	  <http://www.conectiva.com.br/~acme/cycsyn-devel/> (with minor changes
-	  to make it compile with the current wanrouter include files; efforts
-	  are being made to use the original package available at
-	  <ftp://ftp.sangoma.com/>).
-
-	  Feel free to contact me or the cycsyn-devel mailing list at
-	  <acme@conectiva.com.br> and <cycsyn-devel@bazar.conectiva.com.br> for
-	  additional details, I hope to have documentation available as soon as
-	  possible. (Cyclades Brazil is writing the Documentation).
-
-	  The next questions will ask you about the protocols you want the
-	  driver to support (for now only X.25 is supported).
-
-	  If you have one or more of these cards, say Y to this option.
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called cyclomx.
-
-config CYCLOMX_X25
-	bool "Cyclom 2X X.25 support (EXPERIMENTAL)"
-	depends on CYCLADES_SYNC
-	help
-	  Connect a Cyclom 2X card to an X.25 network.
-
-	  Enabling X.25 support will enlarge your kernel by about 11 kB.
-
 # X.25 network drivers
 config LAPBETHER
 	tristate "LAPB over Ethernet driver (EXPERIMENTAL)"
diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index df70248..c135ef4 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -5,10 +5,6 @@
 # Rewritten to use lists instead of if-statements.
 #
 
-cyclomx-y                       := cycx_main.o
-cyclomx-$(CONFIG_CYCLOMX_X25)	+= cycx_x25.o
-cyclomx-objs			:= $(cyclomx-y)  
-
 obj-$(CONFIG_HDLC)		+= hdlc.o
 obj-$(CONFIG_HDLC_RAW)		+= hdlc_raw.o
 obj-$(CONFIG_HDLC_RAW_ETH)	+= hdlc_raw_eth.o
@@ -28,7 +24,6 @@ obj-$(CONFIG_LANMEDIA)		+= lmc/
 
 obj-$(CONFIG_DLCI)		+= dlci.o 
 obj-$(CONFIG_SDLA)		+= sdla.o
-obj-$(CONFIG_CYCLADES_SYNC)	+= cycx_drv.o cyclomx.o
 obj-$(CONFIG_LAPBETHER)		+= lapbether.o
 obj-$(CONFIG_SBNI)		+= sbni.o
 obj-$(CONFIG_N2)		+= n2.o
diff --git a/net/Kconfig b/net/Kconfig
index 3cc5be0..c31348e 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -209,7 +209,6 @@ source "net/ipx/Kconfig"
 source "drivers/net/appletalk/Kconfig"
 source "net/x25/Kconfig"
 source "net/lapb/Kconfig"
-source "net/wanrouter/Kconfig"
 source "net/phonet/Kconfig"
 source "net/ieee802154/Kconfig"
 source "net/mac802154/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index 4f4ee08..c5aa8b3 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -26,7 +26,6 @@ obj-$(CONFIG_BRIDGE)		+= bridge/
 obj-$(CONFIG_NET_DSA)		+= dsa/
 obj-$(CONFIG_IPX)		+= ipx/
 obj-$(CONFIG_ATALK)		+= appletalk/
-obj-$(CONFIG_WAN_ROUTER)	+= wanrouter/
 obj-$(CONFIG_X25)		+= x25/
 obj-$(CONFIG_LAPB)		+= lapb/
 obj-$(CONFIG_NETROM)		+= netrom/
diff --git a/net/socket.c b/net/socket.c
index 2ca51c7..5c4d82c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -69,7 +69,6 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/mutex.h>
-#include <linux/wanrouter.h>
 #include <linux/if_bridge.h>
 #include <linux/if_frad.h>
 #include <linux/if_vlan.h>
-- 
1.8.1.2
