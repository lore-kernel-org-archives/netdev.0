From: Andreas Henriksson <andreas@fatal.se>
Subject: iproute2: make max rounds in ip {neigh,addr} flush configurable.
Date: Thu, 10 Jan 2008 21:33:13 +0100
Message-ID: <1199997194.16358.115.camel@localhost.localdomain>
References: <20080110195423.GA26373@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:37550 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853AbYAJU2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 15:28:49 -0500
In-Reply-To: <20080110195423.GA26373@scream.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On tor, 2008-01-10 at 20:54 +0100, Andreas Henriksson wrote:
> An additional patch will be provided in a followup mail (not available in
> Debian) that was created by request from Patrick McHardy. This one makes max
> rounds configurable (and 0 means try to infinity, so you can restore old
> behaviour).

In my opinion 10 tries should be enough for anyone, but here's the patch anyway.

This one is on top of the patches in the previous mail.


diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index ff9e318..232fd64 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -67,6 +67,7 @@ static void usage(void)
 	fprintf(stderr, "       ip addr del IFADDR dev STRING\n");
 	fprintf(stderr, "       ip addr {show|flush} [ dev STRING ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label PATTERN ]\n");
+	fprintf(stderr, "                            [ maxrounds N ]\n");
 	fprintf(stderr, "IFADDR := PREFIX | ADDR peer PREFIX\n");
 	fprintf(stderr, "          [ broadcast ADDR ] [ anycast ADDR ]\n");
 	fprintf(stderr, "          [ label STRING ] [ scope SCOPE-ID ]\n");
@@ -566,6 +567,7 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 	struct nlmsg_list *l, *n;
 	char *filter_dev = NULL;
 	int no_link = 0;
+	unsigned maxrounds = MAX_ROUNDS;
 
 	ipaddr_reset_filter(oneline);
 	filter.showqueue = 1;
@@ -630,6 +632,10 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
 			filter.label = *argv;
+		} else if (strcmp(*argv, "maxrounds") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&maxrounds, *argv, 0))
+				invarg("maxrounds must be 0 (infinite) or higher", "maxrounds");
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
@@ -669,7 +675,7 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		filter.flushp = 0;
 		filter.flushe = sizeof(flushb);
 
-		while (round < MAX_ROUNDS) {
+		while (maxrounds == 0 || round < maxrounds) {
 			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
@@ -696,7 +702,10 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				fflush(stdout);
 			}
 		}
-		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", MAX_ROUNDS); fflush(stderr);
+		fprintf(stderr,
+			"*** Flush remains incomplete after %u rounds. ***\n",
+			maxrounds);
+		fflush(stderr);
 		return 1;
 	}
 
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index db684f5..61fac66 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -53,6 +53,7 @@ static void usage(void)
 		        "          [ nud { permanent | noarp | stale | reachable } ]\n"
 		        "          | proxy ADDR } [ dev DEV ]\n");
 	fprintf(stderr, "       ip neigh {show|flush} [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n");
+	fprintf(stderr, "                             [ maxrounds N ]\n");
 	exit(-1);
 }
 
@@ -321,6 +322,7 @@ int do_show_or_flush(int argc, char **argv, int flush)
 {
 	char *filter_dev = NULL;
 	int state_given = 0;
+	unsigned maxrounds = MAX_ROUNDS;
 
 	ipneigh_reset_filter();
 
@@ -361,6 +363,10 @@ int do_show_or_flush(int argc, char **argv, int flush)
 			if (state == 0)
 				state = 0x100;
 			filter.state |= state;
+		} else if (strcmp(*argv, "maxrounds") == 0) {
+			NEXT_ARG();
+			if (get_unsigned(&maxrounds, *argv, 0))
+				invarg("maxrounds must be 0 (infinite) or higher", "maxrounds");
 		} else {
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
@@ -392,7 +398,7 @@ int do_show_or_flush(int argc, char **argv, int flush)
 		filter.flushe = sizeof(flushb);
 		filter.state &= ~NUD_FAILED;
 
-		while (round < MAX_ROUNDS) {
+		while (maxrounds == 0 || round < maxrounds) {
 			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETNEIGH) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
@@ -418,8 +424,10 @@ int do_show_or_flush(int argc, char **argv, int flush)
 				fflush(stdout);
 			}
 		}
-		printf("*** Flush not complete bailing out after %d rounds\n",
-			MAX_ROUNDS);
+		fprintf(stderr,
+			"*** Flush remains incomplete after %u rounds. ***\n",
+			maxrounds);
+		fflush(stderr);
 		return 1;
 	}
 






-- 
Regards,
Andreas Henriksson

