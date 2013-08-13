From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] ipv6: fix checkpatch errors in net/ipv6/addrconf.c
Date: Mon, 12 Aug 2013 23:30:56 -0700
Message-ID: <1376375456.1949.22.camel@joe-AO722>
References: <5209CEEC.2050505@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60850 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755536Ab3HMGa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 02:30:57 -0400
In-Reply-To: <5209CEEC.2050505@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-13 at 14:15 +0800, Ding Tianhong wrote:
> ERROR: Macros with complex values should be enclosed in parenthesis
> +#define ADBG(x) printk x
[]
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
[]
> @@ -99,7 +99,7 @@
[]
> -#define ADBG(x) printk x
> +#define ADBG(x) (printk x)

A better way to fix this would be
to convert the uses of ADBG and remove
the superfluous parentheses.

Something like the below but it might
even better to remove the KERN_<LEVEL>s and
just use pr_debug instead of ADBG...
---
 net/ipv6/addrconf.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7fd8572..1286a7d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -99,9 +99,9 @@
 #define ACONF_DEBUG 2
 
 #if ACONF_DEBUG >= 3
-#define ADBG(x) printk x
+#define ADBG(fmt, ...) printk(fmt, ##__VA_ARGS__)
 #else
-#define ADBG(x)
+#define ADBG(fmt, ...) do { if (0) printk(fmt, ##__VA_ARGS__); } while (0)
 #endif
 
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
@@ -369,9 +369,9 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	dev_hold(dev);
 
 	if (snmp6_alloc_dev(ndev) < 0) {
-		ADBG((KERN_WARNING
-			"%s: cannot allocate memory for statistics; dev=%s.\n",
-			__func__, dev->name));
+		ADBG(KERN_WARNING
+		     "%s: cannot allocate memory for statistics; dev=%s\n",
+		     __func__, dev->name);
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		dev_put(dev);
 		kfree(ndev);
@@ -379,9 +379,8 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	}
 
 	if (snmp6_register_dev(ndev) < 0) {
-		ADBG((KERN_WARNING
-			"%s: cannot create /proc/net/dev_snmp6/%s\n",
-			__func__, dev->name));
+		ADBG(KERN_WARNING "%s: cannot create /proc/net/dev_snmp6/%s\n",
+		     __func__, dev->name);
 		neigh_parms_release(&nd_tbl, ndev->nd_parms);
 		ndev->dead = 1;
 		in6_dev_finish_destroy(ndev);
@@ -844,7 +843,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 
 	/* Ignore adding duplicate addresses on an interface */
 	if (ipv6_chk_same_addr(dev_net(idev->dev), addr, idev->dev)) {
-		ADBG(("ipv6_add_addr: already assigned\n"));
+		ADBG("ipv6_add_addr: already assigned\n");
 		err = -EEXIST;
 		goto out;
 	}
@@ -852,7 +851,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifa = kzalloc(sizeof(struct inet6_ifaddr), GFP_ATOMIC);
 
 	if (ifa == NULL) {
-		ADBG(("ipv6_add_addr: malloc failed\n"));
+		ADBG("ipv6_add_addr: malloc failed\n");
 		err = -ENOBUFS;
 		goto out;
 	}
@@ -2052,7 +2051,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 	pinfo = (struct prefix_info *) opt;
 
 	if (len < sizeof(struct prefix_info)) {
-		ADBG(("addrconf: prefix option too short\n"));
+		ADBG("addrconf: prefix option too short\n");
 		return;
 	}
 
@@ -3632,8 +3631,8 @@ restart:
 	if (time_before(next_sched, jiffies + ADDRCONF_TIMER_FUZZ_MAX))
 		next_sched = jiffies + ADDRCONF_TIMER_FUZZ_MAX;
 
-	ADBG((KERN_DEBUG "now = %lu, schedule = %lu, rounded schedule = %lu => %lu\n",
-	      now, next, next_sec, next_sched));
+	ADBG(KERN_DEBUG "now = %lu, schedule = %lu, rounded schedule = %lu => %lu\n",
+	     now, next, next_sec, next_sched);
 
 	addr_chk_timer.expires = next_sched;
 	add_timer(&addr_chk_timer);
