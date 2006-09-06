From: fpavlic@de.ibm.com
Subject: [PATCH 7/9] s390: qeth driver fixes [4/6]
Date: Wed, 6 Sep 2006 17:06:04 +0200
Message-ID: <200609061706.04966.fpavlic@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev Mailinglist <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:64384 "EHLO
	mtagate5.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751294AbWIFPFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 11:05:13 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k86F5Blj166774
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 15:05:11 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86F7HP51650928
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:07:17 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86F5Aqt009643
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:05:11 +0100
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 7/9] s390: qeth driver fixes [4/6]

From: Frank Pavlic <fpavlic@de.ibm.com>
 - fix kernel crash due to race,
   set card->state to SOFTSETUP after
   card and card->dev are initialized properly.
 - remove CONFIG_QETH_PERF_STATS, use sysfs attribute instead,
   as we want to have the ability to turn on/off the
   statistics at runtime.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/Kconfig     |    9 ---
 drivers/s390/net/qeth.h      |   10 +--
 drivers/s390/net/qeth_eddp.c |    5 +
 drivers/s390/net/qeth_main.c |  147 
++++++++++++++++++++----------------------
 drivers/s390/net/qeth_proc.c |   23 +++----
 drivers/s390/net/qeth_sys.c  |   42 ++++++++++++
 6 files changed, 128 insertions(+), 108 deletions(-)

1068b773a870931ccec7009a320e37f7013b268f
diff --git a/drivers/s390/net/Kconfig b/drivers/s390/net/Kconfig
index 5488547..1a93fa6 100644
--- a/drivers/s390/net/Kconfig
+++ b/drivers/s390/net/Kconfig
@@ -92,15 +92,6 @@ config QETH_VLAN
    If CONFIG_QETH is switched on, this option will include IEEE
    802.1q VLAN support in the qeth device driver.
 
-config QETH_PERF_STATS
- bool "Performance statistics in /proc"
- depends on QETH
- help
-   When switched on, this option will add a file in the proc-fs
-   (/proc/qeth_perf_stats) containing performance statistics. It
-   may slightly impact performance, so this is only recommended for
-   internal tuning of the device driver.
-
 config CCWGROUP
   tristate
  default (LCS || CTC || QETH)
diff --git a/drivers/s390/net/qeth.h b/drivers/s390/net/qeth.h
index c04ee91..22a7ffb 100644
--- a/drivers/s390/net/qeth.h
+++ b/drivers/s390/net/qeth.h
@@ -176,7 +176,6 @@ extern struct ccwgroup_driver qeth_ccwgr
 /**
  * card stuff
  */
