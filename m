From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] iproute2: support xfrm upper protocol gre key
Date: Tue, 23 Nov 2010 17:02:39 +0200
Message-ID: <1290524559-22086-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:45460 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744Ab0KWPDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 10:03:00 -0500
Received: by ewy5 with SMTP id 5so2473743ewy.19
        for <netdev@vger.kernel.org>; Tue, 23 Nov 2010 07:02:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gre key handling is consistent with ip tunnel side: both
dotted-quad and number are accepted, but dotted-quad is used
for printing.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
This is the userland part for:
  http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commitdiff;h=3Dcc9ff19da9bf76a2f70bcb80225a1c587c162e52

However, that commit is flawed, and for this patch to work
properly, the following patch is needed:
  http://patchwork.ozlabs.org/patch/72668/

 ip/ipxfrm.c      |   42 ++++++++++++++++++++++++++++++++++++++++++
 ip/xfrm_policy.c |    3 ++-
 man/man8/ip.8    |   25 ++++++++++++++++---------
 3 files changed, 60 insertions(+), 10 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 99a6756..cf4b7c7 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -35,6 +35,7 @@
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
 #include <linux/xfrm.h>
+#include <arpa/inet.h>
=20
 #include "utils.h"
 #include "xfrm.h"
@@ -483,6 +484,14 @@ void xfrm_selector_print(struct xfrm_selector *sel=
, __u16 family,
 		if (sel->dport_mask)
 			fprintf(fp, "code %u ", ntohs(sel->dport));
 		break;
+	case IPPROTO_GRE:
+		if (sel->sport_mask || sel->dport_mask) {
+			struct in_addr key;
+			key.s_addr =3D htonl((ntohs(sel->sport) << 16) + ntohs(sel->dport))=
;
+			inet_ntop(AF_INET, &key, abuf, sizeof(abuf));
+			fprintf(fp, "key %s ", abuf);
+		}
+		break;
 	case IPPROTO_MH:
 		if (sel->sport_mask)
 			fprintf(fp, "type %u ", ntohs(sel->sport));
@@ -1086,6 +1095,7 @@ static int xfrm_selector_upspec_parse(struct xfrm=
_selector *sel,
 	char *dportp =3D NULL;
 	char *typep =3D NULL;
 	char *codep =3D NULL;
+	char *grekey =3D NULL;
=20
 	while (1) {
 		if (strcmp(*argv, "proto") =3D=3D 0) {
@@ -1162,6 +1172,29 @@ static int xfrm_selector_upspec_parse(struct xfr=
m_selector *sel,
=20
 			filter.upspec_dport_mask =3D XFRM_FILTER_MASK_FULL;
=20
+		} else if (strcmp(*argv, "key") =3D=3D 0) {
+			unsigned key;
+
+			grekey =3D *argv;
+
+			NEXT_ARG();
+
+			if (strchr(*argv, '.'))
+				key =3D htonl(get_addr32(*argv));
+			else {
+				if (get_unsigned(&key, *argv, 0)<0) {
+					fprintf(stderr, "invalid value of \"key\"\n");
+					exit(-1);
+				}
+			}
+
+			sel->sport =3D htons(key >> 16);
+			sel->dport =3D htons(key & 0xffff);
+			sel->sport_mask =3D ~((__u16)0);
+			sel->dport_mask =3D ~((__u16)0);
+
+			filter.upspec_dport_mask =3D XFRM_FILTER_MASK_FULL;
+
 		} else {
 			PREV_ARG(); /* back track */
 			break;
@@ -1196,6 +1229,15 @@ static int xfrm_selector_upspec_parse(struct xfr=
m_selector *sel,
 			exit(1);
 		}
 	}
+	if (grekey) {
+		switch (sel->proto) {
+		case IPPROTO_GRE:
+			break;
+		default:
+			fprintf(stderr, "\"key\" is invalid with proto=3D%s\n", strxf_proto=
(sel->proto));
+			exit(1);
+		}
+	}
=20
 	*argcp =3D argc;
 	*argvp =3D argv;
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 121afa1..dcb3da4 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -66,7 +66,8 @@ static void usage(void)
 	fprintf(stderr, "SELECTOR :=3D src ADDR[/PLEN] dst ADDR[/PLEN] [ UPSP=
EC ] [ dev DEV ]\n");
=20
 	fprintf(stderr, "UPSPEC :=3D proto PROTO [ [ sport PORT ] [ dport POR=
T ] |\n");
-	fprintf(stderr, "                        [ type NUMBER ] [ code NUMBE=
R ] ]\n");
+	fprintf(stderr, "                        [ type NUMBER ] [ code NUMBE=
R ] |\n");
+	fprintf(stderr, "                        [ key { DOTTED_QUAD | NUMBER=
 } ] ]\n");
=20
 	//fprintf(stderr, "DEV - device name(default=3Dnone)\n");
=20
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 1a73efa..c1e03f3 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -547,7 +547,10 @@ throw " | " unreachable " | " prohibit " | " black=
hole " | " nat " ]"
 .RB " [ " type
 .IR NUMBER " ] "
 .RB " [ " code
-.IR NUMBER " ]] "
+.IR NUMBER " ] | "
+.br
+.RB " [ " key
+.IR KEY " ]] "
=20
 .ti -8
 .IR LIMIT-LIST " :=3D [ " LIMIT-LIST " ] |"
@@ -642,7 +645,10 @@ throw " | " unreachable " | " prohibit " | " black=
hole " | " nat " ]"
 .RB " [ " type
 .IR NUMBER " ] "
 .RB " [ " code
-.IR NUMBER " ] ] "
+.IR NUMBER " ] | "
+.br
+.RB " [ " key
+.IR KEY " ] ] "
=20
 .ti -8
 .IR ACTION " :=3D "
@@ -2487,9 +2493,11 @@ is defined by source port
 .BR sport ", "
 destination port
 .BR dport ", " type
-as number and
+as number,
 .B code
-also number.
+also number and
+.BR key
+as dotted-quad or number.
=20
 .TP
 .BI dev " DEV "
@@ -2556,11 +2564,10 @@ and the other choice is
 .TP
 .IR UPSPEC
 is specified by
-.BR sport ", "
-.BR dport ", " type
-and
-.B code
-(NUMBER).
+.BR sport " and " dport " (for UDP/TCP), "
+.BR type " and " code " (for ICMP; as number) or "
+.BR key " (for GRE; as dotted-quad or number)."
+.
=20
 .SS ip xfrm monitor - is used for listing all objects or defined group=
 of them.
 The
--=20
1.7.1

