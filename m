From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6 5/5]: act_api: mark some functions
	static/remove	unused function
Date: 04 Nov 2004 10:53:59 -0500
Message-ID: <1099583639.1081.30.camel@jzny.localdomain>
References: <4189CB70.3060703@trash.net>
	 <1099576602.1039.151.camel@jzny.localdomain>  <418A4AA0.8070609@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-jsey1+L9qfIUO70ryExe"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <418A4AA0.8070609@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-jsey1+L9qfIUO70ryExe
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2004-11-04 at 10:28, Patrick McHardy wrote:
> jamal wrote:

> >Please dont.
> >
> Ok, here is the same patch without removing tc_lookup_action_id.
> It is instead surrounded by #if 0.


Why is this function bothering you? ;->
Why do you need to put the #if 0?

> >I am incrementally submitting patches.
> >
> I was about to do more cleanup, please stop me if you are already doing
> any of this:
> 

My changes will be new stuff going in. So any cleanup is welcome.

> - move the functions from include/net/pkt_act.h to act_generic.c

Some of the larger ones make sense to move. Whats the main reason for
moving them?

> - convert lastuse/install/expires to USER_HZ
> - fix ipt: leaks memory at destruction, ovr doesn't work, doesn't refcount
>   iptables module references
> 

These two make sense. I need help eyeballing the iptables stuff.
I commented out some of the refcount attempts; also i think quiet a
few targets are not friendly in getting accessed by anything other than
iptables; I was going at some point fix them and send you guys patches.
Maybe you can help me in this area as well.

> Is there already userspace-code for anything besides gact ?
> I would like to test my changes.
> 

Stephen is probably stalled somewhere because he hasnt been sucking in
my updates to iproute2.
I have the latest and greatest on my test machine at home. But here
are tc updates for ipt and mirred that i could find on my laptop.
The ipt patch needs iptables libraries and may not work with latest
iptables (although the one at home will surely work). The problem is 
some of the iptables functions were updated. It would be nice if i didnt
have to maintain my own variants in user space.


cheers,
jamal


