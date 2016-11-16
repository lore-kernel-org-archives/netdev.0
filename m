From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 v2 7/9] l2tp: support sequence numbering
Date: Wed, 16 Nov 2016 22:45:24 +0000
Message-ID: <20161116224526.32343-7-asbjorn@asbjorn.st>
References: <20161116224526.32343-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:41444 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941326AbcKPWqi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 17:46:38 -0500
In-Reply-To: <20161116224526.32343-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implement and documents the user interface for
sequence numbering.

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 ip/ipl2tp.c        | 23 +++++++++++++++++++++++
 man/man8/ip-l2tp.8 | 15 +++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index f5d4113..ab35023 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -246,6 +246,12 @@ static void print_session(struct l2tp_data *data)
 		printf("  reorder timeout: %u\n", p->reorder_timeout);
 	else
 		printf("\n");
+	if (p->send_seq || p->recv_seq) {
+		printf("  sequence numbering:");
+		if (p->send_seq) printf(" send");
+		if (p->recv_seq) printf(" recv");
+		printf("\n");
+	}
 }
 
 static int get_response(struct nlmsghdr *n, void *arg)
@@ -482,6 +488,7 @@ static void usage(void)
 	fprintf(stderr, "          session_id ID peer_session_id ID\n");
 	fprintf(stderr, "          [ cookie HEXSTR ] [ peer_cookie HEXSTR ]\n");
 	fprintf(stderr, "          [ offset OFFSET ] [ peer_offset OFFSET ]\n");
+	fprintf(stderr, "          [ seq { none | send | recv | both } ]\n");
 	fprintf(stderr, "          [ l2spec_type L2SPEC ]\n");
 	fprintf(stderr, "       ip l2tp del tunnel tunnel_id ID\n");
 	fprintf(stderr, "       ip l2tp del session tunnel_id ID session_id ID\n");
@@ -652,6 +659,22 @@ static int parse_args(int argc, char **argv, int cmd, struct l2tp_parm *p)
 				fprintf(stderr, "Unknown layer2specific header type \"%s\"\n", *argv);
 				exit(-1);
 			}
+		} else if (strcmp(*argv, "seq") == 0) {
+			NEXT_ARG();
+			if (strcasecmp(*argv, "both") == 0) {
+				p->recv_seq = 1;
+				p->send_seq = 1;
+			} else if (strcasecmp(*argv, "recv") == 0) {
+				p->recv_seq = 1;
+			} else if (strcasecmp(*argv, "send") == 0) {
+				p->send_seq = 1;
+			} else if (strcasecmp(*argv, "none") == 0) {
+				p->recv_seq = 0;
+				p->send_seq = 0;
+			} else {
+				fprintf(stderr, "Unknown seq value \"%s\"\n", *argv);
+				exit(-1);
+			}
 		} else if (strcmp(*argv, "tunnel") == 0) {
 			p->tunnel = 1;
 		} else if (strcmp(*argv, "session") == 0) {
diff --git a/man/man8/ip-l2tp.8 b/man/man8/ip-l2tp.8
index 991d097..d4e7270 100644
--- a/man/man8/ip-l2tp.8
+++ b/man/man8/ip-l2tp.8
@@ -51,6 +51,8 @@ ip-l2tp - L2TPv3 static unmanaged tunnel configuration
 .br
 .RB "[ " l2spec_type " { " none " | " default " } ]"
 .br
+.RB "[ " seq " { " none " | " send " | " recv " | " both " } ]"
+.br
 .RB "[ " offset
 .IR OFFSET
 .RB " ] [ " peer_offset
@@ -238,6 +240,19 @@ set the layer2specific header type of the session.
 Valid values are:
 .BR none ", " default "."
 .TP
+.BI seq " SEQ"
+controls sequence numbering to prevent or detect out of order packets.
+.B send
+puts a sequence number in the default layer2specific header of each
+outgoing packet.
+.B recv
+reorder packets if they are received out of order.
+Default is
+.BR none "."
+.br
+Valid values are:
+.BR none ", " send ", " recv ", " both "."
+.TP
 .BI offset " OFFSET"
 sets the byte offset from the L2TP header where user data starts in
 transmitted L2TP data packets. This is hardly ever used. If set, the
-- 
2.10.2
