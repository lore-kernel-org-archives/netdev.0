From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 2/2] iproute2: Fix memory hog of ip batched command.
Date: Tue, 22 May 2012 15:37:29 -0700
Message-ID: <1337726249-9958-1-git-send-email-pshelar@nicira.com>
Cc: jpettit@nicira.com, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: shemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:40613 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753198Ab2EVWhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 18:37:37 -0400
Received: by mail-pb0-f45.google.com with SMTP id ro12so10965436pbb.18
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 15:37:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipaddr_list_or_flush() builds list of all device at start of
every flush or list operation, but does not free memory at end.
This can hog lot of memory for large batched command.
Following patch fixes it.

Reported-by: Justin Pettit <jpettit@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 ip/ipaddress.c |   27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 7080c41..09444e6 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -775,6 +775,8 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 	struct nlmsg_list *l, *n;
 	char *filter_dev = NULL;
 	int no_link = 0;
+	int rc = 0;
+	int print_info = 0;
 
 	ipaddr_reset_filter(oneline);
 	filter.showqueue = 1;
@@ -877,7 +879,8 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		filter.ifindex = ll_name_to_index(filter_dev);
 		if (filter.ifindex <= 0) {
 			fprintf(stderr, "Device \"%s\" does not exist.\n", filter_dev);
-			return -1;
+			rc = -1;
+			goto out;
 		}
 	}
 
@@ -922,11 +925,14 @@ flush_done:
 						printf("*** Flush is complete after %d round%s ***\n", round, round>1?"s":"");
 				}
 				fflush(stdout);
-				return 0;
+				rc = 0;
+				goto out;
 			}
 			round++;
-			if (flush_update() < 0)
-				return 1;
+			if (flush_update() < 0) {
+				rc = 1;
+				goto out;
+			}
 
 			if (show_stats) {
 				printf("\n*** Round %d, deleting %d addresses ***\n", round, filter.flushed);
@@ -943,7 +949,8 @@ flush_done:
 		}
 		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", max_flush_loops);
 		fflush(stderr);
-		return 1;
+		rc = 1;
+		goto out;
 	}
 
 	if (filter.family != AF_PACKET) {
@@ -1017,19 +1024,21 @@ flush_done:
 				lp = &l->next;
 		}
 	}
-
+	print_info = 1;
+out:
 	for (l=linfo; l; l = n) {
 		n = l->next;
-		if (no_link || print_linkinfo(NULL, &l->h, stdout) == 0) {
+		if (print_info &&
+		    (no_link || print_linkinfo(NULL, &l->h, stdout) == 0)) {
 			struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
 			if (filter.family != AF_PACKET)
 				print_selected_addrinfo(ifi->ifi_index, ainfo, stdout);
+			fflush(stdout);
 		}
-		fflush(stdout);
 		free(l);
 	}
 
-	return 0;
+	return rc;
 }
 
 int ipaddr_list_link(int argc, char **argv)
-- 
1.7.10
