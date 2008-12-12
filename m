From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] IPROUTE: add support for skbedit action
Date: Fri, 12 Dec 2008 02:31:41 -0800
Message-ID: <9929d2390812120231u20161604jd0abf90478112439@mail.gmail.com>
References: <20081205221609.7949.26787.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Alexander Duyck" <alexander.h.duyck@intel.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:53077 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbYLLKbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 05:31:43 -0500
Received: by ewy10 with SMTP id 10so1683686ewy.13
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2008 02:31:41 -0800 (PST)
In-Reply-To: <20081205221609.7949.26787.stgit@gitlost.lost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2008 at 2:16 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> Add support for skbedit action.
>        Provides ability to edit queue_mapping field
>        Provides ability to edit priority field
>
> usage: action skbedit [queue_mapping QUEUE_MAPPING] [priority PRIORITY]
>        at least one option must be select, or both at the same time
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>
>  include/linux/tc_act/tc_skbedit.h |   43 ++++++++
>  tc/Makefile                       |    1
>  tc/m_skbedit.c                    |  192 +++++++++++++++++++++++++++++++++++++
>  3 files changed, 236 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/tc_act/tc_skbedit.h
>  create mode 100644 tc/m_skbedit.c
>
> diff --git a/include/linux/tc_act/tc_skbedit.h b/include/linux/tc_act/tc_skbedit.h
> new file mode 100644
> index 0000000..98311f0
> --- /dev/null
> +++ b/include/linux/tc_act/tc_skbedit.h
> @@ -0,0 +1,43 @@
> +/* Copyright (c) 2008, Intel Corporation.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License along with
> + * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
> + * Place - Suite 330, Boston, MA 02111-1307 USA.
> + *
> + * Author: Alexander Duyck <alexander.h.duyck@intel.com>
> + */
> +
> +#ifndef __LINUX_TC_SKBEDIT_H
> +#define __LINUX_TC_SKBEDIT_H
> +
> +#include <linux/pkt_cls.h>
> +
> +#define TCA_ACT_SKBEDIT 11
> +
> +#define SKBEDIT_F_PRIORITY             0x1
> +#define SKBEDIT_F_QUEUE_MAPPING                0x2
> +
> +struct tc_skbedit {
> +       tc_gen;
> +};
> +
> +enum {
> +       TCA_SKBEDIT_UNSPEC,
> +       TCA_SKBEDIT_TM,
> +       TCA_SKBEDIT_PARMS,
> +       TCA_SKBEDIT_PRIORITY,
> +       TCA_SKBEDIT_QUEUE_MAPPING,
> +       __TCA_SKBEDIT_MAX
> +};
> +#define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
> +
> +#endif
> diff --git a/tc/Makefile b/tc/Makefile
> index a3005e9..2fdfdc8 100644
> --- a/tc/Makefile
> +++ b/tc/Makefile
> @@ -30,6 +30,7 @@ TCMODULES += m_mirred.o
>  TCMODULES += m_ipt.o
>  TCMODULES += m_nat.o
>  TCMODULES += m_pedit.o
> +TCMODULES += m_skbedit.o
>  TCMODULES += p_ip.o
>  TCMODULES += p_icmp.o
>  TCMODULES += p_tcp.o
> diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
> new file mode 100644
> index 0000000..55e3f89
> --- /dev/null
> +++ b/tc/m_skbedit.c
> @@ -0,0 +1,192 @@
> +/*
> + * m_skbedit.c         SKB Editing module
> + *
> + * Copyright (c) 2008, Intel Corporation.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License along with
> + * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
> + * Place - Suite 330, Boston, MA 02111-1307 USA.
> + *
> + * Authors:    Alexander Duyck <alexander.h.duyck@intel.com>
> + *
> + */
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <unistd.h>
> +#include <string.h>
> +#include "utils.h"
> +#include "tc_util.h"
> +#include <linux/tc_act/tc_skbedit.h>
> +
> +static void
> +explain(void)
> +{
> +       fprintf(stderr, "Usage: ... skbedit "
> +                       "queue_mapping QUEUE_MAPPING | priority PRIORITY \n"
> +                       "QUEUE_MAPPING = device transmit queue to use\n"
> +                       "PRIORITY = classID to assign to priority field\n");
> +}
> +
> +static void
> +usage(void)
> +{
> +       explain();
> +       exit(-1);
> +}
> +
> +static int
> +parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
> +             struct nlmsghdr *n)
> +{
> +       struct tc_skbedit sel;
> +       int argc = *argc_p;
> +       char **argv = *argv_p;
> +       int ok = 0;
> +       struct rtattr *tail;
> +       unsigned int tmp;
> +       __u16 queue_mapping;
> +       __u32 flags = 0, priority;
> +
> +       if (matches(*argv, "skbedit") != 0)
> +               return -1;
> +
> +       NEXT_ARG();
> +
> +       while (argc > 0) {
> +               if (matches(*argv, "queue_mapping") == 0) {
> +                       flags |= SKBEDIT_F_QUEUE_MAPPING;
> +                       NEXT_ARG();
> +                       if (get_unsigned(&tmp, *argv, 10) || tmp > 65535) {
> +                               fprintf(stderr, "Illegal queue_mapping\n");
> +                               return -1;
> +                       }
> +                       queue_mapping = tmp;
> +                       ok++;
> +               } else if (matches(*argv, "priority") == 0) {
> +                       flags |= SKBEDIT_F_PRIORITY;
> +                       NEXT_ARG();
> +                       if (get_tc_classid(&priority, *argv)) {
> +                               fprintf(stderr, "Illegal priority\n");
> +                               return -1;
> +                       }
> +                       ok++;
> +               } else if (matches(*argv, "help") == 0) {
> +                       usage();
> +               } else {
> +                       break;
> +               }
> +               argc--;
> +               argv++;
> +       }
> +
> +       if (argc) {
> +               if (matches(*argv, "reclassify") == 0) {
> +                       sel.action = TC_ACT_RECLASSIFY;
> +                       NEXT_ARG();
> +               } else if (matches(*argv, "pipe") == 0) {
> +                       sel.action = TC_ACT_PIPE;
> +                       NEXT_ARG();
> +               } else if (matches(*argv, "drop") == 0 ||
> +                       matches(*argv, "shot") == 0) {
> +                       sel.action = TC_ACT_SHOT;
> +                       NEXT_ARG();
> +               } else if (matches(*argv, "continue") == 0) {
> +                       sel.action = TC_ACT_UNSPEC;
> +                       NEXT_ARG();
> +               } else if (matches(*argv, "pass") == 0) {
> +                       sel.action = TC_ACT_OK;
> +                       NEXT_ARG();
> +               }
> +       }
> +
> +       if (argc) {
> +               if (matches(*argv, "index") == 0) {
> +                       NEXT_ARG();
> +                       if (get_u32(&sel.index, *argv, 10)) {
> +                               fprintf(stderr, "Pedit: Illegal \"index\"\n");
> +                               return -1;
> +                       }
> +                       argc--;
> +                       argv++;
> +                       ok++;
> +               }
> +       }
> +
> +       if (!ok) {
> +               explain();
> +               return -1;
> +       }
> +
> +
> +       tail = NLMSG_TAIL(n);
> +       addattr_l(n, MAX_MSG, tca_id, NULL, 0);
> +       addattr_l(n, MAX_MSG, TCA_SKBEDIT_PARMS, &sel, sizeof(sel));
> +       if (flags & SKBEDIT_F_QUEUE_MAPPING)
> +               addattr_l(n, MAX_MSG, TCA_SKBEDIT_QUEUE_MAPPING,
> +                         &queue_mapping, sizeof(queue_mapping));
> +       if (flags & SKBEDIT_F_PRIORITY)
> +               addattr_l(n, MAX_MSG, TCA_SKBEDIT_PRIORITY,
> +                         &priority, sizeof(priority));
> +       tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
> +
> +       *argc_p = argc;
> +       *argv_p = argv;
> +       return 0;
> +}
> +
> +static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
> +{
> +       struct tc_skbedit *sel;
> +       struct rtattr *tb[TCA_SKBEDIT_MAX + 1];
> +       SPRINT_BUF(b1);
> +       __u32 *priority;
> +       __u16 *queue_mapping;
> +
> +       if (arg == NULL)
> +               return -1;
> +
> +       parse_rtattr_nested(tb, TCA_SKBEDIT_MAX, arg);
> +
> +       if (tb[TCA_SKBEDIT_PARMS] == NULL) {
> +               fprintf(f, "[NULL skbedit parameters]");
> +               return -1;
> +       }
> +
> +       sel = RTA_DATA(tb[TCA_SKBEDIT_PARMS]);
> +
> +       fprintf(f, " skbedit");
> +
> +       if (tb[TCA_SKBEDIT_QUEUE_MAPPING] != NULL) {
> +               queue_mapping = RTA_DATA(tb[TCA_SKBEDIT_QUEUE_MAPPING]);
> +               fprintf(f, " queue_mapping %u", *queue_mapping);
> +       }
> +       if (tb[TCA_SKBEDIT_PRIORITY] != NULL) {
> +               priority = RTA_DATA(tb[TCA_SKBEDIT_PRIORITY]);
> +               fprintf(f, " priority %s", sprint_tc_classid(*priority, b1));
> +       }
> +
> +       if (show_stats) {
> +               if (tb[TCA_SKBEDIT_TM]) {
> +                       struct tcf_t *tm = RTA_DATA(tb[TCA_SKBEDIT_TM]);
> +                       print_tm(f, tm);
> +               }
> +       }
> +
> +       return 0;
> +}
> +
> +struct action_util skbedit_action_util = {
> +       .id = "skbedit",
> +       .parse_aopt = parse_skbedit,
> +       .print_aopt = print_skbedit,
> +};
>
> --
>

What is the status of this series of patches?  Stephen?

-- 
Cheers,
Jeff
