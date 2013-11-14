From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 2/3] net_tstamp: Add SIOCGHWTSTAMP ioctl to match
 SIOCSHWTSTAMP
Date: Thu, 14 Nov 2013 02:39:35 +0000
Message-ID: <1384396775.29151.38.camel@bwh-desktop.uk.level5networks.com>
References: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24761 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab3KNCjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 21:39:39 -0500
In-Reply-To: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIOCSHWTSTAMP returns the real configuration to the application
using it, but there is currently no way for any other
application to find out the configuration non-destructively.
Add a new ioctl for this, making it unprivileged.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/uapi/linux/net_tstamp.h | 14 +++++++-------
 include/uapi/linux/sockios.h    |  3 ++-
 net/core/dev_ioctl.c            |  2 ++
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index c9a7de2a6276..f53879c0f590 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -26,17 +26,17 @@ enum {
 };
 
 /**
- * struct hwtstamp_config - %SIOCSHWTSTAMP parameter
+ * struct hwtstamp_config - %SIOCGHWTSTAMP and %SIOCSHWTSTAMP parameter
  *
- * @flags:	no flags defined right now, must be zero
+ * @flags:	no flags defined right now, must be zero for %SIOCSHWTSTAMP
  * @tx_type:	one of HWTSTAMP_TX_*
  * @rx_filter:	one of HWTSTAMP_FILTER_*
  *
- * %SIOCSHWTSTAMP expects a &struct ifreq with a ifr_data pointer to
- * this structure.  If the driver or hardware does not support the
- * requested @rx_filter value, the driver may use a more general
- * filter mode.  In this case @rx_filter will indicate the actual mode
- * on return.
+ * %SIOCGHWTSTAMP and %SIOCSHWTSTAMP expect a &struct ifreq with a
+ * ifr_data pointer to this structure.  For %SIOCSHWTSTAMP, if the
+ * driver or hardware does not support the requested @rx_filter value,
+ * the driver may use a more general filter mode.  In this case
+ * @rx_filter will indicate the actual mode on return.
  */
 struct hwtstamp_config {
 	int flags;
diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
index 7997a506ad41..e888b1aed69f 100644
--- a/include/uapi/linux/sockios.h
+++ b/include/uapi/linux/sockios.h
@@ -125,7 +125,8 @@
 #define SIOCBRDELIF	0x89a3		/* remove interface from bridge */
 
 /* hardware time stamping: parameters in linux/net_tstamp.h */
-#define SIOCSHWTSTAMP   0x89b0
+#define SIOCSHWTSTAMP	0x89b0		/* set and get config		*/
+#define SIOCGHWTSTAMP	0x89b1		/* get config			*/
 
 /* Device private ioctl calls */
 
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index 5b7d0e1d0664..cf999e09bcd2 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -327,6 +327,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 		    cmd == SIOCBRADDIF ||
 		    cmd == SIOCBRDELIF ||
 		    cmd == SIOCSHWTSTAMP ||
+		    cmd == SIOCGHWTSTAMP ||
 		    cmd == SIOCWANDEV) {
 			err = -EOPNOTSUPP;
 			if (ops->ndo_do_ioctl) {
@@ -546,6 +547,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	 */
 	default:
 		if (cmd == SIOCWANDEV ||
+		    cmd == SIOCGHWTSTAMP ||
 		    (cmd >= SIOCDEVPRIVATE &&
 		     cmd <= SIOCDEVPRIVATE + 15)) {
 			dev_load(net, ifr.ifr_name);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
