From: "Krishnakumar. R" <krishnakumar@naturesoft.net>
Subject: [PATCH] PIO register dump support for 8139 driver
Date: Tue, 17 Feb 2004 17:25:54 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402171725.54339.krishnakumar@naturesoft.net>
Reply-To: krishnakumar@naturesoft.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The following patch adds the pio register dump
support for the 8139too.c. The register dump can 
be now obtained when we are using PIO mode.
(eg: ethtool -d eth0 will give the register dump
in the PIO mode after this patch is applied.)

The patch is against linux-2.6.1-bk4-netdev1.

Please do apply.

Regards,
KK.

Diffstat output:
---------------------
8139too.c |   24 +++++++++++++++++++-----
1 files changed, 19 insertions(+), 5 deletions(-)

The Patch:
---------------
--- linux-2.6.1-bk4-netdev1/drivers/net/8139too.orig.c	2004-02-09 
14:09:22.000000000 +0530
+++ linux-2.6.1-bk4-netdev1/drivers/net/8139too.c	2004-02-17 
14:55:05.681637552 +0530
@@ -2391,17 +2391,31 @@
 	np->msg_enable = datum;
 }
 
-/* TODO: we are too slack to do reg dumping for pio, for now */
-#ifdef CONFIG_8139TOO_PIO
-#define rtl8139_get_regs_len	NULL
-#define rtl8139_get_regs	NULL
-#else
 static int rtl8139_get_regs_len(struct net_device *dev)
 {
 	struct rtl8139_private *np = dev->priv;
 	return np->regs_len;
 }
 
+#ifdef CONFIG_8139TOO_PIO
+static void rtl8139_get_regs(struct net_device *dev, 
+                             struct ethtool_regs *regs, void *regbuf)
+{
+	struct rtl8139_private *np = dev->priv;
+	int i;
+	char *p;
+	void *ioaddr = np->mmio_addr;
+	
+	regs->version = RTL_REGS_VER;
+	p = (char *)regbuf;
+
+	spin_lock_irq(&np->lock);
+	for ( i=0 ; i<np->regs_len ; i++ ) {
+		p[i] =  RTL_R8 (i);
+	}
+	spin_unlock_irq(&np->lock);
+}
+#else
 static void rtl8139_get_regs(struct net_device *dev, struct ethtool_regs 
*regs, void *regbuf)
 {
 	struct rtl8139_private *np = dev->priv;




-- 
HomePage: http://puggy.symonds.net/~krishnakumar
