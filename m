From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/16] net_tstamp: Add SIOCGHWTSTAMP ioctl to match
 SIOCSHWTSTAMP
Date: Thu, 5 Dec 2013 23:45:25 +0000
Message-ID: <1386287125.1516.128.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34780 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525Ab3LEXp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:45:28 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIOCSHWTSTAMP returns the real configuration to the application
using it, but there is currently no way for any other
application to find out the configuration non-destructively.
Add a new ioctl for this, making it unprivileged.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
v2: Include documentation update and compat ioctl

 Documentation/networking/timestamping.txt |  9 +++++++--
 include/uapi/linux/net_tstamp.h           | 14 +++++++-------
 include/uapi/linux/sockios.h              |  3 ++-
 net/core/dev_ioctl.c                      |  2 ++
 net/socket.c                              |  1 +
 5 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 98097d8cb910..661d3c316a17 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -85,7 +85,7 @@ Filled in if SOF_TIMESTAMPING_SYS_HARDWARE is set. Requires support
 by the network device and will be empty without that support.
 

-SIOCSHWTSTAMP:
+SIOCSHWTSTAMP, SIOCGHWTSTAMP:
 
 Hardware time stamping must also be initialized for each device driver
 that is expected to do hardware time stamping. The parameter is defined in
@@ -115,6 +115,10 @@ Only a processes with admin rights may change the configuration. User
 space is responsible to ensure that multiple processes don't interfere
 with each other and that the settings are reset.
 
+Any process can read the actual configuration by passing this
+structure to ioctl(SIOCGHWTSTAMP) in the same way.  However, this has
+not been implemented in all drivers.
+
 /* possible values for hwtstamp_config->tx_type */
 enum {
 	/*
@@ -157,7 +161,8 @@ DEVICE IMPLEMENTATION
 
 A driver which supports hardware time stamping must support the
 SIOCSHWTSTAMP ioctl and update the supplied struct hwtstamp_config with
-the actual values as described in the section on SIOCSHWTSTAMP.
+the actual values as described in the section on SIOCSHWTSTAMP.  It
+should also support SIOCGHWTSTAMP.
 
 Time stamps for received packets must be stored in the skb. To get a pointer
 to the shared time stamp structure of the skb call skb_hwtstamps(). Then
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
diff --git a/net/socket.c b/net/socket.c
index 7a766ab83ca5..1a548b70ef3a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -3231,6 +3231,7 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	case SIOCBONDSLAVEINFOQUERY:
 	case SIOCBONDINFOQUERY:
 	case SIOCSHWTSTAMP:
+	case SIOCGHWTSTAMP:
 		return compat_ifr_data_ioctl(net, cmd, argp);
 
 	case FIOSETOWN:


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
