From: frank.blaschka@de.ibm.com
Subject: [patch 10/13] [PATCH] qdio: support forced signal adapter indications
Date: Mon, 08 Aug 2011 13:33:56 +0200
Message-ID: <20110808113516.358415131@de.ibm.com>
References: <20110808113346.516293249@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Einar Lueck <elelueck@de.ibm.com>,
	Jan Glauber <jang@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:59894 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab1HHLfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 07:35:24 -0400
Content-Disposition: inline; filename=net1117_qdio_siga_r.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that signal adapter commands are issued if they are 
indicated to be required.

Signed-off-by: Einar Lueck <elelueck@de.ibm.com>
Signed-off-by: Jan Glauber <jang@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 arch/s390/include/asm/qdio.h |   10 ++++++++++
 drivers/s390/cio/qdio.h      |    9 ---------
 drivers/s390/cio/qdio_main.c |    5 +----
 3 files changed, 11 insertions(+), 13 deletions(-)

--- a/arch/s390/include/asm/qdio.h
+++ b/arch/s390/include/asm/qdio.h
@@ -279,6 +279,16 @@ struct qdio_outbuf_state {
 
 #define CHSC_AC1_INITIATE_INPUTQ	0x80
 
+
+/* qdio adapter-characteristics-1 flag */
+#define AC1_SIGA_INPUT_NEEDED		0x40	/* process input queues */
+#define AC1_SIGA_OUTPUT_NEEDED		0x20	/* process output queues */
+#define AC1_SIGA_SYNC_NEEDED		0x10	/* ask hypervisor to sync */
+#define AC1_AUTOMATIC_SYNC_ON_THININT	0x08	/* set by hypervisor */
+#define AC1_AUTOMATIC_SYNC_ON_OUT_PCI	0x04	/* set by hypervisor */
+#define AC1_SC_QEBSM_AVAILABLE		0x02	/* available for subchannel */
+#define AC1_SC_QEBSM_ENABLED		0x01	/* enabled for subchannel */
+
 #define CHSC_AC2_DATA_DIV_AVAILABLE	0x0010
 #define CHSC_AC2_DATA_DIV_ENABLED	0x0002
 
--- a/drivers/s390/cio/qdio.h
+++ b/drivers/s390/cio/qdio.h
@@ -87,15 +87,6 @@ enum qdio_irq_states {
 #define CHSC_FLAG_QDIO_CAPABILITY	0x80
 #define CHSC_FLAG_VALIDITY		0x40
 
-/* qdio adapter-characteristics-1 flag */
-#define AC1_SIGA_INPUT_NEEDED		0x40	/* process input queues */
-#define AC1_SIGA_OUTPUT_NEEDED		0x20	/* process output queues */
-#define AC1_SIGA_SYNC_NEEDED		0x10	/* ask hypervisor to sync */
-#define AC1_AUTOMATIC_SYNC_ON_THININT	0x08	/* set by hypervisor */
-#define AC1_AUTOMATIC_SYNC_ON_OUT_PCI	0x04	/* set by hypervisor */
-#define AC1_SC_QEBSM_AVAILABLE		0x02	/* available for subchannel */
-#define AC1_SC_QEBSM_ENABLED		0x01	/* enabled for subchannel */
-
 /* SIGA flags */
 #define QDIO_SIGA_WRITE		0x00
 #define QDIO_SIGA_READ		0x01
--- a/drivers/s390/cio/qdio_main.c
+++ b/drivers/s390/cio/qdio_main.c
@@ -1592,12 +1592,9 @@ set:
 	used = atomic_add_return(count, &q->nr_buf_used) - count;
 	BUG_ON(used + count > QDIO_MAX_BUFFERS_PER_Q);
 
-	/* no need to signal as long as the adapter had free buffers */
-	if (used)
-		return 0;
-
 	if (need_siga_in(q))
 		return qdio_siga_input(q);
+
 	return 0;
 }
 

