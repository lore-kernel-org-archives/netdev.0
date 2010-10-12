From: nhorman@tuxdriver.com
Subject: [PATCH 4/5] Fix netconsole to not deadlock on rmmod
Date: Tue, 12 Oct 2010 16:29:36 -0400
Message-ID: <1286915377-1612-5-git-send-email-nhorman@tuxdriver.com>
References: <1286915377-1612-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-076-182-075-229.nc.res.rr.com ([76.182.75.229]:50229 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750757Ab0JLVWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 17:22:46 -0400
In-Reply-To: <1286915377-1612-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

Netconsole calls netpoll_cleanup on receipt of a NETDEVICE_UNREGISTER event.
The notifier subsystem calls these event handlers with rtnl_lock held, which
netpoll_cleanup also takes, resulting in deadlock.  Fix this by calling the
__netpoll_cleanup interior function instead, and fixing up the additional
pointers.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/netconsole.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index ca142c4..94255f0 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -678,7 +678,14 @@ static int netconsole_netdev_event(struct notifier_block *this,
 				strlcpy(nt->np.dev_name, dev->name, IFNAMSIZ);
 				break;
 			case NETDEV_UNREGISTER:
-				netpoll_cleanup(&nt->np);
+				/*
+				 * rtnl_lock already held
+				 */
+				if (nt->np.dev) {
+					__netpoll_cleanup(&nt->np);
+					dev_put(nt->np.dev);
+					nt->np.dev = NULL;
+				}
 				/* Fall through */
 			case NETDEV_GOING_DOWN:
 			case NETDEV_BONDING_DESLAVE:
-- 
1.7.2.3

