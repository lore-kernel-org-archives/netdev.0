From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: Iproute2: update
Date: 16 Jan 2005 12:45:32 -0500
Message-ID: <1105897532.1097.749.camel@jzny.localdomain>
References: <20050112125903.64d42737@dxpl.pdx.osdl.net>
	 <1105895352.1091.705.camel@jzny.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-FJRqejyEx01iPhYLNYub"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <1105895352.1091.705.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-FJRqejyEx01iPhYLNYub
Content-Transfer-Encoding: 7bit
Content-Type: text/plain

On Sun, 2005-01-16 at 12:09, jamal wrote:
> Here's one fix
> 

And another one from before that is missing from the current version.
Also something for the makefile - You may be unhappy with the way the
IPT_INCL is defined in the makefile.
Feel free to move it to configure etc or even kill it if it works
without it.

cheers,
jamal

--=-FJRqejyEx01iPhYLNYub
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=pedit-patch-iproute2-2.6.10
Content-Type: text/plain; name=pedit-patch-iproute2-2.6.10; charset=ISO-8859-1

--- a/tc/Makefile	2005-01-12 15:19:46.000000000 -0500
+++ b/tc/Makefile	2005-01-15 12:59:03.994966464 -0500
@@ -23,6 +23,12 @@
 TCMODULES += m_gact.o
 TCMODULES += m_mirred.o
 TCMODULES += m_ipt.o
+#pedit
+TCMODULES += m_pedit.o 
+TCMODULES += p_ip.o
+TCMODULES += p_icmp.o
+TCMODULES += p_tcp.o
+TCMODULES += p_udp.o
 
 TCOBJ += $(TCMODULES)
 
@@ -31,8 +37,6 @@
 TCLIB += tc_cbq.o
 TCLIB += tc_estimator.o
 
-CFLAGS += -DCONFIG_GACT -DCONFIG_GACT_PROB
-
 
 TCSO :=
 TCSO += q_netem.so
@@ -40,10 +44,13 @@
   TCSO += q_atm.so
 endif
 
+
 NETEM_DIST := normal.dist pareto.dist paretonormal.dist
 
+IPT_INCL = /root/iptables-1.2.11/include
 LDLIBS += -L. -ltc -lm -ldl
 
+CFLAGS += -DCONFIG_GACT -DCONFIG_GACT_PROB -I$(IPT_INCL)
 LDFLAGS += -Wl,-export-dynamic
 
 %.so: %.c
@@ -78,4 +85,3 @@
 q_atm.so: q_atm.c
 	$(CC) $(CFLAGS) -shared -fpic -o q_atm.so q_atm.c -latm
 
