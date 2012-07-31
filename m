From: Rostislav Lisovy <lisovy@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=20iproute2=202/2=5D=20em=5Fcanid=3A=20Ematch=20used=20to=20classify=20CAN=20frames=20according=20to=20their=20identifiers?=
Date: Tue, 31 Jul 2012 16:46:21 +0200
Message-ID: <1343745981-14248-2-git-send-email-lisovy@gmail.com>
References: <1343745981-14248-1-git-send-email-lisovy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-can@vger.kernel.org, pisa@cmp.felk.cvut.cz,
	sojkam1@fel.cvut.cz, Rostislav Lisovy <lisovy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:40938 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754533Ab2GaOqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 10:46:24 -0400
In-Reply-To: <1343745981-14248-1-git-send-email-lisovy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ematch enables effective filtering of CAN frames (AF_CAN) based
on CAN identifiers with masking of compared bits. Implementation
utilizes bitmap based classification for standard frame format (SFF)
which is optimized for minimal overhead.

Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
---
 etc/iproute2/ematch_map |    1 +
 include/linux/pkt_cls.h |    6 +-
 tc/Makefile             |    1 +
 tc/em_canid.c           |  191 +++++++++++++++++++++++++++++++++++++++=
++++++++
 4 files changed, 197 insertions(+), 2 deletions(-)
 create mode 100644 tc/em_canid.c

diff --git a/etc/iproute2/ematch_map b/etc/iproute2/ematch_map
index 7c6a281..8d08613 100644
--- a/etc/iproute2/ematch_map
+++ b/etc/iproute2/ematch_map
@@ -3,3 +3,4 @@
 2	nbyte
 3	u32
 4	meta
