From: Andreas Henriksson <andreas@fatal.se>
Subject: iproute2: resend of patches from Debian.
Date: Thu, 11 Oct 2007 20:25:32 +0200
Message-ID: <1192127132.4732.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-apWSfGRCy7bRtxktbriF"
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:57659 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443AbXJKS0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 14:26:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-apWSfGRCy7bRtxktbriF
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello all!

Posting this set of patches again, since there where no reaction last time I sent them.

Regards,
Andreas Henriksson

----


Hello Stephen Hemminger and the rest of the people on the nevdev list!

I'm posting a bunch of patches for iproute2. A few I've written myself
and have a Signed-off-by with my name in them, the others I've picked up
from the iproute package in Debian. I tried my best to add a decent
description, references to debian bug number and when possible a From
header suggesting who the original author might be.
They should all apply with some offset and sometimes a bit fuzz to the
current iproute2 git tree.


new patches posted to the debian bug tracking system:
add-mpath-docs.diff
doublefree.diff
fix-layer-syntax.diff
new-manpages.diff
tick2time-fix.diff
wrandom-fix.diff

fixes in the debian iproute package:
empty_linkname.diff
ip_address_flush_loop.diff
lartc.diff
netbug_fix.diff
okey-ikey.diff
remove_tc_filters_reference.diff

patches updating help text syntax:
ip_route_usage.diff
ip_rule_usage.diff

patches fixing documentation typos:
fix_ss_typo.diff
ip.8-typo.diff
ip_address.diff
libnetlink_typo.diff
manpages-typo.diff
tcb_htb_typo.diff
tc_cbq_details_typo.diff


-- 
Regards,
Andreas Henriksson

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=empty_linkname.diff
Content-Type: text/x-patch; name=empty_linkname.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Disallow empty link name.

From: Alexander Wirt <formorer@debian.org>

Patch from debian iproute package.

