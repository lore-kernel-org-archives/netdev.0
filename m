From: Yongbae Park <yongbae2@gmail.com>
Subject: [PATCH] ibmveth: enable interrupts after napi_complete()
Date: Tue, 10 Mar 2015 11:15:39 +0900
Message-ID: <1425953739-30149-1-git-send-email-yongbae2@gmail.com>
Cc: davem@davemloft.net, nicolas.ferre@atmel.com, tklauser@distanz.ch,
	wsa@the-dreams.de, varkabhadram@gmail.com, netdev@vger.kernel.org
To: msink@permonline.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:45910 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbCJCOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 22:14:42 -0400
Received: by pdjy10 with SMTP id y10so29501215pdj.12
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 19:14:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt is enabled before napi_complete(). A network timeout
occurs if the interrupt handler is called before napi_complete().

Fix the bug by enabling the interrupt after napi_complete().

Signed-off-by: Yongbae Park <yongbae2@gmail.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 21978cc..edcb4c7 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1136,6 +1136,8 @@ restart_poll:
 	ibmveth_replenish_task(adapter);
 
 	if (frames_processed < budget) {
+		napi_complete(napi);
+
 		/* We think we are done - reenable interrupts,
 		 * then check once more to make sure we are done.
 		 */
@@ -1144,8 +1146,6 @@ restart_poll:
 
 		BUG_ON(lpar_rc != H_SUCCESS);
 
-		napi_complete(napi);
-
 		if (ibmveth_rxq_pending_buffer(adapter) &&
 		    napi_reschedule(napi)) {
 			lpar_rc = h_vio_signal(adapter->vdev->unit_address,
-- 
1.9.1
