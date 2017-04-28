From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 net-next v2] bpf: add support for generic xdp
Date: Fri, 28 Apr 2017 15:44:29 +0200
Message-ID: <e2ca217f7b95b4dd0b5fa8650e8fcf783de73967.1493386943.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39092 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031028AbdD1NpB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 09:45:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up to commit c7272ca72009 ("bpf: add initial support for
attaching xdp progs") to also support generic XDP. This adds an
indicator for loaded generic XDP programs when programs are loaded
as shown in c7272ca72009, but the driver still lacks native XDP
support.

  # ip link
  [...]
  3: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdpgeneric qdisc [...]
      link/ether 0c:c4:7a:03:f9:25 brd ff:ff:ff:ff:ff:ff
  [...]

In case the driver does support native XDP, but the user wants
to load the program as generic XDP (e.g. for testing purposes),
then this can be done with the same semantics as in c7272ca72009,
but with 'xdpgeneric' instead of 'xdp' command for loading:

  # ip -force link set dev eno1 xdpgeneric obj xdp.o

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ( Requires a header update to pull in XDP_FLAGS_SKB_MODE. )

 v1 -> v2:
   - flags need to be set also on deletion

 ip/iplink.c           |  7 +++++--
 ip/iplink_xdp.c       | 46 +++++++++++++++++++++++++++++++++-------------
 ip/xdp.h              |  2 +-
 man/man8/ip-link.8.in | 19 +++++++++++++++++--
 4 files changed, 56 insertions(+), 18 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 866ad72..96b0da3 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -606,9 +606,12 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			if (get_integer(&mtu, *argv, 0))
 				invarg("Invalid \"mtu\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
-		} else if (strcmp(*argv, "xdp") == 0) {
+		} else if (strcmp(*argv, "xdpgeneric") == 0 ||
+			   strcmp(*argv, "xdp") == 0) {
+			bool generic = strcmp(*argv, "xdpgeneric") == 0;
+
 			NEXT_ARG();
-			if (xdp_parse(&argc, &argv, req))
+			if (xdp_parse(&argc, &argv, req, generic))
 				exit(-1);
 		} else if (strcmp(*argv, "netns") == 0) {
 			NEXT_ARG();
diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
index a81ed97..a1380ee 100644
--- a/ip/iplink_xdp.c
+++ b/ip/iplink_xdp.c
@@ -19,41 +19,56 @@
 
 extern int force;
 
+struct xdp_req {
+	struct iplink_req *req;
+	__u32 flags;
+};
+
 static void xdp_ebpf_cb(void *raw, int fd, const char *annotation)
 {
-	__u32 flags = !force ? XDP_FLAGS_UPDATE_IF_NOEXIST : 0;
-	struct iplink_req *req = raw;
-	struct rtattr *xdp;
+	struct xdp_req *xdp = raw;
+	struct iplink_req *req = xdp->req;
+	struct rtattr *xdp_attr;
 
-	xdp = addattr_nest(&req->n, sizeof(*req), IFLA_XDP);
+	xdp_attr = addattr_nest(&req->n, sizeof(*req), IFLA_XDP);
 	addattr32(&req->n, sizeof(*req), IFLA_XDP_FD, fd);
-	addattr32(&req->n, sizeof(*req), IFLA_XDP_FLAGS, flags);
-	addattr_nest_end(&req->n, xdp);
+	if (xdp->flags)
+		addattr32(&req->n, sizeof(*req), IFLA_XDP_FLAGS, xdp->flags);
+	addattr_nest_end(&req->n, xdp_attr);
 }
 
 static const struct bpf_cfg_ops bpf_cb_ops = {
 	.ebpf_cb = xdp_ebpf_cb,
 };
 
-static int xdp_delete(struct iplink_req *req)
+static int xdp_delete(struct xdp_req *xdp)
 {
-	xdp_ebpf_cb(req, -1, NULL);
+	xdp_ebpf_cb(xdp, -1, NULL);
 	return 0;
 }
 
-int xdp_parse(int *argc, char ***argv, struct iplink_req *req)
+int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic)
 {
 	struct bpf_cfg_in cfg = {
 		.argc = *argc,
 		.argv = *argv,
 	};
+	struct xdp_req xdp = {
+		.req = req,
+	};
+
+	if (!force)
+		xdp.flags |= XDP_FLAGS_UPDATE_IF_NOEXIST;
+	if (generic)
+		xdp.flags |= XDP_FLAGS_SKB_MODE;
 
 	if (*argc == 1) {
 		if (strcmp(**argv, "none") == 0 ||
 		    strcmp(**argv, "off") == 0)
-			return xdp_delete(req);
+			return xdp_delete(&xdp);
 	}
-	if (bpf_parse_common(BPF_PROG_TYPE_XDP, &cfg, &bpf_cb_ops, req))
+
+	if (bpf_parse_common(BPF_PROG_TYPE_XDP, &cfg, &bpf_cb_ops, &xdp))
 		return -1;
 
 	*argc = cfg.argc;
@@ -64,12 +79,17 @@ int xdp_parse(int *argc, char ***argv, struct iplink_req *req)
 void xdp_dump(FILE *fp, struct rtattr *xdp)
 {
 	struct rtattr *tb[IFLA_XDP_MAX + 1];
+	__u32 flags = 0;
 
 	parse_rtattr_nested(tb, IFLA_XDP_MAX, xdp);
+
 	if (!tb[IFLA_XDP_ATTACHED] ||
 	    !rta_getattr_u8(tb[IFLA_XDP_ATTACHED]))
 		return;
 
-	fprintf(fp, "xdp ");
-	/* More to come here in future for 'ip -d link' (digest, etc) ... */
+	if (tb[IFLA_XDP_FLAGS])
+		flags = rta_getattr_u32(tb[IFLA_XDP_FLAGS]);
+
+	fprintf(fp, "xdp%s ",
+		flags & XDP_FLAGS_SKB_MODE ? "generic" : "");
 }
diff --git a/ip/xdp.h b/ip/xdp.h
index bc69645..1b95e0f 100644
--- a/ip/xdp.h
+++ b/ip/xdp.h
@@ -3,7 +3,7 @@
 
 #include "utils.h"
 
-int xdp_parse(int *argc, char ***argv, struct iplink_req *req);
+int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic);
 void xdp_dump(FILE *fp, struct rtattr *tb);
 
 #endif /* __XDP__ */
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index a5ddfe7..52571b7 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -126,7 +126,7 @@ ip-link \- network device configuration
 .RB "[ " port_guid " eui64 ] ]"
 .br
 .in -9
-.RB "[ " xdp  " { " off " | "
+.RB "[ { " xdp " | " xdpgeneric  " } { " off " | "
 .br
 .in +8
 .BR object
@@ -1572,8 +1572,23 @@ which may impact security and/or performance. (e.g. VF multicast promiscuous mod
 
 .TP
 .B xdp object "|" pinned "|" off
-set (or unset) a XDP ("express data path") BPF program to run on every
+set (or unset) a XDP ("eXpress Data Path") BPF program to run on every
 packet at driver level.
+.B ip link
+output will indicate a
+.B xdp
+flag for the networking device. If the driver does not have native XDP
+support, the kernel will fall back to a slower, driver-independent "generic"
+XDP variant. The
+.B ip link
+output will in that case indicate
+.B xdpgeneric
+instead of
+.B xdp
+only. If the driver does have native XDP support, but the program is
+loaded under
+.B xdpgeneric object "|" pinned
+then the kernel will use the generic XDP variant instead of the native one.
 
 .B off
 (or
-- 
1.9.3