diff -urNad iproute-20060323~/ip/iplink.c iproute-20060323/ip/iplink.c
--- iproute-20060323~/ip/iplink.c	2006-03-22 00:57:50.000000000 +0100
+++ iproute-20060323/ip/iplink.c	2006-09-08 21:07:14.000000000 +0200
@@ -384,6 +384,10 @@
 	}
 
 	if (newname && strcmp(dev, newname)) {
+		if (strlen(newname) == 0) {
+		    printf("\"\" is not valid device identifier\n",dev);
+		    return -1;
+		}
 		if (do_changename(dev, newname) < 0)
 			return -1;
 		dev = newname;

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=ip_address_flush_loop.diff
Content-Type: text/x-patch; name=ip_address_flush_loop.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Abort flush after 10 seconds.

From: Alexander Wirt <formorer@debian.org>

Patch from Debian iproute package.

diff -urNad iproute-20060323~/ip/ipaddress.c iproute-20060323/ip/ipaddress.c
--- iproute-20060323~/ip/ipaddress.c	2006-09-08 17:02:03.000000000 +0200
+++ iproute-20060323/ip/ipaddress.c	2006-09-08 17:03:01.000000000 +0200
@@ -15,6 +15,7 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <unistd.h>
+#include <time.h>
 #include <syslog.h>
 #include <fcntl.h>
 #include <sys/ioctl.h>
@@ -589,6 +590,7 @@
 	if (flush) {
 		int round = 0;
 		char flushb[4096-512];
+		time_t start = time(0);
 
 		filter.flushb = flushb;
 		filter.flushp = 0;
@@ -617,6 +619,12 @@
 				printf("Warum?\n");
 				return 1;
 
+                        if (time(0) - start > 10) {
+                                printf("\n*** Flush not completed after %ld seconds, %d entries remain ***\n",
+                                       time(0) - start, filter.flushed);
+                                exit(1);
+                        }
+
 			if (show_stats) {
 				printf("\n*** Round %d, deleting %d addresses ***\n", round, filter.flushed);
 				fflush(stdout);

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=lartc.diff
Content-Type: text/x-patch; name=lartc.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Add references to lartc, also drop bogus reference to tc-filters

Patch from Debian iproute package.

diff -Nur old/man/man8/ip.8 new/man/man8/ip.8
--- old/man/man8/ip.8	2005-01-05 22:40:29.000000000 +0000
+++ new/man/man8/ip.8	2005-01-05 22:47:03.000000000 +0000
@@ -1803,6 +1803,8 @@
 .RB "IP Command reference " ip-cref.ps
 .br
 .RB "IP tunnels " ip-cref.ps
+.br
+.RB http://lartc.org/
 
 .SH AUTHOR
 
diff -Nur old/man/man8/tc.8 new/man/man8/tc.8
--- old/man/man8/tc.8	2004-10-19 20:49:02.000000000 +0000
+++ new/man/man8/tc.8	2005-01-05 22:46:15.000000000 +0000
@@ -341,7 +341,7 @@
 .BR tc-pfifo (8),
 .BR tc-bfifo (8),
 .BR tc-pfifo_fast (8),
-.BR tc-filters (8)
+.BR http://lartc.org/
 
 .SH AUTHOR
 Manpage maintained by bert hubert (ahu@ds9a.nl)

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=netbug_fix.diff
Content-Type: text/x-patch; name=netbug_fix.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix misc/netbug script.

See the following debian bugs:
http://bugs.debian.org/289541
http://bugs.debian.org/313540
http://bugs.debian.org/313541
http://bugs.debian.org/313544
http://bugs.debian.org/347699

Changes from Debian iproute package rediffed to apply against current
iproute2 git tree.

--- iproute2/misc/netbug	2007-09-09 17:36:19.000000000 +0200
+++ iproute-20070313/misc/netbug	2007-09-09 20:42:01.000000000 +0200
@@ -1,23 +1,16 @@
 #! /bin/bash
 
+set -e
+
 echo -n "Send network configuration summary to [ENTER means kuznet@ms2.inr.ac.ru] "
 IFS="" read mail || exit 1
 [ -z "$mail" ] && mail=kuznet@ms2.inr.ac.ru
 
+netbug=`mktemp -d -t netbug.XXXXXX` || (echo "$0: Cannot create temporary directory" >&2; exit 1; )
+netbugtar=`tempfile -d $netbug --suffix=tar.gz` || (echo "$0: Cannot create temporary file" >&2; exit 1; )
+tmppath=$netbug
+trap "/bin/rm -rf $netbug $netbugtar" 0 1 2 3 13 15
 
-netbug=""
-while [ "$netbug" = "" ]; do
-	netbug=`echo netbug.$$.$RANDOM`
-	if [ -e /tmp/$netbug ]; then
-		netbug=""
-	fi
-done
-
-tmppath=/tmp/$netbug
-
-trap "rm -rf $tmppath $tmppath.tar.gz" 0 SIGINT
-
-mkdir $tmppath
 mkdir $tmppath/net
 
 cat /proc/slabinfo > $tmppath/slabinfo
@@ -44,9 +37,8 @@
 fi
 
 cd /tmp
-tar c $netbug | gzip -9c > $netbug.tar.gz
-
-uuencode $netbug.tar.gz $netbug.tar.gz | mail -s $netbug "$mail"
+tar c $tmppath | gzip -9c > $netbugtar
+uuencode $netbugtar $netbugtar | mail -s $netbug "$mail"
 
 echo "Sending to <$mail>; subject is $netbug"
 

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=okey-ikey.diff
Content-Type: text/x-patch; name=okey-ikey.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix typo in GRE tunnels (i_key vs. o_key).

From: <herbert@gondor.apana.org.au>

If a dotted quad ikey is specified for GRE tunnels, it gets set as the
okey instead.  This patch fixes it.

See Debian bug #200714 - http://bugs.debian.org/200714

Patch from Debian iproute package.

--- iproute/ip/iptunnel.c.orig  2003-07-10 11:47:06.000000000 +1000
+++ iproute/ip/iptunnel.c       2003-07-10 11:47:11.000000000 +1000
@@ -221,7 +221,7 @@
			NEXT_ARG();
			p->i_flags |= GRE_KEY;
			if (strchr(*argv, '.'))
-				p->o_key = get_addr32(*argv);
+				p->i_key = get_addr32(*argv);
			else {
				if (get_unsigned(&uval, *argv, 0)<0) {
					fprintf(stderr, "invalid value of \"ikey\"\n");

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=remove_tc_filters_reference.diff
Content-Type: text/x-patch; name=remove_tc_filters_reference.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Remove bogus reference to tc-filters(8) from tc(8) manpage.

See debian bug #289225 - http://bugs.debian.org/289225

Patch from Debian iproute package.

diff -urNad iproute-20070313~/man/man8/tc.8 iproute-20070313/man/man8/tc.8
--- iproute-20070313~/man/man8/tc.8	2007-06-10 20:22:40.000000000 +0200
+++ iproute-20070313/man/man8/tc.8	2007-06-10 20:23:16.000000000 +0200
@@ -202,8 +202,7 @@
 tc filters
 If tc filters are attached to a class, they are consulted first 
 for relevant instructions. Filters can match on all fields of a packet header, 
-as well as on the firewall mark applied by ipchains or iptables. See 
-.BR tc-filters (8).
+as well as on the firewall mark applied by ipchains or iptables. 
 .TP
 Type of Service
 Some qdiscs have built in rules for classifying packets based on the TOS field.
@@ -242,8 +241,7 @@
 .TP 
 FILTERS
 Filters have a three part ID, which is only needed when using a hashed
-filter hierarchy, for which see
-.BR tc-filters (8).
+filter hierarchy.
 .SH UNITS
 All parameters accept a floating point number, possibly followed by a unit.
 .P

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=add-mpath-docs.diff
Content-Type: text/x-patch; name=add-mpath-docs.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Add mpath to ip manpage.

From: Norbert Buchmuller <norbi@nix.hu>

The 'mpath' parameter of 'ip route' is not documented in the manual page
nor in ip-cref.tex.

...huge part of the text in the patch was taken from the net/ipv4/Kconfig
file in the Linux kernel source (2.6.18). I suppose that's OK because both
Linux and iproute2 are GPL'd, but I let you know anyway.

See Debian bug #428442 - http://bugs.debian.org/428442

diff -Naur iproute-20061002/doc/ip-cref.tex iproute-20061002.fixed/doc/ip-cref.tex
--- iproute-20061002/doc/ip-cref.tex	2007-06-11 19:26:52.000000000 +0200
+++ iproute-20061002.fixed/doc/ip-cref.tex	2007-06-11 20:34:09.000000000 +0200
@@ -1348,6 +1348,28 @@
 route reflecting its relative bandwidth or quality.
 \end{itemize}
 
+\item \verb|mpath MP_ALGO|
+
+--- the  multipath algo to use.
+\verb|MP_ALGO| may be one of the following values:
+\begin{itemize}
+\item \verb|rr| --- round robin algorithm.
+Multipath routes are chosen according to Round Robin.
+\item \verb|drr| --- interface round robin algorithm.
+Connections are distributed in a round robin fashion over the
+available interfaces. This policy makes sense if the connections 
+should be primarily distributed on interfaces and not on routes.
+\item \verb|random| --- random algorithm.
+Multipath routes are chosen in a random fashion. Actually,
+there is no weight for a route. The advantage of this policy
+is that it is implemented stateless and therefore introduces only
+a very small delay.
+\item \verb|wrandom| --- weighted random algorithm.
+Multipath routes are chosen in a weighted random fashion. 
+The per route weights are the weights visible via ip route 2. As the
+corresponding state management introduces some overhead routing delay
+is increased.
+\end{itemize}
 \item \verb|scope SCOPE_VAL|
 
 --- the scope of the destinations covered by the route prefix.
diff -Naur iproute-20061002/man/man8/ip.8 iproute-20061002.fixed/man/man8/ip.8
--- iproute-20061002/man/man8/ip.8	2007-06-11 19:26:52.000000000 +0200
+++ iproute-20061002.fixed/man/man8/ip.8	2007-06-11 20:26:43.000000000 +0200
@@ -146,7 +146,9 @@
 .B  scope
 .IR SCOPE " ] [ "
 .B  metric
-.IR METRIC " ]"
+.IR METRIC " ] [ "
+.B  mpath
+.IR MP_ALGO " ]"
 
 .ti -8
 .IR INFO_SPEC " := " "NH OPTIONS FLAGS" " ["
@@ -205,6 +207,10 @@
 .BR onlink " | " pervasive " ]"
 
 .ti -8
+.IR MP_ALGO " := [ "
+.BR rr " | " drr " | " random " | " wrandom " ]"
+
+.ti -8
 .IR RTPROTO " := [ "
 .BR kernel " | " boot " | " static " |"
 .IR NUMBER " ]"
@@ -1116,6 +1122,38 @@
 .in -8
 
 .TP
+.BI mpath " MP_ALGO"
+the multipath algo to use.
+.I MP_ALGO
+may be one of the following values:
+
+.in +8
+.B rr
+- round robin algorithm.
+Multipath routes are chosen according to Round Robin.
+.sp
+.B drr
+- interface round robin algorithm.
+Connections are distributed in a round robin fashion over the
+available interfaces. This policy makes sense if the connections 
+should be primarily distributed on interfaces and not on routes.
+.sp
+.B random
+- random algorithm.
+Multipath routes are chosen in a random fashion. Actually,
+there is no weight for a route. The advantage of this policy
+is that it is implemented stateless and therefore introduces only
+a very small delay.
+.sp
+.B wrandom
+- weighted random algorithm.
+Multipath routes are chosen in a weighted random fashion. 
+The per route weights are the weights visible via ip route 2. As the
+corresponding state management introduces some overhead routing delay
+is increased.
+.in -8
+
+.TP
 .BI scope " SCOPE_VAL"
 the scope of the destinations covered by the route prefix.
 .I SCOPE_VAL

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=doublefree.diff
Content-Type: text/x-patch; name=doublefree.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix corruption when using batch files with comments and broken lines.

See Debian bug #398912 - http://bugs.debian.org/398912

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff -urip iproute-20061002/include/utils.h iproute-20061002.fixed2/include/utils.h
--- iproute-20061002/include/utils.h	2006-10-02 22:13:34.000000000 +0200
+++ iproute-20061002.fixed2/include/utils.h	2007-08-16 00:51:58.000000000 +0200
@@ -132,7 +132,7 @@ int print_timestamp(FILE *fp);
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 
 extern int cmdlineno;
-extern size_t getcmdline(char **line, size_t *len, FILE *in);
+extern ssize_t getcmdline(char **line, size_t *len, FILE *in);
 extern int makeargs(char *line, char *argv[], int maxargs);
 
 #endif /* __UTILS_H__ */
diff -urip iproute-20061002/lib/utils.c iproute-20061002.fixed2/lib/utils.c
--- iproute-20061002/lib/utils.c	2006-10-02 22:13:34.000000000 +0200
+++ iproute-20061002.fixed2/lib/utils.c	2007-08-16 00:49:02.000000000 +0200
@@ -578,9 +578,9 @@ int print_timestamp(FILE *fp)
 int cmdlineno;
 
 /* Like glibc getline but handle continuation lines and comments */
-size_t getcmdline(char **linep, size_t *lenp, FILE *in)
+ssize_t getcmdline(char **linep, size_t *lenp, FILE *in)
 {
-	size_t cc;
+	ssize_t cc;
 	char *cp;
 		
 	if ((cc = getline(linep, lenp, in)) < 0)
@@ -608,9 +608,11 @@ size_t getcmdline(char **linep, size_t *
 		if (cp) 
 			*cp = '\0';
 
-		*linep = realloc(*linep, strlen(*linep) + strlen(line1) + 1);
+		*lenp = strlen(*linep) + strlen(line1) + 1;
+		*linep = realloc(*linep, *lenp);
 		if (!*linep) {
 			fprintf(stderr, "Out of memory\n");
+			*lenp = 0;
 			return -1;
 		}
 		cc += cc1 - 2;

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=fix-layer-syntax.diff
Content-Type: text/x-patch; name=fix-layer-syntax.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix ematch cmp and nbyte syntax help text.

From: Lionel Elie Mamane <lionel@mamane.lu>

The help/usage screen of ematch cmp and nbyte say recognised symbolic
values for "layer FOO" are link, header and next-header, but the code
does _not_ implement that: it will recognise "next-header" as what is
supposed to be "header" and will not recognise "header". The right
symbolic values seem to be link, network, transport. Here is a patch
that changes the help/usage screen to match the code.

See Debian bug #438653 - http://bugs.debian.org/438653

diff --recursive -N -u iproute-20070313.deb/tc/em_cmp.c iproute-20070313.lio/tc/em_cmp.c
--- iproute-20070313.deb/tc/em_cmp.c	2007-03-13 22:50:56.000000000 +0100
+++ iproute-20070313.lio/tc/em_cmp.c	2007-08-18 18:44:26.773897785 +0200
@@ -1,5 +1,5 @@
 /*
- * em_cmp.c		Simle coparison Ematch
+ * em_cmp.c		Simple comparison Ematch
  *
  *		This program is free software; you can distribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -32,7 +32,7 @@
 	    "Usage: cmp(ALIGN at OFFSET [ ATTRS ] { eq | lt | gt } VALUE)\n" \
 	    "where: ALIGN  := { u8 | u16 | u32 }\n" \
 	    "       ATTRS  := [ layer LAYER ] [ mask MASK ] [ trans ]\n" \
-	    "       LAYER  := { link | header | next-header | 0..%d }\n" \
+	    "       LAYER  := { link | network | transport | 0..%d }\n" \
 	    "\n" \
 	    "Example: cmp(u16 at 3 layer 2 mask 0xff00 gt 20)\n",
 	    TCF_LAYER_MAX);
diff --recursive -N -u iproute-20070313.deb/tc/em_nbyte.c iproute-20070313.lio/tc/em_nbyte.c
--- iproute-20070313.deb/tc/em_nbyte.c	2007-03-13 22:50:56.000000000 +0100
+++ iproute-20070313.lio/tc/em_nbyte.c	2007-08-18 18:45:48.159607231 +0200
@@ -32,7 +32,7 @@
 	    "Usage: nbyte(NEEDLE at OFFSET [layer LAYER])\n" \
 	    "where: NEEDLE := { string | \"c-escape-sequence\" }\n" \
 	    "       OFFSET := int\n" \
-	    "       LAYER  := { link | header | next-header | 0..%d }\n" \
+	    "       LAYER  := { link | network | transport | 0..%d }\n" \
 	    "\n" \
 	    "Example: nbyte(\"ababa\" at 12 layer 1)\n",
 	    TCF_LAYER_MAX);

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=new-manpages.diff
Content-Type: text/x-patch; name=new-manpages.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Add new manpages and symlinks.

Symlink rtstat(8) and ctstat(8) to lnstat(8).
Add rtacct/nstat manpage based on doc/nstat.sgml as rtacct(8).
Symlink nstat(8) to rtacct(8).
Add arpd(8) symlink based on doc/arpd.sgml.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff --git a/Makefile b/Makefile
index af0d5e4..6c976dd 100644
--- a/Makefile
+++ b/Makefile
@@ -53,6 +53,9 @@ install: all
 	install -m 0755 -d $(DESTDIR)$(MANDIR)/man8
 	install -m 0644 $(shell find man/man8 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man8
 	ln -sf tc-bfifo.8  $(DESTDIR)$(MANDIR)/man8/tc-pfifo.8
+	ln -sf lnstat.8  $(DESTDIR)$(MANDIR)/man8/rtstat.8
+	ln -sf lnstat.8  $(DESTDIR)$(MANDIR)/man8/ctstat.8
+	ln -sf rtacct.8  $(DESTDIR)$(MANDIR)/man8/nstat.8
 	install -m 0755 -d $(DESTDIR)$(MANDIR)/man3
 	install -m 0644 $(shell find man/man3 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man3
 
diff --git a/man/man8/arpd.8 b/man/man8/arpd.8
new file mode 100644
index 0000000..d172600
--- /dev/null
+++ b/man/man8/arpd.8
@@ -0,0 +1,66 @@
+.TH ARPD 8 "28 June, 2007"
+
+.SH NAME
+arpd \- userspace arp daemon.
+
+.SH SYNOPSIS
+Usage: arpd [ -lk ] [ -a N ] [ -b dbase ] [ -f file ] [ interfaces ]
+
+.SH DESCRIPTION
+The
+.B arpd
+daemon collects gratuitous ARP information, saving it on local disk and feeding it to kernel on demand to avoid redundant broadcasting due to limited size of kernel ARP cache.
+
+.SH OPTIONS
+.TP
+-h -?
+Print help
+.TP
+-l
+Dump arpd database to stdout and exit. Output consists of three columns: interface index, IP address and MAC address. Negative entries for dead hosts are also shown, in this case MAC address is replaced by word FAILED followed by colon and time when the fact that host is dead was proven the last time.
+.TP
+-f <FILE>
+Read and load arpd database from FILE in text format similar dumped by option -l. Exit after load, probably listing resulting database, if option -l is also given. If FILE is -, stdin is read to get ARP table.
+.TP
+-b <DATABASE>
+location of database file. Default location is /var/lib/arpd/arpd.db
+.TP
+-a <NUMBER>
+arpd not only passively listens ARP on wire, but also send brodcast queries itself. NUMBER is number of such queries to make before destination is considered as dead. When arpd is started as kernel helper (i.e. with app_solicit enabled in sysctl or even with option -k) without this option and still did not learn enough information, you can observe 1 second gaps in service. Not fatal, but not good.
+.TP
+-k
+Suppress sending broadcast queries by kernel. It takes sense together with option -a.
+.TP
+-n <TIME>
+Timeout of negative cache. When resolution fails arpd suppresses further attempts to resolve for this period. It makes sense only together with option -k This timeout should not be too much longer than boot time of a typical host not supporting gratuitous ARP. Default value is 60 seconds.
+.TP
+-r <RATE>
+Maximal steady rate of broadcasts sent by arpd in packets per second. Default value is 1.
+.TP
+-B <NUMBER>
+Number of broadcasts sent by <tt/arpd/ back to back. Default value is 3. Together with option <tt/-R/ this option allows to police broadcasting not to exceed B+R*T over any interval of time T.
+.P
+<INTERFACE> is the name of networking interface to watch. If no interfaces given, arpd monitors all the interfaces. In this case arpd does not adjust sysctl parameters, it is supposed user does this himself after arpd is started.
+.P
+Signals
+.br
+arpd exits gracefully syncing database and restoring adjusted sysctl parameters, when receives SIGINT or SIGTERM. SIGHUP syncs database to disk. SIGUSR1 sends some statistics to syslog. Effect of another signals is undefined, they may corrupt database and leave sysctl praameters in an unpredictable state.
+.P
+Note
+.br
+In order for arpd to be able to serve as ARP resolver, kernel must be compiled with the option CONFIG_ARPD and, in the case when interface list in not given on command line, variable app_solicit on interfaces of interest should be in /proc/sys/net/ipv4/neigh/*. If this is not made arpd still collects gratuitous ARP information in its database.
+.SH EXAMPLES
+.TP
+arpd -b /var/tmp/arpd.db
+Start arpd to collect gratuitous ARP, but not messing with kernel functionality.
+.TP
+killall arpd ; arpd -l -b /var/tmp/arpd.db
+Look at result after some time.
+.TP
+arpd -b /var/tmp/arpd.db -a 1 eth0 eth1
+Enable kernel helper, leaving leading role to kernel.
+.TP
+arpd -b /var/tmp/arpd.db -a 3 -k eth0 eth1
+Completely replace kernel resolution on interfaces eth0 and eth1. In this case kernel still does unicast probing to validate entries, but all the broadcast activity is suppressed and made under authority of arpd.
+.PP
+This is mode which arpd is supposed to work normally. It is not default just to prevent occasional enabling of too aggressive mode occasionally.
diff --git a/man/man8/rtacct.8 b/man/man8/rtacct.8
new file mode 100644
index 0000000..fb9afe8
--- /dev/null
+++ b/man/man8/rtacct.8
@@ -0,0 +1,48 @@
+.TH RTACCT 8 "27 June, 2007"
+
+.SH NAME
+nstat, rtacct - network statistics tools.
+
+.SH SYNOPSIS
+Usage: nstat [ -h?vVzrnasd:t: ] [ PATTERN [ PATTERN ] ]
+.br
+Usage: rtacct [ -h?vVzrnasd:t: ] [ ListOfRealms ]
+
+.SH DESCRIPTION
+.B nstat
+and
+.B rtacct
+are simple tools to monitor kernel snmp counters and network interface statistics.
+
+.SH OPTIONS
+.TP
+-h -?
+Print help
+.TP
+-v -V
+Print version
+.TP
+-z
+Dump zero counters too. By default they are not shown.
+.TP
+-r
+Reset history.
+.TP
+-n
+Do not display anything, only update history.
+.TP
+-a
+Dump absolute values of counters. The default is to calculate increments since the previous use.
+.TP
+-s
+Do not update history, so that the next time you will see counters including values accumulated to the moment of this measurement too.
+.TP
+-d <INTERVAL>
+Run in daemon mode collecting statistics. <INTERVAL> is interval between measurements in seconds.
+.TP
+-t <INTERVAL>
+Time interval to average rates. Default value is 60 seconds.
+
+.SH SEE ALSO
+lnstat(8)
+

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=tick2time-fix.diff
Content-Type: text/x-patch; name=tick2time-fix.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix overflow in time2tick / tick2time.

The helper functions gets passed an unsigned int, which gets cast to long
and overflows.

See Debian bug #175462 - http://bugs.debian.org/175462

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff -uri iproute-20070313.orig/tc/tc_core.c iproute-20070313/tc/tc_core.c
--- iproute-20070313.orig/tc/tc_core.c	2007-03-13 22:50:56.000000000 +0100
+++ iproute-20070313/tc/tc_core.c	2007-08-15 00:41:30.000000000 +0200
@@ -35,12 +35,12 @@
 }
 
 
-long tc_core_time2tick(long time)
+unsigned tc_core_time2tick(unsigned time)
 {
 	return time*tick_in_usec;
 }
 
-long tc_core_tick2time(long tick)
+unsigned tc_core_tick2time(unsigned tick)
 {
 	return tick/tick_in_usec;
 }
diff -uri iproute-20070313.orig/tc/tc_core.h iproute-20070313/tc/tc_core.h
--- iproute-20070313.orig/tc/tc_core.h	2007-03-13 22:50:56.000000000 +0100
+++ iproute-20070313/tc/tc_core.h	2007-08-15 00:41:49.000000000 +0200
@@ -7,8 +7,8 @@
 #define TIME_UNITS_PER_SEC	1000000000
 
 int  tc_core_time2big(long time);
-long tc_core_time2tick(long time);
-long tc_core_tick2time(long tick);
+unsigned tc_core_time2tick(unsigned time);
+unsigned tc_core_tick2time(unsigned tick);
 long tc_core_time2ktime(long time);
 long tc_core_ktime2time(long ktime);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=wrandom-fix.diff
Content-Type: text/x-patch; name=wrandom-fix.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix off-by-one in print of wrandom algo.

From: Norbert Buchmuller <norbi@nix.hu>

The 'wrandom' multipath algo is recognised when adding the route, but
not resolved when it is printed (prints 'unknown'):

ianus:~# ip ro add 1.2.3.4 mpath wrandom nexthop dev ppp0 weight 1 nexthop dev ppp1 weight 2
ianus:~# ip ro get to 1.2.3.4
1.2.3.4 mpath unknown dev ppp0  src 62.77.192.67 
    cache  mtu 1492 advmss 1452 hoplimit 64
ianus:~# ip ro del 1.2.3.4 mpath wrandom nexthop dev ppp0 weight 1 nexthop dev ppp1 weight 2

See Debian bug #428440 - http://bugs.debian.org/428440

diff -Naur iproute-20061002/ip/iproute.c iproute-20061002.fixed/ip/iproute.c
--- iproute-20061002/ip/iproute.c	2007-06-11 19:26:52.000000000 +0200
+++ iproute-20061002.fixed/ip/iproute.c	2007-06-11 19:27:29.000000000 +0200
@@ -358,7 +358,7 @@
 		__u32 mp_alg = *(__u32*) RTA_DATA(tb[RTA_MP_ALGO]);
 		if (mp_alg > IP_MP_ALG_NONE) {
 			fprintf(fp, "mpath %s ",
-			    mp_alg < IP_MP_ALG_MAX ? mp_alg_names[mp_alg] : "unknown");
+			    mp_alg <= IP_MP_ALG_MAX ? mp_alg_names[mp_alg] : "unknown");
 		}
 	}
 

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=ip_route_usage.diff
Content-Type: text/x-patch; name=ip_route_usage.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Add src syntax to route help text.

From: Alexander Wirt <formorer@debian.org>

Add src option to ip_route usage.

See Debian bug #226142 - http://bugs.debian.org/226142

diff -urNad iproute-20061002~/ip/iproute.c iproute-20061002/ip/iproute.c
--- iproute-20061002~/ip/iproute.c	2006-10-15 16:44:25.000000000 +0200
+++ iproute-20061002/ip/iproute.c	2006-10-15 16:50:29.000000000 +0200
@@ -73,7 +73,7 @@
 	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ]\n");
 	fprintf(stderr, "           [ rtt NUMBER ] [ rttvar NUMBER ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
-	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ]\n");
+	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=ip_rule_usage.diff
Content-Type: text/x-patch; name=ip_rule_usage.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Add syntax for rule prio help text.

From: Alexander Wirt <formorer@debian.org>

Add [ prio NUMBER ] to ip_rule.c

See Debian bug #213673 - http://bugs.debian.org/213673

diff -urNad iproute-20070313~/ip/iprule.c iproute-20070313/ip/iprule.c
--- iproute-20070313~/ip/iprule.c	2007-03-13 22:50:56.000000000 +0100
+++ iproute-20070313/ip/iprule.c	2007-06-10 17:54:46.000000000 +0200
@@ -38,7 +38,7 @@
 {
 	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
-	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ]\n");
+	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ] [ prio NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=fix_ss_typo.diff
Content-Type: text/x-patch; name=fix_ss_typo.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix typo in ss manpage.

Patch from debian iproute package.

diff -urNad iproute-20070313~/man/man8/ss.8 iproute-20070313/man/man8/ss.8
--- iproute-20070313~/man/man8/ss.8	2007-03-13 22:50:56.000000000 +0100
+++ iproute-20070313/man/man8/ss.8	2007-06-10 19:36:04.000000000 +0200
@@ -9,7 +9,7 @@
 is used to dump socket statistics. It allows showing information similar
 to
 .IR netstat .
-It can display more TCP information than state than other tools.
+It can display more TCP and state informations than other tools.
 
 .SH OPTIONS
 These programs follow the usual GNU command line syntax, with long

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=ip.8-typo.diff
Content-Type: text/x-patch; name=ip.8-typo.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Make the backslash visible in ip manpage.

See Debian bug #285507 - http://bugs.debian.org/285507

--- orig/man/man8/ip.8	2004-10-19 20:49:02.000000000 +0000
+++ new/man/man8/ip.8	2005-01-05 22:04:12.000000000 +0000
@@ -374,7 +374,7 @@
 .BR "\-o" , " \-oneline"
 output each record on a single line, replacing line feeds
 with the
-.B '\'
+.B '\e\'
 character. This is convenient when you want to count records 
 with
 .BR wc (1)

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=ip_address.diff
Content-Type: text/x-patch; name=ip_address.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Strict syntax for advice in error message.

diff -ruN iproute-20051007.orig/ip/ipaddress.c iproute-20051007/ip/ipaddress.c
--- iproute-20051007.orig/ip/ipaddress.c	2005-09-21 21:33:18.000000000 +0200
+++ iproute-20051007/ip/ipaddress.c	2006-03-14 07:26:26.830934712 +0100
@@ -901,7 +901,7 @@
 		return ipaddr_list_or_flush(argc-1, argv+1, 1);
 	if (matches(*argv, "help") == 0)
 		usage();
-	fprintf(stderr, "Command \"%s\" is unknown, try \"ip address help\".\n", *argv);
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addr help\".\n", *argv);
 	exit(-1);
 }
 

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=libnetlink_typo.diff
Content-Type: text/x-patch; name=libnetlink_typo.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix typo in libnetlink manpage (writen -> written).

diff -urNad iproute-20070313~/man/man3/libnetlink.3 iproute-20070313/man/man3/libnetlink.3
--- iproute-20070313~/man/man3/libnetlink.3	2007-03-13 22:50:56.000000000 +0100
+++ iproute-20070313/man/man3/libnetlink.3	2007-06-10 19:28:30.000000000 +0200
@@ -187,7 +187,7 @@
 This library should be named librtnetlink.
 
 .SH AUTHORS
-netlink/rtnetlink was designed and writen by Alexey Kuznetsov.
+netlink/rtnetlink was designed and written by Alexey Kuznetsov.
 Andi Kleen wrote the man page.
 
 .SH SEE ALSO

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=manpages-typo.diff
Content-Type: text/x-patch; name=manpages-typo.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix typos in tc-prio(8) manpage.

From: Alexander Wirt <formorer@debian.org>

diff -urNad iproute-20061002~/man/man8/tc-prio.8 iproute-20061002/man/man8/tc-prio.8
--- iproute-20061002~/man/man8/tc-prio.8	2006-10-15 17:06:41.000000000 +0200
+++ iproute-20061002/man/man8/tc-prio.8	2006-10-15 17:10:52.000000000 +0200
@@ -30,7 +30,7 @@
 On creation with 'tc qdisc add', a fixed number of bands is created. Each
 band is a class, although is not possible to add classes with 'tc qdisc
 add', the number of bands to be created must instead be specified on the
-commandline attaching PRIO to its root.
+command line attaching PRIO to its root.
 
 When dequeueing, band 0 is tried first and only if it did not deliver a
 packet does PRIO try band 1, and so onwards. Maximum reliability packets
@@ -88,7 +88,7 @@
 The four TOS bits (the 'TOS field') are defined as:
 
 .nf
-Binary Decimcal  Meaning
+Binary Decimal  Meaning
 -----------------------------------------
 1000   8         Minimize delay (md)
 0100   4         Maximize throughput (mt)
@@ -125,13 +125,13 @@
 
 The second column contains the value of the relevant
 four TOS bits, followed by their translated meaning. For example, 15 stands
-for a packet wanting Minimal Montetary Cost, Maximum Reliability, Maximum
+for a packet wanting Minimal Monetary Cost, Maximum Reliability, Maximum
 Throughput AND Minimum Delay. 
 
 The fourth column lists the way the Linux kernel interprets the TOS bits, by
 showing to which Priority they are mapped.
 
-The last column shows the result of the default priomap. On the commandline,
+The last column shows the result of the default priomap. On the command line,
 the default priomap looks like this:
 
     1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=tcb_htb_typo.diff
Content-Type: text/x-patch; name=tcb_htb_typo.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix typo in tc-htb(8) manpage (mininum -> minimum).

diff -urNad iproute-20070313~/man/man8/tc-htb.8 iproute-20070313/man/man8/tc-htb.8
--- iproute-20070313~/man/man8/tc-htb.8	2007-03-13 22:50:56.000000000 +0100
+++ iproute-20070313/man/man8/tc-htb.8	2007-06-10 19:30:08.000000000 +0200
@@ -137,7 +137,7 @@
 .SH NOTES
 Due to Unix timing constraints, the maximum ceil rate is not infinite and may in fact be quite low. On Intel, 
 there are 100 timer events per second, the maximum rate is that rate at which 'burst' bytes are sent each timer tick.
-From this, the mininum burst size for a specified rate can be calculated. For i386, a 10mbit rate requires a 12 kilobyte 
+From this, the minimum burst size for a specified rate can be calculated. For i386, a 10mbit rate requires a 12 kilobyte 
 burst as 100*12kb*8 equals 10mbit.
 
 .SH SEE ALSO

--=-apWSfGRCy7bRtxktbriF
Content-Disposition: attachment; filename=tc_cbq_details_typo.diff
Content-Type: text/x-patch; name=tc_cbq_details_typo.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

Fix typo in tc-cbq-details(8) manpage (occured -> occurred).

diff -urNad iproute-20070313~/man/man8/tc-cbq-details.8 iproute-20070313/man/man8/tc-cbq-details.8
--- iproute-20070313~/man/man8/tc-cbq-details.8	2007-06-10 19:25:18.000000000 +0200
+++ iproute-20070313/man/man8/tc-cbq-details.8	2007-06-10 19:25:58.000000000 +0200
@@ -210,7 +210,7 @@
 priority. If found, choose it, and terminate.
 .TP
 (iii)
-Choose the class at which break out to the fallback algorithm occured. Terminate.
+Choose the class at which break out to the fallback algorithm occurred. Terminate.
 .P
 The packet is enqueued to the class which was chosen when either algorithm 
 terminated. It is therefore possible for a packet to be enqueued *not* at a

--=-apWSfGRCy7bRtxktbriF--

