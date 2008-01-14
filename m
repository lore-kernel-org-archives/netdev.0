From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 8/8 net-2.6.25] [NETNS] Process inet_confirm_addr in the correct namespace.
Date: Mon, 14 Jan 2008 18:00:01 +0300
Message-ID: <1200322801-19054-8-git-send-email-den@openvz.org>
References: <478B78CB.4030404@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:62420 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753301AbYANPAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 10:00:01 -0500
In-Reply-To: <478B78CB.4030404@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_confirm_addr can be called with NULL in_dev from arp_ignore iff
scope is RT_SCOPE_LINK.

Lets always pass the device and check for RT_SCOPE_LINK scope inside
inet_confirm_addr. This let us take network namespace from in_device a
need for an additional argument.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/arp.c     |    1 -
 net/ipv4/devinet.c |    6 ++++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index f38e1a9..b715ec0 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -402,7 +400,6 @@ static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
 	case 3:	/* Do not reply for scope host addresses */
 		sip = 0;
 		scope = RT_SCOPE_LINK;
-		in_dev = NULL;
 		break;
 	case 4:	/* Reserved */
 	case 5:
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index dc1665a..4569c69 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -978,13 +978,15 @@ __be32 inet_confirm_addr(struct in_device *in_dev,
 {
 	__be32 addr = 0;
 	struct net_device *dev;
+	struct net *net;
 
-	if (in_dev != NULL)
+	if (scope != RT_SCOPE_LINK)
 		return confirm_addr_indev(in_dev, dst, local, scope);
 
+	net = in_dev->dev->nd_net;
 	read_lock(&dev_base_lock);
 	rcu_read_lock();
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		if ((in_dev = __in_dev_get_rcu(dev))) {
 			addr = confirm_addr_indev(in_dev, dst, local, scope);
 			if (addr)
-- 
1.5.3.rc5