-#ifdef CONFIG_QETH_PERF_STATS
 struct qeth_perf_stats {
  unsigned int bufs_rec;
  unsigned int bufs_sent;
@@ -211,8 +210,10 @@ struct qeth_perf_stats {
  unsigned int large_send_cnt;
  unsigned int sg_skbs_sent;
  unsigned int sg_frags_sent;
+ /* initial values when measuring starts */
+ unsigned long initial_rx_packets;
+ unsigned long initial_tx_packets;
 };
-#endif /* CONFIG_QETH_PERF_STATS */
 
 /* Routing stuff */
 struct qeth_routing_info {
@@ -767,6 +768,7 @@ struct qeth_card_options {
  int fake_ll;
  int layer2;
  enum qeth_large_send_types large_send;
+ int performance_stats;
 };
 
 /*
@@ -819,9 +821,7 @@ struct qeth_card {
  struct list_head cmd_waiter_list;
  /* QDIO buffer handling */
  struct qeth_qdio_info qdio;
-#ifdef CONFIG_QETH_PERF_STATS
  struct qeth_perf_stats perf_stats;
-#endif /* CONFIG_QETH_PERF_STATS */
  int use_hard_stop;
  int (*orig_hard_header)(struct sk_buff *,struct net_device *,
     unsigned short,void *,void *,unsigned);
@@ -1049,13 +1049,11 @@ qeth_get_arphdr_type(int cardtype, int l
  }
 }
 
-#ifdef CONFIG_QETH_PERF_STATS
 static inline int
 qeth_get_micros(void)
 {
  return (int) (get_clock() >> 12);
 }
-#endif
 
 static inline int
 qeth_get_qdio_q_format(struct qeth_card *card)
diff --git a/drivers/s390/net/qeth_eddp.c b/drivers/s390/net/qeth_eddp.c
index 8491598..a363721 100644
--- a/drivers/s390/net/qeth_eddp.c
+++ b/drivers/s390/net/qeth_eddp.c
@@ -179,9 +179,8 @@ out_check:
    flush_cnt++;
   }
  } else {
-#ifdef CONFIG_QETH_PERF_STATS
-  queue->card->perf_stats.skbs_sent_pack++;
-#endif
+  if (queue->card->options.performance_stats)
+   queue->card->perf_stats.skbs_sent_pack++;
   QETH_DBF_TEXT(trace, 6, "fillbfpa");
   if (buf->next_element_to_fill >=
     QETH_MAX_BUFFER_ELEMENTS(queue->card)) {
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 522fb9d..0bc55a3 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -1073,6 +1073,7 @@ qeth_set_intial_options(struct qeth_card
   card->options.layer2 = 1;
  else
   card->options.layer2 = 0;
+ card->options.performance_stats = 1;
 }
 
 /**
@@ -2564,9 +2565,8 @@ qeth_process_inbound_buffer(struct qeth_
  /* get first element of current buffer */
  element = (struct qdio_buffer_element *)&buf->buffer->element[0];
  offset = 0;
-#ifdef CONFIG_QETH_PERF_STATS
- card->perf_stats.bufs_rec++;
-#endif
+ if (card->options.performance_stats)
+  card->perf_stats.bufs_rec++;
  while((skb = qeth_get_next_skb(card, buf->buffer, &element,
            &offset, &hdr))) {
   skb->dev = card->dev;
@@ -2623,7 +2623,7 @@ qeth_init_input_buffer(struct qeth_card 
 {
  struct qeth_buffer_pool_entry *pool_entry;
  int i;
-
+ 
  pool_entry = qeth_get_buffer_pool_entry(card);
  /*
   * since the buffer is accessed only from the input_tasklet
@@ -2697,17 +2697,18 @@ qeth_queue_input_buffer(struct qeth_card
    * 'index') un-requeued -> this buffer is the first buffer that
    * will be requeued the next time
    */
-#ifdef CONFIG_QETH_PERF_STATS
-  card->perf_stats.inbound_do_qdio_cnt++;
-  card->perf_stats.inbound_do_qdio_start_time = qeth_get_micros();
-#endif
+  if (card->options.performance_stats) {
+   card->perf_stats.inbound_do_qdio_cnt++;
+   card->perf_stats.inbound_do_qdio_start_time =
+    qeth_get_micros();
+  }
   rc = do_QDIO(CARD_DDEV(card),
         QDIO_FLAG_SYNC_INPUT | QDIO_FLAG_UNDER_INTERRUPT,
         0, queue->next_buf_to_init, count, NULL);
-#ifdef CONFIG_QETH_PERF_STATS
-  card->perf_stats.inbound_do_qdio_time += qeth_get_micros() -
-   card->perf_stats.inbound_do_qdio_start_time;
-#endif
+  if (card->options.performance_stats)
+   card->perf_stats.inbound_do_qdio_time +=
+    qeth_get_micros() -
+    card->perf_stats.inbound_do_qdio_start_time;
   if (rc){
    PRINT_WARN("qeth_queue_input_buffer's do_QDIO "
        "return %i (device %s).\n",
@@ -2743,10 +2744,10 @@ qeth_qdio_input_handler(struct ccw_devic
  QETH_DBF_TEXT(trace, 6, "qdinput");
  card = (struct qeth_card *) card_ptr;
  net_dev = card->dev;
-#ifdef CONFIG_QETH_PERF_STATS
- card->perf_stats.inbound_cnt++;
- card->perf_stats.inbound_start_time = qeth_get_micros();
-#endif
+ if (card->options.performance_stats) {
+  card->perf_stats.inbound_cnt++;
+  card->perf_stats.inbound_start_time = qeth_get_micros();
+ }
  if (status & QDIO_STATUS_LOOK_FOR_ERROR) {
   if (status & QDIO_STATUS_ACTIVATE_CHECK_CONDITION){
    QETH_DBF_TEXT(trace, 1,"qdinchk");
@@ -2768,10 +2769,9 @@ qeth_qdio_input_handler(struct ccw_devic
   qeth_put_buffer_pool_entry(card, buffer->pool_entry);
   qeth_queue_input_buffer(card, index);
  }
-#ifdef CONFIG_QETH_PERF_STATS
- card->perf_stats.inbound_time += qeth_get_micros() -
-  card->perf_stats.inbound_start_time;
-#endif
+ if (card->options.performance_stats)
+  card->perf_stats.inbound_time += qeth_get_micros() -
+   card->perf_stats.inbound_start_time;
 }
 
 static inline int
@@ -2861,10 +2861,11 @@ qeth_flush_buffers(struct qeth_qdio_out_
  }
 
  queue->card->dev->trans_start = jiffies;
-#ifdef CONFIG_QETH_PERF_STATS
- queue->card->perf_stats.outbound_do_qdio_cnt++;
- queue->card->perf_stats.outbound_do_qdio_start_time = qeth_get_micros();
-#endif
+ if (queue->card->options.performance_stats) {
+  queue->card->perf_stats.outbound_do_qdio_cnt++;
+  queue->card->perf_stats.outbound_do_qdio_start_time =
+   qeth_get_micros();
+ }
  if (under_int)
   rc = do_QDIO(CARD_DDEV(queue->card),
         QDIO_FLAG_SYNC_OUTPUT | QDIO_FLAG_UNDER_INTERRUPT,
@@ -2872,10 +2873,10 @@ qeth_flush_buffers(struct qeth_qdio_out_
  else
   rc = do_QDIO(CARD_DDEV(queue->card), QDIO_FLAG_SYNC_OUTPUT,
         queue->queue_no, index, count, NULL);
-#ifdef CONFIG_QETH_PERF_STATS
- queue->card->perf_stats.outbound_do_qdio_time += qeth_get_micros() -
-  queue->card->perf_stats.outbound_do_qdio_start_time;
-#endif
+ if (queue->card->options.performance_stats)
+  queue->card->perf_stats.outbound_do_qdio_time +=
+   qeth_get_micros() -
+   queue->card->perf_stats.outbound_do_qdio_start_time;
  if (rc){
   QETH_DBF_TEXT(trace, 2, "flushbuf");
   QETH_DBF_TEXT_(trace, 2, " err%d", rc);
@@ -2887,9 +2888,8 @@ qeth_flush_buffers(struct qeth_qdio_out_
   return;
  }
  atomic_add(count, &queue->used_buffers);
-#ifdef CONFIG_QETH_PERF_STATS
- queue->card->perf_stats.bufs_sent += count;
-#endif
+ if (queue->card->options.performance_stats)
+  queue->card->perf_stats.bufs_sent += count;
 }
 
 /*
@@ -2904,9 +2904,8 @@ qeth_switch_to_packing_if_needed(struct 
       >= QETH_HIGH_WATERMARK_PACK){
    /* switch non-PACKING -> PACKING */
    QETH_DBF_TEXT(trace, 6, "np->pack");
-#ifdef CONFIG_QETH_PERF_STATS
-   queue->card->perf_stats.sc_dp_p++;
-#endif
+   if (queue->card->options.performance_stats)
+    queue->card->perf_stats.sc_dp_p++;
    queue->do_pack = 1;
   }
  }
@@ -2929,9 +2928,8 @@ qeth_switch_to_nonpacking_if_needed(stru
       <= QETH_LOW_WATERMARK_PACK) {
    /* switch PACKING -> non-PACKING */
    QETH_DBF_TEXT(trace, 6, "pack->np");
-#ifdef CONFIG_QETH_PERF_STATS
-   queue->card->perf_stats.sc_p_dp++;
-#endif
+   if (queue->card->options.performance_stats)
+    queue->card->perf_stats.sc_p_dp++;
    queue->do_pack = 0;
    /* flush packing buffers */
    buffer = &queue->bufs[queue->next_buf_to_fill];
@@ -2943,7 +2941,7 @@ qeth_switch_to_nonpacking_if_needed(stru
     queue->next_buf_to_fill =
      (queue->next_buf_to_fill + 1) %
      QDIO_MAX_BUFFERS_PER_Q;
-    }
+   }
   }
  }
  return flush_count;
@@ -2999,11 +2997,10 @@ qeth_check_outbound_queue(struct qeth_qd
        !atomic_read(&queue->set_pci_flags_count))
     flush_cnt +=
      qeth_flush_buffers_on_no_pci(queue);
-#ifdef CONFIG_QETH_PERF_STATS
-   if (q_was_packing)
+   if (queue->card->options.performance_stats &&
+       q_was_packing)
     queue->card->perf_stats.bufs_sent_pack +=
      flush_cnt;
-#endif
    if (flush_cnt)
     qeth_flush_buffers(queue, 1, index, flush_cnt);
    atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
@@ -3033,10 +3030,11 @@ qeth_qdio_output_handler(struct ccw_devi
    return;
   }
  }
-#ifdef CONFIG_QETH_PERF_STATS
- card->perf_stats.outbound_handler_cnt++;
- card->perf_stats.outbound_handler_start_time = qeth_get_micros();
-#endif
+ if (card->options.performance_stats) {
+  card->perf_stats.outbound_handler_cnt++;
+  card->perf_stats.outbound_handler_start_time =
+   qeth_get_micros();
+ }
  for(i = first_element; i < (first_element + count); ++i){
   buffer = &queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q];
   /*we only handle the KICK_IT error by doing a recovery */
@@ -3055,10 +3053,9 @@ qeth_qdio_output_handler(struct ccw_devi
   qeth_check_outbound_queue(queue);
 
  netif_wake_queue(queue->card->dev);
-#ifdef CONFIG_QETH_PERF_STATS
- card->perf_stats.outbound_handler_time += qeth_get_micros() -
-  card->perf_stats.outbound_handler_start_time;
-#endif
+ if (card->options.performance_stats)
+  card->perf_stats.outbound_handler_time += qeth_get_micros() -
+   card->perf_stats.outbound_handler_start_time;
 }
 
 static void
@@ -3684,10 +3681,10 @@ qeth_hard_start_xmit(struct sk_buff *skb
   /* return OK; otherwise ksoftirqd goes to 100% */
   return NETDEV_TX_OK;
  }
-#ifdef CONFIG_QETH_PERF_STATS
- card->perf_stats.outbound_cnt++;
- card->perf_stats.outbound_start_time = qeth_get_micros();
-#endif
+ if (card->options.performance_stats) {
+  card->perf_stats.outbound_cnt++;
+  card->perf_stats.outbound_start_time = qeth_get_micros();
+ }
  netif_stop_queue(dev);
  if ((rc = qeth_send_packet(card, skb))) {
   if (rc == -EBUSY) {
@@ -3701,10 +3698,9 @@ qeth_hard_start_xmit(struct sk_buff *skb
   }
  }
  netif_wake_queue(dev);
-#ifdef CONFIG_QETH_PERF_STATS
- card->perf_stats.outbound_time += qeth_get_micros() -
-  card->perf_stats.outbound_start_time;
-#endif
+ if (card->options.performance_stats)
+  card->perf_stats.outbound_time += qeth_get_micros() -
+   card->perf_stats.outbound_start_time;
  return rc;
 }
 
@@ -4213,9 +4209,8 @@ qeth_fill_buffer(struct qeth_qdio_out_q 
   flush_cnt = 1;
  } else {
   QETH_DBF_TEXT(trace, 6, "fillbfpa");
-#ifdef CONFIG_QETH_PERF_STATS
-  queue->card->perf_stats.skbs_sent_pack++;
-#endif
+  if (queue->card->options.performance_stats)
+   queue->card->perf_stats.skbs_sent_pack++;
   if (buf->next_element_to_fill >=
     QETH_MAX_BUFFER_ELEMENTS(queue->card)) {
    /*
@@ -4380,10 +4375,8 @@ out:
    qeth_flush_buffers(queue, 0, start_index, flush_count);
  }
  /* at this point the queue is UNLOCKED again */
-#ifdef CONFIG_QETH_PERF_STATS
- if (do_pack)
+ if (queue->card->options.performance_stats && do_pack)
   queue->card->perf_stats.bufs_sent_pack += flush_count;
-#endif /* CONFIG_QETH_PERF_STATS */
 
  return rc;
 }
@@ -4420,10 +4413,8 @@ qeth_send_packet(struct qeth_card *card,
  enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
  struct qeth_eddp_context *ctx = NULL;
  int tx_bytes = skb->len;
-#ifdef CONFIG_QETH_PERF_STATS
  unsigned short nr_frags = skb_shinfo(skb)->nr_frags;
  unsigned short tso_size = skb_shinfo(skb)->gso_size;
-#endif
  struct sk_buff *new_skb, *new_skb2;
  int rc;
 
@@ -4505,19 +4496,19 @@ qeth_send_packet(struct qeth_card *card,
   card->stats.tx_bytes += tx_bytes;
   if (new_skb != skb)
    dev_kfree_skb_any(skb);
-#ifdef CONFIG_QETH_PERF_STATS
-  if (tso_size &&
-     !(large_send == QETH_LARGE_SEND_NO)) {
-   card->perf_stats.large_send_bytes += tx_bytes;
-   card->perf_stats.large_send_cnt++;
-  }
-  if (nr_frags > 0) {
-   card->perf_stats.sg_skbs_sent++;
-   /* nr_frags + skb->data */
-   card->perf_stats.sg_frags_sent +=
-    nr_frags + 1;
+  if (card->options.performance_stats) {
+   if (tso_size &&
+       !(large_send == QETH_LARGE_SEND_NO)) {
+    card->perf_stats.large_send_bytes += tx_bytes;
+    card->perf_stats.large_send_cnt++;
+   }
+   if (nr_frags > 0) {
+    card->perf_stats.sg_skbs_sent++;
+    /* nr_frags + skb->data */
+    card->perf_stats.sg_frags_sent +=
+     nr_frags + 1;
+   }
   }
-#endif /* CONFIG_QETH_PERF_STATS */
  } else {
   card->stats.tx_dropped++;
   __qeth_free_new_skb(skb, new_skb);
@@ -7878,12 +7869,12 @@ __qeth_set_online(struct ccwgroup_device
   QETH_DBF_TEXT_(setup, 2, "5err%d", rc);
   goto out_remove;
  }
- card->state = CARD_STATE_SOFTSETUP;
 
  if ((rc = qeth_init_qdio_queues(card))){
   QETH_DBF_TEXT_(setup, 2, "6err%d", rc);
   goto out_remove;
  }
+ card->state = CARD_STATE_SOFTSETUP;
  netif_carrier_on(card->dev);
 
  qeth_set_allowed_threads(card, 0xffffffff, 0);
diff --git a/drivers/s390/net/qeth_proc.c b/drivers/s390/net/qeth_proc.c
index 66f2da1..faa768e 100644
--- a/drivers/s390/net/qeth_proc.c
+++ b/drivers/s390/net/qeth_proc.c
@@ -173,7 +173,6 @@ static struct file_operations qeth_procf
 #define QETH_PERF_PROCFILE_NAME "qeth_perf"
 static struct proc_dir_entry *qeth_perf_procfile;
 
-#ifdef CONFIG_QETH_PERF_STATS
 static int
 qeth_perf_procfile_seq_show(struct seq_file *s, void *it)
 {
@@ -192,14 +191,21 @@ qeth_perf_procfile_seq_show(struct seq_f
    CARD_DDEV_ID(card),
    QETH_CARD_IFNAME(card)
     );
+ if (!card->options.performance_stats)
+  seq_printf(s, "Performance statistics are deactivated.\n");
  seq_printf(s, "  Skb's/buffers received                 : %lu/%u\n"
         "  Skb's/buffers sent                     : %lu/%u\n\n",
-          card->stats.rx_packets, card->perf_stats.bufs_rec,
-          card->stats.tx_packets, card->perf_stats.bufs_sent
+          card->stats.rx_packets -
+    card->perf_stats.initial_rx_packets,
+   card->perf_stats.bufs_rec,
+          card->stats.tx_packets -
+    card->perf_stats.initial_tx_packets,
+   card->perf_stats.bufs_sent
     );
  seq_printf(s, "  Skb's/buffers sent without packing     : %lu/%u\n"
         "  Skb's/buffers sent with packing        : %u/%u\n\n",
-     card->stats.tx_packets - card->perf_stats.skbs_sent_pack,
+     card->stats.tx_packets - card->perf_stats.initial_tx_packets
+       - card->perf_stats.skbs_sent_pack,
      card->perf_stats.bufs_sent - card->perf_stats.bufs_sent_pack,
      card->perf_stats.skbs_sent_pack,
      card->perf_stats.bufs_sent_pack
@@ -275,11 +281,6 @@ static struct file_operations qeth_perf_
  .release = seq_release,
 };
 
-#define qeth_perf_procfile_created qeth_perf_procfile
-#else
-#define qeth_perf_procfile_created 1
-#endif /* CONFIG_QETH_PERF_STATS */
-
 int __init
 qeth_create_procfs_entries(void)
 {
@@ -288,15 +289,13 @@ qeth_create_procfs_entries(void)
  if (qeth_procfile)
   qeth_procfile->proc_fops = &qeth_procfile_fops;
 
-#ifdef CONFIG_QETH_PERF_STATS
  qeth_perf_procfile = create_proc_entry(QETH_PERF_PROCFILE_NAME,
         S_IFREG | 0444, NULL);
  if (qeth_perf_procfile)
   qeth_perf_procfile->proc_fops = &qeth_perf_procfile_fops;
-#endif /* CONFIG_QETH_PERF_STATS */
 
  if (qeth_procfile &&
-     qeth_perf_procfile_created)
+     qeth_perf_procfile)
   return 0;
  else
   return -ENOMEM;
diff --git a/drivers/s390/net/qeth_sys.c b/drivers/s390/net/qeth_sys.c
index c1f3187..5836737 100644
--- a/drivers/s390/net/qeth_sys.c
+++ b/drivers/s390/net/qeth_sys.c
@@ -743,6 +743,47 @@ static DEVICE_ATTR(layer2, 0644, qeth_de
      qeth_dev_layer2_store);
 
 static ssize_t
+qeth_dev_performance_stats_show(struct device *dev, struct device_attribute 
*attr, char *buf)
+{
+ struct qeth_card *card = dev->driver_data;
+
+ if (!card)
+  return -EINVAL;
+
+ return sprintf(buf, "%i\n", card->options.performance_stats ? 1:0);
+}
+
+static ssize_t
+qeth_dev_performance_stats_store(struct device *dev, struct device_attribute 
*attr, const char *buf, size_t count)
+{
+ struct qeth_card *card = dev->driver_data;
+ char *tmp;
+ int i;
+
+ if (!card)
+  return -EINVAL;
+
+ i = simple_strtoul(buf, &tmp, 16);
+ if ((i == 0) || (i == 1)) {
+  if (i == card->options.performance_stats)
+   return count;
+  card->options.performance_stats = i;
+  if (i == 0)
+   memset(&card->perf_stats, 0,
+    sizeof(struct qeth_perf_stats));
+  card->perf_stats.initial_rx_packets = card->stats.rx_packets;
+  card->perf_stats.initial_tx_packets = card->stats.tx_packets;
+ } else {
+  PRINT_WARN("performance_stats: write 0 or 1 to this file!\n");
+  return -EINVAL;
+ }
+ return count;
+}
+
+static DEVICE_ATTR(performance_stats, 0644, qeth_dev_performance_stats_show,
+     qeth_dev_performance_stats_store);
+
+static ssize_t
 qeth_dev_large_send_show(struct device *dev, struct device_attribute *attr, 
char *buf)
 {
  struct qeth_card *card = dev->driver_data;
@@ -928,6 +969,7 @@ static struct device_attribute * qeth_de
  &dev_attr_canonical_macaddr,
  &dev_attr_layer2,
  &dev_attr_large_send,
+ &dev_attr_performance_stats,
  NULL,
 };
 
-- 
1.2.4