-
diff -druN a/include/linux/tc_act/tc_pedit.h b/include/linux/tc_act/tc_pedit.h
--- a/include/linux/tc_act/tc_pedit.h	1969-12-31 19:00:00.000000000 -0500
+++ b/include/linux/tc_act/tc_pedit.h	2004-12-28 09:31:34.000000000 -0500
@@ -0,0 +1,36 @@
+#ifndef __LINUX_TC_PED_H
+#define __LINUX_TC_PED_H
+
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_PEDIT 7
+
+enum
+{
+	TCA_PEDIT_UNSPEC,
+	TCA_PEDIT_TM,
+	TCA_PEDIT_PARMS,
+	__TCA_PEDIT_MAX
+};
+#define TCA_PEDIT_MAX (__TCA_PEDIT_MAX - 1)
+                                                                                
+struct tc_pedit_key
+{
+	__u32           mask;  /* AND */
+	__u32           val;   /*XOR */
+	__u32           off;  /*offset */
+	__u32           at;
+	__u32           offmask;
+	__u32           shift;
+};
+                                                                                
+struct tc_pedit_sel
+{
+	tc_gen;
+	unsigned char           nkeys;
+	unsigned char           flags;
+	struct tc_pedit_key     keys[0];
+};
+#define tc_pedit tc_pedit_sel
+
+#endif
diff -druN a/tc/m_pedit.c b/tc/m_pedit.c
--- a/tc/m_pedit.c	1969-12-31 19:00:00.000000000 -0500
+++ b/tc/m_pedit.c	2005-01-04 06:47:23.113260368 -0500
@@ -0,0 +1,606 @@
+/*
+ * m_pedit.c		generic packet editor actions module 
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (hadi@cyberus.ca) 
+ * 
+ * TODO: 
+ * 	1) Big endian broken in some spots
+ * 	2) A lot of this stuff was added on the fly; get a big double-double
+ * 	and clean it up at some point.
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
+#include <dlfcn.h>
+#include "utils.h"
+#include "tc_util.h"
+#include "m_pedit.h"
+
+void *pBODY;
+static struct m_pedit_util *pedit_list;
+int pedit_debug = 1;
+
+static void
+p_explain(void)
+{
+	fprintf(stderr, "Usage: ... pedit <MUNGE>\n");
+	fprintf(stderr,
+		"Where: MUNGE := <RAW>|<LAYERED>\n" 
+		"<RAW>:= <OFFSETC>[ATC]<CMD>\n "
+		"OFFSETC:= offset <offval> <u8|u16|u32>\n "
+		"ATC:= at <atval> offmask <maskval> shift <shiftval>\n "
+		"NOTE: offval is byte offset, must be multiple of 4\n "
+		"NOTE: maskval is a 32 bit hex number\n "
+		"NOTE: shiftval is a is a shift value\n "
+		"CMD:= clear | invert | set <setval>| retain\n "
+		"<LAYERED>:= ip <ipdata> | ip6 <ip6data> \n "
+		" | udp <udpdata> | tcp <tcpdata> | icmp <icmpdata> \n"
+		"For Example usage look at the examples directory");
+
+}
+
+#define usage() return(-1)
+
+static int 
+pedit_parse_nopopt (int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey) 
+{
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc) {
+		fprintf(stderr, "Unknown action  hence option \"%s\" is unparsable\n", *argv);
+			return -1;
+	}
+
+	return 0;
+
+}
+
+struct m_pedit_util 
+*get_pedit_kind(char *str)
+{
+	void *dlh;
+	char buf[256];
+	struct  m_pedit_util *p;
+
+	for (p = pedit_list; p; p = p->next) {
+		if (strcmp(p->id, str) == 0)
+			return p;
+	}
+
+	snprintf(buf, sizeof(buf), "p_%s.so", str);
+	dlh = dlopen(buf, RTLD_LAZY);
+	if (dlh == NULL) {
+		dlh = pBODY;
+		if (dlh == NULL) {
+			dlh = pBODY = dlopen(NULL, RTLD_LAZY);
+			if (dlh == NULL)
+				goto noexist;
+		}
+	}
+
+	snprintf(buf, sizeof(buf), "p_pedit_%s", str);
+	p = dlsym(dlh, buf);
+	if (p == NULL)
+		goto noexist;
+
+reg:
+	p->next = pedit_list;
+	pedit_list = p;
+	return p;
+
+noexist:
+	p = malloc(sizeof(*p));
+	if (p) {
+		memset(p, 0, sizeof(*p));
+		strncpy(p->id, str, 15);
+		p->parse_peopt = pedit_parse_nopopt;
+		goto reg;
+	}
+	return p;
+}
+
+int
+pack_key(struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	int hwm = sel->nkeys;
+
+	if (hwm >= MAX_OFFS)
+		return -1;
+
+	if (tkey->off % 4) {
+		fprintf(stderr, "offsets MUST be in 32 bit boundaries\n");
+		return -1;
+	}
+
+	sel->keys[hwm].val = tkey->val;
+	sel->keys[hwm].mask = tkey->mask;
+	sel->keys[hwm].off = tkey->off;
+	sel->keys[hwm].at = tkey->at;
+	sel->keys[hwm].offmask = tkey->offmask;
+	sel->keys[hwm].shift = tkey->shift;
+	sel->nkeys++;
+	return 0;
+}
+
+
+int
+pack_key32(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	if (tkey->off > (tkey->off & ~3)) {
+		fprintf(stderr,
+			"pack_key32: 32 bit offsets must begin in 32bit boundaries\n");
+		return -1;
+	}
+
+	tkey->val = htonl(tkey->val & retain);
+	tkey->mask = htonl(tkey->mask | ~retain);
+	/* jamal remove this - it is not necessary given the if check above */
+	tkey->off &= ~3;
+	return pack_key(sel,tkey);
+}
+
+int
+pack_key16(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	int ind = 0, stride = 0;
+	__u32 m[4] = {0xFFFF0000,0xFF0000FF,0x0000FFFF};
+
+	if (0 > tkey->off) {
+		ind = tkey->off + 1;
+		if (0 > ind)
+			ind = -1*ind;
+	} else {
+		ind = tkey->off;
+	}
+
+	if (tkey->val > 0xFFFF || tkey->mask > 0xFFFF) {
+		fprintf(stderr, "pack_key16 bad value\n");
+		return -1;
+	}
+
+	ind = tkey->off & 3;
+
+	if (0 > ind || 2 < ind) {
+		fprintf(stderr, "pack_key16 bad index value %d\n",ind);
+		return -1;
+	}
+
+	stride = 8 * ind;
+	tkey->val = htons(tkey->val);
+	if (stride > 0) {
+		tkey->val <<= stride;
+		tkey->mask <<= stride;
+		retain <<= stride;
+	}
+	tkey->mask = retain|m[ind];
+
+	tkey->off &= ~3;
+
+	if (pedit_debug)
+		printf("pack_key16: Final val %08x mask %08x \n",tkey->val,tkey->mask);
+	return pack_key(sel,tkey);
+
+}
+
+int
+pack_key8(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	int ind = 0, stride = 0;
+	__u32 m[4] = {0xFFFFFF00,0xFFFF00FF,0xFF00FFFF,0x00FFFFFF};
+
+	if (0 > tkey->off) {
+		ind = tkey->off + 1;
+		if (0 > ind)
+			ind = -1*ind;
+	} else {
+		ind = tkey->off;
+	}
+
+	if (tkey->val > 0xFF || tkey->mask > 0xFF) {
+		fprintf(stderr, "pack_key8 bad value (val %x mask %x\n", tkey->val, tkey->mask);
+		return -1;
+	}
+
+	ind = tkey->off & 3;
+	stride = 8 * ind;
+	tkey->val <<= stride;
+	tkey->mask <<= stride;
+	retain <<= stride;
+	tkey->mask = retain|m[ind];
+	tkey->off &= ~3;
+	
+	if (pedit_debug)
+		printf("pack_key8: Final word off %d  val %08x mask %08x \n",tkey->off , tkey->val,tkey->mask);
+	return pack_key(sel,tkey);
+}
+
+int
+parse_val(int *argc_p, char ***argv_p, __u32 * val, int type)
+{
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc <= 0)
+		return -1;
+
+	if (TINT == type)
+		return get_integer(val, *argv, 0);
+	if (TU32 == type)
+		return get_u32(val, *argv, 0);
+	if (TIPV4 == type) {
+		inet_prefix addr;
+		if (get_prefix_1(&addr, *argv, AF_INET)) {
+			return -1;
+		}
+		*val=addr.data[0];
+		return 0;
+	}
+	if (TIPV6 == type) {
+		/* not implemented yet */
+		return -1;
+	}
+
+	return -1;
+}
+
+int
+parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type,__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	__u32 mask = 0, val = 0;
+	__u32 o = 0xFF;
+	int res = -1;
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc <= 0)
+		return -1;
+
+	if (pedit_debug)
+		printf("parse_cmd argc %d %s offset %d length %d\n",argc,*argv,tkey->off,len);
+
+	if (len == 2)
+		o = 0xFFFF;
+	if (len == 4)
+		o = 0xFFFFFFFF;
+
+	if (matches(*argv, "invert") == 0) {
+		retain = val = mask = o;
+	} else if (matches(*argv, "set") == 0) {
+		NEXT_ARG();
+		if (parse_val(&argc, &argv, &val, type))
+			return -1;
+	} else if (matches(*argv, "preserve") == 0) {
+		retain = mask = o;
+	} else {
+		if (matches(*argv, "clear") != 0) 
+			return -1;
+	}
+
+	argc--; argv++;
+
+	if (argc && matches(*argv, "retain") == 0) {
+		NEXT_ARG();
+		if (parse_val(&argc, &argv, &retain, TU32))
+			return -1;
+		argc--; argv++;
+	}
+
+	tkey->val = val;
+
+	if (len == 1) {
+		tkey->mask = 0xFF;
+		res = pack_key8(retain,sel,tkey);
+		goto done;
+	}
+	if (len == 2) {
+		tkey->mask = mask;
+		res = pack_key16(retain,sel,tkey);
+		goto done;
+	}
+	if (len == 4) {
+		tkey->mask = mask;
+		res = pack_key32(retain,sel,tkey);
+		goto done;
+	}
+
+	return -1;
+done:
+	if (pedit_debug)
+		printf("parse_cmd done argc %d %s offset %d length %d\n",argc,*argv,tkey->off,len);
+	*argc_p = argc;
+	*argv_p = argv;
+	return res;
+
+}
+
+int
+parse_offset(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	int off;
+	__u32 len, retain;
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int res = -1;
+
+	if (argc <= 0)
+		return -1;
+
+	if (get_integer(&off, *argv, 0))
+		return -1;
+	tkey->off = off;
+
+	argc--;
+	argv++;
+
+	if (argc <= 0)
+		return -1;
+
+
+	if (matches(*argv, "u32") == 0) {
+		len = 4;
+		retain = 0xFFFFFFFF;
+		goto done;
+	}
+	if (matches(*argv, "u16") == 0) {
+		len = 2;
+		retain = 0x0;
+		goto done;
+	}
+	if (matches(*argv, "u8") == 0) {
+		len = 1;
+		retain = 0x0;
+		goto done;
+	}
+
+	return -1;
+
+done:
+
+	NEXT_ARG();
+
+	/* [at <someval> offmask <maskval> shift <shiftval>] */
+	if (matches(*argv, "at") == 0) {
+
+		__u32 atv=0,offmask=0x0,shift=0;
+
+		NEXT_ARG();
+		if (get_u32(&atv, *argv, 0))
+			return -1;
+		tkey->at = atv;
+
+		NEXT_ARG();
+		
+		if (get_u32(&offmask, *argv, 16))
+			return -1;
+		tkey->offmask = offmask;
+
+		NEXT_ARG();
+
+		if (get_u32(&shift, *argv, 0))
+			return -1;
+		tkey->shift = shift;
+
+		NEXT_ARG();
+	}
+
+	res = parse_cmd(&argc, &argv, len, TU32,retain,sel,tkey);
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return res;
+}
+
+int
+parse_munge(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel)
+{
+	struct tc_pedit_key tkey;
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int res = -1;
+
+	if (argc <= 0)
+		return -1;
+
+	memset(&tkey, 0, sizeof(tkey));
+
+	if (matches(*argv, "offset") == 0) {
+		NEXT_ARG();
+		res = parse_offset(&argc, &argv,sel,&tkey);
+		goto done;
+#if jamal
+	} else if (strcmp(*argv, "help") == 0) {
+		p_explain();
+		return -1;
+#endif
+	} else {
+		char k[16];
+		struct m_pedit_util *p = NULL;
+
+		strncpy(k, *argv, sizeof (k) - 1);
+
+		if (argc > 0 ) {
+			p = get_pedit_kind(k);
+			if (NULL == p)
+				goto bad_val;
+			res = p->parse_peopt(&argc, &argv, sel,&tkey);
+			if (res < 0) {
+				fprintf(stderr,"bad pedit parsing\n");
+				goto bad_val;
+			}
+			goto done;
+		}
+	}
+
+bad_val:
+	return -1;
+
+done:
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return res;
+}
+
+int
+parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
+{
+	struct {
+		struct tc_pedit_sel sel;
+		struct tc_pedit_key keys[MAX_OFFS];
+	} sel;
+
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int ok = 0, iok = 0;
+	struct rtattr *tail;
+
+	memset(&sel, 0, sizeof(sel));
+
+	while (argc > 0) {
+		if (pedit_debug > 1)
+			fprintf(stderr, "while pedit (%d:%s)\n",argc, *argv);
+		if (matches(*argv, "pedit") == 0) {
+			NEXT_ARG();
+			ok++;
+			continue;
+		} else if (matches(*argv, "munge") == 0) {
+			if (!ok) {
+				fprintf(stderr, "Illegal pedit construct (%s) \n", *argv);
+				p_explain();
+				return -1;
+			}
+			NEXT_ARG();
+			if (parse_munge(&argc, &argv,&sel.sel)) {
+				fprintf(stderr, "Illegal pedit construct (%s) \n", *argv);
+				p_explain();
+				return -1;
+			}
+			ok++;
+		} else {
+			break;
+		}
+
+	}
+
+	if (!ok) {
+		p_explain();
+		return -1;
+	}
+
+	if (argc) {
+		if (matches(*argv, "reclassify") == 0) {
+			sel.sel.action = TC_ACT_RECLASSIFY;
+			NEXT_ARG();
+		} else if (matches(*argv, "pipe") == 0) {
+			sel.sel.action = TC_ACT_PIPE;
+			NEXT_ARG();
+		} else if (matches(*argv, "drop") == 0 ||
+			matches(*argv, "shot") == 0) {
+			sel.sel.action = TC_ACT_SHOT;
+			NEXT_ARG();
+		} else if (matches(*argv, "continue") == 0) {
+			sel.sel.action = TC_ACT_UNSPEC;
+			NEXT_ARG();
+		} else if (matches(*argv, "pass") == 0) {
+			sel.sel.action = TC_ACT_OK;
+			NEXT_ARG();
+		}
+	}
+
+	if (argc) {
+		if (matches(*argv, "index") == 0) {
+			NEXT_ARG();
+			if (get_u32(&sel.sel.index, *argv, 10)) {
+				fprintf(stderr, "Pedit: Illegal \"index\"\n");
+				return -1;
+			}
+			argc--;
+			argv++;
+			iok++;
+		}
+	}
+
+	tail = (struct rtattr *) (((void *) n) + NLMSG_ALIGN(n->nlmsg_len));
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_PEDIT_PARMS,&sel, sizeof(sel.sel)+sel.sel.nkeys*sizeof(struct tc_pedit_key));
+	tail->rta_len =
+	    (((void *) n) + NLMSG_ALIGN(n->nlmsg_len)) - (void *) tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+int
+print_pedit(struct action_util *au,FILE * f, struct rtattr *arg)
+{
+	struct tc_pedit_sel *sel;
+	struct rtattr *tb[TCA_PEDIT_MAX + 1];
+	SPRINT_BUF(b1);
+
+	if (arg == NULL)
+		return -1;
+
+	memset(tb, 0, sizeof (tb));
+	parse_rtattr(tb, TCA_PEDIT_MAX, RTA_DATA(arg), RTA_PAYLOAD(arg));
+
+	if (tb[TCA_PEDIT_PARMS] == NULL) {
+		fprintf(f, "[NULL pedit parameters]");
+		return -1;
+	}
+	sel = RTA_DATA(tb[TCA_PEDIT_PARMS]);
+
+	fprintf(f, " pedit action %s keys %d\n ", action_n2a(sel->action, b1, sizeof (b1)),sel->nkeys);
+	fprintf(f, "\t index %d ref %d bind %d", sel->index,sel->refcnt, sel->bindcnt);
+
+	if (show_stats) {
+		if (tb[TCA_PEDIT_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_PEDIT_TM]);
+			print_tm(f,tm);
+		}
+	}
+	if (sel->nkeys) {
+		int i;
+		struct tc_pedit_key *key = sel->keys;
+
+		for (i=0; i<sel->nkeys; i++, key++) {
+			fprintf(f, "\n\t key #%d",i);
+			fprintf(f, "  at %d: val %08x mask %08x",
+			(unsigned int)key->off,
+			(unsigned int)ntohl(key->val),
+			(unsigned int)ntohl(key->mask));
+		}
+	} else {
+		fprintf(f, "\npedit %x keys %d is not LEGIT", sel->index,sel->nkeys);
+	}
+
+
+	fprintf(f, "\n ");
+	return 0;
+}
+
+int 
+pedit_print_xstats(struct action_util *au, FILE *f, struct rtattr *xstats)
+{
+	return 0;
+}
+
+struct action_util pedit_action_util = {
+	.id = "pedit",
+	.parse_aopt = parse_pedit,
+	.print_aopt = print_pedit,
+};
diff -druN a/tc/m_pedit.h b/tc/m_pedit.h
--- a/tc/m_pedit.h	1969-12-31 19:00:00.000000000 -0500
+++ b/tc/m_pedit.h	2004-12-28 09:31:34.000000000 -0500
@@ -0,0 +1,60 @@
+/*
+ * m_pedit.h		generic packet editor actions module 
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (hadi@cyberus.ca) 
+ * 
+ */
+
+#ifndef _ACT_PEDIT_H_
+#define _ACT_PEDIT_H_ 1
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
+#include <linux/tc_act/tc_pedit.h>
+
+#define MAX_OFFS 128
+
+#define TIPV4 1
+#define TIPV6 2
+#define TINT 3
+#define TU32 4
+
+#define RU32 0xFFFFFFFF
+#define RU16 0xFFFF
+#define RU8 0xFF
+
+struct m_pedit_util
+{
+	struct m_pedit_util *next;
+	char    id[16];
+	int     (*parse_peopt)(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+};
+
+
+extern int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type,__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+extern int pack_key(struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+extern int pack_key32(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+extern int pack_key16(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+extern int pack_key8(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+extern int parse_val(int *argc_p, char ***argv_p, __u32 * val, int type);
+extern int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type,__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+extern int parse_offset(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey);
+int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n);
+extern int print_pedit(struct action_util *au,FILE * f, struct rtattr *arg);
+extern int pedit_print_xstats(struct action_util *au, FILE *f, struct rtattr *xstats);
+
+#endif
diff -druN a/tc/p_icmp.c b/tc/p_icmp.c
--- a/tc/p_icmp.c	1969-12-31 19:00:00.000000000 -0500
+++ b/tc/p_icmp.c	2004-12-28 09:31:34.000000000 -0500
@@ -0,0 +1,61 @@
+/*
+ * m_pedit_icmp.c	packet editor: ICMP header
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (hadi@cyberus.ca) 
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
+#include "m_pedit.h"
+
+
+static int
+parse_icmp(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	int res = -1;
+#if 0
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc < 2)
+		return -1;
+
+	if (strcmp(*argv, "type") == 0) {
+		NEXT_ARG();
+		res = parse_u8(&argc, &argv, 0);
+		goto done;
+	}
+	if (strcmp(*argv, "code") == 0) {
+		NEXT_ARG();
+		res = parse_u8(&argc, &argv, 1);
+		goto done;
+	}
+	return -1;
+
+      done:
+	*argc_p = argc;
+	*argv_p = argv;
+#endif
+	return res;
+}
+
+struct m_pedit_util p_pedit_icmp = {
+	NULL,
+	"icmp",
+	parse_icmp,
+};
diff -druN a/tc/p_ip.c b/tc/p_ip.c
--- a/tc/p_ip.c	1969-12-31 19:00:00.000000000 -0500
+++ b/tc/p_ip.c	2004-12-28 09:31:34.000000000 -0500
@@ -0,0 +1,159 @@
+/*
+ * m_pedit.c		packet editor: IPV4/6 header 
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (hadi@cyberus.ca) 
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
+#include "m_pedit.h"
+
+static int
+parse_ip(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	int res = -1;
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc < 2)
+		return -1;
+
+	if (strcmp(*argv, "src") == 0) {
+		NEXT_ARG();
+		tkey->off = 12;
+		res = parse_cmd(&argc, &argv, 4, TIPV4,RU32,sel,tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "dst") == 0) {
+		NEXT_ARG();
+		tkey->off = 16;
+		res = parse_cmd(&argc, &argv, 4, TIPV4,RU32,sel,tkey);
+		goto done;
+	}
+	/* jamal - look at these and make them either old or new
+	** scheme given diffserv
+	** dont forget the CE bit
+	*/
+	if (strcmp(*argv, "tos") == 0 || matches(*argv, "dsfield") == 0) {
+		NEXT_ARG();
+		tkey->off = 1;
+		res = parse_cmd(&argc, &argv,  1, TU32,RU8,sel,tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "ihl") == 0) {
+		NEXT_ARG();
+		tkey->off = 0;
+		res = parse_cmd(&argc, &argv, 1, TU32,RU8,sel,tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "protocol") == 0) {
+		NEXT_ARG();
+		tkey->off = 9;
+		res = parse_cmd(&argc, &argv, 1, TU32,RU8,sel,tkey);
+		goto done;
+	}
+	/* jamal - fix this */
+	if (matches(*argv, "precedence") == 0) {
+		NEXT_ARG();
+		tkey->off = 1;
+		res = parse_cmd(&argc, &argv, 1, TU32,RU8,sel,tkey);
+		goto done;
+	}
+	/* jamal - validate this at some point */
+	if (strcmp(*argv, "nofrag") == 0) {
+		NEXT_ARG();
+		tkey->off = 6;
+		res = parse_cmd(&argc, &argv, 1, TU32,0x3F,sel,tkey);
+		goto done;
+	}
+	/* jamal - validate this at some point */
+	if (strcmp(*argv, "firstfrag") == 0) {
+		NEXT_ARG();
+		tkey->off = 6;
+		res = parse_cmd(&argc, &argv, 1, TU32,0x1F,sel,tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "ce") == 0) {
+		NEXT_ARG();
+		tkey->off = 6;
+		res = parse_cmd(&argc, &argv, 1, TU32,0x80,sel,tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "df") == 0) {
+		NEXT_ARG();
+		tkey->off = 6;
+		res = parse_cmd(&argc, &argv, 1, TU32,0x40,sel,tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "mf") == 0) {
+		NEXT_ARG();
+		tkey->off = 6;
+		res = parse_cmd(&argc, &argv, 1, TU32,0x20,sel,tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "dport") == 0) {
+		NEXT_ARG();
+		tkey->off = 22;
+		res = parse_cmd(&argc, &argv, 2, TU32,RU16,sel,tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "sport") == 0) {
+		NEXT_ARG();
+		tkey->off = 20;
+		res = parse_cmd(&argc, &argv, 2, TU32,RU16,sel,tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "icmp_type") == 0) {
+		NEXT_ARG();
+		tkey->off = 20;
+		res = parse_cmd(&argc, &argv, 1, TU32,RU8,sel,tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "icmp_code") == 0) {
+		NEXT_ARG();
+		tkey->off = 20;
+		res = parse_cmd(&argc, &argv, 1, TU32,RU8,sel,tkey);
+		goto done;
+	}
+	return -1;
+
+      done:
+	*argc_p = argc;
+	*argv_p = argv;
+	return res;
+}
+
+static int
+parse_ip6(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	int res = -1;
+	return res;
+}
+
+struct m_pedit_util p_pedit_ip = {
+	NULL,
+	"ip",
+	parse_ip,
+};
+
+
+struct m_pedit_util p_pedit_ip6 = {
+	NULL,
+	"ip6",
+	parse_ip6,
+};
diff -druN a/tc/p_tcp.c b/tc/p_tcp.c
--- a/tc/p_tcp.c	1969-12-31 19:00:00.000000000 -0500
+++ b/tc/p_tcp.c	2004-12-28 09:31:34.000000000 -0500
@@ -0,0 +1,38 @@
+/*
+ * m_pedit_tcp.c	packet editor: TCP header
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (hadi@cyberus.ca) 
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
+#include "m_pedit.h"
+
+static int
+parse_tcp(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	int res = -1;
+	return res;
+}
+struct m_pedit_util p_pedit_tcp = {
+	NULL,
+	"tcp",
+	parse_tcp,
+};
+
+
diff -druN a/tc/p_udp.c b/tc/p_udp.c
--- a/tc/p_udp.c	1969-12-31 19:00:00.000000000 -0500
+++ b/tc/p_udp.c	2004-12-28 09:31:34.000000000 -0500
@@ -0,0 +1,38 @@
+/*
+ * m_pedit_udp.c	packet editor: UDP header
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (hadi@cyberus.ca) 
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
+#include "m_pedit.h"
+
+static int
+parse_udp(int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
+{
+	int res = -1;
+	return res;
+}
+
+struct m_pedit_util p_pedit_udp = {
+	NULL,
+	"udp",
+	parse_udp,
+};
+

--=-FJRqejyEx01iPhYLNYub--
