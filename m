From: Mathias Nyman <m.nyman@iki.fi>
Subject: [PATCH net-next] ip: Add color output option
Date: Fri, 17 Apr 2015 16:02:02 +0300
Message-ID: <20150417130202.GA29596@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: aleksi.aalto@iki.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:43905 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865AbbDQNCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2015 09:02:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is hard to quickly find what you are looking for in the output of th=
e ip
command. Color helps.

This patch adds a '-c' flag to highlight these with individual colors:
   - interface name
   - ip addresse
   - mac addresse
   - up/down state


---
  include/color.h | 17 ++++++++++++++++
  ip/Makefile     |  2 +-
  ip/color.c      | 63 ++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++++
  ip/ip.c         |  5 ++++-
  ip/ipaddress.c  | 43 +++++++++++++++++++++++++++++----------
  man/man8/ip.8   |  7 ++++++-
  6 files changed, 123 insertions(+), 14 deletions(-)
  create mode 100644 include/color.h
  create mode 100644 ip/color.c

diff --git a/include/color.h b/include/color.h
new file mode 100644
index 0000000..1662c62
--- /dev/null
+++ b/include/color.h
@@ -0,0 +1,17 @@
+#ifndef __COLOR_H__
+#define __COLOR_H__ 1
+
+enum color_attr
+{
+       COLOR_IFNAME,
+       COLOR_MAC,
+       COLOR_INET,
+       COLOR_INET6,
+       COLOR_OPERSTATE_UP,
+       COLOR_OPERSTATE_DOWN
+};
+
+void enable_color(void);
+int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...=
);
+
+#endif
diff --git a/ip/Makefile b/ip/Makefile
index 5637bcf..ac35131 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -6,7 +6,7 @@ IPOBJ=3Dip.o ipaddress.o ipaddrlabel.o iproute.o iprule=
=2Eo ipnetns.o \
      iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o link_vti6.o=
 \
      iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6t=
nl.o \
      link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink=
_hsr.o \
-    iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o
+    iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o colo=
r.o
 =20
  RTMONOBJ=3Drtmon.o
 =20
diff --git a/ip/color.c b/ip/color.c
new file mode 100644
index 0000000..2e73fcb
--- /dev/null
+++ b/ip/color.c
@@ -0,0 +1,63 @@
+#include <stdio.h>
+#include <stdarg.h>
+
+#include "color.h"
+
+enum color
+{
+       C_RED,
+       C_GREEN,
+       C_YELLOW,
+       C_BLUE,
+       C_MAGENTA,
+       C_CYAN,
+       C_WHITE,
+       C_CLEAR
+};
+
+static const char * const color_codes[] =3D
+{
+       "\e[31m",
+       "\e[32m",
+       "\e[33m",
+       "\e[34m",
+       "\e[35m",
+       "\e[36m",
+       "\e[37m",
+       "\e[0m",
+       NULL,
+};
+
+static enum color attr_colors[] =3D
+{
+       C_CYAN,
+       C_YELLOW,
+       C_MAGENTA,
+       C_BLUE,
+       C_GREEN,
+       C_RED
+};
+
+static int color_enable =3D 0;
+
+void enable_color(void)
+{
+       ++color_enable;
+}
+
+int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...=
)
+{
+       int ret =3D 0;
+       va_list args;
+       va_start(args, fmt);
+
+       if (!color_enable)
+               return vfprintf(fp, fmt, args);
+
+       ret +=3D fprintf(fp, "%s", color_codes[attr_colors[attr]]);
+       ret +=3D vfprintf(fp, fmt, args);
+       ret +=3D fprintf(fp, "%s", color_codes[C_CLEAR]);
+
+       va_end(args);
+       return ret;
+}
diff --git a/ip/ip.c b/ip/ip.c
index f7f214b..c23de74 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -23,6 +23,7 @@
  #include "utils.h"
  #include "ip_common.h"
  #include "namespace.h"
+#include "color.h"
 =20
  int preferred_family =3D AF_UNSPEC;
  int human_readable =3D 0;
@@ -56,7 +57,7 @@ static void usage(void)
  "                    -4 | -6 | -I | -D | -B | -0 |\n"
  "                    -l[oops] { maximum-addr-flush-attempts } |\n"
  "                    -o[neline] | -t[imestamp] | -ts[hort] | -b[atch]=
 [filename] |\n"
-"                    -rc[vbuf] [size] | -n[etns] name | -a[ll] }\n");
+"                    -rc[vbuf] [size] | -n[etns] name | -a[ll] |=A0-c[=
olor]}\n");
         exit(-1);
  }
 =20
@@ -257,6 +258,8 @@ int main(int argc, char **argv)
                                 exit(-1);
                         }
                         rcvbuf =3D size;
