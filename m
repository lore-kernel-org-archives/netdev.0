From: Andreas Henriksson <andreas@fatal.se>
Subject: debian iproute2 patches branch rebased.
Date: Thu, 10 Jan 2008 20:54:23 +0100
Message-ID: <20080110195423.GA26373@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:42737 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbYAJUT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 15:19:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen!

I've rebased the patches branch we carry in debian on top of the new
080108 release of iproute2.

See patches branch of git://git.debian.org/git/collab-maint/pkg-iproute

I've dropped one of the patches you picked up[1], so there's now one of the
old ones left and a new manpage for routel/routef.
(Any reason you didn't pull the actual commit we served you with git?)

The old remaining patch fixes the infinite loop in ip route flush exactly the
same way you fixed the same problem in ip neigh flush[2].
An additional patch will be provided in a followup mail (not available in
Debian) that was created by request from Patrick McHardy. This one makes max
rounds configurable (and 0 means try to infinity, so you can restore old
behaviour).
Patrick and me disagrees on what the default should be[3]. He thinks the 'ip
route flush' aka 'loop forever' behaviour should stay, while I vote for the
'ip neigh flush' behaviour of bailing out after N attempts.
IMNSHO looping infinitely is an *insane* default. Specially since this is a
tool used in bootup scripts....

[1]: See commit ea5dd59c03b36fe2acec8f03a8d7a2f7b7036b04
[2]: See commit 660818498d0f5a3f52c05355a3e82c23f670fcc1
     Where the comment seems to be wrong about "Limit ip route flush...",
     since it's actually "ip neigh flush" that's being modified.
[3]: Read thread from here on:
     http://www.spinics.net/lists/netdev/msg44920.html


commit 1eef590948f81b5c84e8450d5c95dd73744b4278
Author: Andreas Henriksson <andreas@fatal.se>
Date:   Thu Jan 3 16:48:56 2008 +0100

    Add routel and routef man page.

diff --git a/Makefile b/Makefile
index de04176..723eb5d 100644
--- a/Makefile
+++ b/Makefile
@@ -56,6 +56,7 @@ install: all
 	ln -sf lnstat.8  $(DESTDIR)$(MANDIR)/man8/rtstat.8
 	ln -sf lnstat.8  $(DESTDIR)$(MANDIR)/man8/ctstat.8
 	ln -sf rtacct.8  $(DESTDIR)$(MANDIR)/man8/nstat.8
+	ln -sf routel.8  $(DESTDIR)$(MANDIR)/man8/routef.8
 	install -m 0755 -d $(DESTDIR)$(MANDIR)/man3
 	install -m 0644 $(shell find man/man3 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man3
 
diff --git a/man/man8/routel.8 b/man/man8/routel.8
new file mode 100644
index 0000000..cdf8f55
--- /dev/null
+++ b/man/man8/routel.8
@@ -0,0 +1,32 @@
+.TH "ROUTEL" "8" "3 Jan, 2008" "iproute2" "Linux"
+.SH "NAME"
+.LP 
+routel \- list routes with pretty output format
+.br
+routef \- flush routes
+.SH "SYNTAX"
+.LP 
+routel [\fItablenr\fP [\fIraw ip args...\fP]]
+.br 
+routef
+.SH "DESCRIPTION"
+.LP 
+These programs are a set of helper scripts you can use instead of raw iproute2 commands.
+.br
+The routel script will list routes in a format that some might consider easier to interpret then the ip route list equivalent.
+.br
+The routef script does not take any arguments and will simply flush the routing table down the drain. Beware! This means deleting all routes which will make your network unusable!
+
+.SH "FILES"
+.LP 
+\fI/usr/bin/routef\fP 
+.br 
+\fI/usr/bin/routel\fP 
+.SH "AUTHORS"
+.LP 
+The routel script was written by Stephen R. van den Berg <srb@cuci.nl>, 1999/04/18 and donated to the public domain.
+.br
+This manual page was written by Andreas Henriksson  <andreas@fatal.se>, for the Debian GNU/Linux system.
+.SH "SEE ALSO"
+.LP 
+ip(8)

commit 1d1dab5826d1a9091e0bb2cf832f0785dc2add63
Author: Daniel Silverstone <daniel.silverstone@ubuntu.com>
Date:   Fri Oct 19 13:32:24 2007 +0200

    Avoid infinite loop in ip addr flush.
    
    Fix "ip addr flush" the same way "ip neigh flush" was previously fixed,
    by bailing out if the flush hasn't completed after MAX_ROUNDS (10) tries.

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index d1c6620..34379d0 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -34,6 +34,8 @@
 #include "ll_map.h"
 #include "ip_common.h"
 
+#define MAX_ROUNDS 10
+
 static struct
 {
 	int ifindex;
@@ -667,7 +669,7 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		filter.flushp = 0;
 		filter.flushe = sizeof(flushb);
 
-		for (;;) {
+		while (round < MAX_ROUNDS) {
 			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
@@ -694,6 +696,8 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				fflush(stdout);
 			}
 		}
+		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", MAX_ROUNDS); fflush(stderr);
+		return 1;
 	}
 
 	if (filter.family != AF_PACKET) {



-- 
Regards,
Andreas Henriksson
