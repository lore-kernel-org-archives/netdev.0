From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v3 08/10] ss: symmetrical formatter extension example
Date: Thu, 20 Aug 2015 22:40:19 +0200
Message-ID: <1440103221-21854-9-git-send-email-matthias.tafelmeier@gmx.net>
References: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:54154 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150AbbHTUkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 16:40:33 -0400
In-Reply-To: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit shall show shortly where to place changes when one wants to
extend an ss output formatter with a new handler (format print
procedure). The extension is done symmetrically. That means, every up to
now existing formatter is extended with a semantically equivalent
handler (hr and json formatter).

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/ss_hr_fmt.c   | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++
 misc/ss_json_fmt.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 misc/ss_out_fmt.c  | 10 +++++++++
 misc/ss_out_fmt.h  | 10 +++++++++
 4 files changed, 146 insertions(+)

diff --git a/misc/ss_hr_fmt.c b/misc/ss_hr_fmt.c
index 6955ea5..2051ff2 100644
--- a/misc/ss_hr_fmt.c
+++ b/misc/ss_hr_fmt.c
@@ -240,6 +240,66 @@ static void packet_show_ring_hr_fmt(struct packet_diag_ring *ring)
 	printf(",features:0x%x", ring->pdr_features);
 }
 
+static void packet_details_hr_fmt(struct packet_diag_info *pinfo,
+		struct packet_diag_ring *ring_rx,
+		struct packet_diag_ring *ring_tx,
+		uint32_t fanout,
+		bool has_fanout)
+{
+	if (pinfo) {
+		printf("\n\tver:%d", pinfo->pdi_version);
+		printf(" cpy_thresh:%d", pinfo->pdi_copy_thresh);
+		printf(" flags( ");
+		if (pinfo->pdi_flags & PDI_RUNNING)
+			printf("running");
+		if (pinfo->pdi_flags & PDI_AUXDATA)
+			printf(" auxdata");
+		if (pinfo->pdi_flags & PDI_ORIGDEV)
+			printf(" origdev");
+		if (pinfo->pdi_flags & PDI_VNETHDR)
+			printf(" vnethdr");
+		if (pinfo->pdi_flags & PDI_LOSS)
+			printf(" loss");
+		if (!pinfo->pdi_flags)
+			printf("0");
+		printf(" )");
+	}
+	if (ring_rx) {
+		printf("\n\tring_rx(");
+		packet_show_ring_fmt(ring_rx);
+		printf(")");
+	}
+	if (ring_tx) {
+		printf("\n\tring_tx(");
+		packet_show_ring_fmt(ring_tx);
+		printf(")");
+	}
+	if (has_fanout) {
+		uint16_t type = (fanout >> 16) & 0xffff;
+
+		printf("\n\tfanout(");
+		printf("id:%d,", fanout & 0xffff);
+		printf("type:");
+
+		if (type == 0)
+			printf("hash");
+		else if (type == 1)
+			printf("lb");
+		else if (type == 2)
+			printf("cpu");
+		else if (type == 3)
+			printf("roll");
+		else if (type == 4)
+			printf("random");
+		else if (type == 5)
+			printf("qm");
+		else
+			printf("0x%x", type);
+
+		printf(")");
+	}
+}
+
 const struct fmt_op_hub hr_output_op = {
 	.tcp_stats_fmt = tcp_stats_hr_fmt,
 	.tcp_timer_fmt = tcp_timer_hr_fmt,
@@ -255,4 +315,5 @@ const struct fmt_op_hub hr_output_op = {
 	.opt_fmt = opt_hr_fmt,
 	.proc_fmt = proc_hr_fmt,
 	.packet_show_ring_fmt = packet_show_ring_hr_fmt,
+	.packet_details_fmt = packet_details_hr_fmt
 };
diff --git a/misc/ss_json_fmt.c b/misc/ss_json_fmt.c
index d7dfce9..3d10220 100644
--- a/misc/ss_json_fmt.c
+++ b/misc/ss_json_fmt.c
@@ -355,6 +355,70 @@ static void packet_show_ring_json_fmt(struct packet_diag_ring *ring)
 	printf("\"features_0x\" : \"%x\"\n", ring->pdr_features);
 }
 
