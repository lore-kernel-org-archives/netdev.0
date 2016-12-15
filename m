From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 4/4] ip netns: Reset vrf to default VRF on namespace switch
Date: Thu, 15 Dec 2016 12:07:02 -0800
Message-ID: <1481832422-10267-5-git-send-email-dsa@cumulusnetworks.com>
References: <1481832422-10267-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35727 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754546AbcLOUHM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 15:07:12 -0500
Received: by mail-pf0-f180.google.com with SMTP id i88so10205321pfk.2
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 12:07:11 -0800 (PST)
In-Reply-To: <1481832422-10267-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A vrf is local to a namespace. Drop any VRF association before trying
to exec a command in the new namespace.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ip_common.h |  1 +
 ip/ipnetns.c   |  5 +++++
 ip/ipvrf.c     | 14 ++++++++++++++
 3 files changed, 20 insertions(+)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 28763e81e4a4..ab6a83431fd6 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -58,6 +58,7 @@ int do_tcp_metrics(int argc, char **argv);
 int do_ipnetconf(int argc, char **argv);
 int do_iptoken(int argc, char **argv);
 int do_ipvrf(int argc, char **argv);
+void vrf_reset(void);
 
 int iplink_get(unsigned int flags, char *name, __u32 filt_mask);
 
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index db9a541769f1..8201b94a1620 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -387,6 +387,11 @@ static int netns_exec(int argc, char **argv)
 	if (netns_switch(argv[0]))
 		return -1;
 
+	/* we just changed namespaces. clear any vrf association
+	 * with prior namespace before exec'ing command
+	 */
+	vrf_reset();
+
 	/* ip must return the status of the child,
 	 * but do_cmd() will add a minus to this,
 	 * so let's add another one here to cancel it.
diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index de2ec5c120cb..dc8364a43a57 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -277,6 +277,20 @@ static int ipvrf_exec(int argc, char **argv)
 	return -cmd_exec(argv[1], argv + 1, !!batch_mode);
 }
 
+/* reset VRF association of current process to default VRF;
+ * used by netns_exec
+ */
+void vrf_reset(void)
+{
+	char vrf[32];
+
+	if (vrf_identify(getpid(), vrf, sizeof(vrf)) ||
+	    (vrf[0] == '\0'))
+		return;
+
+	vrf_switch("default");
+}
+
 int do_ipvrf(int argc, char **argv)
 {
 	if (argc == 0) {
-- 
2.1.4