--=-jsey1+L9qfIUO70ryExe
Content-Disposition: attachment; filename=tc-269-mirred-patch-oct052004
Content-Type: text/plain; name=tc-269-mirred-patch-oct052004; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- /dev/null	1998-05-05 16:32:27.000000000 -0400
+++ /home/hadi/iproute2-2.6.9/tc/m_mirred.c	2004-10-04 11:57:51.000000000 -0400
@@ -0,0 +1,310 @@
+/*
+ * m_egress.c		ingress/egress packet mirror/redir actions module 
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (hadi@cyberus.ca) 
+ * 
+ * TODO: Add Ingress support
+ *
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
+#include "utils.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_mirred.h>
+
+int mirred_d = 1;
+
+static void
+explain(void)
+{
+	fprintf(stderr, "Usage: mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME> \n");
+	fprintf(stderr, "where: \n");
+	fprintf(stderr, "DIRECTION := <ingress | egress>\n");
+	fprintf(stderr, "aCTION := <mirror | redirect>\n");
+	fprintf(stderr, "     : INDEX  is the specific policy instance id\n");
+	fprintf(stderr, "     : DEVICENAME is the devicename \n");
+}
+
+#define usage() return(-1)
+
+char *mirred_n2a(int action)
+{
+	switch (action) {
+	case TCA_EGRESS_REDIR:
+		return "Egress Redirect";
+	case TCA_INGRESS_REDIR:
+		return "Ingress Redirect";
+	case TCA_EGRESS_MIRROR:
+		return "Egress Mirror";
+	case TCA_INGRESS_MIRROR:
+		return "Ingress Mirror";
+	default:
+		return "unknown";
+	}
+}
+
+int
+parse_egress(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
+{
+
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int ok = 0, iok = 0, mirror=0,redir=0;
+	struct tc_mirred p;
+	struct rtattr *tail;
+	char d[16];
+	struct rtnl_handle rth;
+
+	memset(d,0,sizeof(d)-1);
+	memset(&p,0,sizeof(struct tc_mirred));
+
+	while (argc > 0) {
+
+		if (matches(*argv, "action") == 0) {
+			break;
+		} else if (matches(*argv, "egress") == 0) {
+			NEXT_ARG();
+			ok++;
+			continue;
+		} else {
+
+			if (matches(*argv, "index") == 0) {
+				NEXT_ARG();
+				if (get_u32(&p.index, *argv, 10)) {
+					fprintf(stderr, "Illegal \"index\"\n");
+					return -1;
+				}
+				iok++;
+				if (!ok) {
+					argc--;
+					argv++;
+					break;
+				}
+			} else if(!ok) {
+				fprintf(stderr, "was expecting egress (%s)\n", *argv);
+				break;
+
+			} else if (!mirror && matches(*argv, "mirror") == 0) {
+				mirror=1;
+				if (redir) {
+					fprintf(stderr, "Cant have both mirror and redir\n");
+					return -1;
+				}
+				p.eaction = TCA_EGRESS_MIRROR;
+				p.action = TC_ACT_PIPE;
+				ok++;
+			} else if (!redir && matches(*argv, "redirect") == 0) {
+				redir=1;
+				if (mirror) {
+					fprintf(stderr, "Cant have both mirror and redir\n");
+					return -1;
+				}
+				p.eaction = TCA_EGRESS_REDIR;
+				p.action = TC_ACT_STOLEN;
+				ok++;
+			} else if ((redir || mirror) && matches(*argv, "dev") == 0) {
+				NEXT_ARG();
+				if (strlen(d))
+					duparg("dev", *argv);
+
+				strncpy(d, *argv, sizeof(d)-1);
+				argc--;
+				argv++;
+
+				break;
+
+			}
+		}
+
+		NEXT_ARG();
+	}
+
+	if (!ok && !iok) {
+		explain();
+		return -1;
+	}
+
+
+
+	if (d[0])  {
+		int idx;
+		if (rtnl_open(&rth, 0) < 0) {
+			fprintf(stderr, "Cannot open rtnetlink\n");
+			exit(1);
+		}
+		ll_init_map(&rth);
+
+
+		if ((idx = ll_name_to_index(d)) == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n", d);
+			rtnl_close(&rth);
+			return -1;
+		}
+
+		p.ifindex = idx;
+		rtnl_close(&rth);
+	}
+
+
+	if (argc && p.eaction == TCA_EGRESS_MIRROR) {
+
+		if (matches(*argv, "reclassify") == 0) {
+			p.action = TC_POLICE_RECLASSIFY;
+			NEXT_ARG();
+		} else if (matches(*argv, "pipe") == 0) {
+			p.action = TC_POLICE_PIPE;
+			NEXT_ARG();
+		} else if (matches(*argv, "drop") == 0 ||
+			   matches(*argv, "shot") == 0) {
+			p.action = TC_POLICE_SHOT;
+			NEXT_ARG();
+		} else if (matches(*argv, "continue") == 0) {
+			p.action = TC_POLICE_UNSPEC;
+			NEXT_ARG();
+		} else if (matches(*argv, "pass") == 0) {
+			p.action = TC_POLICE_OK;
+			NEXT_ARG();
+		}
+
+	}
+
+	if (argc) {
+		if (iok && matches(*argv, "index") == 0) {
+			fprintf(stderr, "mirred: Illegal double index\n");
+			return -1;
+		} else {
+			if (matches(*argv, "index") == 0) {
+				NEXT_ARG();
+				if (get_u32(&p.index, *argv, 10)) {
+					fprintf(stderr, "mirred: Illegal \"index\"\n");
+					return -1;
+				}
+				argc--;
+				argv++;
+			}
+		}
+	}
+
+	if (mirred_d)
+		fprintf(stdout, "Action %d device %s ifindex %d\n",p.action, d,p.ifindex);
+
+	tail = (struct rtattr *) (((void *) n) + NLMSG_ALIGN(n->nlmsg_len));
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_MIRRED_PARMS, &p, sizeof (p));
+	tail->rta_len =
+	    (((void *) n) + NLMSG_ALIGN(n->nlmsg_len)) - (void *) tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+
+int
+parse_mirred(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
+{
+
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc < 0) {
+		fprintf(stderr,"mirred bad arguement count %d\n", argc);
+		return -1;
+	}
+
+	if (matches(*argv, "mirred") == 0) {
+		NEXT_ARG();
+	} else {
+		fprintf(stderr,"mirred bad arguement %s\n", *argv);
+		return -1;
+	}
+
+
+	if (matches(*argv, "egress") == 0 || matches(*argv, "index") == 0) {
+		int ret = parse_egress(a, &argc, &argv, tca_id, n);
+		if (ret == 0) {
+			*argc_p = argc;
+			*argv_p = argv;
+			return 0;
+		}
+
+	} else if (matches(*argv, "ingress") == 0) {
+		fprintf(stderr,"mirred ingress not supported at the moment\n");
+
+	} else {
+		fprintf(stderr,"mirred not supported %s\n", *argv);
+	}
+
+	return -1;
+	
+}
+
+int
+print_mirred(struct action_util *au,FILE * f, struct rtattr *arg)
+{
+	struct tc_mirred *p;
+	struct rtattr *tb[TCA_MIRRED_MAX + 1];
+	struct rtnl_handle rth;
+	const char *dev;
+	SPRINT_BUF(b1);
+
+	if (arg == NULL)
+		return -1;
+
+	memset(tb, 0, sizeof (tb));
+	parse_rtattr(tb, TCA_MIRRED_MAX, RTA_DATA(arg), RTA_PAYLOAD(arg));
+
+	if (tb[TCA_MIRRED_PARMS] == NULL) {
+		fprintf(f, "[NULL mirred parameters]");
+		return -1;
+	}
+	p = RTA_DATA(tb[TCA_MIRRED_PARMS]);
+
+	if (rtnl_open(&rth, 0) < 0) {
+		fprintf(stderr, "Cannot open rtnetlink\n");
+		return -1;
+	}
+
+	ll_init_map(&rth);
+
+
+	if ((dev = ll_index_to_name(p->ifindex)) == 0) {
+		fprintf(stderr, "Cannot find device %d\n", p->ifindex);
+		rtnl_close(&rth);
+		return -1;
+	}
+
+	fprintf(f, "mirred (%s to device %s) %s", mirred_n2a(p->eaction), dev,action_n2a(p->action, b1, sizeof (b1)));
+
+	fprintf(f, "\n ");
+	fprintf(f, "\tindex %d ref %d bind %d",p->index,p->refcnt,p->bindcnt);
+
+	if (show_stats) {
+		if (tb[TCA_MIRRED_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_MIRRED_TM]);
+			print_tm(f,tm);
+		}
+	}
+	fprintf(f, "\n ");
+	rtnl_close(&rth);
+	return 0;
+}
+
+struct action_util mirred_util = {
+	.id = "mirred",
+	.parse_aopt = parse_mirred,
+	.print_aopt = print_mirred,
+};
--- /dev/null	1998-05-05 16:32:27.000000000 -0400
+++ /home/hadi/iproute2-2.6.9/include/linux/tc_act/tc_mirred.h	2004-10-04 11:34:03.000000000 -0400
@@ -0,0 +1,28 @@
+#ifndef __LINUX_TC_MIR_H
+#define __LINUX_TC_MIR_H
+
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_MIRRED 8
+#define TCA_EGRESS_REDIR 1  /* packet redirect to EGRESS*/
+#define TCA_EGRESS_MIRROR 2 /* mirror packet to EGRESS */
+#define TCA_INGRESS_REDIR 3  /* packet redirect to INGRESS*/
+#define TCA_INGRESS_MIRROR 4 /* mirror packet to INGRESS */
+                                                                                
+struct tc_mirred
+{
+	tc_gen;
+	int                     eaction;   /* one of IN/EGRESS_MIRROR/REDIR */
+	__u32                   ifindex;  /* ifindex of egress port */
+};
+                                                                                
+enum
+{
+	TCA_MIRRED_UNSPEC,
+	TCA_MIRRED_TM,
+	TCA_MIRRED_PARMS,
+	__TCA_MIRRED_MAX
+};
+#define TCA_MIRRED_MAX (__TCA_MIRRED_MAX - 1)
+                                                                                
+#endif
--- /home/hadi/iproute2-2.6.9/configure	2004/10/04 15:31:54	1.1
+++ /home/hadi/iproute2-2.6.9/configure	2004/10/04 15:36:07
@@ -26,12 +26,19 @@
 fi
 rm -f /tmp/atmtest.c /tmp/atmtest
 
