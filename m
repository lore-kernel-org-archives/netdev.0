From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net v2] be2net: call napi_disable() for all event queues
Date: Wed, 27 Nov 2013 08:59:32 +0100
Message-ID: <1385539172-4744-1-git-send-email-ivecera@redhat.com>
Cc: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952Ab3K0H7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Nov 2013 02:59:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent be2net commit 6384a4d (adds a support for busy polling)
introduces a regression that results in kernel crash. It incorrectly
modified be_close() so napi_disable() is called only for the first queue.
This breaks a correct pairing of napi_enable/_disable for the rest
of event queues and causes a crash in subsequent be_open() call.

v2: Applied suggestions from Sathya

Fixes: 6384a4d ("be2net: add support for ndo_busy_poll")
Cc: Sathya Perla <sathya.perla@emulex.com>
Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 78a0e85..fee64bf 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2658,8 +2658,8 @@ static int be_close(struct net_device *netdev)
 
 	be_roce_dev_close(adapter);
 
-	for_all_evt_queues(adapter, eqo, i) {
-		if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
+	if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
+		for_all_evt_queues(adapter, eqo, i) {
 			napi_disable(&eqo->napi);
 			be_disable_busy_poll(eqo);
 		}
-- 
1.8.3.2
