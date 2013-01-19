From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 13/21] NTB: Out of free receive entries issue
Date: Sat, 19 Jan 2013 02:02:27 -0700
Message-ID: <1358586155-23322-14-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the NTB client driver enqueues the maximum number of rx buffers, it
will not be able to re-enqueue another in its callback handler due to a
lack of free entries.  This can be avoided by adding the current entry
to the free queue prior to calling the client callback handler.  With
this change, ntb_netdev will no longer encounter a rx error on its first
packet.

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/ntb/ntb_transport.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/ntb/ntb_transport.c b/drivers/ntb/ntb_transport.c
index 69c58da..b3afb24 100644
--- a/drivers/ntb/ntb_transport.c
+++ b/drivers/ntb/ntb_transport.c
@@ -910,12 +910,15 @@ void ntb_transport_free(void *transport)
 static void ntb_rx_copy_task(struct ntb_transport_qp *qp,
 			     struct ntb_queue_entry *entry, void *offset)
 {
-	memcpy(entry->buf, offset, entry->len);
+	void *cb_data = entry->cb_data;
+	unsigned int len = entry->len;
 
-	if (qp->rx_handler && qp->client_ready == NTB_LINK_UP)
-		qp->rx_handler(qp, qp->cb_data, entry->cb_data, entry->len);
+	memcpy(entry->buf, offset, entry->len);
 
 	ntb_list_add(&qp->ntb_rx_free_q_lock, &entry->entry, &qp->rx_free_q);
+
+	if (qp->rx_handler && qp->client_ready == NTB_LINK_UP)
+		qp->rx_handler(qp, qp->cb_data, cb_data, len);
 }
 
 static int ntb_process_rxc(struct ntb_transport_qp *qp)
-- 
1.7.9.5
