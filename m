From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] be2net: don't {en,dis}able filters on BE3 when transparent tagging is enabled
Date: Fri, 26 Feb 2016 09:46:41 +0100
Message-ID: <1456476401-23398-1-git-send-email-ivecera@redhat.com>
Cc: Sathya Perla <sathya.perla@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867AbcBZIqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 03:46:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FILTMGMT privilege is necessary on BE3 chip to manipulare filters
like MC, UC list management, VLAN filter, promisc mode... This privilege
is dropped for VFs when transparrent tagging is enabled on them. This
prevents to make interface up for such VF because be_enable_if_filters()
called from be_open() fails thus be_open() also fails.

Cc: Sathya Perla <sathya.perla@broadcom.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f99de36..2e176f6 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3430,7 +3430,8 @@ static int be_close(struct net_device *netdev)
 	if (!(adapter->flags & BE_FLAGS_SETUP_DONE))
 		return 0;
 
-	be_disable_if_filters(adapter);
+	if (!(BEx_chip(adapter) && be_pvid_tagging_enabled(adapter)))
+		be_disable_if_filters(adapter);
 
 	if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
 		for_all_evt_queues(adapter, eqo, i) {
@@ -3571,9 +3572,11 @@ static int be_open(struct net_device *netdev)
 	if (status)
 		goto err;
 
-	status = be_enable_if_filters(adapter);
-	if (status)
-		goto err;
+	if (!(BEx_chip(adapter) && be_pvid_tagging_enabled(adapter))) {
+		status = be_enable_if_filters(adapter);
+		if (status)
+			goto err;
+	}
 
 	status = be_irq_register(adapter);
 	if (status)
-- 
2.4.10
