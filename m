From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: Fix incorrect disable_ipv6 behavior
Date: Thu,  5 Mar 2009 17:28:40 -0500
Message-ID: <1236292120-32050-1-git-send-email-brian.haley@hp.com>
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:42096 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbZCEW2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 17:28:43 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't look like the disable_ipv6 devconf setting works
as described in ip-sysctl.txt.  I think it was originally
designed to only be set by addrconf_dad_failure(), but since
it's mode 0644 it can be controlled through sysctl -w.

Here's an example:

# sysctl -w net.ipv6.conf.eth0.disable_ipv6=1
net.ipv6.conf.eth0.disable_ipv6 = 1
# sysctl -w net.ipv6.conf.eth0.accept_dad=2
net.ipv6.conf.eth0.accept_dad = 2

# ifdown eth0
# ifup eth0

Mar  5 11:23:45 titan kernel: eth0: duplicate address detected!

# ip -6 a show dev eth0
5: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 fe80::21f:29ff:fe5a:ef04/64 scope link tentative
       valid_lft forever preferred_lft forever

The address didn't actually fail DAD, but since disable_ipv6
was set, addrconf_dad_timer() called addrconf_dad_failure()
before checking if it succeeded.

The following patch fixes the behavior.  The other option is
to make this value read-only, but disable_ipv6 can be useful.

---

Fix the behavior of allowing both sysctl and addrconf_dad_failure()
to set the disable_ipv6 parameter without any bad side-effects.
If DAD fails and accept_dad > 1, we will still set disable_ipv6=1,
but then instead of allowing an RA to add an address then
immediately fail DAD, we simply don't allow the address to be
added in the first place.  This also lets the user set this flag
and disable all IPv6 addresses on the interface, or on the entire
system.


Signed-off-by: Brian Haley <brian.haley@hp.com>
---
 Documentation/networking/ip-sysctl.txt |    4 +++-
 net/ipv6/addrconf.c                    |   21 ++++++++++++++-------
 2 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 7185e4c..ec5de02 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1043,7 +1043,9 @@ max_addresses - INTEGER
 	Default: 16
 
 disable_ipv6 - BOOLEAN
-	Disable IPv6 operation.
+	Disable IPv6 operation.  If accept_dad is set to 2, this value
+	will be dynamically set to TRUE if DAD fails for the link-local
+	address.
 	Default: FALSE (enable IPv6 operation)
 
 accept_dad - INTEGER
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e83852a..717584b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -590,6 +590,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 {
 	struct inet6_ifaddr *ifa = NULL;
 	struct rt6_info *rt;
+	struct net *net = dev_net(idev->dev);
 	int hash;
 	int err = 0;
 	int addr_type = ipv6_addr_type(addr);
@@ -606,6 +607,11 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 		goto out2;
 	}
 
+	if (idev->cnf.disable_ipv6 || net->ipv6.devconf_all->disable_ipv6) {
+		err = -EACCES;
+		goto out2;
+	}
+
 	write_lock(&addrconf_hash_lock);
 
 	/* Ignore adding duplicate addresses on an interface */
@@ -1433,6 +1439,11 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
 void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 {
 	struct inet6_dev *idev = ifp->idev;
+
+	if (net_ratelimit())
+		printk(KERN_INFO "%s: IPv6 duplicate address detected!\n",
+			ifp->idev->dev->name);
+
 	if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
 		struct in6_addr addr;
 
@@ -1443,11 +1454,12 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 		    ipv6_addr_equal(&ifp->addr, &addr)) {
 			/* DAD failed for link-local based on MAC address */
 			idev->cnf.disable_ipv6 = 1;
+
+			printk(KERN_INFO "%s: IPv6 being disabled!\n",
+				ifp->idev->dev->name);
 		}
 	}
 
-	if (net_ratelimit())
-		printk(KERN_INFO "%s: duplicate address detected!\n", ifp->idev->dev->name);
 	addrconf_dad_stop(ifp);
 }
 
@@ -2823,11 +2835,6 @@ static void addrconf_dad_timer(unsigned long data)
 		read_unlock_bh(&idev->lock);
 		goto out;
 	}
-	if (idev->cnf.accept_dad > 1 && idev->cnf.disable_ipv6) {
-		read_unlock_bh(&idev->lock);
-		addrconf_dad_failure(ifp);
-		return;
-	}
 	spin_lock_bh(&ifp->lock);
 	if (ifp->probes == 0) {
 		/*
-- 
1.5.4.3

