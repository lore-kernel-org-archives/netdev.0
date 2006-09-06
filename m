From: fpavlic@de.ibm.com
Subject: [PATCH 8/9] s390: qeth driver fixes [5/6]
Date: Wed, 6 Sep 2006 17:06:13 +0200
Message-ID: <200609061706.13432.fpavlic@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev Mailinglist <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:897 "EHLO
	mtagate5.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751305AbWIFPFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 11:05:17 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k86F5FEi046230
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 15:05:15 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86F7MsO1638574
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:07:22 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86F5F4N021685
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:05:15 +0100
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 8/9] s390: qeth driver fixes [5/6]

From: Frank Pavlic <fpavlic@de.ibm.com>
 fix kernel panic in qdio queue handling.
 qeth_qdio_clear_card() could be invoked by 2 CPUs
 simultaneously (for example reboot event and recovery).

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/qeth.h      |    3 +-
 drivers/s390/net/qeth_main.c |   71 
+++++++++++++++++++++++++-----------------
 2 files changed, 44 insertions(+), 30 deletions(-)

146a24d1aeba1ad3b16e98a5553693ccc0799349
diff --git a/drivers/s390/net/qeth.h b/drivers/s390/net/qeth.h
index 22a7ffb..821383d 100644
--- a/drivers/s390/net/qeth.h
+++ b/drivers/s390/net/qeth.h
@@ -463,6 +463,7 @@ enum qeth_qdio_info_states {
  QETH_QDIO_UNINITIALIZED,
  QETH_QDIO_ALLOCATED,
  QETH_QDIO_ESTABLISHED,
+ QETH_QDIO_CLEANING
 };
 
 struct qeth_buffer_pool_entry {
@@ -537,7 +538,7 @@ struct qeth_qdio_out_q {
 } __attribute__ ((aligned(256)));
 
 struct qeth_qdio_info {
- volatile enum qeth_qdio_info_states state;
+ atomic_t state;
  /* input */
  struct qeth_qdio_q *in_q;
  struct qeth_qdio_buffer_pool in_buf_pool;
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 0bc55a3..a1b2e6f 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -3179,13 +3179,14 @@ qeth_alloc_qdio_buffers(struct qeth_card
 
  QETH_DBF_TEXT(setup, 2, "allcqdbf");
 
- if (card->qdio.state == QETH_QDIO_ALLOCATED)
+ if (atomic_cmpxchg(&card->qdio.state, QETH_QDIO_UNINITIALIZED,
+  QETH_QDIO_ALLOCATED) != QETH_QDIO_UNINITIALIZED)
   return 0;
 
  card->qdio.in_q = kmalloc(sizeof(struct qeth_qdio_q),
       GFP_KERNEL|GFP_DMA);
  if (!card->qdio.in_q)
-  return - ENOMEM;
+  goto out_nomem;
  QETH_DBF_TEXT(setup, 2, "inq");
  QETH_DBF_HEX(setup, 2, &card->qdio.in_q, sizeof(void *));
  memset(card->qdio.in_q, 0, sizeof(struct qeth_qdio_q));
@@ -3194,27 +3195,19 @@ qeth_alloc_qdio_buffers(struct qeth_card
   card->qdio.in_q->bufs[i].buffer =
    &card->qdio.in_q->qdio_bufs[i];
  /* inbound buffer pool */
- if (qeth_alloc_buffer_pool(card)){
-  kfree(card->qdio.in_q);
-  return -ENOMEM;
- }
+ if (qeth_alloc_buffer_pool(card))
+  goto out_freeinq;
  /* outbound */
  card->qdio.out_qs =
   kmalloc(card->qdio.no_out_queues *
    sizeof(struct qeth_qdio_out_q *), GFP_KERNEL);
- if (!card->qdio.out_qs){
-  qeth_free_buffer_pool(card);
-  return -ENOMEM;
- }
- for (i = 0; i < card->qdio.no_out_queues; ++i){
+ if (!card->qdio.out_qs)
+  goto out_freepool;
+ for (i = 0; i < card->qdio.no_out_queues; ++i) {
   card->qdio.out_qs[i] = kmalloc(sizeof(struct qeth_qdio_out_q),
             GFP_KERNEL|GFP_DMA);
-  if (!card->qdio.out_qs[i]){
-   while (i > 0)
-    kfree(card->qdio.out_qs[--i]);
-   kfree(card->qdio.out_qs);
-   return -ENOMEM;
-  }
+  if (!card->qdio.out_qs[i])
+   goto out_freeoutq;
   QETH_DBF_TEXT_(setup, 2, "outq %i", i);
   QETH_DBF_HEX(setup, 2, &card->qdio.out_qs[i], sizeof(void *));
   memset(card->qdio.out_qs[i], 0, sizeof(struct qeth_qdio_out_q));
@@ -3231,8 +3224,19 @@ qeth_alloc_qdio_buffers(struct qeth_card
    INIT_LIST_HEAD(&card->qdio.out_qs[i]->bufs[j].ctx_list);
   }
  }
- card->qdio.state = QETH_QDIO_ALLOCATED;
  return 0;
+
+out_freeoutq:
+ while (i > 0)
+  kfree(card->qdio.out_qs[--i]);
+ kfree(card->qdio.out_qs);
+out_freepool:
+ qeth_free_buffer_pool(card);
+out_freeinq:
+ kfree(card->qdio.in_q);
+out_nomem:
+ atomic_set(&card->qdio.state, QETH_QDIO_UNINITIALIZED);
+ return -ENOMEM;
 }
 
 static void
@@ -3241,7 +3245,8 @@ qeth_free_qdio_buffers(struct qeth_card 
  int i, j;
 
  QETH_DBF_TEXT(trace, 2, "freeqdbf");
- if (card->qdio.state == QETH_QDIO_UNINITIALIZED)
+ if (atomic_swap(&card->qdio.state, QETH_QDIO_UNINITIALIZED) ==
+  QETH_QDIO_UNINITIALIZED)
   return;
  kfree(card->qdio.in_q);
  /* inbound buffer pool */
@@ -3254,7 +3259,6 @@ qeth_free_qdio_buffers(struct qeth_card 
   kfree(card->qdio.out_qs[i]);
  }
  kfree(card->qdio.out_qs);
- card->qdio.state = QETH_QDIO_UNINITIALIZED;
 }
 
 static void
@@ -3276,7 +3280,7 @@ static void
 qeth_init_qdio_info(struct qeth_card *card)
 {
  QETH_DBF_TEXT(setup, 4, "intqdinf");
- card->qdio.state = QETH_QDIO_UNINITIALIZED;
+ atomic_set(&card->qdio.state, QETH_QDIO_UNINITIALIZED);
  /* inbound */
  card->qdio.in_buf_size = QETH_IN_BUF_SIZE_DEFAULT;
  card->qdio.init_pool.buf_count = QETH_IN_BUF_COUNT_DEFAULT;
@@ -3339,7 +3343,7 @@ qeth_qdio_establish(struct qeth_card *ca
  struct qdio_buffer **in_sbal_ptrs;
  struct qdio_buffer **out_sbal_ptrs;
  int i, j, k;
- int rc;
+ int rc = 0;
 
  QETH_DBF_TEXT(setup, 2, "qdioest");
 
@@ -3398,8 +3402,10 @@ qeth_qdio_establish(struct qeth_card *ca
  init_data.input_sbal_addr_array  = (void **) in_sbal_ptrs;
  init_data.output_sbal_addr_array = (void **) out_sbal_ptrs;
 
- if (!(rc = qdio_initialize(&init_data)))
-  card->qdio.state = QETH_QDIO_ESTABLISHED;
+ if (atomic_cmpxchg(&card->qdio.state, QETH_QDIO_ALLOCATED,
+  QETH_QDIO_ESTABLISHED) == QETH_QDIO_ALLOCATED)
+  if ((rc = qdio_initialize(&init_data)))
+   atomic_set(&card->qdio.state, QETH_QDIO_ALLOCATED);
 
  kfree(out_sbal_ptrs);
  kfree(in_sbal_ptrs);
@@ -3515,13 +3521,20 @@ qeth_qdio_clear_card(struct qeth_card *c
  int rc = 0;
 
  QETH_DBF_TEXT(trace,3,"qdioclr");
- if (card->qdio.state == QETH_QDIO_ESTABLISHED){
+ switch (atomic_cmpxchg(&card->qdio.state, QETH_QDIO_ESTABLISHED,
+  QETH_QDIO_CLEANING)) {
+ case QETH_QDIO_ESTABLISHED:
   if ((rc = qdio_cleanup(CARD_DDEV(card),
-        (card->info.type == QETH_CARD_TYPE_IQD) ?
-        QDIO_FLAG_CLEANUP_USING_HALT :
-        QDIO_FLAG_CLEANUP_USING_CLEAR)))
+    (card->info.type == QETH_CARD_TYPE_IQD) ?
+    QDIO_FLAG_CLEANUP_USING_HALT :
+    QDIO_FLAG_CLEANUP_USING_CLEAR)))
    QETH_DBF_TEXT_(trace, 3, "1err%d", rc);
-  card->qdio.state = QETH_QDIO_ALLOCATED;
+  atomic_set(&card->qdio.state, QETH_QDIO_ALLOCATED);
+  break;
+ case QETH_QDIO_CLEANING:
+  return rc;
+ default:
+  break;
  }
  if ((rc = qeth_clear_halt_card(card, use_halt)))
   QETH_DBF_TEXT_(trace, 3, "2err%d", rc);
-- 
1.2.4