-# hack for now 
+# hacks for now 
 echo "TC actions"
 
 if [ -e "tc/m_gact.c" ]
 then
+	echo "   GACT found"
 	echo "TC_CONFIG_ACTION_GACT=y" >>Config
 	echo "TC_CONFIG_ACTION_PROB=y" >>Config
 fi
 
+if [ -e "tc/m_mirred.c" ]
+then
+	echo "   MIRRED found"
+	echo "TC_CONFIG_ACTION_MIRRED=y" >>Config
+fi
+
--- /dev/null	1998-05-05 16:32:27.000000000 -0400
+++ /home/hadi/iproute2-2.6.9/doc/actions/mirred-usage	2004-10-04 14:38:43.000000000 -0400
@@ -0,0 +1,71 @@
+
+Very funky action. I do plan to add to a few more things to it
+This is the basic stuff. Idea borrowed from the way ethernet switches
+mirror and redirect packets.
+
+Usage: 
+
+mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME> 
+where: 
+DIRECTION := <ingress | egress>
+ACTION := <mirror | redirect>
+INDEX is the specific policy instance id
+DEVICENAME is the devicename
+
+
+Mirroring essentially takes a copy of the packet whereas redirecting
+steals the packet and redirects to specified destination.
+
+Some examples:
+Host A is hooked  up to us on eth0
+
+tc qdisc add dev lo ingress
+# redirect all packets arriving on ingress of lo to eth0
+tc filter add dev lo parent ffff: protocol ip prio 10 u32 \
+match u32 0 0 flowid 1:2 action mirred egress redirect dev eth0
+
+On host A start a tcpdump on interface connecting to us.
+
+on our host ping -c 2 127.0.0.1
+
+Ping would fail sinc all packets are heading out eth0
+tcpudmp on host A would show them
+
+if you substitute the redirect with mirror above as in:
+tc filter add dev lo parent ffff: protocol ip prio 10 u32 \
+match u32 0 0 flowid 1:2 action mirred egress mirror dev eth0
+
+Then you should see the packets on both host A and the local
+stack (i.e ping would work).
+
+Even more funky example:
+
+#
+#allow 1 out 10 packets to randomly make it to the 
+# host A (Randomness uses the netrand generator)
+#
+tc filter add dev lo parent ffff: protocol ip prio 10 u32 \
+match u32 0 0 flowid 1:2 \
+action drop random determ ok 10\
+action mirred egress mirror dev eth0
+
+------
+Example 2:
+# for packets coming from 10.0.0.9:
+#Redirect packets on egress (to ISP A) if you exceed a certain rate
+# to eth1 (to ISP B) if you exceed a certain rate
+#
+
+tc qdisc add dev eth0 handle 1:0 root prio
+
+tc filter add dev eth0 parent 1:0 protocol ip prio 6 u32 \
+match ip src 10.0.0.9/32 flowid 1:16 \
+action police rate 100kbit burst 90k ok \
+action mirred egress mirror dev eth1
+
+---
+
+A more interesting example is when you mirror flows to a dummy device
+so you could tcpdump them (dummy by defaults drops all devices it sees).
+This is a very useful debug feature.
+
--- /home/hadi/iproute2-2.6.9/tc/Makefile	2004/10/04 15:34:15	1.1
+++ /home/hadi/iproute2-2.6.9/tc/Makefile	2004/10/04 15:35:40
@@ -21,6 +21,7 @@
 TCMODULES += q_hfsc.o
 TCMODULES += q_htb.o
 TCMODULES += m_gact.o
