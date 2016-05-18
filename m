From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next] xen-netback: only deinitialized hash if it was initialized
Date: Wed, 18 May 2016 15:55:42 +0100
Message-ID: <1463583342-25085-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22583 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753108AbcERPJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 11:09:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A domain with a frontend that does not implement a control ring has been
seen to cause a crash during domain save. This was apparently because
the call to xenvif_deinit_hash() in xenvif_disconnect_ctrl() is made
regardless of whether a control ring was connected, and hence
xenvif_hash_init() was called.

This patch brings the call to xenvif_deinit_hash() in
xenvif_disconnect_ctrl() inside the if clause that checks whether the
control ring event channel was connected. This is sufficient to ensure
it is only called if xenvif_init_hash() was called previously.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/interface.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 1c7f49b..83deeeb 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -780,9 +780,8 @@ void xenvif_disconnect_ctrl(struct xenvif *vif)
 		vif->ctrl_task = NULL;
 	}
 
-	xenvif_deinit_hash(vif);
-
 	if (vif->ctrl_irq) {
+		xenvif_deinit_hash(vif);
 		unbind_from_irqhandler(vif->ctrl_irq, vif);
 		vif->ctrl_irq = 0;
 	}
-- 
2.1.4
