From: Shanker Wang <miao.wang@tuna.tsinghua.edu.cn>
Subject: [PATCH] iproute2: ip: add udp_csum, udp6_csum_tx, udp6_csum_rx control flags to ip l2tp add tunnel
Date: Thu, 21 Jul 2016 18:59:10 +0800
Message-ID: <F9EDF03C-EBC6-468D-A917-ED5CF232C203@tuna.tsinghua.edu.cn>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org,
	=?gb2312?B?zfXl4w==?= <shankerwangmiao@gmail.com>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35238 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbcGUK7R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 06:59:17 -0400
Received: by mail-pf0-f194.google.com with SMTP id h186so5284894pfg.2
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 03:59:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three options are added for the user to control
whether the checksum is enabled

Signed-off-by: Miao Wang <miao.wang@tuna.tsinghua.edu.cn>
---
 ip/ipl2tp.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 1f84c61..9ebda13 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -56,6 +56,8 @@ struct l2tp_parm {
 
 	uint16_t pw_type;
 	uint16_t mtu;
+	int udp6_csum_tx:1;
+	int udp6_csum_rx:1;
 	int udp_csum:1;
 	int recv_seq:1;
 	int send_seq:1;
@@ -117,6 +119,12 @@ static int create_tunnel(struct l2tp_parm *p)
 	if (p->encap == L2TP_ENCAPTYPE_UDP) {
 		addattr16(&req.n, 1024, L2TP_ATTR_UDP_SPORT, p->local_udp_port);
 		addattr16(&req.n, 1024, L2TP_ATTR_UDP_DPORT, p->peer_udp_port);
+		if (p->udp_csum)
+			addattr(&req.n, 1024, L2TP_ATTR_UDP_CSUM);
+		if (!p->udp6_csum_tx)
+			addattr(&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_TX);
+		if (!p->udp6_csum_rx)
+			addattr(&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_RX);
 	}
 
 	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
@@ -282,6 +290,12 @@ static int get_response(struct nlmsghdr *n, void *arg)
 		p->l2spec_len = rta_getattr_u8(attrs[L2TP_ATTR_L2SPEC_LEN]);
 
 	p->udp_csum = !!attrs[L2TP_ATTR_UDP_CSUM];
+	/*
+	 * Not fetching from L2TP_ATTR_UDP_ZERO_CSUM6_{T,R}X because the
+	 * kernel doesn't send it so just leave it as default value.
+	 */
+	p->udp6_csum_tx = 1;
+	p->udp6_csum_rx = 1;
 	if (attrs[L2TP_ATTR_COOKIE])
 		memcpy(p->cookie, RTA_DATA(attrs[L2TP_ATTR_COOKIE]),
 		       p->cookie_len = RTA_PAYLOAD(attrs[L2TP_ATTR_COOKIE]));
@@ -459,6 +473,9 @@ static void usage(void)
 	fprintf(stderr, "          tunnel_id ID peer_tunnel_id ID\n");
 	fprintf(stderr, "          [ encap { ip | udp } ]\n");
 	fprintf(stderr, "          [ udp_sport PORT ] [ udp_dport PORT ]\n");
+	fprintf(stderr, "          [ udp_csum { on | off } ]\n");
+	fprintf(stderr, "          [ udp6_csum_tx { on | off } ]\n");
+	fprintf(stderr, "          [ udp6_csum_rx { on | off } ]\n");
 	fprintf(stderr, "Usage: ip l2tp add session [ name NAME ]\n");
 	fprintf(stderr, "          tunnel_id ID\n");
 	fprintf(stderr, "          session_id ID peer_session_id ID\n");
@@ -489,6 +506,8 @@ static int parse_args(int argc, char **argv, int cmd, struct l2tp_parm *p)
 	/* Defaults */
 	p->l2spec_type = L2TP_L2SPECTYPE_DEFAULT;
 	p->l2spec_len = 4;
+	p->udp6_csum_rx = 1;
+	p->udp6_csum_tx = 1;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "encap") == 0) {
@@ -558,6 +577,32 @@ static int parse_args(int argc, char **argv, int cmd, struct l2tp_parm *p)
 			if (get_u16(&uval, *argv, 0))
 				invarg("invalid port\n", *argv);
 			p->peer_udp_port = uval;
+		} else if (strcmp(*argv, "udp_csum") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "on") == 0)
+				p->udp_csum = 1;
+			else if (strcmp(*argv, "off") == 0)
+				p->udp_csum = 0;
+			else
+				invarg("invalid option for udp_csum\n", *argv);
+		} else if (strcmp(*argv, "udp6_csum_rx") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "on") == 0)
+				p->udp6_csum_rx = 1;
+			else if (strcmp(*argv, "off") == 0)
+				p->udp6_csum_rx = 0;
+			else
+				invarg("invalid option for udp6_csum_rx\n"
+						, *argv);
+		} else if (strcmp(*argv, "udp6_csum_tx") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "on") == 0)
+				p->udp6_csum_tx = 1;
+			else if (strcmp(*argv, "off") == 0)
+				p->udp6_csum_tx = 0;
+			else
+				invarg("invalid option for udp6_csum_tx\n"
+						, *argv);
 		} else if (strcmp(*argv, "offset") == 0) {
 			__u8 uval;
 
-- 
2.5.2