+TCMODULES += m_mirred.o
 
 TCOBJ += $(TCMODULES)
 

--=-jsey1+L9qfIUO70ryExe
Content-Disposition: attachment; filename=patch-ipt-tc-269-3
Content-Type: text/plain; name=patch-ipt-tc-269-3; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- /dev/null	2003-09-15 09:40:47.000000000 -0400
+++ /root/iproute2-2.6.9-041019-mod/tc/m_ipt.c	2004-10-25 18:37:57.656805960 -0400
@@ -0,0 +1,683 @@
+/*
+ * m_ipt.c	iptables based targets 
+ * 		utilities mostly ripped from iptables <duh, its the linux way>
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (hadi@cyberus.ca) 
+ * 
+ * TODO: bad bad hardcoding IPT_LIB_DIR and PROC_SYS_MODPROBE
+ *
+*/
+
+#include <syslog.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <iptables.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include "utils.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_ipt.h>
+#include <stdio.h>
+#include <dlfcn.h>
+#include <getopt.h>
+#include <errno.h>
+#include <string.h>
+#include <netdb.h>
+#include <stdlib.h>
+#include <ctype.h>
+#include <stdarg.h>
+#include <limits.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <sys/wait.h>
+
+const char *pname = "tc-ipt";
+const char *tname = "mangle";
+const char *pversion = "0.1";
+
+#ifndef TRUE
+#define TRUE 1
+#endif
+#ifndef FALSE
+#define FALSE 0
+#endif
+
+#ifndef IPT_LIB_DIR
+#define IPT_LIB_DIR "/usr/local/lib/iptables"
+#endif
+
+#ifndef PROC_SYS_MODPROBE
+#define PROC_SYS_MODPROBE "/proc/sys/kernel/modprobe"
+#endif
+
+static char *ipthooks[] = {
+	"NF_IP_PRE_ROUTING",
+	"NF_IP_LOCAL_IN",
+	"NF_IP_FORWARD",
+	"NF_IP_LOCAL_OUT",
+	"NF_IP_POST_ROUTING",
+};
+
+static struct option original_opts[] = {
+	{"jump", 1, 0, 'j'},
+	{0, 0, 0, 0}
+};
+
+static struct iptables_target *t_list = NULL;
+static unsigned int global_option_offset = 0;
+#define OPTION_OFFSET 256
+
+/* no clue why register match is within targets
+ figure out later. Talk to Harald -- JHS
+*/
+void
+register_match(struct iptables_match *me)
+{
+/*      fprintf(stderr, "\nDummy register_match\n"); */
+}
+
+void
+register_target(struct iptables_target *me)
+{
+/*      fprintf(stderr, "\nDummy register_target %s \n", me->name);
+*/
+	me->next = t_list;
+	t_list = me;
+
+}
+
+void
+exit_tryhelp(int status)
+{
+	fprintf(stderr, "Try `%s -h' or '%s --help' for more information.\n",
+		pname, pname);
+	exit(status);
+}
+
+void
+exit_error(enum exittype status, char *msg, ...)
+{
+	va_list args;
+
+	va_start(args, msg);
+	fprintf(stderr, "%s v%s: ", pname, pversion);
+	vfprintf(stderr, msg, args);
+	va_end(args);
+	fprintf(stderr, "\n");
+	if (status == PARAMETER_PROBLEM)
+		exit_tryhelp(status);
+	if (status == VERSION_PROBLEM)
+		fprintf(stderr,
+			"Perhaps iptables or your kernel needs to be upgraded.\n");
+	exit(status);
+}
+
+/* stolen from iptables 1.2.11
+They should really have them as a library so i can link to them
+Email them next time i remember
+*/
+
+static char *
+addr_to_network(const struct in_addr *addr)
+{
+	struct netent *net;
+
+	if ((net = getnetbyaddr((long) ntohl(addr->s_addr), AF_INET)) != NULL)
+		return (char *) net->n_name;
+
+	return (char *) NULL;
+}
+
+char *
+addr_to_dotted(const struct in_addr *addrp)
+{
+	static char buf[20];
+	const unsigned char *bytep;
+
+	bytep = (const unsigned char *) &(addrp->s_addr);
+	sprintf(buf, "%d.%d.%d.%d", bytep[0], bytep[1], bytep[2], bytep[3]);
+	return buf;
+}
+
+int
+string_to_number_ll(const char *s, unsigned long long min, unsigned long long max,
+		 unsigned long long *ret)
+{
+	unsigned long long number;
+	char *end;
+
+	/* Handle hex, octal, etc. */
+	errno = 0;
+	number = strtoull(s, &end, 0);
+	if (*end == '\0' && end != s) {
+		/* we parsed a number, let's see if we want this */
+		if (errno != ERANGE && min <= number && (!max || number <= max)) {
+			*ret = number;
+			return 0;
+		}
+	}
+	return -1;
+}
+
+int
+string_to_number_l(const char *s, unsigned long min, unsigned long max,
+		 unsigned long *ret)
+{
+	int result;
+	unsigned long long number;
+
+	result = string_to_number_ll(s, min, max, &number);
+	*ret = (unsigned long)number;
+
+	return result;
+}
+
+int string_to_number(const char *s, unsigned int min, unsigned int max,
+		unsigned int *ret)
+{
+	int result;
+	unsigned long number;
+
+	result = string_to_number_l(s, min, max, &number);
+	*ret = (unsigned int)number;
+
+	return result;
+}
+
+#if 0
+int
+string_to_number(const char *s, unsigned int min, unsigned int max,
+		 unsigned int *ret)
+{
+	long number;
+	char *end;
+
+	/* Handle hex, octal, etc. */
+	errno = 0;
+	number = strtol(s, &end, 0);
+	if (*end == '\0' && end != s) {
+		/* we parsed a number, let's see if we want this */
+		if (errno != ERANGE && min <= number && number <= max) {
+			*ret = number;
+			return 0;
+		}
+	}
+	return -1;
+}
+#endif
+
+static struct option *
+copy_options(struct option *oldopts)
+{
+	struct option *merge;
+	unsigned int num_old;
+	for (num_old = 0; oldopts[num_old].name; num_old++) ;
+	merge = malloc(sizeof (struct option) * (num_old + 1));
+	if (NULL == merge)
+		return NULL;
+	memcpy(merge, oldopts, num_old * sizeof (struct option));
+	memset(merge + num_old, 0, sizeof (struct option));
+	return merge;
+}
+
+static struct option *
+merge_options(struct option *oldopts, const struct option *newopts,
+	      unsigned int *option_offset)
+{
+	struct option *merge;
+	unsigned int num_old, num_new, i;
+
+	for (num_old = 0; oldopts[num_old].name; num_old++) ;
+	for (num_new = 0; newopts[num_new].name; num_new++) ;
+
+	*option_offset = global_option_offset + OPTION_OFFSET;
+
+	merge = malloc(sizeof (struct option) * (num_new + num_old + 1));
+	memcpy(merge, oldopts, num_old * sizeof (struct option));
+	for (i = 0; i < num_new; i++) {
+		merge[num_old + i] = newopts[i];
+		merge[num_old + i].val += *option_offset;
+	}
+	memset(merge + num_old + num_new, 0, sizeof (struct option));
+
+	return merge;
+}
+
+static void *
+fw_calloc(size_t count, size_t size)
+{
+	void *p;
+
+	if ((p = (void *) calloc(count, size)) == NULL) {
+		perror("iptables: calloc failed");
+		exit(1);
+	}
+	return p;
+}
+
+#if 0
+static void *
+fw_malloc(size_t size)
+{
+	void *p;
+
+	if ((p = (void *) malloc(size)) == NULL) {
+		perror("iptables: malloc failed");
+		exit(1);
+	}
+	return p;
+}
+
+int
+check_inverse(const char option[], int *invert)
+{
+	if (option && strcmp(option, "!") == 0) {
+		if (*invert)
+			exit_error(PARAMETER_PROBLEM,
+				   "Multiple `!' flags not allowed");
+
+		*invert = TRUE;
+		return TRUE;
+	}
+	return FALSE;
+}
+#endif
+
+struct iptables_target *
+find_t(char *name)
+{
+	struct iptables_target *m;
+	for (m = t_list; m; m = m->next) {
+		if (strcmp(m->name, name) == 0)
+			return m;
+	}
+
+	return NULL;
+}
+
+struct iptables_target *
+get_target_name(char *name)
+{
+	void *handle;
+	char *error;
+	char *new_name, *lname;
+	struct iptables_target *m;
+
+	char path[sizeof (IPT_LIB_DIR) + sizeof ("/libipt_.so") + strlen(name)];
+
+	new_name = malloc(strlen(name) + 1);
+	lname = malloc(strlen(name) + 1);
+	if (new_name)
+		memset(new_name, '\0', strlen(name) + 1);
+	else
+		exit_error(PARAMETER_PROBLEM, "get_target_name");
+
+	if (lname)
+		memset(lname, '\0', strlen(name) + 1);
+	else
+		exit_error(PARAMETER_PROBLEM, "get_target_name");
+
+	strcpy(new_name, name);
+	strcpy(lname, name);
+
+	if (isupper(lname[0])) {
+		int i;
+		for (i = 0; i < strlen(name); i++) {
+			lname[i] = tolower(lname[i]);
+		}
+	}
+
+	if (islower(new_name[0])) {
+		int i;
+		for (i = 0; i < strlen(new_name); i++) {
+			new_name[i] = toupper(new_name[i]);
+		}
+	}
+
+	sprintf(path, IPT_LIB_DIR "/libipt_%s.so", new_name);
+	handle = dlopen(path, RTLD_LAZY);
+	if (!handle) {
+		sprintf(path, IPT_LIB_DIR "/libipt_%s.so", lname);
+		handle = dlopen(path, RTLD_LAZY);
+		if (!handle) {
+			fputs(dlerror(), stderr);
+			printf("\n");
+			return NULL;
+		}
+	}
+
+	m = dlsym(handle, new_name);
+	if ((error = dlerror()) != NULL) {
+		m = (struct iptables_target *) dlsym(handle, lname);
+		if ((error = dlerror()) != NULL) {
+			m = find_t(new_name);
+			if (NULL == m) {
+				m = find_t(lname);
+				if (NULL == m) {
+					fputs(error, stderr);
+					fprintf(stderr, "\n");
+					dlclose(handle);
+					return NULL;
+				}
+			}
+		}
+	}
+
+	return m;
+}
+
+#if 0
+char *
+addr_to_dotted(const struct in_addr *addrp)
+{
+	static char buf[20];
+	const unsigned char *bytep;
+
+	bytep = (const unsigned char *) &(addrp->s_addr);
+	sprintf(buf, "%d.%d.%d.%d", bytep[0], bytep[1], bytep[2], bytep[3]);
+	return buf;
+}
+#endif
+
+struct in_addr *
+dotted_to_addr(const char *dotted)
+{
+	static struct in_addr addr;
+	unsigned char *addrp;
+	char *p, *q;
+	unsigned int onebyte;
+	int i;
+	char buf[20];
+
+	/* copy dotted string, because we need to modify it */
+	strncpy(buf, dotted, sizeof (buf) - 1);
+	addrp = (unsigned char *) &(addr.s_addr);
+
+	p = buf;
+	for (i = 0; i < 3; i++) {
+		if ((q = strchr(p, '.')) == NULL)
+			return (struct in_addr *) NULL;
+
+		*q = '\0';
+		if (string_to_number(p, 0, 255, &onebyte) == -1)
+			return (struct in_addr *) NULL;
+
+		addrp[i] = (unsigned char) onebyte;
+		p = q + 1;
+	}
+
+	/* we've checked 3 bytes, now we check the last one */
+	if (string_to_number(p, 0, 255, &onebyte) == -1)
+		return (struct in_addr *) NULL;
+
+	addrp[3] = (unsigned char) onebyte;
+
+	return &addr;
+}
+
+int
+build_st(struct iptables_target *target, struct ipt_entry_target *t)
+{
+	unsigned int nfcache = 0;
+
+	if (target) {
+		size_t size;
+
+		size =
+		    IPT_ALIGN(sizeof (struct ipt_entry_target)) + target->size;
+
+		if (NULL == t) {
+			target->t = fw_calloc(1, size);
+			target->init(target->t, &nfcache);
+			target->t->u.target_size = size;
+		} else {
+			target->t = t;
+		}
+		strcpy(target->t->u.user.name, target->name);
+		return 0;
+	}
+
+	return -1;
+}
+
+int
+parse_ipt(struct action_util *a,int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
+{
+	struct iptables_target *m = NULL;
+	struct ipt_entry fw;
+	struct rtattr *tail;
+	int c;
+	int rargc = *argc_p;
+	char **argv = *argv_p;
+	struct option *opts;
+	int argc = 0, iargc = 0;
+	char k[16];
+	int res = -1;
+	int size = 0;
+	int iok = 0, ok = 0;
+	__u32 hook = 0, index = 0;
+	res = 0;
+
+	{
+		int i;
+		for (i = 0; i < rargc; i++) {
+			if (NULL == argv[i] || 0 == strcmp(argv[i], "action")) {
+				break;
+			}
+		}
+		iargc = argc = i;
+	}
+
+	if (argc <= 2) {
+		fprintf(stderr,"bad arguements to ipt %d vs %d \n", argc, rargc);
+		return -1;
+	}
+
+	opts = copy_options(original_opts);
+
+	if (NULL == opts)
+		return -1;
+
+	while (1) {
+		c = getopt_long(argc, argv, "j:", opts, NULL);
+		if (c == -1)
+			break;
+		switch (c) {
+		case 'j':
+			m = get_target_name(optarg);
+			if (NULL != m) {
+
+				if (0 > build_st(m, NULL)) {
+					printf(" %s error \n", m->name);
+					return -1;
+				}
+				opts =
+				    merge_options(opts, m->extra_opts,
+						  &m->option_offset);
+			} else {
+				fprintf(stderr," failed to find target %s\n\n", optarg);
+				return -1;
+			}
+			ok++;
+			break;
+
+		default:
+			memset(&fw, 0, sizeof (fw));
+			if (m) {
+				unsigned int fake_flags = 0;
+				m->parse(c - m->option_offset, argv, 0,
+					 &fake_flags, NULL, &m->t);
+			} else {
+				fprintf(stderr," failed to find target %s\n\n", optarg);
+				return -1;
+
+			}
+			ok++;
+
+			/*m->final_check(m->t); -- Is this necessary?
+			** useful when theres depencies
+			** eg ipt_TCPMSS.c has have the TCP match loaded
+			** before this can be used;
+			**  also seems the ECN target needs it 
+			*/
+
+			break;
+
+		}
+	}
+
+	if (iargc > optind) {
+		if (matches(argv[optind], "index") == 0) {
+			if (get_u32(&index, argv[optind + 1], 10)) {
+				fprintf(stderr, "Illegal \"index\"\n");
+				return -1;
+			}
+			iok++;
+
+			optind += 2;
+		}
+	}
+
+	if (!ok && !iok) {
+		fprintf(stderr," ipt Parser BAD!! (%s)\n",argv);
+		return -1;
+	}
+
+	{
+		struct tcmsg *t = NLMSG_DATA(n);
+		if (t->tcm_parent != TC_H_ROOT
+		    && t->tcm_parent == TC_H_MAJ(TC_H_INGRESS)) {
+			hook = NF_IP_PRE_ROUTING;
+		} else {
+			hook = NF_IP_POST_ROUTING;
+		}
+	}
+
+	tail = (struct rtattr *) (((void *) n) + NLMSG_ALIGN(n->nlmsg_len));
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	fprintf(stdout, "tablename: %s hook: %s\n ", tname, ipthooks[hook]);
+	fprintf(stdout, "\ttarget: ");
+
+	if (m)
+		m->print(NULL, m->t, 0);
+	fprintf(stdout, " index %d\n", index);
+
+	if (strlen(tname) > 16) {
+		size = 16;
+		k[15] = 0;
+	} else {
+		size = 1 + strlen(tname);
+	}
+	strncpy(k, tname, size);
+
+	addattr_l(n, MAX_MSG, TCA_IPT_TABLE, k, size);
+	addattr_l(n, MAX_MSG, TCA_IPT_HOOK, &hook, 4);
+	addattr_l(n, MAX_MSG, TCA_IPT_INDEX, &index, 4);
+	if (m)
+		addattr_l(n, MAX_MSG, TCA_IPT_TARG, m->t, m->t->u.target_size);
+	tail->rta_len =
+	    (((void *) n) + NLMSG_ALIGN(n->nlmsg_len)) - (void *) tail;
+
+	argc -= optind;
+	argv += optind;
+	*argc_p = rargc - iargc;
+	*argv_p = argv;
+	
+	optind = 1;
+
+	return 0;
+
+}
+
+int
+print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
+{
+	struct rtattr *tb[TCA_IPT_MAX + 1];
+	struct ipt_entry_target *t = NULL;
+	struct option *opts;
+
+	if (arg == NULL)
+		return -1;
+
+	opts = copy_options(original_opts);
+
+	if (NULL == opts)
+		return -1;
+	memset(tb, 0, sizeof (tb));
+	parse_rtattr(tb, TCA_IPT_MAX, RTA_DATA(arg), RTA_PAYLOAD(arg));
+
+	if (tb[TCA_IPT_TABLE] == NULL) {
+		fprintf(f, "[NULL ipt table name ] assuming mangle ");
+	} else {
+		fprintf(f, "tablename: %s ",
+			(char *) RTA_DATA(tb[TCA_IPT_TABLE]));
+	}
+
+	if (tb[TCA_IPT_HOOK] == NULL) {
+		fprintf(f, "[NULL ipt hook name ]\n ");
+		return -1;
+	} else {
+		__u32 hook;
+		hook = *(__u32 *) RTA_DATA(tb[TCA_IPT_HOOK]);
+		fprintf(f, " hook: %s \n", ipthooks[hook]);
+	}
+
+	if (tb[TCA_IPT_TARG] == NULL) {
+		fprintf(f, "\t[NULL ipt target parameters ] \n");
+		return -1;
+	} else {
+		struct iptables_target *m = NULL;
+		t = RTA_DATA(tb[TCA_IPT_TARG]);
+		m = get_target_name(t->u.user.name);
+		if (NULL != m) {
+			if (0 > build_st(m, t)) {
+				fprintf(stderr, " %s error \n", m->name);
+				return -1;
+			}
+
+			opts =
+			    merge_options(opts, m->extra_opts,
+					  &m->option_offset);
+		} else {
+			fprintf(stderr, " failed to find target %s\n\n",
+				t->u.user.name);
+			return -1;
+		}
+		fprintf(f, "\ttarget ");
+		m->print(NULL, m->t, 0);
+		if (tb[TCA_IPT_INDEX] == NULL) {
+			fprintf(f, " [NULL ipt target index ]\n");
+		} else {
+			__u32 index;
+			index = *(__u32 *) RTA_DATA(tb[TCA_IPT_INDEX]);
+			fprintf(f, " \n\tindex %d", index);
+		}
+
+		if (tb[TCA_IPT_CNT]) {
+			struct tc_cnt *c  = RTA_DATA(tb[TCA_IPT_CNT]);;
+			fprintf(f, " ref %d bind %d", c->refcnt, c->bindcnt);
+		}
+		if (show_stats) {
+			if (tb[TCA_IPT_TM]) {
+				struct tcf_t *tm = RTA_DATA(tb[TCA_IPT_TM]);
+				print_tm(f,tm);
+			}
+		} 
+		fprintf(f, " \n");
+
+	}
+
+	return 0;
+}
+
+struct action_util ipt_action_util = {
+        .id = "ipt",
+        .parse_aopt = parse_ipt,
+        .print_aopt = print_ipt,
+};
+
--- /dev/null	2003-09-15 09:40:47.000000000 -0400
+++ /root/iproute2-2.6.9-041019-mod/include/linux/tc_act/tc_ipt.h	2004-10-24 14:48:06.000000000 -0400
@@ -0,0 +1,21 @@
+#ifndef __LINUX_TC_IPT_H
+#define __LINUX_TC_IPT_H
+
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_IPT 6
+
+enum
+{
+	TCA_IPT_UNSPEC,
+	TCA_IPT_TABLE,
+	TCA_IPT_HOOK,
+	TCA_IPT_INDEX,
+	TCA_IPT_CNT,
+	TCA_IPT_TM,
+	TCA_IPT_TARG,
+	__TCA_IPT_MAX
+};
+#define TCA_IPT_MAX (__TCA_IPT_MAX - 1)
+                                                                                
+#endif
--- /root/iproute2-2.6.9-041019/tc/Makefile	2004-10-19 16:49:02.000000000 -0400
+++ /root/iproute2-2.6.9-041019-mod/tc/Makefile	2004-10-24 21:49:33.000000000 -0400
@@ -3,6 +3,8 @@
 
 include ../Config
 
+IPT_INCL = /root/iptables-1.2.11/include
+
 TCMODULES :=
 TCMODULES += q_fifo.o
 TCMODULES += q_sfq.o
@@ -29,6 +31,12 @@
 TCLIB += tc_cbq.o
 TCLIB += tc_estimator.o
 
+ifeq ($(TC_CONFIG_ACTION_IPT),y)
+LDLIBS += -L. m_ipt.o -ltc -lm -ldl
+else
+LDLIBS += -L. -ltc -lm -ldl
+endif
+
 CFLAGS += -DCONFIG_GACT -DCONFIG_GACT_PROB
 
 
@@ -52,10 +60,15 @@
 	./$* >$@
 	rm $*
 
-all: libtc.a tc $(TCSO) $(NETEM_DIST)
+all: ipt libtc.a tc $(TCSO) $(NETEM_DIST)
 
 tc: $(TCOBJ) $(LIBNETLINK) $(LIBUTIL) $(TCLIB)
 
+ipt:
+ifeq ($(TC_CONFIG_ACTION_IPT),y)
+	$(CC) $(CCOPTS)  -I$(KERNEL_INCLUDE) $(DEFINES) -I$(IPT_INCL) -I../include -c -o m_ipt.o m_ipt.c
+#$(CC) $(CCOPTS)  -I$(KERNEL_INCLUDE) -I../include $(DEFINES) -DCONFIG_NET_CLS_ACT -I$(IPT_INCL) -c -o m_ipt.o m_ipt.c
+endif
 
 libtc.a: $(TCLIB)
 	$(AR) rcs $@ $(TCLIB)
--- /root/iproute2-2.6.9-041019/configure	2004-10-19 16:49:02.000000000 -0400
+++ /root/iproute2-2.6.9-041019-mod/configure	2004-10-24 14:40:01.000000000 -0400
@@ -26,12 +26,24 @@
 fi
 rm -f /tmp/atmtest.c /tmp/atmtest
 
-# hack for now 
+# hacks for now 
 echo "TC actions"
 
 if [ -e "tc/m_gact.c" ]
 then
+	echo "   GACT found"
 	echo "TC_CONFIG_ACTION_GACT=y" >>Config
 	echo "TC_CONFIG_ACTION_PROB=y" >>Config
 fi
 
+if [ -e "tc/m_mirred.c" ]
+then
+	echo "   MIRRED found"
+	echo "TC_CONFIG_ACTION_MIRRED=y" >>Config
+fi
+
+if [ -e "tc/m_ipt.c" ]
+then
+	echo "   IPT found"
+	echo "TC_CONFIG_ACTION_IPT=y" >>Config
+fi

--=-jsey1+L9qfIUO70ryExe--
