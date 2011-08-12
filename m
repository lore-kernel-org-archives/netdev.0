From: Alex Dubov <oakad@yahoo.com>
Subject: iproute2: make arpd daemon write pid file on fork
Date: Fri, 12 Aug 2011 16:23:24 +1000
Message-ID: <201108121623.24984.oakad@yahoo.com>
References: <1313080925.3635.YahooMailNeo@web121018.mail.ne1.yahoo.com> <20110811110029.023a5955@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm12-vm2.bullet.mail.ne1.yahoo.com ([98.138.91.88]:47432 "HELO
	nm12-vm2.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750781Ab1HLGXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 02:23:34 -0400
In-Reply-To: <20110811110029.023a5955@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current version of arpd included with iproute2-2.6.37 will fork 
unconditionally on start-up (using daemon() library call). This causes 
problems with distro start-up scripts, as PID of the started daemon can not be 
reliably obtained, hampering orderly daemon shutdown process.

The included patch makes arpd write it's own pid file after fork, in a common 
LSB fashion, so as to better inter-operate with start up scripts. Removal of 
stale pid files is handled elsewhere.

--- misc/arpd.c.orig	2011-01-08 04:54:30.000000000 +1100
+++ misc/arpd.c	2011-08-12 16:04:51.098754397 +1000
@@ -41,6 +41,7 @@
 
 DB	*dbase;
 char	*dbname = "/var/lib/arpd/arpd.db";
+char	*pidfname = "/var/run/arpd.pid";
 
 int	ifnum;
 int	*ifvec;
@@ -780,6 +781,17 @@
 		goto do_abort;
 	}
 
+	do {
+		FILE *fp = fopen(pidfname, "w");
+		if (fp) {
+			fprintf(fp, "%ld\n", (long)getpid());
+			fclose(fp);
+		} else {
+			perror("arpd: pid fopen");
+			goto do_abort;
+		}
+	} while (0);
+
 	openlog("arpd", LOG_PID | LOG_CONS, LOG_DAEMON);
 	catch_signal(SIGINT, sig_exit);
 	catch_signal(SIGTERM, sig_exit);
