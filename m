From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPv6: Don't assign a same IPv6 address on a same interface
 (is Re: IPv6 duplicate address bugfix)
Date: Sun, 30 Mar 2003 23:58:09 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030330.235809.70243437.yoshfuji@linux-ipv6.org>
References: <20030330122705.GA18283@ferrara.linux.it>
	<20030330.220829.129728506.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, usagi@linux-ipv6.org,
   yoshfuji@linux-ipv6.org, pioppo@ferrara.linux.it
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
In-Reply-To: <20030330.220829.129728506.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030330.220829.129728506.yoshfuji@linux-ipv6.org> (at Sun, 30 Mar 2003 22:08:29 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> And, patch does not seem optimal. I'd take a look at very soon.

Here's our patch based on our fix in August, 2001.
Question: should we use spin_lock_bh() instead of spin_lock()?

--------
Don't assign a same IPv6 address on a same interface.
This patch is against linux-2.5.66.
We believe this fix should be suitable on linux-2.4 tree.
(This patch itself conflicts at the first chunk...)

Thanks in advance.

-------------------------------------------------------------------
Patch-Name: Don't assign a same IPv6 address on a same interface
Patch-Id: FIX_2_5_66_ADDRCONF_DUPADDR-20030330
Patch-Author: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
Credit: Yuji SEKIYA / USAGI Project <sekiya@linux-ipv6.org>,
	YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>,
	Simone Piunno <pioppo@ferrara.linux.it>
-------------------------------------------------------------------
Index: net/ipv6/addrconf.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/addrconf.c,v
retrieving revision 1.1.1.9
retrieving revision 1.1.1.9.2.3
diff -u -r1.1.1.9 -r1.1.1.9.2.3
--- net/ipv6/addrconf.c	25 Mar 2003 04:33:45 -0000	1.1.1.9
+++ net/ipv6/addrconf.c	30 Mar 2003 13:50:41 -0000	1.1.1.9.2.3
@@ -30,6 +30,8 @@
  *						address validation timer.
  *	YOSHIFUJI Hideaki @USAGI	:	Privacy Extensions (RFC3041)
  *						support.
+ *	Yuji SEKIYA @USAGI		:	Don't assign a same IPv6
+ *						address on a same interface.
  */
 
 #include <linux/config.h>
@@ -126,6 +128,8 @@
 static void addrconf_rs_timer(unsigned long data);
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifa);
 
+static int ipv6_chk_same_addr(const struct in6_addr *addr, struct net_device *dev);
+
 static struct notifier_block *inet6addr_chain;
 
 struct ipv6_devconf ipv6_devconf =
@@ -492,10 +496,21 @@
 {
 	struct inet6_ifaddr *ifa;
 	int hash;
+	static spinlock_t lock = SPIN_LOCK_UNLOCKED;
+
+	spin_lock(&lock);
+
+	/* Ignore adding duplicate addresses on an interface */
+	if (ipv6_chk_same_addr(addr, idev->dev)) {
+		spin_unlock(&lock);
+		ADBG(("ipv6_add_addr: already assigned\n"));
+		return NULL;
+	}
 
 	ifa = kmalloc(sizeof(struct inet6_ifaddr), GFP_ATOMIC);
 
 	if (ifa == NULL) {
+		spin_unlock(&lock);
 		ADBG(("ipv6_add_addr: malloc failed\n"));
 		return NULL;
 	}
@@ -514,6 +529,7 @@
 	if (idev->dead) {
 		read_unlock(&addrconf_lock);
 		kfree(ifa);
+		spin_unlock(&lock);
 		return NULL;
 	}
 
@@ -551,6 +567,7 @@
 	in6_ifa_hold(ifa);
 	write_unlock_bh(&idev->lock);
 	read_unlock(&addrconf_lock);
+	spin_unlock(&lock);
 
 	notifier_call_chain(&inet6addr_chain,NETDEV_UP,ifa);
 
@@ -921,6 +938,23 @@
 		    !(ifp->flags&IFA_F_TENTATIVE)) {
 			if (dev == NULL || ifp->idev->dev == dev ||
 			    !(ifp->scope&(IFA_LINK|IFA_HOST)))
+				break;
+		}
+	}
+	read_unlock_bh(&addrconf_hash_lock);
+	return ifp != NULL;
+}
+
+static
+int ipv6_chk_same_addr(const struct in6_addr *addr, struct net_device *dev)
+{
+	struct inet6_ifaddr * ifp;
+	u8 hash = ipv6_addr_hash(addr);
+
+	read_lock_bh(&addrconf_hash_lock);
+	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
+		if (ipv6_addr_cmp(&ifp->addr, addr) == 0) {
+			if (dev != NULL && ifp->idev->dev == dev)
 				break;
 		}
 	}

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
