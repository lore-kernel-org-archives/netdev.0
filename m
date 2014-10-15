From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv3 RFC 3/4] sparc64: Avoid irqsave/restore on vio.lock if
 in_softirq()
Date: Wed, 15 Oct 2014 12:43:17 -0400
Message-ID: <20141015164317.GD11840@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44060 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbaJOQnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 12:43:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For NAPIfied drivers , there is no need to
synchronize by doing irqsave/restore on vio.lock in the I/O
path.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 arch/sparc/kernel/viohs.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/sparc/kernel/viohs.c b/arch/sparc/kernel/viohs.c
index 7ef081a..d731586 100644
--- a/arch/sparc/kernel/viohs.c
+++ b/arch/sparc/kernel/viohs.c
@@ -747,10 +747,11 @@ EXPORT_SYMBOL(vio_ldc_free);
 
 void vio_port_up(struct vio_driver_state *vio)
 {
-	unsigned long flags;
+	unsigned long flags = 0;
 	int err, state;
 
-	spin_lock_irqsave(&vio->lock, flags);
+	if (!in_softirq())
+		spin_lock_irqsave(&vio->lock, flags);
 
 	state = ldc_state(vio->lp);
 
@@ -777,7 +778,8 @@ void vio_port_up(struct vio_driver_state *vio)
 		mod_timer(&vio->timer, expires);
 	}
 
-	spin_unlock_irqrestore(&vio->lock, flags);
+	if (!in_softirq())
+		spin_unlock_irqrestore(&vio->lock, flags);
 }
 EXPORT_SYMBOL(vio_port_up);
 
-- 
1.8.4.2
