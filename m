From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/6 net-next] cnic: Simplify netdev events handling.
Date: Sun, 28 Jul 2013 19:03:55 -0700
Message-ID: <1375063440-4016-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4299 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642Ab3G2BmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 21:42:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After this earlier commit to simplify probing:

    commit 4bd9b0fffb193d2e288f67f81821af32df8d4349
    cnic, bnx2x, bnx2: Simplify cnic probing.

we can now reliably receive netdev events and we can simplify the handling
of these events.  We now remove the logic that tries to handle missed
NETDEV_REGISTER events.

This change will allow cleanup to be simplified in the next patch.  We can
now rely on the play back of netdev events during
unregister_netdevice_notifier() to cleanup the structures.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index d78d4cf..764bfc1 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5628,7 +5628,7 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 
 	dev = cnic_from_netdev(netdev);
 
-	if (!dev && (event == NETDEV_REGISTER || netif_running(netdev))) {
+	if (!dev && event == NETDEV_REGISTER) {
 		/* Check for the hot-plug device */
 		dev = is_cnic_dev(netdev);
 		if (dev) {
@@ -5644,7 +5644,7 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 		else if (event == NETDEV_UNREGISTER)
 			cnic_ulp_exit(dev);
 
-		if (event == NETDEV_UP || (new_dev && netif_running(netdev))) {
+		if (event == NETDEV_UP) {
 			if (cnic_register_netdev(dev) != 0) {
 				cnic_put(dev);
 				goto done;
-- 
1.7.1
