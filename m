From: =?utf-8?B?6rmA7J6s7Je0?= <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
Subject: [HELP] for using class group classifier network controller
Date: Mon, 15 Jun 2009 09:56:57 +0900
Message-ID: <4C86297B4AC6554B8BA018F0806590CE01C8AFA5@email1>
Reply-To: =?utf-8?B?6rmA7J6s7Je0?= <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>, <tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi.

 

I'm trying to use class group classifier network controller written by Thomas Graf.

But it doesn't work well.

I need a help to use this network classifier collectly

 

Below is the my testing environment

 

kernel : 2.6.29

iproute : iproute2-2.6.29-1 + net_cls patch

 

I compiled kernel in order to use control group classifier by enabling  CGROUPS and NET_CLS_CGROUPS and other cgroup related options.

And I operated like this.

 

mkdir -p /dev/cpuctl/

mount -t cgroup net_cls -onet_cls /dev/cpuctl

mkdir /dev/cpuctl/foo

mkdir /dev/cpuctl/bob

 

# classid 1:10

echo 0x1000A > /dev/cpuctl/foo/net_cls.classid

#classid 1:20

echo 0x10014 > /dev/cpuctl/bob/net_cls.classid

 

And I put two bashshell's pid into foo and bob group

 

echo $$ > /dev/cpuctl/foo/task

echo $$ > /dev/cpuctl/bob/task

 

And then I configured the kernel's traffic control policy

 

TC = /sbin/tc

$TC qdisc delete dev eth0 root

 

$TC qdisc add dev eth0 root handle 1: htb default 10 r2q 200

 

# add class 1:10 for foo group

$TC class add dev eth0 parent 1:0 classid 1:10 htb rate 50mbit

# add class 1:20 for bob group

$TC class add dev eth0 parent 1:0 classid 1:20 htb rate 30mbit

# default class

$TC class add dev eth0 parent 1:0 classid 1:30 htb rate 10mbit

 

# add net_cls filter for class foo and bob

$TC filter add dev eth0 parent 1: protocol ip prio 10 handle 100: cgroup

# default class filter
$TC filter add dev eth0 parent 1: protocol ip prio 20 basic classid 1:30

After finishing this configuration, I ran the iperf  for measuring the network BW.

Iperf showd about 10mbps in each group.

10mbps is the rate of class 1:30, default class.

 

When I send a data in group foo or group bob, the data rate is equal to default class 1:30 rate,

so I think kernel couldn't identify classified packet from normal packet.

What is wrong?

 

I expect your kindness.

 

- Cheiyol Kim

 

*************************************************************************************

 

This is the iproute patch

 

--- ./iproute2-2.6.29-1/tc/Makefile     2009-03-25 07:40:54.000000000 +0900
+++ ./iproute2-2.6.29-1-mod/tc/Makefile 2009-06-02 17:33:21.000000000 +0900
@@ -20,6 +20,7 @@
 TCMODULES += f_fw.o
 TCMODULES += f_basic.o
 TCMODULES += f_flow.o
+TCMODULES += f_cgroup.o
 TCMODULES += q_dsmark.o
 TCMODULES += q_gred.o
 TCMODULES += f_tcindex.o

--- ./iproute2-2.6.29-1/tc/NULL 1970-01-01 09:00:00.000000000 +0900
+++ ./iproute2-2.6.29-1-mod/tc/f_cgroup.c       2009-06-02 17:32:47.000000000 +0900
@@ -0,0 +1,101 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include "utils.h"
+#include "tc_util.h"
+#include "m_ematch.h"
+
+static void explain(void)
+{
+       fprintf(stderr, "Usage: ... cgroup [ match EMATCH_TREE ] [ police POLICE_SPEC ]\n");
+       fprintf(stderr, "                 [ action ACTION_SPEC ]\n");
+}
+
+static int cgroup_parse_opt(struct filter_util *qu, char *handle,
+                          int argc, char **argv, struct nlmsghdr *n) {
+       struct tcmsg *t = NLMSG_DATA(n);
+       struct rtattr *tail;
+       long h = 0;
+
+       if (handle) {
+               h = strtol(handle, NULL, 0);
+               if (h == LONG_MIN || h == LONG_MAX) {
+                       fprintf(stderr, "Illegal handle \"%s\", must be numeric.\n",
+                           handle);
+                       return -1;
+               }
+       }
+
+       t->tcm_handle = h;
+
+       tail = (struct rtattr*)(((void*)n)+NLMSG_ALIGN(n->nlmsg_len));
+       addattr_l(n, MAX_MSG, TCA_OPTIONS, NULL, 0);
+
+       while (argc > 0) {
+               if (matches(*argv, "match") == 0) {
+                       NEXT_ARG();
+                       if (parse_ematch(&argc, &argv, TCA_CGROUP_EMATCHES, n)) {
+                               fprintf(stderr, "Illegal \"ematch\"\n");
+                               return -1;
+                       }
+                       continue;
+               } else if (matches(*argv, "action") == 0) {
+                       NEXT_ARG();
+                       if (parse_action(&argc, &argv, TCA_CGROUP_ACT, n)) {
+                               fprintf(stderr, "Illegal \"action\"\n");
+                               return -1;
+                       }
+                       continue;
+
+               } else if (matches(*argv, "police") == 0) {
+                       NEXT_ARG();
+                       if (parse_police(&argc, &argv, TCA_CGROUP_POLICE, n)) {
+                               fprintf(stderr, "Illegal \"police\"\n");
+                               return -1;
+                       }
+                       continue;
+               } else if (strcmp(*argv, "help") == 0) {
+                       explain();
+                       return -1;
+               } else {
+                       fprintf(stderr, "What is \"%s\"?\n", *argv);
+                       explain();
+                       return -1;
+               }
+               argc--; argv++;
+       }
+
+       tail->rta_len = (((void*)n)+n->nlmsg_len) - (void*)tail;
+       return 0;
+}
+
+static int cgroup_print_opt(struct filter_util *qu, FILE *f,
+                          struct rtattr *opt, __u32 handle) {
+       struct rtattr *tb[TCA_CGROUP_MAX+1];
+
+       if (opt == NULL)
+               return 0;
+
+       parse_rtattr_nested(tb, TCA_CGROUP_MAX, opt);
+
+       if (handle)
+               fprintf(f, "handle 0x%x ", handle);
+
+       if (tb[TCA_CGROUP_EMATCHES])
+               print_ematch(f, tb[TCA_CGROUP_EMATCHES]);
+
+       if (tb[TCA_CGROUP_POLICE]) {
+               fprintf(f, "\n");
+               tc_print_police(f, tb[TCA_CGROUP_POLICE]);
+       }
+
+       if (tb[TCA_CGROUP_ACT])
+               tc_print_action(f, tb[TCA_CGROUP_ACT]);
+
+       return 0;
+}
+
+struct filter_util cgroup_filter_util = {
+       .id = "cgroup",
+       .parse_fopt = cgroup_parse_opt,
+       .print_fopt = cgroup_print_opt,
+};
