From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 1/2] iproute2: add l2spec_type param to l2tp add session
Date: Tue, 26 Mar 2013 16:49:22 +0000
Message-ID: <1364316563-23303-1-git-send-email-jchapman@katalix.com>
Cc: tlund@nxs.se, James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36403 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958Ab3CZQti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 12:49:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When unmanaged L2TP sessions are created using "ip l2tp add session",
there is no option to allow the session's Layer2SpecificHeader type to
be selected - the kernel's default setting is always used. For
interopability with some vendor equipment, it might be necessary to
use a different setting. So add a new l2spec_type parameter to the "ip
l2tp add session" parameter list, allowing operators to set a specific
Layer2SpecificHeader type. The kernel already exposes the setting as a
netlink attribute so it is straightforward to add support for it in
iproute2.

This change allows unmanaged L2TP sessions to be configured between
Linux and some Cisco equipment by specifying "l2spec_type none" in "ip
l2tp add session" command parameters.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
:100644 100644 2d22317... 5cd8632... M	ip/ipl2tp.c
 ip/ipl2tp.c |   26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 2d22317..5cd8632 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -65,6 +65,8 @@ struct l2tp_parm {
 	int session:1;
 	int reorder_timeout;
 	const char *ifname;
+	uint8_t l2spec_type;
+	uint8_t l2spec_len;
 };
 
 struct l2tp_stats {
@@ -146,6 +148,8 @@ static int create_session(struct l2tp_parm *p)
 	addattr32(&req.n, 1024, L2TP_ATTR_SESSION_ID, p->session_id);
 	addattr32(&req.n, 1024, L2TP_ATTR_PEER_SESSION_ID, p->peer_session_id);
 	addattr16(&req.n, 1024, L2TP_ATTR_PW_TYPE, p->pw_type);
+	addattr8(&req.n, 1024, L2TP_ATTR_L2SPEC_TYPE, p->l2spec_type);
+	addattr8(&req.n, 1024, L2TP_ATTR_L2SPEC_LEN, p->l2spec_len);
 
 	if (p->mtu)		addattr16(&req.n, 1024, L2TP_ATTR_MTU, p->mtu);
 	if (p->recv_seq)	addattr(&req.n, 1024, L2TP_ATTR_RECV_SEQ);
@@ -271,6 +275,10 @@ static int get_response(struct nlmsghdr *n, void *arg)
 		p->session_id = rta_getattr_u32(attrs[L2TP_ATTR_SESSION_ID]);
 	if (attrs[L2TP_ATTR_PEER_SESSION_ID])
 		p->peer_session_id = rta_getattr_u32(attrs[L2TP_ATTR_PEER_SESSION_ID]);
+	if (attrs[L2TP_ATTR_L2SPEC_TYPE])
+		p->l2spec_type = rta_getattr_u8(attrs[L2TP_ATTR_L2SPEC_TYPE]);
+	if (attrs[L2TP_ATTR_L2SPEC_LEN])
+		p->l2spec_len = rta_getattr_u8(attrs[L2TP_ATTR_L2SPEC_LEN]);
 
 	p->udp_csum = !!attrs[L2TP_ATTR_UDP_CSUM];
 	if (attrs[L2TP_ATTR_COOKIE])
@@ -466,6 +474,7 @@ static void usage(void)
 	fprintf(stderr, "          session_id ID peer_session_id ID\n");
 	fprintf(stderr, "          [ cookie HEXSTR ] [ peer_cookie HEXSTR ]\n");
 	fprintf(stderr, "          [ offset OFFSET ] [ peer_offset OFFSET ]\n");
+	fprintf(stderr, "          [ l2spec_type L2SPEC ]\n");
 	fprintf(stderr, "       ip l2tp del tunnel tunnel_id ID\n");
 	fprintf(stderr, "       ip l2tp del session tunnel_id ID session_id ID\n");
 	fprintf(stderr, "       ip l2tp show tunnel [ tunnel_id ID ]\n");
@@ -476,6 +485,7 @@ static void usage(void)
 	fprintf(stderr, "       PORT   := { 0..65535 }\n");
 	fprintf(stderr, "       ID     := { 1..4294967295 }\n");
 	fprintf(stderr, "       HEXSTR := { 8 or 16 hex digits (4 / 8 bytes) }\n");
+	fprintf(stderr, "       L2SPEC := { none | default }\n");
 	exit(-1);
 }
 
@@ -486,6 +496,10 @@ static int parse_args(int argc, char **argv, int cmd, struct l2tp_parm *p)
 	if (argc == 0)
 		usage();
 
+	/* Defaults */
+	p->l2spec_type = L2TP_L2SPECTYPE_DEFAULT;
+	p->l2spec_len = 4;
+
 	while (argc > 0) {
 		if (strcmp(*argv, "encap") == 0) {
 			NEXT_ARG();
@@ -580,6 +594,18 @@ static int parse_args(int argc, char **argv, int cmd, struct l2tp_parm *p)
 			p->peer_cookie_len = slen / 2;
 			if (hex2mem(*argv, p->peer_cookie, p->peer_cookie_len) < 0)
 				invarg("cookie must be a hex string\n", *argv);
+		} else if (strcmp(*argv, "l2spec_type") == 0) {
+			NEXT_ARG();
+			if (strcasecmp(*argv, "default") == 0) {
+				p->l2spec_type = L2TP_L2SPECTYPE_DEFAULT;
+				p->l2spec_len = 4;
+			} else if (strcasecmp(*argv, "none") == 0) {
+				p->l2spec_type = L2TP_L2SPECTYPE_NONE;
+				p->l2spec_len = 0;
+			} else {
+				fprintf(stderr, "Unknown layer2specific header type \"%s\"\n", *argv);
+				exit(-1);
+			}
 		} else if (strcmp(*argv, "tunnel") == 0) {
 			p->tunnel = 1;
 		} else if (strcmp(*argv, "session") == 0) {
-- 
1.7.9.5
