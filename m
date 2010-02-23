From: jamal <hadi@cyberus.ca>
Subject: [iproute2 PATCH 1/3] xfrm: Introduce xfrm by mark
Date: Tue, 23 Feb 2010 08:15:10 -0500
Message-ID: <1266930912-14640-1-git-send-email-hadi@cyberus.ca>
References: <xfrm-iproute-mark>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:61657 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab0BWNPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 08:15:21 -0500
Received: by pwj8 with SMTP id 8so3774506pwj.19
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 05:15:21 -0800 (PST)
In-Reply-To: <xfrm-iproute-mark>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

This patch carries basic infrastructure.
You need to make sure that the proper include/linux/xfrm.h is included
for it to compile.

Example:
---

output:
src 192.168.2.100 dst 192.168.1.10
        proto esp spi 0x00000301 reqid 0 mode tunnel
        replay-window 0
        mark 7/0xffffffff
        auth hmac(md5) 0x96358c90783bbfa3d7b196ceabe0536b
        enc cbc(des3_ede) 0xf6ddb555acfd9d77b03ea3843f2653255afe8eb5573965df
        sel src 0.0.0.0/0 dst 0.0.0.0/0
        dir fwd ptype main \
        tmpl src 192.168.2.100 dst 192.168.1.100 \
        proto esp mode tunnel mark 7 mask 0xffffffff
output:
src 172.16.2.0/24 dst 172.16.1.0/24
        dir fwd priority 0 ptype main
        mark 7/0xffffffff
        tmpl src 192.168.2.100 dst 192.168.1.100
                proto esp reqid 0 mode tunnel
-----
A mark-configured SAD/SPD entry will use the mark as part of the
lookup key (both in data and control path).
Example:

---
output:
RTNETLINK answers: No such file or directory
output:
src 172.16.2.0/24 dst 172.16.1.0/24
        dir fwd priority 0 ptype main
        mark 7/0xffffffff
        tmpl src 192.168.2.100 dst 192.168.1.100
                proto esp reqid 0 mode tunnel
---

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 ip/ipxfrm.c |   40 ++++++++++++++++++++++++++++++++++++++++
 ip/xfrm.h   |    1 +
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 7dc36f3..78e1926 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -629,9 +629,48 @@ static void xfrm_tmpl_print(struct xfrm_user_tmpl *tmpls, int len,
 	}
 }
 
+int xfrm_parse_mark(struct xfrm_mark *mark, int *argcp, char ***argvp)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+
+	NEXT_ARG();
+	if (get_u32(&mark->v, *argv, 0)) {
+		invarg("Illegal \"mark\" value\n", *argv);
+	}
+	if (argc > 1)
+		NEXT_ARG();
+	else { /* last entry on parse line */
+		mark->m = 0xffffffff;
+		goto done;
+	}
+
+	if (strcmp(*argv, "mask") == 0) {
+		NEXT_ARG();
+		if (get_u32(&mark->m, *argv, 0)) {
+			invarg("Illegal \"mark\" mask\n", *argv);
+		}
+	} else {
+		mark->m = 0xffffffff;
+		PREV_ARG();
+	}
+
+done:
+	*argcp = argc;
+	*argvp = argv;
+
+	return 0;
+}
+
 void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 		      FILE *fp, const char *prefix)
 {
+	if (tb[XFRMA_MARK]) {
+		struct rtattr *rta = tb[XFRMA_MARK];
+		struct xfrm_mark *m = (struct xfrm_mark *) RTA_DATA(rta);
+		fprintf(fp, "\tmark %d/0x%x\n", m->v, m->m);
+	}
+
 	if (tb[XFRMA_ALG_AUTH]) {
 		struct rtattr *rta = tb[XFRMA_ALG_AUTH];
 		xfrm_algo_print((struct xfrm_algo *) RTA_DATA(rta),
@@ -740,6 +779,7 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 		fprintf(fp, "%s", strxf_time(lastused));
 		fprintf(fp, "%s", _SL_);
 	}
+
 }
 
 static int xfrm_selector_iszero(struct xfrm_selector *s)
diff --git a/ip/xfrm.h b/ip/xfrm.h
index 104fb20..d3ca5c5 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -121,6 +121,7 @@ int xfrm_xfrmproto_is_ipsec(__u8 proto);
 int xfrm_xfrmproto_is_ro(__u8 proto);
 int xfrm_xfrmproto_getbyname(char *name);
 int xfrm_algotype_getbyname(char *name);
+int xfrm_parse_mark(struct xfrm_mark *mark, int *argcp, char ***argvp);
 const char *strxf_xfrmproto(__u8 proto);
 const char *strxf_algotype(int type);
 const char *strxf_mask8(__u8 mask);
-- 
1.6.0.4

