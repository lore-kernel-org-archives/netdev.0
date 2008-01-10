From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 6/6][NETNS]: Use the per-net ipv6_devconf(_all)
 in sysctl handlers
Date: Thu, 10 Jan 2008 17:10:44 +0300
Message-ID: <47862764.60807@openvz.org>
References: <478623C0.7030008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39795 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754504AbYAJOLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 09:11:12 -0500
In-Reply-To: <478623C0.7030008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually the net->ipv6.devconf_all can be used in a few places,
but to keep the /proc/sys/net/ipv6/conf/ sysctls work consistently
in the namespace we should use the per-net devconf_all in the
sysctl "forwarding" handler.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/addrconf.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9b96de3..cd90f9a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -456,7 +456,7 @@ static void dev_forward_change(struct inet6_dev *idev)
 }
 
 
-static void addrconf_forward_change(struct net *net)
+static void addrconf_forward_change(struct net *net, __s32 newf)
 {
 	struct net_device *dev;
 	struct inet6_dev *idev;
@@ -466,8 +466,8 @@ static void addrconf_forward_change(struct net *net)
 		rcu_read_lock();
 		idev = __in6_dev_get(dev);
 		if (idev) {
-			int changed = (!idev->cnf.forwarding) ^ (!ipv6_devconf.forwarding);
-			idev->cnf.forwarding = ipv6_devconf.forwarding;
+			int changed = (!idev->cnf.forwarding) ^ (!newf);
+			idev->cnf.forwarding = newf;
 			if (changed)
 				dev_forward_change(idev);
 		}
@@ -484,9 +484,10 @@ static void addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
 	if (p == &net->ipv6.devconf_dflt->forwarding)
 		return;
 
-	if (p == &ipv6_devconf.forwarding) {
-		net->ipv6.devconf_dflt->forwarding = ipv6_devconf.forwarding;
-		addrconf_forward_change(net);
+	if (p == &net->ipv6.devconf_all->forwarding) {
+		__s32 newf = net->ipv6.devconf_all->forwarding;
+		net->ipv6.devconf_dflt->forwarding = newf;
+		addrconf_forward_change(net, newf);
 	} else if ((!*p) ^ (!old))
 		dev_forward_change((struct inet6_dev *)table->extra1);
 
-- 
1.5.3.4


