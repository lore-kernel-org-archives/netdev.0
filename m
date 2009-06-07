From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/5] qlge: Fix bug in firmware event handler.
Date: Sun,  7 Jun 2009 16:58:26 -0700
Message-ID: <1244419109-355-3-git-send-email-ron.mercer@qlogic.com>
References: <1244419109-355-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:19996 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976AbZFHAGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 20:06:22 -0400
In-Reply-To: <1244419109-355-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each firmware mailbox command can have a different number of
valid data elements. When waiting for a mailbox command to
complete it the process passes it's element count and
waits for the completion.  It is possible that while waiting
an unrelated firmware async event (AE) can arrive.  When this
happens, the handler will over write the element count
with the value for the newly arrived AE. This can cause
the mailbox command to not get all of it's data.
This patch restores original mailbox count at the end
of the handler.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 7cb30fd..ff84243 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -453,6 +453,13 @@ static int ql_mpi_handler(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	}
 end:
 	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
+	/* Restore the original mailbox count to
+	 * what the caller asked for.  This can get
+	 * changed when a mailbox command is waiting
+	 * for a response and an AEN arrives and
+	 * is handled.
+	 * */
+	mbcp->out_count = orig_count;
 	return status;
 }
 
-- 
1.6.0.2