+static void packet_details_json_fmt(struct packet_diag_info *pinfo,
+		struct packet_diag_ring *ring_rx,
+		struct packet_diag_ring *ring_tx,
+		uint32_t fanout,
+		bool has_fanout)
+{
+	printf(",\n");
+	if (pinfo) {
+		printf("\t\"ver\": \"%d\",\n", pinfo->pdi_version);
+		printf("\t\"cpy_thresh\": \"%d\",\n", pinfo->pdi_copy_thresh);
+		printf("\t\"flags\": \"");
+		if (pinfo->pdi_flags & PDI_RUNNING)
+			printf("running");
+		if (pinfo->pdi_flags & PDI_AUXDATA)
+			printf("_auxdata");
+		if (pinfo->pdi_flags & PDI_ORIGDEV)
+			printf("_origdev");
+		if (pinfo->pdi_flags & PDI_VNETHDR)
+			printf("_vnethdr");
+		if (pinfo->pdi_flags & PDI_LOSS)
+			printf("_loss");
+		if (!pinfo->pdi_flags)
+			printf("0");
+		printf("\"");
+		res_json_fmt_branch(ring_rx || ring_tx || has_fanout, ' ');
+	}
+	if (ring_rx) {
+		printf("\t\"ring_rx\": {");
+		packet_show_ring_fmt(ring_rx);
+		printf("}");
+		res_json_fmt_branch(ring_tx || has_fanout, ' ');
+	}
+	if (ring_tx) {
+		printf("\t\"ring_tx\": {");
+		packet_show_ring_fmt(ring_tx);
+		printf("}");
+		res_json_fmt_branch(has_fanout, ' ');
+	}
+	if (has_fanout) {
+		uint16_t type = (fanout >> 16) & 0xffff;
+
+		printf("\t\"fanout\": \"");
+		printf("id:%d,", fanout & 0xffff);
+		printf("type:");
+
+		if (type == 0)
+			printf("hash");
+		else if (type == 1)
+			printf("lb");
+		else if (type == 2)
+			printf("cpu");
+		else if (type == 3)
+			printf("roll");
+		else if (type == 4)
+			printf("random");
+		else if (type == 5)
+			printf("qm");
+		else
+			printf("0x%x", type);
+
+		printf("\"");
+	}
+}
+
 const struct fmt_op_hub json_output_op = {
 	.tcp_stats_fmt = tcp_stats_json_fmt,
 	.tcp_timer_fmt = tcp_timer_json_fmt,
@@ -370,4 +434,5 @@ const struct fmt_op_hub json_output_op = {
 	.opt_fmt = opt_json_fmt,
 	.proc_fmt = proc_json_fmt,
 	.packet_show_ring_fmt = packet_show_ring_json_fmt,
+	.packet_details_fmt = packet_details_json_fmt
 };
diff --git a/misc/ss_out_fmt.c b/misc/ss_out_fmt.c
index e17d898..3a0eb12 100644
--- a/misc/ss_out_fmt.c
+++ b/misc/ss_out_fmt.c
@@ -125,3 +125,13 @@ void packet_show_ring_fmt(struct packet_diag_ring *ring)
 {
 	fmt_op_hub[fmt_type]->packet_show_ring_fmt(ring);
 }
+void packet_details_fmt(struct packet_diag_info *pinfo,
+		struct packet_diag_ring *ring_rx,
+		struct packet_diag_ring *ring_tx,
+		uint32_t fanout,
+		bool has_fanout)
+{
+	fmt_op_hub[fmt_type]->packet_details_fmt(pinfo,
+			ring_rx, ring_tx, fanout, has_fanout);
+}
+
diff --git a/misc/ss_out_fmt.h b/misc/ss_out_fmt.h
index b74f668..9443d44 100644
--- a/misc/ss_out_fmt.h
+++ b/misc/ss_out_fmt.h
@@ -54,6 +54,11 @@ struct fmt_op_hub {
 	void (*opt_fmt)(char *opt);
 	void (*proc_fmt)(int serv_width, char *pid_ctx);
 	void (*packet_show_ring_fmt)(struct packet_diag_ring *ring);
+	void (*packet_details_fmt)(struct packet_diag_info *pinfo,
+		struct packet_diag_ring *ring_rx,
+		struct packet_diag_ring *ring_tx,
+		uint32_t fanout,
+		bool has_fanout);
 };
 
 void tcp_stats_fmt(struct tcpstat *s);
@@ -74,6 +79,11 @@ void bpf_filter_fmt(struct sock_filter *f, int num);
 void opt_fmt(char *opt);
 void proc_fmt(int serv_width, char *pid_ctx);
 void packet_show_ring_fmt(struct packet_diag_ring *ring);
+void packet_details_fmt(struct packet_diag_info *pinfo,
+		struct packet_diag_ring *ring_rx,
+		struct packet_diag_ring *ring_tx,
+		uint32_t fanout,
+		bool has_fanout);
 
 /*unisonly utilized formatting parts*/
 char *sprint_bw(char *buf, double bw);
-- 
1.9.1
