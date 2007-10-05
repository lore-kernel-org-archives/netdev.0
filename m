From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Fri, 5 Oct 2007 14:20:08 -0400
Message-ID: <20071005182008.GA17519@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:34096 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754011AbXJESUK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 14:20:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

Auke Kok (2):
      e1000e: fix debugging printout code
      e1000e: Fix ethtool register test code

Frank Blaschka (1):
      qeth: EDDP does not work on large MTUs

Klaus D. Wacker (2):
      qeth: HiperSockets layer-3 interface drop non IPv4 or non IPv6 packets
      lcs: Channel errors drive lcs_recovery which leads to kernel panic.

Ursula Braun (2):
      qeth: avoid duplicate deletion of multicast addresses
      qeth: discard inbound packets with unknown header id

 drivers/net/e1000e/ethtool.c |   14 ++++++++++----
 drivers/net/e1000e/hw.h      |    2 +-
 drivers/net/e1000e/netdev.c  |    4 +---
 drivers/s390/net/lcs.c       |   11 ++++++++---
 drivers/s390/net/lcs.h       |    1 +
 drivers/s390/net/qeth_eddp.c |   16 +++++++++-------
 drivers/s390/net/qeth_main.c |   19 +++++++++++++------
 7 files changed, 43 insertions(+), 24 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 3423f33..2e8218f 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -784,10 +784,16 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	REG_SET_AND_CHECK(E1000_RCTL, before, 0x003FFFFB);
 	REG_SET_AND_CHECK(E1000_TCTL, 0xFFFFFFFF, 0x00000000);
 