+7	canid
diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index defbde2..082eafa 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -451,8 +451,10 @@ enum {
 #define	TCF_EM_U32		3
 #define	TCF_EM_META		4
 #define	TCF_EM_TEXT		5
-#define        TCF_EM_VLAN		6
-#define	TCF_EM_MAX		6
+#define	TCF_EM_VLAN		6
+#define	TCF_EM_CANID		7
+#define	TCF_EM_IPSET		8
+#define	TCF_EM_MAX		8
=20
 enum {
 	TCF_EM_PROG_TC
diff --git a/tc/Makefile b/tc/Makefile
index 64d93ad..bfdcf9f 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -45,6 +45,7 @@ TCMODULES +=3D p_udp.o
 TCMODULES +=3D em_nbyte.o
 TCMODULES +=3D em_cmp.o
 TCMODULES +=3D em_u32.o
+TCMODULES +=3D em_canid.o
 TCMODULES +=3D em_meta.o
 TCMODULES +=3D q_mqprio.o
 TCMODULES +=3D q_codel.o
diff --git a/tc/em_canid.c b/tc/em_canid.c
new file mode 100644
index 0000000..16f6ed5
--- /dev/null
+++ b/tc/em_canid.c
@@ -0,0 +1,191 @@
+/*
+ * em_canid.c  Ematch rule to match CAN frames according to their CAN =
identifiers
+ *
+ *             This program is free software; you can distribute it an=
d/or
+ *             modify it under the terms of the GNU General Public Lic=
ense
+ *             as published by the Free Software Foundation; either ve=
rsion
+ *             2 of the License, or (at your option) any later version=
=2E
+ *
+ * Idea:       Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
+ * Copyright:  (c) 2011 Czech Technical University in Prague
+ *             (c) 2011 Volkswagen Group Research
+ * Authors:    Michal Sojka <sojkam1@fel.cvut.cz>
+ *             Pavel Pisa <pisa@cmp.felk.cvut.cz>
+ *             Rostislav Lisovy <lisovy@gmail.cz>
+ * Funded by:  Volkswagen Group Research
+ *
+ * Documentation: http://rtime.felk.cvut.cz/can/socketcan-qdisc-final.=
pdf
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <string.h>
+#include <errno.h>
+#include <linux/can.h>
+#include <inttypes.h>
+#include "m_ematch.h"
+
+#define EM_CANID_RULES_MAX 400 /* Main reason for this number is Nelin=
k
+	message size limit equal to Single memory page size. When dump()
+	is invoked, there are even some ematch related headers sent from
+	kernel to userspace together with em_canid configuration --
+	400*sizeof(struct can_filter) should fit without any problems */
+
+extern struct ematch_util canid_ematch_util;
+struct rules {
+	struct can_filter *rules_raw;
+	int rules_capacity;	/* Size of array allocated for rules_raw */
+	int rules_cnt;		/* Actual number of rules stored in rules_raw */
+};
+
+static void canid_print_usage(FILE *fd)
+{
+	fprintf(fd,
+		"Usage: canid(IDLIST)\n" \
+		"where: IDLIST :=3D IDSPEC [ IDLIST ]\n" \
+		"       IDSPEC :=3D { =E2=80=99sff=E2=80=99 CANID | =E2=80=99eff=E2=80=
=99 CANID }\n" \
+		"       CANID :=3D ID[:MASK]\n" \
+		"       ID, MASK :=3D hexadecimal number (i.e. 0x123)\n" \
+		"Example: canid(sff 0x123 sff 0x124 sff 0x125:0xf)\n");
+}
+
+static int canid_parse_rule(struct rules *rules, struct bstr *a, int i=
seff)
+{
+	unsigned int can_id =3D 0;
+	unsigned int can_mask =3D 0;
+
+	if (sscanf(a->data, "%"SCNx32 ":" "%"SCNx32, &can_id, &can_mask) !=3D=
 2) {
+		if (sscanf(a->data, "%"SCNx32, &can_id) !=3D 1) {
+			return -1;
+		} else {
+			can_mask =3D (iseff) ? CAN_EFF_MASK : CAN_SFF_MASK;
+		}
+	}
+
+	/* Stretch rules array up to EM_CANID_RULES_MAX if necessary */
+	if (rules->rules_cnt =3D=3D rules->rules_capacity) {
+		if (rules->rules_capacity <=3D EM_CANID_RULES_MAX/2) {
+			rules->rules_capacity *=3D 2;
+			rules->rules_raw =3D realloc(rules->rules_raw,
+				sizeof(struct can_filter) * rules->rules_capacity);
+		} else {
+			return -2;
+		}
+	}
+
+	rules->rules_raw[rules->rules_cnt].can_id =3D
+		can_id | ((iseff) ? CAN_EFF_FLAG : 0);
+	rules->rules_raw[rules->rules_cnt].can_mask =3D
+		can_mask | CAN_EFF_FLAG;
+
+	rules->rules_cnt++;
+
+	return 0;
+}
+
+static int canid_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr =
*hdr,
+			  struct bstr *args)
+{
+	int iseff =3D 0;
+	int ret =3D 0;
+	struct rules rules =3D {
+		.rules_capacity =3D 25, /* Denominator of EM_CANID_RULES_MAX
+			Will be multiplied by 2 to calculate the size for realloc() */
+		.rules_cnt =3D 0
+	};
+
+#define PARSE_ERR(CARG, FMT, ARGS...) \
+	em_parse_error(EINVAL, args, CARG, &canid_ematch_util, FMT, ##ARGS)
+
+	if (args =3D=3D NULL)
+		return PARSE_ERR(args, "canid: missing arguments");
+
+	rules.rules_raw =3D malloc(sizeof(struct can_filter) * rules.rules_ca=
pacity);
+	memset(rules.rules_raw, 0, sizeof(struct can_filter) * rules.rules_ca=
pacity);
+
+	do {
+		if (!bstrcmp(args, "sff")) {
+			iseff =3D 0;
+		} else if (!bstrcmp(args, "eff")) {
+			iseff =3D 1;
+		} else {
+			ret =3D PARSE_ERR(args, "canid: invalid key");
+			goto exit;
+		}
+
+		args =3D bstr_next(args);
+		if (args =3D=3D NULL) {
+			ret =3D PARSE_ERR(args, "canid: missing argument");
+			goto exit;
+		}
+
+		ret =3D canid_parse_rule(&rules, args, iseff);
+		if (ret =3D=3D -1) {
+			ret =3D PARSE_ERR(args, "canid: Improperly formed CAN ID & mask\n")=
;
+			goto exit;
+		} else if (ret =3D=3D -2) {
+			ret =3D PARSE_ERR(args, "canid: Too many arguments on input\n");
+			goto exit;
+		}
+	} while ((args =3D bstr_next(args)) !=3D NULL);
+
+	addraw_l(n, MAX_MSG, hdr, sizeof(*hdr));
+	addraw_l(n, MAX_MSG, rules.rules_raw,
+		sizeof(struct can_filter) * rules.rules_cnt);
+
+#undef PARSE_ERR
+exit:
+	free(rules.rules_raw);
+	return ret;
+}
+
+static int canid_print_eopt(FILE *fd, struct tcf_ematch_hdr *hdr, void=
 *data,
+			  int data_len)
+{
+	struct can_filter *conf =3D data; /* Array with rules */
+	int rules_count;
+	int i;
+
+	rules_count =3D data_len / sizeof(struct can_filter);
+
+	for (i =3D 0; i < rules_count; i++) {
+		struct can_filter *pcfltr =3D &conf[i];
+
+		if (pcfltr->can_id & CAN_EFF_FLAG) {
+			if (pcfltr->can_mask =3D=3D (CAN_EFF_FLAG | CAN_EFF_MASK))
+				fprintf(fd, "eff 0x%"PRIX32,
+						pcfltr->can_id & CAN_EFF_MASK);
+			else
+				fprintf(fd, "eff 0x%"PRIX32":0x%"PRIX32,
+						pcfltr->can_id & CAN_EFF_MASK,
+						pcfltr->can_mask & CAN_EFF_MASK);
+		} else {
+			if (pcfltr->can_mask =3D=3D (CAN_EFF_FLAG | CAN_SFF_MASK))
+				fprintf(fd, "sff 0x%"PRIX32,
+						pcfltr->can_id & CAN_SFF_MASK);
+			else
+				fprintf(fd, "sff 0x%"PRIX32":0x%"PRIX32,
+						pcfltr->can_id & CAN_SFF_MASK,
+						pcfltr->can_mask & CAN_SFF_MASK);
+		}
+
+		if ((i + 1) < rules_count)
+			fprintf(fd, " ");
+	}
+
+	return 0;
+}
+
+struct ematch_util canid_ematch_util =3D {
+	.kind =3D "canid",
+	.kind_num =3D TCF_EM_CANID,
+	.parse_eopt =3D canid_parse_eopt,
+	.print_eopt =3D canid_print_eopt,
+	.print_usage =3D canid_print_usage
+};
--=20
1.7.10.4
