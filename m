From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH iproute2 2/3] bpf: add xdpdrv for requesting XDP driver mode
Date: Mon, 26 Jun 2017 17:23:52 -0700
Message-ID: <20170627002353.12292-3-jakub.kicinski@netronome.com>
References: <20170627002353.12292-1-jakub.kicinski@netronome.com>
Cc: daniel@iogearbox.net, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33310 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751480AbdF0AYD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 20:24:03 -0400
Received: by mail-pg0-f46.google.com with SMTP id f127so7437328pgc.0
        for <netdev@vger.kernel.org>; Mon, 26 Jun 2017 17:24:03 -0700 (PDT)
In-Reply-To: <20170627002353.12292-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow user to select XDP DRV_MODE flag by using xdpdrv keyword
instead of xdp or xdpgeneric.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 ip/iplink.c           | 4 +++-
 ip/iplink_xdp.c       | 5 ++++-
 ip/xdp.h              | 3 ++-
 man/man8/ip-link.8.in | 8 +++++++-
 4 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 682f7eebd139..811513c01c25 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -615,11 +615,13 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				invarg("Invalid \"mtu\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
 		} else if (strcmp(*argv, "xdpgeneric") == 0 ||
+			   strcmp(*argv, "xdpdrv") == 0 ||
 			   strcmp(*argv, "xdp") == 0) {
 			bool generic = strcmp(*argv, "xdpgeneric") == 0;
+			bool drv = strcmp(*argv, "xdpdrv") == 0;
 
 			NEXT_ARG();
-			if (xdp_parse(&argc, &argv, req, generic))
+			if (xdp_parse(&argc, &argv, req, generic, drv))
 				exit(-1);
 		} else if (strcmp(*argv, "netns") == 0) {
 			NEXT_ARG();
diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
index 1b4ef3b836e8..cabb2348562e 100644
--- a/ip/iplink_xdp.c
+++ b/ip/iplink_xdp.c
@@ -47,7 +47,8 @@ static int xdp_delete(struct xdp_req *xdp)
 	return 0;
 }
 
-int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic)
+int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic,
+	      bool drv)
 {
 	struct bpf_cfg_in cfg = {
 		.argc = *argc,
@@ -61,6 +62,8 @@ int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic)
 		xdp.flags |= XDP_FLAGS_UPDATE_IF_NOEXIST;
 	if (generic)
 		xdp.flags |= XDP_FLAGS_SKB_MODE;
+	if (drv)
+		xdp.flags |= XDP_FLAGS_DRV_MODE;
 
 	if (*argc == 1) {
 		if (strcmp(**argv, "none") == 0 ||
diff --git a/ip/xdp.h b/ip/xdp.h
index 1b95e0f63a99..5f594132f494 100644
--- a/ip/xdp.h
+++ b/ip/xdp.h
@@ -3,7 +3,8 @@
 
 #include "utils.h"
 
-int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic);
+int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic,
+	      bool drv);
 void xdp_dump(FILE *fp, struct rtattr *tb);
 
 #endif /* __XDP__ */
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 5d73538b7ec3..326002d95e87 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -126,7 +126,7 @@ ip-link \- network device configuration
 .RB "[ " port_guid " eui64 ] ]"
 .br
 .in -9
-.RB "[ { " xdp " | " xdpgeneric  " } { " off " | "
+.RB "[ { " xdp " | " xdpgeneric  " | " xdpdrv " } { " off " | "
 .br
 .in +8
 .BR object
@@ -1589,6 +1589,12 @@ only. If the driver does have native XDP support, but the program is
 loaded under
 .B xdpgeneric object "|" pinned
 then the kernel will use the generic XDP variant instead of the native one.
+.B xdpdrv
+has the opposite effect of requestsing that the automatic fallback to the
+generic XDP variant be disabled and in case driver is not XDP-capable error
+should be returned.
+.B xdpdrv
+also disables hardware offloads.
 
 .B off
 (or
-- 
2.11.0
