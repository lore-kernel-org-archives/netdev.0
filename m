From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/5] qlge: Fix firmware event handler loop.
Date: Sun,  7 Jun 2009 16:58:25 -0700
Message-ID: <1244419109-355-2-git-send-email-ron.mercer@qlogic.com>
References: <1244419109-355-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:19996 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbZFHAGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 20:06:21 -0400
In-Reply-To: <1244419109-355-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check status on every iteration of event handler loop and exit
if an error occurred.  If an error occurred then recover process
will be queued so this loop should no continue.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 9f81b79..7cb30fd 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -831,13 +831,19 @@ void ql_mpi_work(struct work_struct *work)
 	    container_of(work, struct ql_adapter, mpi_work.work);
 	struct mbox_params mbc;
 	struct mbox_params *mbcp = &mbc;
+	int err = 0;
 
 	mutex_lock(&qdev->mpi_mutex);
 
 	while (ql_read32(qdev, STS) & STS_PI) {
 		memset(mbcp, 0, sizeof(struct mbox_params));
 		mbcp->out_count = 1;
-		ql_mpi_handler(qdev, mbcp);
+		/* Don't continue if an async event
+		 * did not complete properly.
+		 */
+		err = ql_mpi_handler(qdev, mbcp);
+		if (err)
+			break;
 	}
 
 	mutex_unlock(&qdev->mpi_mutex);
-- 
1.6.0.2

