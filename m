From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH net-next] net: ipv6: send NS for DAD when link operationally up
Date: Mon, 25 Sep 2017 22:01:36 +0100
Message-ID: <1506373296-24977-1-git-send-email-mmanning@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [144.49.130.148] ([144.49.130.148]:61287 "EHLO
        mail.eng.vyatta.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S964935AbdIYVCO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 17:02:14 -0400
Received: from BRA-F155P12.brocade.com (unknown [10.252.53.4])
        by mail.eng.vyatta.net (Postfix) with ESMTPA id 875D63606DC
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 14:02:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NS for DAD are sent on admin up as long as a valid qdisc is found.
A race condition exists by which these packets will not egress the
interface if the operational state of the lower device is not yet up.
The solution is to delay DAD until the link is operationally up
according to RFC2863. Rather than only doing this, follow the existing
code checks by deferring IPv6 device initialization altogether. The fix
allows DAD on devices like tunnels that are controlled by userspace
control plane. The fix has no impact on regular deployments, but means
that there is no IPv6 connectivity until the port has been opened in
the case of port-based network access control, which should be
desirable.

Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/ipv6/addrconf.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c2e2a78..dffbf3b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -303,10 +303,10 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.disable_policy		= 0,
 };
 
-/* Check if a valid qdisc is available */
-static inline bool addrconf_qdisc_ok(const struct net_device *dev)
+/* Check if link is ready: is it up and is a valid qdisc available */
+static inline bool addrconf_link_ready(const struct net_device *dev)
 {
-	return !qdisc_tx_is_noop(dev);
+	return netif_oper_up(dev) && !qdisc_tx_is_noop(dev);
 }
 
 static void addrconf_del_rs_timer(struct inet6_dev *idev)
@@ -451,7 +451,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 
 	ndev->token = in6addr_any;
 
-	if (netif_running(dev) && addrconf_qdisc_ok(dev))
+	if (netif_running(dev) && addrconf_link_ready(dev))
 		ndev->if_flags |= IF_READY;
 
 	ipv6_mc_init_dev(ndev);
@@ -3393,7 +3393,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			/* restore routes for permanent addresses */
 			addrconf_permanent_addr(dev);
 
-			if (!addrconf_qdisc_ok(dev)) {
+			if (!addrconf_link_ready(dev)) {
 				/* device is not ready yet. */
 				pr_info("ADDRCONF(NETDEV_UP): %s: link is not ready\n",
 					dev->name);
@@ -3408,7 +3408,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 				run_pending = 1;
 			}
 		} else if (event == NETDEV_CHANGE) {
-			if (!addrconf_qdisc_ok(dev)) {
+			if (!addrconf_link_ready(dev)) {
 				/* device is still not ready. */
 				break;
 			}
-- 
2.1.4
