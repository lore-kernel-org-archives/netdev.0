From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH v4 iproute2] ip: Add color output option
Date: Tue, 28 Apr 2015 12:34:12 +0200
Message-ID: <CAGm1_ksSn7p98k5OynBUR5Q7sqJRvhwbe9+Gw_Xb_me-3mSW=A@mail.gmail.com>
References: <20150428101821.GA25794@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	aleksi.aalto@iki.fi
To: Mathias Nyman <m.nyman@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f196.google.com ([209.85.192.196]:36451 "EHLO
	mail-pd0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933112AbbD1Ked (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 06:34:33 -0400
Received: by pdev10 with SMTP id v10so43638592pde.3
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 03:34:32 -0700 (PDT)
In-Reply-To: <20150428101821.GA25794@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 12:18 PM, Mathias Nyman <m.nyman@iki.fi> wrote:
> It is hard to quickly find what you are looking for in the output of the
> ip command. Color helps.
>
> This patch adds a '-c' flag to highlight these with individual colors:
>   - interface name
>   - ip address
>   - mac address
>   - up/down state
>
> Signed-off-by: Mathias Nyman <m.nyman@iki.fi>

Tested-by: Yegor Yefremov <yegorslists@googlemail.com>

> ---
>
> v4 - Remove leading spaces added by email client
>
>  include/color.h | 16 +++++++++++++++
>  ip/ip.c         |  5 ++++-
>  ip/ipaddress.c  | 43 ++++++++++++++++++++++++++++----------
>  lib/Makefile    |  2 +-
>  lib/color.c     | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  man/man8/ip.8   |  7 ++++++-
>  6 files changed, 123 insertions(+), 14 deletions(-)
>  create mode 100644 include/color.h
>  create mode 100644 lib/color.c
>
> diff --git a/include/color.h b/include/color.h
> new file mode 100644
> index 0000000..b85003a
> --- /dev/null
> +++ b/include/color.h
> @@ -0,0 +1,16 @@
> +#ifndef __COLOR_H__
> +#define __COLOR_H__ 1
> +
> +enum color_attr {
> +       COLOR_IFNAME,
> +       COLOR_MAC,
> +       COLOR_INET,
> +       COLOR_INET6,
> +       COLOR_OPERSTATE_UP,
> +       COLOR_OPERSTATE_DOWN
> +};
> +
> +void enable_color(void);
> +int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...);
> +
> +#endif
> diff --git a/ip/ip.c b/ip/ip.c
> index f7f214b..c23de74 100644
> --- a/ip/ip.c
> +++ b/ip/ip.c
> @@ -23,6 +23,7 @@
>  #include "utils.h"
>  #include "ip_common.h"
>  #include "namespace.h"
> +#include "color.h"
>
>  int preferred_family = AF_UNSPEC;
>  int human_readable = 0;
> @@ -56,7 +57,7 @@ static void usage(void)
>  "                    -4 | -6 | -I | -D | -B | -0 |\n"
>  "                    -l[oops] { maximum-addr-flush-attempts } |\n"
>  "                    -o[neline] | -t[imestamp] | -ts[hort] | -b[atch] [filename] |\n"
> -"                    -rc[vbuf] [size] | -n[etns] name | -a[ll] }\n");
> +"                    -rc[vbuf] [size] | -n[etns] name | -a[ll] | -c[olor]}\n");
>         exit(-1);
>  }
>
> @@ -257,6 +258,8 @@ int main(int argc, char **argv)
>                                 exit(-1);
>                         }
>                         rcvbuf = size;
> +               } else if (matches(opt, "-color") == 0) {
> +                       enable_color();
>                 } else if (matches(opt, "-help") == 0) {
>                         usage();
>                 } else if (matches(opt, "-netns") == 0) {
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index e582da0..92afa49 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -34,6 +34,7 @@
>  #include "utils.h"
>  #include "ll_map.h"
>  #include "ip_common.h"
> +#include "color.h"
>
>  enum {
>         IPADD_LIST,
> @@ -136,8 +137,15 @@ static void print_operstate(FILE *f, __u8 state)
>  {
>         if (state >= sizeof(oper_states)/sizeof(oper_states[0]))
>                 fprintf(f, "state %#x ", state);
> -       else
> -               fprintf(f, "state %s ", oper_states[state]);
> +       else {
> +               fprintf(f, "state ");
> +               if (strcmp(oper_states[state], "UP") == 0)
> +                       color_fprintf(f, COLOR_OPERSTATE_UP, "%s ", oper_states[state]);
> +               else if (strcmp(oper_states[state], "DOWN") == 0)
> +                       color_fprintf(f, COLOR_OPERSTATE_DOWN, "%s ", oper_states[state]);
> +               else
> +                       fprintf(f, "%s ", oper_states[state]);
> +       }
>  }
>
>  int get_operstate(const char *name)
> @@ -606,7 +614,8 @@ int print_linkinfo(const struct sockaddr_nl *who,
>         if (n->nlmsg_type == RTM_DELLINK)
>                 fprintf(fp, "Deleted ");
>
> -       fprintf(fp, "%d: %s", ifi->ifi_index,
> +       fprintf(fp, "%d: ", ifi->ifi_index);
> +       color_fprintf(fp, COLOR_IFNAME, "%s",
>                 tb[IFLA_IFNAME] ? rta_getattr_str(tb[IFLA_IFNAME]) : "<nil>");
>
>         if (tb[IFLA_LINK]) {
> @@ -666,10 +675,11 @@ int print_linkinfo(const struct sockaddr_nl *who,
>                 fprintf(fp, "    link/%s ", ll_type_n2a(ifi->ifi_type, b1, sizeof(b1)));
>
>                 if (tb[IFLA_ADDRESS]) {
> -                       fprintf(fp, "%s", ll_addr_n2a(RTA_DATA(tb[IFLA_ADDRESS]),
> -                                                     RTA_PAYLOAD(tb[IFLA_ADDRESS]),
> -                                                     ifi->ifi_type,
> -                                                     b1, sizeof(b1)));
> +                       color_fprintf(fp, COLOR_MAC, "%s",
> +                                       ll_addr_n2a(RTA_DATA(tb[IFLA_ADDRESS]),
> +                                               RTA_PAYLOAD(tb[IFLA_ADDRESS]),
> +                                               ifi->ifi_type,
> +                                               b1, sizeof(b1)));
>                 }
>                 if (tb[IFLA_BROADCAST]) {
>                         if (ifi->ifi_flags&IFF_POINTOPOINT)
> @@ -849,10 +859,21 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
>                 fprintf(fp, "    family %d ", ifa->ifa_family);
>
>         if (rta_tb[IFA_LOCAL]) {
> -               fprintf(fp, "%s", format_host(ifa->ifa_family,
> -                                             RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
> -                                             RTA_DATA(rta_tb[IFA_LOCAL]),
> -                                             abuf, sizeof(abuf)));
> +               if (ifa->ifa_family == AF_INET)
> +                       color_fprintf(fp, COLOR_INET, "%s", format_host(ifa->ifa_family,
> +                                               RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
> +                                               RTA_DATA(rta_tb[IFA_LOCAL]),
> +                                               abuf, sizeof(abuf)));
> +               else if (ifa->ifa_family == AF_INET6)
> +                       color_fprintf(fp, COLOR_INET6, "%s", format_host(ifa->ifa_family,
> +                                               RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
> +                                               RTA_DATA(rta_tb[IFA_LOCAL]),
> +                                               abuf, sizeof(abuf)));
> +               else
> +                       fprintf(fp, "%s", format_host(ifa->ifa_family,
> +                                               RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
> +                                               RTA_DATA(rta_tb[IFA_LOCAL]),
> +                                               abuf, sizeof(abuf)));
>
>                 if (rta_tb[IFA_ADDRESS] == NULL ||
>                     memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]), RTA_DATA(rta_tb[IFA_LOCAL]),
> diff --git a/lib/Makefile b/lib/Makefile
> index 4c7cbc2..1d4045f 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -7,7 +7,7 @@ endif
>  CFLAGS += -fPIC
>
>  UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o namespace.o \
> -       names.o
> +       names.o color.o
>
>  NLOBJ=libgenl.o ll_map.o libnetlink.o
>
> diff --git a/lib/color.c b/lib/color.c
> new file mode 100644
> index 0000000..8c9a48b
> --- /dev/null
> +++ b/lib/color.c
> @@ -0,0 +1,64 @@
> +#include <stdio.h>
> +#include <stdarg.h>
> +
> +#include "color.h"
> +
> +enum color {
> +       C_RED,
> +       C_GREEN,
> +       C_YELLOW,
> +       C_BLUE,
> +       C_MAGENTA,
> +       C_CYAN,
> +       C_WHITE,
> +       C_CLEAR
> +};
> +
> +static const char * const color_codes[] = {
> +       "\e[31m",
> +       "\e[32m",
> +       "\e[33m",
> +       "\e[34m",
> +       "\e[35m",
> +       "\e[36m",
> +       "\e[37m",
> +       "\e[0m",
> +       NULL,
> +};
> +
> +static enum color attr_colors[] = {
> +       C_CYAN,
> +       C_YELLOW,
> +       C_MAGENTA,
> +       C_BLUE,
> +       C_GREEN,
> +       C_RED
> +};
> +
> +static int color_is_enabled;
> +
> +void enable_color(void)
> +{
> +       color_is_enabled = 1;
> +}
> +
> +int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
> +{
> +       int ret = 0;
> +       va_list args;
> +
> +       va_start(args, fmt);
> +
> +       if (!color_is_enabled) {
> +               ret = vfprintf(fp, fmt, args);
> +               goto end;
> +       }
> +
> +       ret += fprintf(fp, "%s", color_codes[attr_colors[attr]]);
> +       ret += vfprintf(fp, fmt, args);
> +       ret += fprintf(fp, "%s", color_codes[C_CLEAR]);
> +
> +end:
> +       va_end(args);
> +       return ret;
> +}
> diff --git a/man/man8/ip.8 b/man/man8/ip.8
> index 44d1ee6..43ddac9 100644
> --- a/man/man8/ip.8
> +++ b/man/man8/ip.8
> @@ -33,7 +33,8 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
>  .BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
>  \fB\-o\fR[\fIneline\fR] |
>  \fB\-n\fR[\fIetns\fR] name |
> -\fB\-a\fR[\fIll\fR] }
> +\fB\-a\fR[\fIll\fR] |
> +\fB\-c\fR[\fIolor\fR] }
>
>
>  .SH OPTIONS
> @@ -165,6 +166,10 @@ to
>  .BR "\-a" , " \-all"
>  executes specified command over all objects, it depends if command supports this option.
>
> +.TP
> +.BR "\-c" , " -color"
> +Use color output.
> +
>  .SH IP - COMMAND SYNTAX
>
>  .SS
> --
> 2.3.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
