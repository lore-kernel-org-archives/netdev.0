From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2: git pull request from debian repo.
Date: Tue, 23 Oct 2007 15:56:01 +0200
Message-ID: <20071023135601.GA25097@scream.fatal.se>
References: <20071019122753.GA30078@scream.fatal.se> <20071019130616.GH1362@baikonur.stro.at> <20071019144815.GB30444@scream.fatal.se> <471B90E5.1040108@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maximilian attems <max@stro.at>, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:40182 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682AbXJWOAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 10:00:20 -0400
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


Something like the patch below should hopefully please everybody. Making
MAX_ROUNDS configurable is possibly even better (and 0=infinite), I'll see if
I can whip up an alternativ patch so you can decide which one you like better.

I've not added it to the patches branch yet, since Stephen said next release
will probably be a bugfix only release and I consider this a new feature.
(The previous patch simply makes ip addr flush behave the same as ip neigh
flush, and avoids an endless loop which I consider a staight bugfix.
Plus I don't want to do anything more with it until it's confirmed
I've set up the git repo correctly.)
I guess it's up to Stephen if he wants this feature and if he wants in now or
later... Please tell me.


Only compile-tested for now (this is on top of the previous patch):


diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index ff9e318..356535b 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -65,7 +65,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip addr {add|change|replace} IFADDR dev STRING [ LIFETIME ]\n");
 	fprintf(stderr, "                                                      [ CONFFLAG-LIST]\n");
 	fprintf(stderr, "       ip addr del IFADDR dev STRING\n");
-	fprintf(stderr, "       ip addr {show|flush} [ dev STRING ] [ scope SCOPE-ID ]\n");
+	fprintf(stderr, "       ip addr {show|flush|forceflush} [ dev STRING ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label PATTERN ]\n");
 	fprintf(stderr, "IFADDR := PREFIX | ADDR peer PREFIX\n");
 	fprintf(stderr, "          [ broadcast ADDR ] [ anycast ADDR ]\n");
@@ -559,7 +559,7 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	return 0;
 }
 
-int ipaddr_list_or_flush(int argc, char **argv, int flush)
+int ipaddr_list_or_flush(int argc, char **argv, int flush, int force)
 {
 	struct nlmsg_list *linfo = NULL;
 	struct nlmsg_list *ainfo = NULL;
@@ -669,7 +669,7 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		filter.flushp = 0;
 		filter.flushe = sizeof(flushb);
 
-		while (round < MAX_ROUNDS) {
+		while (force || (round < MAX_ROUNDS)) {
 			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
@@ -696,7 +696,8 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				fflush(stdout);
 			}
 		}
-		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", MAX_ROUNDS); fflush(stderr);
+		fprintf(stderr, "*** Flush remains incomplete, bailing out after %d rounds (use forceflush to never give up).\n", MAX_ROUNDS);
+		fflush(stderr);
 		return 1;
 	}
 
@@ -790,7 +791,7 @@ int ipaddr_list_link(int argc, char **argv)
 {
 	preferred_family = AF_PACKET;
 	do_link = 1;
-	return ipaddr_list_or_flush(argc, argv, 0);
+	return ipaddr_list_or_flush(argc, argv, 0, 0);
 }
 
 void ipaddr_reset_filter(int oneline)
@@ -1006,7 +1007,7 @@ int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 int do_ipaddr(int argc, char **argv)
 {
 	if (argc < 1)
-		return ipaddr_list_or_flush(0, NULL, 0);
+		return ipaddr_list_or_flush(0, NULL, 0, 0);
 	if (matches(*argv, "add") == 0)
 		return ipaddr_modify(RTM_NEWADDR, NLM_F_CREATE|NLM_F_EXCL, argc-1, argv+1);
 	if (matches(*argv, "change") == 0 ||
@@ -1018,9 +1019,11 @@ int do_ipaddr(int argc, char **argv)
 		return ipaddr_modify(RTM_DELADDR, 0, argc-1, argv+1);
 	if (matches(*argv, "list") == 0 || matches(*argv, "show") == 0
 	    || matches(*argv, "lst") == 0)
-		return ipaddr_list_or_flush(argc-1, argv+1, 0);
+		return ipaddr_list_or_flush(argc-1, argv+1, 0, 0);
 	if (matches(*argv, "flush") == 0)
-		return ipaddr_list_or_flush(argc-1, argv+1, 1);
+		return ipaddr_list_or_flush(argc-1, argv+1, 1, 0);
+	if (matches(*argv, "forceflush") == 0)
+		return ipaddr_list_or_flush(argc-1, argv+1, 1, 1);
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip address help\".\n", *argv);
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index db684f5..6a99377 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -52,7 +52,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip neigh { add | del | change | replace } { ADDR [ lladdr LLADDR ]\n"
 		        "          [ nud { permanent | noarp | stale | reachable } ]\n"
 		        "          | proxy ADDR } [ dev DEV ]\n");
-	fprintf(stderr, "       ip neigh {show|flush} [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n");
+	fprintf(stderr, "       ip neigh {show|flush|forceflush} [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n");
 	exit(-1);
 }
 
@@ -317,7 +317,7 @@ void ipneigh_reset_filter()
 	filter.state = ~0;
 }
 
-int do_show_or_flush(int argc, char **argv, int flush)
+int do_show_or_flush(int argc, char **argv, int flush, int force)
 {
 	char *filter_dev = NULL;
 	int state_given = 0;
@@ -392,7 +392,7 @@ int do_show_or_flush(int argc, char **argv, int flush)
 		filter.flushe = sizeof(flushb);
 		filter.state &= ~NUD_FAILED;
 
-		while (round < MAX_ROUNDS) {
+		while (force || (round < MAX_ROUNDS)) {
 			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETNEIGH) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
@@ -418,8 +418,9 @@ int do_show_or_flush(int argc, char **argv, int flush)
 				fflush(stdout);
 			}
 		}
-		printf("*** Flush not complete bailing out after %d rounds\n",
-			MAX_ROUNDS);
+		fprintf(stderr, "*** Flush remains incomplete, bailing out after %d rounds (use forceflush to never give up).\n", MAX_ROUNDS);
+		fflush(stderr);
+
 		return 1;
 	}
 
@@ -455,13 +456,15 @@ int do_ipneigh(int argc, char **argv)
 		if (matches(*argv, "show") == 0 ||
 		    matches(*argv, "lst") == 0 ||
 		    matches(*argv, "list") == 0)
-			return do_show_or_flush(argc-1, argv+1, 0);
+			return do_show_or_flush(argc-1, argv+1, 0, 0);
 		if (matches(*argv, "flush") == 0)
-			return do_show_or_flush(argc-1, argv+1, 1);
+			return do_show_or_flush(argc-1, argv+1, 1, 0);
+		if (matches(*argv, "forceflush") == 0)
+			return do_show_or_flush(argc-1, argv+1, 1, 1);
 		if (matches(*argv, "help") == 0)
 			usage();
 	} else
-		return do_show_or_flush(0, NULL, 0);
+		return do_show_or_flush(0, NULL, 0, 0);
 
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip neigh help\".\n", *argv);
 	exit(-1);


-- 
Regards,
Andreas Henriksson
