From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 1/5] s390: fix connection hang in qeth
Date: Mon, 30 Apr 2007 17:41:20 +0200
Message-ID: <20070430154120.GA23666@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:59306 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423408AbXD3Pmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 11:42:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>
      Frank Pavlic <fpavlic@de.ibm.com>
      
Connection hangs when using EDDP mode because sk is NULL
when skb has been copied via skb_copy. This results in dropping 
packets.
Also keep MAC address after recovery of Virtual NICs so that
traffic can flow again and duplicate statements in 
qeth_dev_set_route_store removed.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 qeth_eddp.c |    4 ++--
 qeth_eddp.h |    3 ++-
 qeth_main.c |    5 +++--
 qeth_sys.c  |    2 --
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/s390/net/qeth_eddp.c b/drivers/s390/net/qeth_eddp.c
index dd7034f..4640f32 100644
--- a/drivers/s390/net/qeth_eddp.c
+++ b/drivers/s390/net/qeth_eddp.c
@@ -620,10 +620,10 @@ qeth_eddp_create_context_tcp(struct qeth_card *card, struct sk_buff *skb,
 
 struct qeth_eddp_context *
 qeth_eddp_create_context(struct qeth_card *card, struct sk_buff *skb,
-			 struct qeth_hdr *qhdr)
+			 struct qeth_hdr *qhdr, unsigned char sk_protocol)
 {
 	QETH_DBF_TEXT(trace, 5, "creddpc");
-	switch (skb->sk->sk_protocol){
+	switch (sk_protocol) {
 	case IPPROTO_TCP:
 		return qeth_eddp_create_context_tcp(card, skb, qhdr);
 	default:
diff --git a/drivers/s390/net/qeth_eddp.h b/drivers/s390/net/qeth_eddp.h
index 103768d..52910c9 100644
--- a/drivers/s390/net/qeth_eddp.h
+++ b/drivers/s390/net/qeth_eddp.h
@@ -34,7 +34,8 @@ struct qeth_eddp_context_reference {
 };
 
 extern struct qeth_eddp_context *
-qeth_eddp_create_context(struct qeth_card *,struct sk_buff *,struct qeth_hdr *);
+qeth_eddp_create_context(struct qeth_card *,struct sk_buff *,
+			 struct qeth_hdr *, unsigned char);
 
 extern void
 qeth_eddp_put_context(struct qeth_eddp_context *);
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index ad7792d..54839fa 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -4423,7 +4423,8 @@ qeth_send_packet(struct qeth_card *card, struct sk_buff *skb)
 		qeth_fill_header(card, hdr, new_skb, ipv, cast_type);
 	}
 	if (large_send == QETH_LARGE_SEND_EDDP) {
-		ctx = qeth_eddp_create_context(card, new_skb, hdr);
+		ctx = qeth_eddp_create_context(card, new_skb, hdr,
+					       skb->sk->sk_protocol);
 		if (ctx == NULL) {
 			__qeth_free_new_skb(skb, new_skb);
 			PRINT_WARN("could not create eddp context\n");
@@ -6584,7 +6585,7 @@ qeth_setadpparms_change_macaddr_cb(struct qeth_card *card,
 	QETH_DBF_TEXT(trace,4,"chgmaccb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
-	if (!card->options.layer2 || card->info.guestlan ||
+	if (!card->options.layer2 ||
 	    !(card->info.mac_bits & QETH_LAYER2_MAC_READ)) {
 		memcpy(card->dev->dev_addr,
 		       &cmd->data.setadapterparms.data.change_addr.addr,
diff --git a/drivers/s390/net/qeth_sys.c b/drivers/s390/net/qeth_sys.c
index d518419..65ffc21 100644
--- a/drivers/s390/net/qeth_sys.c
+++ b/drivers/s390/net/qeth_sys.c
@@ -384,8 +384,6 @@ qeth_dev_route_store(struct qeth_card *card, struct qeth_routing_info *route,
 		route->type = PRIMARY_CONNECTOR;
 	} else if (!strcmp(tmp, "secondary_connector")) {
 		route->type = SECONDARY_CONNECTOR;
-	} else if (!strcmp(tmp, "multicast_router")) {
-		route->type = MULTICAST_ROUTER;
 	} else if (!strcmp(tmp, "primary_router")) {
 		route->type = PRIMARY_ROUTER;
 	} else if (!strcmp(tmp, "secondary_router")) {
-- 
1.5.1.2

