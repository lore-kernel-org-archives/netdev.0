From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/4] s390/qeth: fix packing buffer statistics
Date: Mon, 19 Jun 2017 13:22:23 +0200
Message-ID: <20170619112225.30471-3-jwi@linux.vnet.ibm.com>
References: <20170619112225.30471-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:58785 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753894AbdFSLWn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 07:22:43 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5JBKPjT138460
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 07:22:42 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b6chcc0r9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 07:22:42 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 19 Jun 2017 12:22:39 +0100
In-Reply-To: <20170619112225.30471-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's two spots in qeth_send_packet() where we don't accurately
account for transmitted packing buffers in qeth's performance
statistics:

1) when flushing the current buffer due to insufficient size,
   and the next buffer is not EMPTY, we need to account for that
   flushed buffer.
2) when synchronizing with the TX completion code, we reset
   flush_count and thus forget to account for any previously
   flushed buffers.

Reported-by: Nils Hoppmann <niho@de.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 08338f27c82c..13a55f1dee7a 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4103,7 +4103,8 @@ int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 							   flush_count);
 				atomic_set(&queue->state,
 						QETH_OUT_Q_UNLOCKED);
-				return -EBUSY;
+				rc = -EBUSY;
+				goto out;
 			}
 		}
 	}
@@ -4122,19 +4123,21 @@ int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 	 * In that case we will enter this loop
 	 */
 	while (atomic_dec_return(&queue->state)) {
-		flush_count = 0;
 		start_index = queue->next_buf_to_fill;
 		/* check if we can go back to non-packing state */
-		flush_count += qeth_switch_to_nonpacking_if_needed(queue);
+		tmp = qeth_switch_to_nonpacking_if_needed(queue);
 		/*
 		 * check if we need to flush a packing buffer to get a pci
 		 * flag out on the queue
 		 */
-		if (!flush_count && !atomic_read(&queue->set_pci_flags_count))
-			flush_count += qeth_prep_flush_pack_buffer(queue);
-		if (flush_count)
-			qeth_flush_buffers(queue, start_index, flush_count);
+		if (!tmp && !atomic_read(&queue->set_pci_flags_count))
+			tmp = qeth_prep_flush_pack_buffer(queue);
+		if (tmp) {
+			qeth_flush_buffers(queue, start_index, tmp);
+			flush_count += tmp;
+		}
 	}
+out:
 	/* at this point the queue is UNLOCKED again */
 	if (queue->card->options.performance_stats && do_pack)
 		queue->card->perf_stats.bufs_sent_pack += flush_count;
-- 
2.11.2
