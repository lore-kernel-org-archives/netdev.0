From: divy@chelsio.com
Subject: [PATCH 2.6.21 1/3] cxgb3 - avoid deadlock with mac watchdog
Date: Mon, 09 Apr 2007 20:10:22 -0700
Message-ID: <20070410031022.12878.81342.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:24160 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932933AbXDJDKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 23:10:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Fix a deadlock when the interface s configured down and 
the watchdog tack is sleeping on rtnl_lock.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 26240fd..c6ebe25 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2119,7 +2119,9 @@ static void check_t3b2_mac(struct adapte
 {
 	int i;
 
-	rtnl_lock();                      /* synchronize with ifdown */
+	if (!rtnl_trylock())	/* synchronize with ifdown */
+		return;
+
 	for_each_port(adapter, i) {
 		struct net_device *dev = adapter->port[i];
 		struct port_info *p = netdev_priv(dev);
