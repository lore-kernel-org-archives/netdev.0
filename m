From: Thomas Munck Steenholdt <tmus@tmus.dk>
Subject: [PATCH] 2.6.3 pcnet32.c fix link reporting for non-mii devices
Date: Fri, 20 Feb 2004 20:55:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40366625.8060008@tmus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Guys!

A lot of people have been experiencing problems with the pcnet32 nic 
driver that
always returns link down on some devices (including the VMware vlance 
adapter).

The patch makes sure that link is always reported as up (in contrast to 
always
being rported as down) if the device is not MII capable. Devices that 
ARE MII
capable will return whatever mii_link_ok() says.

Please let be know what you think and possible give me a hint as to how 
I can
make sure this fix gets included whereever such a patch should be included!

Thanks a lot!

diff -ur linux-2.6.2-1.87/drivers/net/pcnet32.c linux-2.6.2-1.87-tmus/drivers/net/pcnet32.c
--- linux-2.6.2-1.87/drivers/net/pcnet32.c	2004-02-19 00:27:36.033478624 +0100
+++ linux-2.6.2-1.87-tmus/drivers/net/pcnet32.c	2004-02-19 00:26:03.733510352 +0100
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.27b"
-#define DRV_RELDATE	"01.10.2002"
+#define DRV_VERSION	"1.27c"
+#define DRV_RELDATE	"02.19.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -213,6 +213,8 @@
  *	   clean up and using new mii module
  * v1.27b  Sep 30 2002 Kent Yoder <yoder1@us.ibm.com>
  * 	   Added timer for cable connection state changes.
+ * v1.27c  Feb 19 2004 Thomas M Steenholdt <tmus@tmus.dk>
+ *         fixed link status on non-mii capable devices.
  */
 
 
@@ -1630,7 +1632,10 @@
 	/* get link status */
 	case ETHTOOL_GLINK: {
 		struct ethtool_value edata = {ETHTOOL_GLINK};
-		edata.data = mii_link_ok(&lp->mii_if);
+                /* read link status  */
+		if(lp->mii) edata.data = mii_link_ok(&lp->mii_if);
+                /* always return link ok for non-mii devices */
+                else edata.data = 1;
 		if (copy_to_user(useraddr, &edata, sizeof(edata)))
 			return -EFAULT;
 		return 0;
