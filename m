From: frank.blaschka@de.ibm.com
Subject: [patch 3/3] qeth: Fix scatter-gather regression
Date: Tue, 19 Mar 2013 07:04:44 +0100
Message-ID: <20130319060454.971106494@de.ibm.com>
References: <20130319060441.956271217@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:43329 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932673Ab3CSGFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 02:05:00 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 19 Mar 2013 06:02:48 -0000
Content-Disposition: inline; filename=603-qeth-scatter-gather.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>

This patch fixes a scatter-gather regression introduced with

commit 5640f768 net: use a per task frag allocator

Now the qeth driver can cope with bigger framents and split a fragment in
sub framents if required.

Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |    1 
 drivers/s390/net/qeth_core_main.c |   45 ++++++++++++++++++++++++++++++++------
 drivers/s390/net/qeth_l3_main.c   |    4 ++-
 3 files changed, 42 insertions(+), 8 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -916,6 +916,7 @@ int qeth_send_control_data(struct qeth_c
 	void *reply_param);
 int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
 int qeth_get_elements_no(struct qeth_card *, void *, struct sk_buff *, int);
+int qeth_get_elements_for_frags(struct sk_buff *);
 int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
 			struct sk_buff *, struct qeth_hdr *, int, int, int);
 int qeth_do_send_packet(struct qeth_card *, struct qeth_qdio_out_q *,
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3679,6 +3679,25 @@ int qeth_get_priority_queue(struct qeth_
 }
 EXPORT_SYMBOL_GPL(qeth_get_priority_queue);
 
+int qeth_get_elements_for_frags(struct sk_buff *skb)
+{
+	int cnt, length, e, elements = 0;
+	struct skb_frag_struct *frag;
+	char *data;
+
+	for (cnt = 0; cnt < skb_shinfo(skb)->nr_frags; cnt++) {
+		frag = &skb_shinfo(skb)->frags[cnt];
+		data = (char *)page_to_phys(skb_frag_page(frag)) +
+			frag->page_offset;
+		length = frag->size;
+		e = PFN_UP((unsigned long)data + length - 1) -
+			PFN_DOWN((unsigned long)data);
+		elements += e;
+	}
+	return elements;
+}
+EXPORT_SYMBOL_GPL(qeth_get_elements_for_frags);
+
 int qeth_get_elements_no(struct qeth_card *card, void *hdr,
 		     struct sk_buff *skb, int elems)
 {
@@ -3686,7 +3705,8 @@ int qeth_get_elements_no(struct qeth_car
 	int elements_needed = PFN_UP((unsigned long)skb->data + dlen - 1) -
 		PFN_DOWN((unsigned long)skb->data);
 
-	elements_needed += skb_shinfo(skb)->nr_frags;
+	elements_needed += qeth_get_elements_for_frags(skb);
+
 	if ((elements_needed + elems) > QETH_MAX_BUFFER_ELEMENTS(card)) {
 		QETH_DBF_MESSAGE(2, "Invalid size of IP packet "
 			"(Number=%d / Length=%d). Discarded.\n",
@@ -3771,12 +3791,23 @@ static inline void __qeth_fill_buffer(st
 
 	for (cnt = 0; cnt < skb_shinfo(skb)->nr_frags; cnt++) {
 		frag = &skb_shinfo(skb)->frags[cnt];
-		buffer->element[element].addr = (char *)
-			page_to_phys(skb_frag_page(frag))
-			+ frag->page_offset;
-		buffer->element[element].length = frag->size;
-		buffer->element[element].eflags = SBAL_EFLAGS_MIDDLE_FRAG;
-		element++;
+		data = (char *)page_to_phys(skb_frag_page(frag)) +
+			frag->page_offset;
+		length = frag->size;
+		while (length > 0) {
+			length_here = PAGE_SIZE -
+				((unsigned long) data % PAGE_SIZE);
+			if (length < length_here)
+				length_here = length;
+
+			buffer->element[element].addr = data;
+			buffer->element[element].length = length_here;
+			buffer->element[element].eflags =
+				SBAL_EFLAGS_MIDDLE_FRAG;
+			length -= length_here;
+			data += length_here;
+			element++;
+		}
 	}
 
 	if (buffer->element[element - 1].eflags)
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2903,7 +2903,9 @@ static inline int qeth_l3_tso_elements(s
 		tcp_hdr(skb)->doff * 4;
 	int tcpd_len = skb->len - (tcpd - (unsigned long)skb->data);
 	int elements = PFN_UP(tcpd + tcpd_len - 1) - PFN_DOWN(tcpd);
-	elements += skb_shinfo(skb)->nr_frags;
+
+	elements += qeth_get_elements_for_frags(skb);
+
 	return elements;
 }
 
