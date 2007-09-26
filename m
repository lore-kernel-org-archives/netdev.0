From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/4] net ipv4: When possible test for IFF_LOOPBACK and not dev == loopback_dev
Date: Wed, 26 Sep 2007 17:58:21 -0600
Message-ID: <m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
	<m1ir5xrngu.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:49577 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbXIZX7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 19:59:08 -0400
In-Reply-To: <m1ir5xrngu.fsf@ebiederm.dsl.xmission.com> (Eric W. Biederman's
	message of "Wed, 26 Sep 2007 17:55:29 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Now that multiple loopback devices are becoming possible it makes
the code a little cleaner and more maintainable to test if a deivice
is th a loopback device by testing dev->flags & IFF_LOOPBACK instead
of dev == loopback_dev.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/devinet.c         |    4 ++--
 net/ipv4/ipconfig.c        |   10 +++++++---
 net/ipv4/ipvs/ip_vs_core.c |    2 +-
 3 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index e7f2b02..55d199e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1059,7 +1059,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 			in_dev = inetdev_init(dev);
 			if (!in_dev)
 				return notifier_from_errno(-ENOMEM);
-			if (dev == loopback_dev) {
+			if (dev->flags & IFF_LOOPBACK) {
 				IN_DEV_CONF_SET(in_dev, NOXFRM, 1);
 				IN_DEV_CONF_SET(in_dev, NOPOLICY, 1);
 			}
@@ -1075,7 +1075,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	case NETDEV_UP:
 		if (dev->mtu < 68)
 			break;
-		if (dev == loopback_dev) {
+		if (dev->flags & IFF_LOOPBACK) {
 			struct in_ifaddr *ifa;
 			if ((ifa = inet_alloc_ifa()) != NULL) {
 				ifa->ifa_local =
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 2d2e0cd..af5d5b3 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -190,11 +190,15 @@ static int __init ic_open_devs(void)
 	rtnl_lock();
 
 	/* bring loopback device up first */
-	if (dev_change_flags(loopback_dev, loopback_dev->flags | IFF_UP) < 0)
-		printk(KERN_ERR "IP-Config: Failed to open %s\n", loopback_dev->name);
+	for_each_netdev(&init_net, dev) {
+		if (!(dev->flags & IFF_LOOPBACK))
+			continue;
+		if (dev_change_flags(dev, dev->flags | IFF_UP) < 0)
+			printk(KERN_ERR "IP-Config: Failed to open %s\n", dev->name);
+	}
 
 	for_each_netdev(&init_net, dev) {
-		if (dev == loopback_dev)
+		if (dev->flags & IFF_LOOPBACK)
 			continue;
 		if (user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
 		    (!(dev->flags & IFF_LOOPBACK) &&
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 7450326..fbca2a2 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -961,7 +961,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff **pskb,
 	 *	... don't know why 1st test DOES NOT include 2nd (?)
 	 */
 	if (unlikely(skb->pkt_type != PACKET_HOST
-		     || skb->dev == loopback_dev || skb->sk)) {
+		     || skb->dev->flags & IFF_LOOPBACK || skb->sk)) {
 		IP_VS_DBG(12, "packet type=%d proto=%d daddr=%d.%d.%d.%d ignored\n",
 			  skb->pkt_type,
 			  ip_hdr(skb)->protocol,
-- 
1.5.3.rc6.17.g1911

