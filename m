From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC]  SIOCGIFCOUNT implementation
Date: Mon, 23 Apr 2007 14:12:26 -0700
Message-ID: <20070423141226.1c2127ce@localhost.localdomain>
References: <200704210004.51278.ak@suse.de>
 <20070420.154133.76947512.davem@davemloft.net>
 <200704211148.52705.ak@suse.de>
 <20070421.104047.41636018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35946 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753607AbXDWVMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 17:12:37 -0400
In-Reply-To: <20070421.104047.41636018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trivial implementation of SIOCGIFCOUNT.
If you search the archives, this was suggested and rejected
6 years ago. But there maybe legacy Unix applications that
could actually use it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/core/dev.c |   50 ++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 40 insertions(+), 10 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4dc93cc..6779aa4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1987,7 +1987,7 @@ int register_gifconf(unsigned int family, gifconf_func_t * gifconf)
  *	match.  --pb
  */
 
-static int dev_ifname(struct ifreq __user *arg)
+static int dev_ifname(void __user *arg)
 {
 	struct net_device *dev;
 	struct ifreq ifr;
@@ -2020,7 +2020,7 @@ static int dev_ifname(struct ifreq __user *arg)
  *	Thus we will need a 'compatibility mode'.
  */
 
-static int dev_ifconf(char __user *arg)
+static int dev_ifconf(void __user *arg)
 {
 	struct ifconf ifc;
 	struct net_device *dev;
@@ -2071,6 +2071,32 @@ static int dev_ifconf(char __user *arg)
 	return copy_to_user(arg, &ifc, sizeof(struct ifconf)) ? -EFAULT : 0;
 }
 
+/*
+ * 	Perform SIOCGIFCONF give estimate of number of interfaces.
+ *	This show the poor design of Berkeley ioctl interface because number
+ *	of interfaces can change at any time.
+ */
+static int dev_ifcount(char __user *arg)
+{
+	struct ifconf ifc;
+	struct net_device *dev;
+	int i, total = 0;
+
+	for (dev = dev_base; dev; dev = dev->next)
+		for (i = 0; i < NPROTO; i++)
+			if (gifconf_list[i]) {
+				int done = gifconf_list[i](dev, NULL, 0);
+				if (done > 0)
+					total += done;
+					
+		}
+
+	memset(&ifc, 0, sizeof(ifc));
+	ifc.ifc_len = total;
+	return copy_to_user(arg, &ifc, sizeof(struct ifconf)) ? -EFAULT : 0;
+}
+
+
 #ifdef CONFIG_PROC_FS
 /*
  *	This is invoked by the /proc filesystem handler to display a device
@@ -2643,19 +2669,23 @@ int dev_ioctl(unsigned int cmd, void __user *arg)
 	int ret;
 	char *colon;
 
-	/* One special case: SIOCGIFCONF takes ifconf argument
-	   and requires shared lock, because it sleeps writing
-	   to user space.
-	 */
+	/* Special case ioctl's that don't relate to a specific device */
+	switch(cmd) {
+	case SIOCGIFCONF:
+		rtnl_lock();
+		ret = dev_ifconf(arg);
+		rtnl_unlock();
+		return ret;
 
-	if (cmd == SIOCGIFCONF) {
+	case SIOCGIFCOUNT:
 		rtnl_lock();
-		ret = dev_ifconf((char __user *) arg);
+		ret = dev_ifcount(arg);
 		rtnl_unlock();
 		return ret;
+
+	case SIOCGIFNAME:
+		return dev_ifname(arg);
 	}
-	if (cmd == SIOCGIFNAME)
-		return dev_ifname((struct ifreq __user *)arg);
 
 	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
 		return -EFAULT;
-- 
1.5.0.6

