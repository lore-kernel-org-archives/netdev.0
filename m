From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v4 08/10] ss: symmetrical formatter extension example
Date: Sun, 30 Aug 2015 15:24:33 +0200
Message-ID: <1440941075-26478-9-git-send-email-matthias.tafelmeier@gmx.net>
References: <1440941075-26478-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:55761 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753419AbbH3NZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Aug 2015 09:25:11 -0400
In-Reply-To: <1440941075-26478-1-git-send-email-matthias.tafelmeier@gmx.net>
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
index 4046ebf..7b4eb7b 100644
--- a/misc/ss_hr_fmt.c
+++ b/misc/ss_hr_fmt.c
@@ -242,6 +242,66 @@ static void packet_show_ring_hr_fmt(struct packet_diag_ring *ring)
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
@@ -257,4 +317,5 @@ const struct fmt_op_hub hr_output_op = {
 	.opt_fmt = opt_hr_fmt,
 	.proc_fmt = proc_hr_fmt,
 	.packet_show_ring_fmt = packet_show_ring_hr_fmt,
+	.packet_details_fmt = packet_details_hr_fmt
 };
diff --git a/misc/ss_json_fmt.c b/misc/ss_json_fmt.c
index bf51a44..ae34875 100644
--- a/misc/ss_json_fmt.c
+++ b/misc/ss_json_fmt.c
@@ -375,6 +375,70 @@ static void packet_show_ring_json_fmt(struct packet_diag_ring *ring)
 	jsonw_hex_field(json_wr, "features_0x", ring->pdr_features);
 }
 
+static void packet_details_json_fmt(struct packet_diag_info *pinfo,
+		struct packet_diag_ring *ring_rx,
+		struct packet_diag_ring *ring_tx,
+		uint32_t fanout,
+		bool has_fanout)
+{
+	char tmp_out[16];
+
+	if (pinfo) {
+		jsonw_int_field(json_wr, "ver", pinfo->pdi_version);
+		jsonw_int_field(json_wr, "cpy_thresh", pinfo->pdi_copy_thresh);
+		if (pinfo->pdi_flags & PDI_RUNNING)
+			sprintf(tmp_out, "running");
+		if (pinfo->pdi_flags & PDI_AUXDATA)
+			sprintf(tmp_out, "_auxdata");
+		if (pinfo->pdi_flags & PDI_ORIGDEV)
+			sprintf(tmp_out, "_origdev");
+		if (pinfo->pdi_flags & PDI_VNETHDR)
+			sprintf(tmp_out, "_vnethdr");
+		if (pinfo->pdi_flags & PDI_LOSS)
+			sprintf(tmp_out, "_loss");
+		if (!pinfo->pdi_flags)
+			sprintf(tmp_out, "0");
+		jsonw_string_field(json_wr, "flags", tmp_out);
+	}
+	if (ring_rx) {
+		jsonw_name(json_wr, "ring_rx");
+		jsonw_start_object(json_wr);
+		packet_show_ring_fmt(ring_rx);
+		jsonw_end_object(json_wr);
+	}
+	if (ring_tx) {
+		jsonw_name(json_wr, "ring_tx");
+		jsonw_start_object(json_wr);
+		packet_show_ring_fmt(ring_tx);
+		jsonw_end_object(json_wr);
+	}
+	if (has_fanout) {
+		uint16_t type = (fanout >> 16) & 0xffff;
+
+		jsonw_name(json_wr, "fanout");
+		jsonw_start_object(json_wr);
+		jsonw_int_field(json_wr, "id", fanout & 0xffff);
+
+		if (type == 0)
+			sprintf(tmp_out, "hash");
+		else if (tmp_out, type == 1)
+			sprintf(tmp_out, "lb");
+		else if (tmp_out, type == 2)
+			sprintf(tmp_out, "cpu");
+		else if (tmp_out, type == 3)
+			sprintf(tmp_out, "roll");
+		else if (tmp_out, type == 4)
+			sprintf(tmp_out, "random");
+		else if (tmp_out, type == 5)
+			sprintf(tmp_out, "qm");
+		else
+			sprintf(tmp_out, "0x%x", type);
+
+		jsonw_string_field(json_wr, "type", tmp_out);
+		jsonw_end_object(json_wr);
+	}
+}
+
 const struct fmt_op_hub json_output_op = {
 	.tcp_stats_fmt = tcp_stats_json_fmt,
 	.tcp_timer_fmt = tcp_timer_json_fmt,
@@ -390,4 +454,5 @@ const struct fmt_op_hub json_output_op = {
 	.opt_fmt = opt_json_fmt,
 	.proc_fmt = proc_json_fmt,
 	.packet_show_ring_fmt = packet_show_ring_json_fmt,
+	.packet_details_fmt = packet_details_json_fmt
 };
diff --git a/misc/ss_out_fmt.c b/misc/ss_out_fmt.c
index 57bc24e..6d92201 100644
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
index fa29cec..c7a896b 100644
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
