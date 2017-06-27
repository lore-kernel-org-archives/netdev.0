From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH iproute2 3/3] bpf: allow requesting XDP HW offload
Date: Mon, 26 Jun 2017 17:23:53 -0700
Message-ID: <20170627002353.12292-4-jakub.kicinski@netronome.com>
References: <20170627002353.12292-1-jakub.kicinski@netronome.com>
Cc: daniel@iogearbox.net, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34998 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdF0AYE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 20:24:04 -0400
Received: by mail-pf0-f181.google.com with SMTP id c73so7786544pfk.2
        for <netdev@vger.kernel.org>; Mon, 26 Jun 2017 17:24:04 -0700 (PDT)
In-Reply-To: <20170627002353.12292-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let XDP link set command request that the program be offloaded.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/if_link.h | 1 +
 ip/iplink.c             | 5 ++++-
 ip/iplink_xdp.c         | 4 +++-
 ip/xdp.h                | 2 +-
 man/man8/ip-link.8.in   | 7 ++++++-
 5 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 8a41b3bafcd4..3c0b2d365bcb 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -888,6 +888,7 @@ enum {
 #define XDP_FLAGS_UPDATE_IF_NOEXIST	(1U << 0)
 #define XDP_FLAGS_SKB_MODE		(1U << 1)
 #define XDP_FLAGS_DRV_MODE		(1U << 2)
+#define XDP_FLAGS_HW_MODE		(1U << 3)
 #define XDP_FLAGS_MASK			(XDP_FLAGS_UPDATE_IF_NOEXIST | \
 					 XDP_FLAGS_SKB_MODE | \
 					 XDP_FLAGS_DRV_MODE)
diff --git a/ip/iplink.c b/ip/iplink.c
index 811513c01c25..9674cb657322 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -616,12 +616,15 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
 		} else if (strcmp(*argv, "xdpgeneric") == 0 ||
 			   strcmp(*argv, "xdpdrv") == 0 ||
+			   strcmp(*argv, "xdpoffload") == 0 ||
 			   strcmp(*argv, "xdp") == 0) {
 			bool generic = strcmp(*argv, "xdpgeneric") == 0;
 			bool drv = strcmp(*argv, "xdpdrv") == 0;
+			bool offload = strcmp(*argv, "xdpoffload") == 0;
 
 			NEXT_ARG();
-			if (xdp_parse(&argc, &argv, req, generic, drv))
+			if (xdp_parse(&argc, &argv, req, generic, drv,
+				      offload))
 				exit(-1);
 		} else if (strcmp(*argv, "netns") == 0) {
 			NEXT_ARG();
diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
index cabb2348562e..9ae9ee5d0665 100644
--- a/ip/iplink_xdp.c
+++ b/ip/iplink_xdp.c
@@ -48,7 +48,7 @@ static int xdp_delete(struct xdp_req *xdp)
 }
 
 int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic,
-	      bool drv)
+	      bool drv, bool offload)
 {
 	struct bpf_cfg_in cfg = {
 		.argc = *argc,
@@ -64,6 +64,8 @@ int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic,
 		xdp.flags |= XDP_FLAGS_SKB_MODE;
 	if (drv)
 		xdp.flags |= XDP_FLAGS_DRV_MODE;
+	if (offload)
+		xdp.flags |= XDP_FLAGS_HW_MODE;
 
 	if (*argc == 1) {
 		if (strcmp(**argv, "none") == 0 ||
diff --git a/ip/xdp.h b/ip/xdp.h
index 5f594132f494..ba897a29af58 100644
--- a/ip/xdp.h
+++ b/ip/xdp.h
@@ -4,7 +4,7 @@
 #include "utils.h"
 
 int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic,
-	      bool drv);
+	      bool drv, bool offload);
 void xdp_dump(FILE *fp, struct rtattr *tb);
 
 #endif /* __XDP__ */
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 326002d95e87..141d3597f945 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -126,7 +126,7 @@ ip-link \- network device configuration
 .RB "[ " port_guid " eui64 ] ]"
 .br
 .in -9
-.RB "[ { " xdp " | " xdpgeneric  " | " xdpdrv " } { " off " | "
+.RB "[ { " xdp " | " xdpgeneric  " | " xdpdrv " | " xdpoffload " } { " off " | "
 .br
 .in +8
 .BR object
@@ -1595,6 +1595,11 @@ generic XDP variant be disabled and in case driver is not XDP-capable error
 should be returned.
 .B xdpdrv
 also disables hardware offloads.
+.B xdpoffload
+in ip link output indicates that the program has been offloaded to hardware
+and can also be used to request the "offload" mode, much like
+.B xdpgeneric
+it forces program to be installed specifically in HW/FW of the apater.
 
 .B off
 (or
-- 
2.11.0