-	REG_SET_AND_CHECK(E1000_RCTL, 0xFFFFFFFF, 0x01FFFFFF);
-	REG_PATTERN_TEST(E1000_RDBAL, 0xFFFFF000, 0xFFFFFFFF);
-	REG_PATTERN_TEST(E1000_TXCW, 0x0000FFFF, 0x0000FFFF);
-	REG_PATTERN_TEST(E1000_TDBAL, 0xFFFFF000, 0xFFFFFFFF);
+	REG_SET_AND_CHECK(E1000_RCTL, before, 0xFFFFFFFF);
+	REG_PATTERN_TEST(E1000_RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
+	if ((mac->type != e1000_ich8lan) &&
+	    (mac->type != e1000_ich9lan))
+		REG_PATTERN_TEST(E1000_TXCW, 0xC000FFFF, 0x0000FFFF);
+	REG_PATTERN_TEST(E1000_TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
+	REG_PATTERN_TEST(E1000_TIDV, 0x0000FFFF, 0x0000FFFF);
+	for (i = 0; i < mac->rar_entry_count; i++)
+		REG_PATTERN_TEST_ARRAY(E1000_RA, ((i << 1) + 1),
+				       0x8003FFFF, 0xFFFFFFFF);
 
 	for (i = 0; i < mac->mta_reg_count; i++)
 		REG_PATTERN_TEST_ARRAY(E1000_MTA, i, 0xFFFFFFFF, 0xFFFFFFFF);
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 848217a..aa82f1a 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -852,7 +852,7 @@ struct e1000_hw {
 
 #ifdef DEBUG
 #define hw_dbg(hw, format, arg...) \
-	printk(KERN_DEBUG, "%s: " format, e1000_get_hw_dev_name(hw), ##arg);
+	printk(KERN_DEBUG, "%s: " format, e1000e_get_hw_dev_name(hw), ##arg);
 #else
 static inline int __attribute__ ((format (printf, 2, 3)))
 hw_dbg(struct e1000_hw *hw, const char *format, ...)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4a21d7d..3a0bb2a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -66,9 +66,7 @@ static const struct e1000_info *e1000_info_tbl[] = {
  **/
 char *e1000e_get_hw_dev_name(struct e1000_hw *hw)
 {
-	struct e1000_adapter *adapter = hw->back;
-	struct net_device *netdev = adapter->netdev;
-	return netdev->name;
+	return hw->adapter->netdev->name;
 }
 #endif
 
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index e4b11af..0fd663b 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -1400,11 +1400,14 @@ lcs_irq(struct ccw_device *cdev, unsigned long intparm, struct irb *irb)
 		PRINT_WARN("check on device %s, dstat=0x%X, cstat=0x%X \n",
 			    cdev->dev.bus_id, dstat, cstat);
 		if (rc) {
-			lcs_schedule_recovery(card);
-			wake_up(&card->wait_q);
-			return;
+			channel->state = LCS_CH_STATE_ERROR;
 		}
 	}
+	if (channel->state == LCS_CH_STATE_ERROR) {
+		lcs_schedule_recovery(card);
+		wake_up(&card->wait_q);
+		return;
+	}
 	/* How far in the ccw chain have we processed? */
 	if ((channel->state != LCS_CH_STATE_INIT) &&
 	    (irb->scsw.fctl & SCSW_FCTL_START_FUNC)) {
@@ -1708,6 +1711,8 @@ lcs_stopcard(struct lcs_card *card)
 
 	if (card->read.state != LCS_CH_STATE_STOPPED &&
 	    card->write.state != LCS_CH_STATE_STOPPED &&
+	    card->read.state != LCS_CH_STATE_ERROR &&
+	    card->write.state != LCS_CH_STATE_ERROR &&
 	    card->state == DEV_STATE_UP) {
 		lcs_clear_multicast_list(card);
 		rc = lcs_send_stoplan(card,LCS_INITIATOR_TCPIP);
diff --git a/drivers/s390/net/lcs.h b/drivers/s390/net/lcs.h
index 0e1e4a0..8976fb0 100644
--- a/drivers/s390/net/lcs.h
+++ b/drivers/s390/net/lcs.h
@@ -138,6 +138,7 @@ enum lcs_channel_states {
 	LCS_CH_STATE_RUNNING,
 	LCS_CH_STATE_SUSPENDED,
 	LCS_CH_STATE_CLEARED,
+	LCS_CH_STATE_ERROR,
 };
 
 /**
diff --git a/drivers/s390/net/qeth_eddp.c b/drivers/s390/net/qeth_eddp.c
index 70108fb..e3c268c 100644
--- a/drivers/s390/net/qeth_eddp.c
+++ b/drivers/s390/net/qeth_eddp.c
@@ -159,13 +159,15 @@ qeth_eddp_fill_buffer(struct qeth_qdio_out_q *queue,
 		buffer = buf->buffer;
 		/* fill one skb into buffer */
 		for (i = 0; i < ctx->elements_per_skb; ++i){
-			buffer->element[buf->next_element_to_fill].addr =
-				ctx->elements[element].addr;
-			buffer->element[buf->next_element_to_fill].length =
-				ctx->elements[element].length;
-			buffer->element[buf->next_element_to_fill].flags =
-				ctx->elements[element].flags;
-			buf->next_element_to_fill++;
+			if (ctx->elements[element].length != 0) {
+				buffer->element[buf->next_element_to_fill].
+				addr = ctx->elements[element].addr;
+				buffer->element[buf->next_element_to_fill].
+				length = ctx->elements[element].length;
+				buffer->element[buf->next_element_to_fill].
+				flags = ctx->elements[element].flags;
+				buf->next_element_to_fill++;
+			}
 			element++;
 			elements--;
 		}
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 778ddfb..c67e7df 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -823,14 +823,15 @@ __qeth_delete_all_mc(struct qeth_card *card, unsigned long *flags)
 again:
 	list_for_each_entry_safe(addr, tmp, &card->ip_list, entry) {
 		if (addr->is_multicast) {
+			list_del(&addr->entry);
 			spin_unlock_irqrestore(&card->ip_lock, *flags);
 			rc = qeth_deregister_addr_entry(card, addr);
 			spin_lock_irqsave(&card->ip_lock, *flags);
 			if (!rc) {
-				list_del(&addr->entry);
 				kfree(addr);
 				goto again;
-			}
+			} else
+				list_add(&addr->entry, &card->ip_list);
 		}
 	}
 }
@@ -2701,10 +2702,15 @@ qeth_process_inbound_buffer(struct qeth_card *card,
 			qeth_layer2_rebuild_skb(card, skb, hdr);
 		else if (hdr->hdr.l3.id == QETH_HEADER_TYPE_LAYER3)
 			vlan_tag = qeth_rebuild_skb(card, skb, hdr);
-		else { /*in case of OSN*/
+		else if (hdr->hdr.osn.id == QETH_HEADER_TYPE_OSN) {
 			skb_push(skb, sizeof(struct qeth_hdr));
 			skb_copy_to_linear_data(skb, hdr,
 						sizeof(struct qeth_hdr));
+		} else { /* unknown header type */
+			dev_kfree_skb_any(skb);
+			QETH_DBF_TEXT(trace, 3, "inbunkno");
+			QETH_DBF_HEX(control, 3, hdr, QETH_DBF_CONTROL_LEN);
+			continue;
 		}
 		/* is device UP ? */
 		if (!(card->dev->flags & IFF_UP)){
@@ -4508,7 +4514,8 @@ qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 			/* check if we have enough elements (including following
 			 * free buffers) to handle eddp context */
 			if (qeth_eddp_check_buffers_for_context(queue,ctx) < 0){
-				printk("eddp tx_dropped 1\n");
+				if (net_ratelimit())
+					PRINT_WARN("eddp tx_dropped 1\n");
 				rc = -EBUSY;
 				goto out;
 			}
@@ -4719,8 +4726,8 @@ qeth_send_packet(struct qeth_card *card, struct sk_buff *skb)
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
 					 elements_needed, ctx);
 	else {
-		if ((skb->protocol == htons(ETH_P_ARP)) &&
-		    (card->dev->flags & IFF_NOARP)) {
+		if ((!card->options.layer2) &&
+		    (ipv == 0)) {
 			__qeth_free_new_skb(skb, new_skb);
 			return -EPERM;
 		}
