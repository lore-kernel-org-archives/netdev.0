From: Jeff Harris <jefftharris@gmail.com>
Subject: [PATCH iproute2] ip: neigh: Fix leftover attributes message during flush
Date: Thu, 14 Apr 2016 14:15:03 -0400
Message-ID: <1460657703-8222-1-git-send-email-jefftharris@gmail.com>
Cc: Jeff Harris <jefftharris@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34109 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbcDNSP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 14:15:28 -0400
Received: by mail-yw0-f193.google.com with SMTP id h6so11988197ywc.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 11:15:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the same rtnl_dump_request_n call as the show.  The rtnl_wilddump_request
assumes the type uses an ifinfomsg which is not the case for the neighbor
table.

Signed-off-by: Jeff Harris <jefftharris@gmail.com>
---
 ip/ipneigh.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index c49fb4e..4ddb747 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -430,6 +430,8 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 		addattr32(&req.n, sizeof(req), NDA_IFINDEX, filter.index);
 	}
 
+	req.ndm.ndm_family = filter.family;
+
 	if (flush) {
 		int round = 0;
 		char flushb[4096-512];
@@ -440,7 +442,7 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 		filter.state &= ~NUD_FAILED;
 
 		while (round < MAX_ROUNDS) {
-			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETNEIGH) < 0) {
+			if (rtnl_dump_request_n(&rth, &req.n) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
 			}
@@ -472,8 +474,6 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 		return 1;
 	}
 
-	req.ndm.ndm_family = filter.family;
-
 	if (rtnl_dump_request_n(&rth, &req.n) < 0) {
 		perror("Cannot send dump request");
 		exit(1);
-- 
1.7.9.5
