From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: net/hsr Patch - Help
Date: Tue, 15 Oct 2013 21:09:01 +0200
Message-ID: <525D92CD.6090901@xdin.com>
References: <52299175.90302@ehu.es> <522E1035.2050503@xdin.com> <525CF1F3.2050006@ehu.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>,
	Joe Perches <joe@perches.com>
To: =?ISO-8859-1?Q?El=EDas_Molina_Mu=F1oz?= <elias.molina@ehu.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:58791 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757185Ab3JOTJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 15:09:05 -0400
In-Reply-To: <525CF1F3.2050006@ehu.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-15 09:42, El=EDas Molina Mu=F1oz wrote:
> El 09/09/2013 20:15, Arvid Brodin escribi=F3:
>> On 2013-09-06 10:25, El=EDas Molina Mu=F1oz wrote:
>>> Dear Mr. Brodin,
>>>=20
>>> I would like to introduce myself. My name is El=EDas Molina, PhD.=20
>>> Student at University of Basque Country (Spain). I am writing to=20
>>> enquire about your HSR patch.
>> Hi!
>>=20
>>> I have read "This is a patch against net-next (2013-08-21)" in
>>> its last version (v3) so I have tried with several kernel
>>> versions but I do not know which is the repo's correct version
>>> of=20
>>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/
>>> .
>>>=20
>>> Could you tell me which is the kernel version to apply your
>>> patch?
>> I made an error when I sent that patch, so it won't apply to any
>> kernel version.
>>=20
>> The below patch should work (cd to the net-next directory and apply
>> with patch -Np1):
>>=20
[removed]

> Dear Mr. Brodin,
> =20
> Thanks for getting back to me and I apologize for being so late
> replying.
> =20
> I am writing to enquire if, once compiled the kernel with your patch,
> there is a sample application for verifying the correct operation of
> HSR, as you did in http://patchwork.ozlabs.org/patch/191165/ with
> Documentation/networking/hsr/hsr_genl.c
> =20
> Thank you very much. Best regards,
> =20
> El=EDas Molina

Hi again,

I'm CC:ing the netdev list and others who've shown interest in HSR, sin=
ce=20
they might be interested as well.

Yes, I have patches for iproute2 (to make it possible to add HSR device=
s)
and also a "hsrinfo" program which can be used to query an HSR interfac=
e=20
for statistics, and to listen for any HSR errors detected. The hsrinfo=20
program is based on the hsr_genl program that you mention. It requires=20
the libnl3 library.

The iproute patch is below (I'll send a separate message with the hsrin=
fo
code).

(I don't think the patch below will get accepted into iproute2 before=20
the HSR patch itself is accepted into the kernel - which I'm beginning =
to=20
doubt it ever will be, unfortunately.)


This patch adds support to iproute2 for adding High-Availability Seamle=
ss
Redundancy (HSR) network devices.

Signed-off-by: Arvid Brodin <arvid.brodin@xdin.com>
---
 include/linux/if_link.h | 12 +++++++
 ip/Makefile             |  2 +-
 ip/iplink_hsr.c         | 86 +++++++++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 99 insertions(+), 1 deletion(-)
 create mode 100644 ip/iplink_hsr.c

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index d07aeca..bab39e8 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -465,4 +465,16 @@ enum {
=20
 #define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)
=20
+/* HSR section */
+
+enum {
+	IFLA_HSR_UNSPEC,
+	IFLA_HSR_SLAVE1,
+	IFLA_HSR_SLAVE2,
+	IFLA_HSR_MULTICAST_SPEC,
+	__IFLA_HSR_MAX,
+};
+
+#define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/Makefile b/ip/Makefile
index 48bd4a1..5ef1562 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -5,7 +5,7 @@ IPOBJ=3Dip.o ipaddress.o ipaddrlabel.o iproute.o iprule=
=2Eo ipnetns.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tn=
l.o \
-    link_iptnl.o
+    link_iptnl.o iplink_hsr.o
=20
 RTMONOBJ=3Drtmon.o
=20
diff --git a/ip/iplink_hsr.c b/ip/iplink_hsr.c
new file mode 100644
index 0000000..c7c00d6
--- /dev/null
+++ b/ip/iplink_hsr.c
@@ -0,0 +1,86 @@
+/*
+ * iplink_hsr.c	HSR device support
+ *
+ *              This program is free software; you can redistribute it=
 and/or
+ *              modify it under the terms of the GNU General Public Li=
cense
+ *              as published by the Free Software Foundation; either v=
ersion
+ *              2 of the License, or (at your option) any later versio=
n.
+ *
+ * Authors:     Arvid Brodin <arvid.brodin@xdin.com>
+ *
+ * 		Based on iplink_vlan.c by Patrick McHardy <kaber@trash.net>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/socket.h>  /* Needed by linux/if.h for some reason */
+#include <linux/if.h>
+
+#include "utils.h"
+#include "ip_common.h"
+
+static void usage(void)
+{
+	fprintf(stderr,
+"Usage:\tip link add name NAME type hsr slave1 SLAVE1-IF slave2 SLAVE2=
-IF\n"
+"\t[ multicast ADDR-BYTE ]\n"
+"\n"
+"NAME\n"
+"	name of new hsr device (e.g. hsr0)\n"
+"SLAVE1-IF, SLAVE2-IF\n"
+"	the two slave devices bound to the HSR device\n"
+"ADDR-BYTE\n"
+"	0-255; the last byte of the multicast address used for HSR supervisi=
on\n"
+"	frames (default =3D 0)\n");
+}
+
+static int hsr_parse_opt(struct link_util *lu, int argc, char **argv,
+			  struct nlmsghdr *n)
+{
+	int ifindex;
+	unsigned char multicast_spec;
+
+	while (argc > 0) {
+		if (matches(*argv, "multicast") =3D=3D 0) {
+			NEXT_ARG();
+			if (get_u8(&multicast_spec, *argv, 0))
+				invarg("ADDR-BYTE is invalid", *argv);
+			addattr_l(n, 1024, IFLA_HSR_MULTICAST_SPEC, &multicast_spec, 1);
+		} else if (matches(*argv, "slave1") =3D=3D 0) {
+			NEXT_ARG();
+			ifindex =3D ll_name_to_index(*argv);
+			if (ifindex =3D=3D 0)
+				invarg("No such interface", *argv);
+			addattr_l(n, 1024, IFLA_HSR_SLAVE1, &ifindex, 4);
+		} else if (matches(*argv, "slave2") =3D=3D 0) {
+			NEXT_ARG();
+			ifindex =3D ll_name_to_index(*argv);
+			if (ifindex =3D=3D 0)
+				invarg("No such interface", *argv);
+			addattr_l(n, 1024, IFLA_HSR_SLAVE2, &ifindex, 4);
+		} else if (matches(*argv, "help") =3D=3D 0) {
+			usage();
+			return -1;
+		} else {
+			fprintf(stderr, "hsr: what is \"%s\"?\n", *argv);
+			usage();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	return 0;
+}
+
+static void hsr_print_opt(struct link_util *lu, FILE *f, struct rtattr=
 *tb[])
+{
+	fprintf(f, "hsr_print_opt() called\n");
+}
+
+struct link_util hsr_link_util =3D {
+	.id		=3D "hsr",
+	.maxattr	=3D IFLA_VLAN_MAX,
+	.parse_opt	=3D hsr_parse_opt,
+	.print_opt	=3D hsr_print_opt,
+};
--=20
1.8.1.5



--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
