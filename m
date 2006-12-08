From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2 PATCH][XFRM] update xfrm async events
Date: Thu, 07 Dec 2006 20:31:14 -0500
Message-ID: <1165541475.3666.13.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-NffsmQrfXOuGiXQ7icR7"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:3514 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1164369AbWLHBbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 20:31:21 -0500
Received: by wx-out-0506.google.com with SMTP id h27so681990wxd
        for <netdev@vger.kernel.org>; Thu, 07 Dec 2006 17:31:20 -0800 (PST)
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-NffsmQrfXOuGiXQ7icR7
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



--=-NffsmQrfXOuGiXQ7icR7
Content-Disposition: attachment; filename=xfrm_ae_report
Content-Type: text/plain; name=xfrm_ae_report; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] update xfrm async events

Report abbreviated async xfrm aevents.

---
commit 06f5ab6e44fd60430c1b25cd6144d93d3c598bb0
tree a2fe589d73fe8a0e565ae4a73790b0a6b14c96d4
parent 74ca97373a2c98ac49156bd76d6df6a0d2a27ffc
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Dec 2006 20:27:06 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Dec 2006 20:27:06 -0500

 ip/xfrm_monitor.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index 154bbee..b2014b4 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -150,6 +150,49 @@ static int xfrm_report_print(const struct sockaddr_nl *who,
 	return 0;
 }
 
+void xfrm_ae_flags_print(__u32 flags, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	fprintf(fp, " (0x%x) ", flags);
+	if (!flags)
+		return;
+	if (flags & XFRM_AE_CR)
+		fprintf(fp, " replay update ");
+	if (flags & XFRM_AE_CE)
+		fprintf(fp, " timer expired ");
+	if (flags & XFRM_AE_CU)
+		fprintf(fp, " policy updated ");
+
+}
+
+static int xfrm_ae_print(const struct sockaddr_nl *who,
+			     struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	struct xfrm_aevent_id *id = NLMSG_DATA(n);
+	char abuf[256];
+
+	fprintf(fp, "Async event ");
+	xfrm_ae_flags_print(id->flags, arg);
+	fprintf(fp,"\n\t");
+	memset(abuf, '\0', sizeof(abuf));
+	fprintf(fp, "src %s ", rt_addr_n2a(id->sa_id.family, 
+		sizeof(id->saddr), &id->saddr, 
+		abuf, sizeof(abuf)));
+	memset(abuf, '\0', sizeof(abuf));
+	fprintf(fp, "dst %s ", rt_addr_n2a(id->sa_id.family, 
+		sizeof(id->sa_id.daddr), &id->sa_id.daddr, 
+		abuf, sizeof(abuf)));
+	fprintf(fp, " reqid 0x%x", id->reqid);
+	fprintf(fp, " protocol %s ", strxf_proto(id->sa_id.proto));
+	fprintf(fp, " SPI 0x%x", ntohl(id->sa_id.spi));
+
+	fprintf(fp, "\n");
+	fflush(fp);
+
+	return 0;
+}
+
 static int xfrm_accept_msg(const struct sockaddr_nl *who,
 			   struct nlmsghdr *n, void *arg)
 {
@@ -190,6 +233,10 @@ static int xfrm_accept_msg(const struct sockaddr_nl *who,
 		xfrm_report_print(who, n, arg);
 		return 0;
 	}
+	if (n->nlmsg_type == XFRM_MSG_NEWAE) {
+		xfrm_ae_print(who, n, arg);
+		return 0;
+	}
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
 	    n->nlmsg_type != NLMSG_DONE) {
 		fprintf(fp, "Unknown message: %08d 0x%08x 0x%08x\n",
@@ -206,6 +253,7 @@ int do_xfrm_monitor(int argc, char **argv)
 	unsigned groups = ~((unsigned)0); /* XXX */
 	int lacquire=0;
 	int lexpire=0;
+	int laevent=0;
 	int lpolicy=0;
 	int lsa=0;
 	int lreport=0;
@@ -225,6 +273,9 @@ int do_xfrm_monitor(int argc, char **argv)
 		} else if (matches(*argv, "SA") == 0) {
 			lsa=1;
 			groups = 0;
+		} else if (matches(*argv, "aevent") == 0) {
+			laevent=1;
+			groups = 0;
 		} else if (matches(*argv, "policy") == 0) {
 			lpolicy=1;
 			groups = 0;
@@ -248,6 +299,8 @@ int do_xfrm_monitor(int argc, char **argv)
 		groups |= XFRMGRP_SA;
 	if (lpolicy)
 		groups |= XFRMGRP_POLICY;
+	if (laevent)
+		groups |= (1 <<  (XFRMNLGRP_AEVENTS - 1));
 	if (lreport)
 		groups |= XFRMGRP_REPORT;
 

--=-NffsmQrfXOuGiXQ7icR7--

