From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2: git pull request from debian repo.
Date: Tue, 23 Oct 2007 16:18:38 +0200
Message-ID: <20071023141838.GA25201@scream.fatal.se>
References: <20071019122753.GA30078@scream.fatal.se> <20071019130616.GH1362@baikonur.stro.at> <20071019144815.GB30444@scream.fatal.se> <471B90E5.1040108@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maximilian attems <max@stro.at>, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:50887 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbXJWOWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 10:22:52 -0400
Content-Disposition: inline
In-Reply-To: <471B90E5.1040108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 21, 2007 at 07:48:21PM +0200, Patrick McHardy wrote:
> Andreas Henriksson wrote:
> >-		for (;;) {
> >+		while (round < MAX_ROUNDS) {
> > 			if (rtnl_wilddump_request(&rth, filter.family, 
> > 			RTM_GETADDR) < 0) {
> > 				perror("Cannot send dump request");
> > 				exit(1);
> >@@ -694,6 +696,8 @@ int ipaddr_list_or_flush(int argc, char **argv, int 
> >flush)
> > 				fflush(stdout);
> > 			}
> > 		}
> >+		fprintf(stderr, "*** Flush remains incomplete after %d 
> >rounds. ***\n", MAX_ROUNDS); fflush(stderr);
> 
> 
> Again, please make this optional. People might want to make
> sure the cache is flushed even if it takes a bit longer.

And here's the alternativ with configurable max rounds (0=infinite)...


diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index ff9e318..e4ba340 100644
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
+	int maxrounds = MAX_ROUNDS;
 
 	ipaddr_reset_filter(oneline);
 	filter.showqueue = 1;
@@ -630,6 +632,9 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
 			filter.label = *argv;
+		} else if (strcmp(*argv, "maxrounds") == 0) {
+			NEXT_ARG();
+			maxrounds = atoi(*argv);
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
@@ -669,7 +674,7 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		filter.flushp = 0;
 		filter.flushe = sizeof(flushb);
 
-		while (round < MAX_ROUNDS) {
+		while ((maxrounds == 0) || (round < maxrounds)) {
 			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
@@ -696,7 +701,10 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				fflush(stdout);
 			}
 		}
-		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", MAX_ROUNDS); fflush(stderr);
+		fprintf(stderr,
+			"*** Flush remains incomplete after %d rounds. ***\n",
+			maxrounds);
+		fflush(stderr);
 		return 1;
 	}
 
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index db684f5..5a9ce40 100644
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
+	int maxrounds = MAX_ROUNDS;
 
 	ipneigh_reset_filter();
 
@@ -361,6 +363,9 @@ int do_show_or_flush(int argc, char **argv, int flush)
 			if (state == 0)
 				state = 0x100;
 			filter.state |= state;
+		} else if (strcmp(*argv, "maxrounds") == 0) {
+			NEXT_ARG();
+			maxrounds = atoi(*argv);
 		} else {
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
@@ -392,7 +397,7 @@ int do_show_or_flush(int argc, char **argv, int flush)
 		filter.flushe = sizeof(flushb);
 		filter.state &= ~NUD_FAILED;
 
-		while (round < MAX_ROUNDS) {
+		while ((maxrounds == 0) || (round < maxrounds)) {
 			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETNEIGH) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
@@ -418,8 +423,10 @@ int do_show_or_flush(int argc, char **argv, int flush)
 				fflush(stdout);
 			}
 		}
-		printf("*** Flush not complete bailing out after %d rounds\n",
-			MAX_ROUNDS);
+		fprintf(stderr,
+			"*** Flush remains incomplete after %d rounds. ***\n",
+			maxrounds);
+		fflush(stderr);
 		return 1;
 	}
 


-- 
Regards,
Andreas Henriksson
