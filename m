From: Konstantin Khlebnikov <koct9i@gmail.com>
Subject: [PATCH] ip neigh: device is optional for proxy entries
Date: Tue, 01 Dec 2015 01:17:06 +0300
Message-ID: <144892182676.2301.1460574558873523132.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33438 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755056AbbK3WRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 17:17:12 -0500
Received: by lfaz4 with SMTP id z4so216581598lfa.0
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 14:17:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Though dumping such entries crashes present kernels.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 ip/ipneigh.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 54655842ed38..92b7cd6f2a75 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -100,8 +100,9 @@ static int ipneigh_modify(int cmd, int flags, int argc, char **argv)
 		struct ndmsg		ndm;
 		char  			buf[256];
 	} req;
-	char  *d = NULL;
+	char  *dev = NULL;
 	int dst_ok = 0;
+	int dev_ok = 0;
 	int lladdr_ok = 0;
 	char * lla = NULL;
 	inet_prefix dst;
@@ -135,10 +136,12 @@ static int ipneigh_modify(int cmd, int flags, int argc, char **argv)
 				duparg("address", *argv);
 			get_addr(&dst, *argv, preferred_family);
 			dst_ok = 1;
+			dev_ok = 1;
 			req.ndm.ndm_flags |= NTF_PROXY;
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			d = *argv;
+			dev = *argv;
+			dev_ok = 1;
 		} else {
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
@@ -153,7 +156,7 @@ static int ipneigh_modify(int cmd, int flags, int argc, char **argv)
 		}
 		argc--; argv++;
 	}
-	if (d == NULL || !dst_ok || dst.family == AF_UNSPEC) {
+	if (!dev_ok || !dst_ok || dst.family == AF_UNSPEC) {
 		fprintf(stderr, "Device and destination are required arguments.\n");
 		exit(-1);
 	}
@@ -175,8 +178,8 @@ static int ipneigh_modify(int cmd, int flags, int argc, char **argv)
 
 	ll_init_map(&rth);
 
-	if ((req.ndm.ndm_ifindex = ll_name_to_index(d)) == 0) {
-		fprintf(stderr, "Cannot find device \"%s\"\n", d);
+	if (dev && (req.ndm.ndm_ifindex = ll_name_to_index(dev)) == 0) {
+		fprintf(stderr, "Cannot find device \"%s\"\n", dev);
 		return -1;
 	}
 
