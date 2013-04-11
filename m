From: David Howells <dhowells@redhat.com>
Subject: [PATCH 16/26] atmel: Don't use create_proc_read_entry() [RFC]
Date: Thu, 11 Apr 2013 14:29:45 +0100
Message-ID: <20130411132944.32763.85351.stgit@warthog.procyon.org.uk>
References: <20130411132739.32763.82609.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Simon Kelley <simon@thekelleys.org.uk>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, viro@ZenIV.linux.org.uk,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238Ab3DKN3y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 09:29:54 -0400
In-Reply-To: <20130411132739.32763.82609.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use create_proc_read_entry() as that is deprecated, but rather use
proc_create_data() and seq_file instead.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Simon Kelley <simon@thekelleys.org.uk>
cc: John W. Linville <linville@tuxdriver.com>
cc: linux-wireless@vger.kernel.org
cc: netdev@vger.kernel.org
---

 drivers/net/wireless/atmel.c |   69 +++++++++++++++++++-----------------------
 1 file changed, 31 insertions(+), 38 deletions(-)

diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 4374079..23a3498 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -63,6 +63,7 @@
 #include <net/iw_handler.h>
 #include <linux/crc32.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/device.h>
 #include <linux/moduleparam.h>
 #include <linux/firmware.h>
@@ -1409,30 +1410,28 @@ static int atmel_validate_channel(struct atmel_private *priv, int channel)
 	return 0;
 }
 
-static int atmel_proc_output (char *buf, struct atmel_private *priv)
+static int atmel_proc_show(struct seq_file *m, void *v)
 {
+	struct atmel_private *priv = m->private;
 	int i;
-	char *p = buf;
 	char *s, *r, *c;
 
-	p += sprintf(p, "Driver version:\t\t%d.%d\n",
-		     DRIVER_MAJOR, DRIVER_MINOR);
+	seq_printf(m, "Driver version:\t\t%d.%d\n", DRIVER_MAJOR, DRIVER_MINOR);
 
 	if (priv->station_state != STATION_STATE_DOWN) {
-		p += sprintf(p, "Firmware version:\t%d.%d build %d\n"
-				"Firmware location:\t",
-			     priv->host_info.major_version,
-			     priv->host_info.minor_version,
-			     priv->host_info.build_version);
+		seq_printf(m,
+			   "Firmware version:\t%d.%d build %d\n"
+			   "Firmware location:\t",
+			   priv->host_info.major_version,
+			   priv->host_info.minor_version,
+			   priv->host_info.build_version);
 
 		if (priv->card_type != CARD_TYPE_EEPROM)
-			p += sprintf(p, "on card\n");
+			seq_puts(m, "on card\n");
 		else if (priv->firmware)
-			p += sprintf(p, "%s loaded by host\n",
-				     priv->firmware_id);
+			seq_printf(m, "%s loaded by host\n", priv->firmware_id);
 		else
-			p += sprintf(p, "%s loaded by hotplug\n",
-				     priv->firmware_id);
+			seq_printf(m, "%s loaded by hotplug\n", priv->firmware_id);
 
 		switch (priv->card_type) {
 		case CARD_TYPE_PARALLEL_FLASH:
@@ -1453,12 +1452,12 @@ static int atmel_proc_output (char *buf, struct atmel_private *priv)
 			if (priv->reg_domain == channel_table[i].reg_domain)
 				r = channel_table[i].name;
 
-		p += sprintf(p, "MAC memory type:\t%s\n", c);
-		p += sprintf(p, "Regulatory domain:\t%s\n", r);
-		p += sprintf(p, "Host CRC checking:\t%s\n",
-			     priv->do_rx_crc ? "On" : "Off");
-		p += sprintf(p, "WPA-capable firmware:\t%s\n",
-			     priv->use_wpa ? "Yes" : "No");
+		seq_printf(m, "MAC memory type:\t%s\n", c);
+		seq_printf(m, "Regulatory domain:\t%s\n", r);
+		seq_printf(m, "Host CRC checking:\t%s\n",
+			 priv->do_rx_crc ? "On" : "Off");
+		seq_printf(m, "WPA-capable firmware:\t%s\n",
+			 priv->use_wpa ? "Yes" : "No");
 	}
 
 	switch (priv->station_state) {
@@ -1490,26 +1489,22 @@ static int atmel_proc_output (char *buf, struct atmel_private *priv)
 		s = "<unknown>";
 	}
 
-	p += sprintf(p, "Current state:\t\t%s\n", s);
-	return p - buf;
+	seq_printf(m, "Current state:\t\t%s\n", s);
+	return 0;
 }
 
-static int atmel_read_proc(char *page, char **start, off_t off,
-			   int count, int *eof, void *data)
+static int atmel_proc_open(struct inode *inode, struct file *file)
 {
-	struct atmel_private *priv = data;
-	int len = atmel_proc_output (page, priv);
-	if (len <= off+count)
-		*eof = 1;
-	*start = page + off;
-	len -= off;
-	if (len > count)
-		len = count;
-	if (len < 0)
-		len = 0;
-	return len;
+	return single_open(file, atmel_proc_show, PDE_DATA(inode));
 }
 
+static const struct file_operations atmel_proc_fops = {
+	.open		= atmel_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 static const struct net_device_ops atmel_netdev_ops = {
 	.ndo_open 		= atmel_open,
 	.ndo_stop		= atmel_close,
@@ -1525,7 +1520,6 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 				   struct device *sys_dev,
 				   int (*card_present)(void *), void *card)
 {
-	struct proc_dir_entry *ent;
 	struct net_device *dev;
 	struct atmel_private *priv;
 	int rc;
@@ -1630,8 +1624,7 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 
 	netif_carrier_off(dev);
 
-	ent = create_proc_read_entry ("driver/atmel", 0, NULL, atmel_read_proc, priv);
-	if (!ent)
+	if (!proc_create_data("driver/atmel", 0, NULL, &atmel_proc_fops, priv));
 		printk(KERN_WARNING "atmel: unable to create /proc entry.\n");
 
 	printk(KERN_INFO "%s: Atmel at76c50x. Version %d.%d. MAC %pM\n",
