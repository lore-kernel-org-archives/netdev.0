From: Colin Leroy <colin@colino.net>
Subject: Re: [linux-usb-devel] [PATCH] PM support for zd1201
Date: Fri, 1 Apr 2005 23:27:47 +0200
Message-ID: <20050401232747.3f9ed365@jack.colino.net>
References: <20050330144423.0dde5b71@jack.colino.net>
	<200504011030.57978.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-usb-devel@lists.sourceforge.net, Andrew Morton <akpm@osdl.org>,
        Jeroen Vreeken <pe1rxq@amsat.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <200504011030.57978.david-b@pacbell.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 01 Apr 2005 at 10h04, David Brownell wrote:

Hi, 

> Looked ok to me, other than needing to change "u32 state" into
> a "pm_message_t message".  And I'm not sure why "mac_enabled"
> would be the right test, rather than maybe netif_running().

Here it is.

Signed-off-by: Colin Leroy <colin@colino.net>
--- drivers/usb/net/zd1201.c.orig	2005-03-30 14:35:23.000000000 +0200
+++ drivers/usb/net/zd1201.c	2005-04-01 23:24:04.000000000 +0200
@@ -1896,12 +1896,50 @@
 	kfree(zd);
 }
 
+#ifdef CONFIG_PM
+
+static int zd1201_suspend (struct usb_interface *interface, 
+			   pm_message_t message)
+{
+	struct zd1201 *zd = (struct zd1201 *)usb_get_intfdata(interface);
+	
+	netif_device_detach(zd->dev);
+	
+	zd->was_enabled = zd->mac_enabled;
+	
+	if (zd->was_enabled)
+		return zd1201_disable(zd);
+	else
+		return 0;
+}
+
+static int zd1201_resume (struct usb_interface *interface)
+{
+	struct zd1201 *zd = (struct zd1201 *)usb_get_intfdata(interface);
+	
+	netif_device_attach(zd->dev);
+	
+	if (zd->was_enabled)
+		return zd1201_enable(zd);
+	else
+		return 0;
+}
+
+#else
+
+#define zd1201_suspend NULL
+#define zd1201_resume  NULL
+
+#endif
+
 struct usb_driver zd1201_usb = {
 	.owner = THIS_MODULE,
 	.name = "zd1201",
 	.probe = zd1201_probe,
 	.disconnect = zd1201_disconnect,
 	.id_table = zd1201_table,
+	.suspend = zd1201_suspend,
+	.resume = zd1201_resume,
 };
 
 static int __init zd1201_init(void)
--- drivers/usb/net/zd1201.h.orig	2005-03-30 14:35:36.000000000 +0200
+++ drivers/usb/net/zd1201.h	2005-03-30 14:24:33.000000000 +0200
@@ -46,6 +46,7 @@
 	char			essid[IW_ESSID_MAX_SIZE+1];
 	int			essidlen;
 	int			mac_enabled;
+	int			was_enabled;
 	int			monitor;
 	int			encode_enabled;
 	int			encode_restricted;
