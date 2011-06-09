From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/5 net-next] cnic: Improve NETDEV_UP event handling
Date: Wed, 8 Jun 2011 22:29:35 -0700
Message-ID: <1307597376-5379-4-git-send-email-mchan@broadcom.com>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
 <1307597376-5379-2-git-send-email-mchan@broadcom.com>
 <1307597376-5379-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1236 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341Ab1FIGVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 02:21:06 -0400
In-Reply-To: <1307597376-5379-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During NETDEV_UP, we use symbol_get() to get the net driver's cnic
probe function.  This sometimes doesn't work if NETDEV_UP happens
right after NETDEV_REGISTER and the net driver is still running module
init code.  As a result, the cnic device may not be discovered.  We
fix this by probing on all NETDEV events if the device's netif_running
state is up.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index a529bde..6c544b3 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -5342,7 +5342,7 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 
 	dev = cnic_from_netdev(netdev);
 
-	if (!dev && (event == NETDEV_REGISTER || event == NETDEV_UP)) {
+	if (!dev && (event == NETDEV_REGISTER || netif_running(netdev))) {
 		/* Check for the hot-plug device */
 		dev = is_cnic_dev(netdev);
 		if (dev) {
@@ -5358,7 +5358,7 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 		else if (event == NETDEV_UNREGISTER)
 			cnic_ulp_exit(dev);
 
-		if (event == NETDEV_UP) {
+		if (event == NETDEV_UP || (new_dev && netif_running(netdev))) {
 			if (cnic_register_netdev(dev) != 0) {
 				cnic_put(dev);
 				goto done;
-- 
1.6.4.GIT


