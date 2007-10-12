From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 09/12] Add new rtacct/nstat manpages and additional symlinks.
Date: Fri, 12 Oct 2007 10:56:44 +0200
Message-ID: <1192179407-22461-9-git-send-email-andreas@fatal.se>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
 <1192179407-22461-2-git-send-email-andreas@fatal.se>
 <1192179407-22461-3-git-send-email-andreas@fatal.se>
 <1192179407-22461-4-git-send-email-andreas@fatal.se>
 <1192179407-22461-5-git-send-email-andreas@fatal.se>
 <1192179407-22461-6-git-send-email-andreas@fatal.se>
 <1192179407-22461-7-git-send-email-andreas@fatal.se>
 <1192179407-22461-8-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38393 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbXJLI5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:57:31 -0400
In-Reply-To: <1192179407-22461-8-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Symlink rtstat(8) and ctstat(8) to lnstat(8).
Add rtacct/nstat manpage based on doc/nstat.sgml as rtacct(8).
Symlink nstat(8) to rtacct(8).
Add arpd(8) symlink based on doc/arpd.sgml.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 Makefile          |    3 ++
 man/man8/arpd.8   |   66 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/rtacct.8 |   48 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 117 insertions(+), 0 deletions(-)
 create mode 100644 man/man8/arpd.8
 create mode 100644 man/man8/rtacct.8

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
-- 
1.5.3.4