+               } else if (matches(opt, "-color") =3D=3D 0) {
+                       enable_color();
                 } else if (matches(opt, "-help") =3D=3D 0) {
                         usage();
                 } else if (matches(opt, "-netns") =3D=3D 0) {
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index e582da0..92afa49 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -34,6 +34,7 @@
  #include "utils.h"
  #include "ll_map.h"
  #include "ip_common.h"
+#include "color.h"
 =20
  enum {
         IPADD_LIST,
@@ -136,8 +137,15 @@ static void print_operstate(FILE *f, __u8 state)
  {
         if (state >=3D sizeof(oper_states)/sizeof(oper_states[0]))
                 fprintf(f, "state %#x ", state);
-       else
-               fprintf(f, "state %s ", oper_states[state]);
+       else {
+               fprintf(f, "state ");
+               if (strcmp(oper_states[state], "UP") =3D=3D 0)
+                       color_fprintf(f, COLOR_OPERSTATE_UP, "%s ", ope=
r_states[state]);
+               else if (strcmp(oper_states[state], "DOWN") =3D=3D 0)
+                       color_fprintf(f, COLOR_OPERSTATE_DOWN, "%s ", o=
per_states[state]);
+               else
+                       fprintf(f, "%s ", oper_states[state]);
+       }
  }
 =20
  int get_operstate(const char *name)
@@ -606,7 +614,8 @@ int print_linkinfo(const struct sockaddr_nl *who,
         if (n->nlmsg_type =3D=3D RTM_DELLINK)
                 fprintf(fp, "Deleted ");
 =20
-       fprintf(fp, "%d: %s", ifi->ifi_index,
+       fprintf(fp, "%d: ", ifi->ifi_index);
+       color_fprintf(fp, COLOR_IFNAME, "%s",
                 tb[IFLA_IFNAME] ? rta_getattr_str(tb[IFLA_IFNAME]) : "=
<nil>");
 =20
         if (tb[IFLA_LINK]) {
@@ -666,10 +675,11 @@ int print_linkinfo(const struct sockaddr_nl *who,
                 fprintf(fp, "    link/%s ", ll_type_n2a(ifi->ifi_type,=
 b1, sizeof(b1)));
 =20
                 if (tb[IFLA_ADDRESS]) {
-                       fprintf(fp, "%s", ll_addr_n2a(RTA_DATA(tb[IFLA_=
ADDRESS]),
-                                                     RTA_PAYLOAD(tb[IF=
LA_ADDRESS]),
-                                                     ifi->ifi_type,
-                                                     b1, sizeof(b1)));
+                       color_fprintf(fp, COLOR_MAC, "%s",
+                                       ll_addr_n2a(RTA_DATA(tb[IFLA_AD=
DRESS]),
+                                               RTA_PAYLOAD(tb[IFLA_ADD=
RESS]),
+                                               ifi->ifi_type,
+                                               b1, sizeof(b1)));
                 }
                 if (tb[IFLA_BROADCAST]) {
                         if (ifi->ifi_flags&IFF_POINTOPOINT)
@@ -849,10 +859,21 @@ int print_addrinfo(const struct sockaddr_nl *who,=
 struct nlmsghdr *n,
                 fprintf(fp, "    family %d ", ifa->ifa_family);
 =20
         if (rta_tb[IFA_LOCAL]) {
-               fprintf(fp, "%s", format_host(ifa->ifa_family,
-                                             RTA_PAYLOAD(rta_tb[IFA_LO=
CAL]),
-                                             RTA_DATA(rta_tb[IFA_LOCAL=
]),
-                                             abuf, sizeof(abuf)));
+               if (ifa->ifa_family =3D=3D AF_INET)
+                       color_fprintf(fp, COLOR_INET, "%s", format_host=
(ifa->ifa_family,
+                                               RTA_PAYLOAD(rta_tb[IFA_=
LOCAL]),
+                                               RTA_DATA(rta_tb[IFA_LOC=
AL]),
+                                               abuf, sizeof(abuf)));
+               else if (ifa->ifa_family =3D=3D AF_INET6)
+                       color_fprintf(fp, COLOR_INET6, "%s", format_hos=
t(ifa->ifa_family,
+                                               RTA_PAYLOAD(rta_tb[IFA_=
LOCAL]),
+                                               RTA_DATA(rta_tb[IFA_LOC=
AL]),
+                                               abuf, sizeof(abuf)));
+               else
+                       fprintf(fp, "%s", format_host(ifa->ifa_family,
+                                               RTA_PAYLOAD(rta_tb[IFA_=
LOCAL]),
+                                               RTA_DATA(rta_tb[IFA_LOC=
AL]),
+                                               abuf, sizeof(abuf)));
 =20
                 if (rta_tb[IFA_ADDRESS] =3D=3D NULL ||
                     memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]), RTA_DATA(rta=
_tb[IFA_LOCAL]),
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 44d1ee6..43ddac9 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -33,7 +33,8 @@ ip \- show / manipulate routing, devices, policy rout=
ing and tunnels
  .BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
  \fB\-o\fR[\fIneline\fR] |
  \fB\-n\fR[\fIetns\fR] name |
-\fB\-a\fR[\fIll\fR] }
+\fB\-a\fR[\fIll\fR] |
+\fB\-c\fR[\fIolor\fR] }
 =20
 =20
  .SH OPTIONS
@@ -165,6 +166,10 @@ to
  .BR "\-a" , " \-all"
  executes specified command over all objects, it depends if command su=
pports this option.
 =20
+.TP
+.BR "\-c" , " -color"
+Use color output.
+
  .SH IP - COMMAND SYNTAX
 =20
  .SS
--=20
2.3.5
