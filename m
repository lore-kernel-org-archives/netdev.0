From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Show more info (ring,fanout) for packet socks
Date: Wed, 13 May 2015 12:39:26 +0300
Message-ID: <1431509966-5054-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:33215 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933372AbbEMJkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 05:40:07 -0400
Received: by wgin8 with SMTP id n8so37410169wgi.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 02:40:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Print such info like version, tx/rx ring, fanout for
packet sockets when '-e' option was specified.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
Would it be problematic for parsers as it uses '-e' option? Or
may be it would be better to use '-e -e' ?

 misc/ss.c | 81 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 79 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 870cad1..74797a8 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2834,13 +2834,27 @@ static int packet_stats_print(struct sockstat *s, const struct filter *f)
 	return 0;
 }
 
+static void packet_show_ring(struct packet_diag_ring *ring)
+{
+	printf("blk_size:%d", ring->pdr_block_size);
+	printf(",blk_nr:%d", ring->pdr_block_nr);
+	printf(",frm_size:%d", ring->pdr_frame_size);
+	printf(",frm_nr:%d", ring->pdr_frame_nr);
+	printf(",tmo:%d", ring->pdr_retire_tmo);
+	printf(",features:0x%x", ring->pdr_features);
+}
+
 static int packet_show_sock(const struct sockaddr_nl *addr,
 		struct nlmsghdr *nlh, void *arg)
 {
 	const struct filter *f = arg;
 	struct packet_diag_msg *r = NLMSG_DATA(nlh);
+	struct packet_diag_info *pinfo = NULL;
+	struct packet_diag_ring *ring_rx = NULL, *ring_tx = NULL;
 	struct rtattr *tb[PACKET_DIAG_MAX+1];
 	struct sockstat stat = {};
+	uint32_t fanout = 0;
+	bool has_fanout = false;
 
 	parse_rtattr(tb, PACKET_DIAG_MAX, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
@@ -2861,16 +2875,78 @@ static int packet_show_sock(const struct sockaddr_nl *addr,
 	}
 
 	if (tb[PACKET_DIAG_INFO]) {
-		struct packet_diag_info *pinfo = RTA_DATA(tb[PACKET_DIAG_INFO]);
+		pinfo = RTA_DATA(tb[PACKET_DIAG_INFO]);
 		stat.lport = stat.iface = pinfo->pdi_index;
 	}
 
 	if (tb[PACKET_DIAG_UID])
 		stat.uid = *(__u32 *)RTA_DATA(tb[PACKET_DIAG_UID]);
 
+	if (tb[PACKET_DIAG_RX_RING])
+		ring_rx = RTA_DATA(tb[PACKET_DIAG_RX_RING]);
+
+	if (tb[PACKET_DIAG_TX_RING])
+		ring_tx = RTA_DATA(tb[PACKET_DIAG_TX_RING]);
+
+	if (tb[PACKET_DIAG_FANOUT]) {
+		has_fanout = true;
+		fanout = *(uint32_t *)RTA_DATA(tb[PACKET_DIAG_FANOUT]);
+	}
+
 	if (packet_stats_print(&stat, f))
 		return 0;
 
+	if (show_details) {
+		if (pinfo) {
+			printf("\n\tver:%d", pinfo->pdi_version);
+			printf(" cpy_thresh:%d", pinfo->pdi_copy_thresh);
+			printf(" flags( ");
+			if (pinfo->pdi_flags & PDI_RUNNING)
+				printf("running");
+			if (pinfo->pdi_flags & PDI_AUXDATA)
+				printf(" auxdata");
+			if (pinfo->pdi_flags & PDI_ORIGDEV)
+				printf(" origdev");
+			if (pinfo->pdi_flags & PDI_VNETHDR)
+				printf(" vnethdr");
+			if (pinfo->pdi_flags & PDI_LOSS)
+				printf(" loss");
+			if (!pinfo->pdi_flags)
+				printf("0");
+			printf(" )");
+		}
+		if (ring_rx) {
+			printf("\n\tring_rx(");
+			packet_show_ring(ring_rx);
+			printf(")");
+		}
+		if (ring_tx) {
+			printf("\n\tring_tx(");
+			packet_show_ring(ring_tx);
+			printf(")");
+		}
+		if (has_fanout) {
+			uint16_t type = (fanout >> 16) & 0xffff;
+
+			printf("\n\tfanout(");
+			printf("id:%d,", fanout & 0xff);
+			printf("type:0x%x", type);
+			if (type == 0)
+				printf("(hash)");
+			else if (type == 1)
+				printf("(lb)");
+			else if (type == 2)
+				printf("(cpu)");
+			else if (type == 3)
+				printf("(rollover)");
+			else if (type == 4)
+				printf("(random)");
+			else if (type == 5)
+				printf("(qm)");
+			printf(")");
+		}
+	}
+
 	if (show_bpf && tb[PACKET_DIAG_FILTER]) {
 		struct sock_filter *fil =
 		       RTA_DATA(tb[PACKET_DIAG_FILTER]);
@@ -2894,7 +2970,8 @@ static int packet_show_netlink(struct filter *f)
 	DIAG_REQUEST(req, struct packet_diag_req r);
 
 	req.r.sdiag_family = AF_PACKET;
-	req.r.pdiag_show = PACKET_SHOW_INFO | PACKET_SHOW_MEMINFO | PACKET_SHOW_FILTER;
+	req.r.pdiag_show = PACKET_SHOW_INFO | PACKET_SHOW_MEMINFO |
+		PACKET_SHOW_FILTER | PACKET_SHOW_RING_CFG | PACKET_SHOW_FANOUT;
 
 	return handle_netlink_request(f, &req.nlh, sizeof(req), packet_show_sock);
 }
-- 
2.3.1
