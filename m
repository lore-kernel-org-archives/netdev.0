From: Daniel Ritz <daniel.ritz@gmx.ch>
Subject: [PATCH] fix airo memory leak
Date: Sat, 2 Aug 2003 17:43:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308021743.12635.daniel.ritz@gmx.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-net <linux-net@vger.kernel.org>, "linux-netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

fixes a memory leak: memory for the airo_devices list is allocated but
never freed.

against 2.6.0-test2-bk, but should apply to 2.4 as well...



--- 1.54/drivers/net/wireless/airo.c	Sun Jul 20 05:17:02 2003
+++ edited/drivers/net/wireless/airo.c	Sat Aug  2 17:33:24 2003
@@ -4038,12 +4038,23 @@
 	return 0;
 }
 
-static void del_airo_dev( struct net_device *dev ) {
-	struct net_device_list **p = &airo_devices;
-	while( *p && ( (*p)->dev != dev ) )
-		p = &(*p)->next;
-	if ( *p && (*p)->dev == dev )
-		*p = (*p)->next;
+static void del_airo_dev(struct net_device *dev)
+{
+	struct net_device_list *this = airo_devices, *prev = NULL;
+
+	while (this) {
+		if (this->dev == dev) {
+			if (prev)
+				prev->next = this->next;
+			else
+				airo_devices = this->next;
+			kfree(this);
+			break;	
+		}
+
+		prev = this;
+		this = this->next;
+	}
 }
 
 #ifdef CONFIG_PCI
