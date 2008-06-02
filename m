From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH] Display Correct Error For Addrlabel Info
Date: Mon, 2 Jun 2008 13:55:56 +0530
Message-ID: <20080602135556.0f4bc82a.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([59.145.155.5]:33113 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbYFBI0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 04:26:10 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m528PsbR021203
	for <netdev@vger.kernel.org>; Mon, 2 Jun 2008 13:55:55 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m528PS9f819450
	for <netdev@vger.kernel.org>; Mon, 2 Jun 2008 13:55:28 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m528PsbP022398
	for <netdev@vger.kernel.org>; Mon, 2 Jun 2008 13:55:54 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

The command "ip addrlabel add/del" displays incorrect error message when provided with insufficient inputs. This patch fixes it in par with "ip addr add/del".

Currently:
# ./ip addrlabel add
RTNETLINK answers: Numerical result out of range

# ./ip addr add
Not enough information: "dev" argument is required.

After patch:
# ./ip addrlabel add
Not enough information: "prefix" argument is required.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 ip/ipaddrlabel.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index a4cdece..cf438d6 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -139,6 +139,8 @@ static int ipaddrlabel_modify(int cmd, int argc, char **argv)
 
 	inet_prefix prefix;
 	uint32_t label = 0xffffffffUL;
+	char *p = NULL;
+	char *l = NULL;        
 
 	memset(&req, 0, sizeof(req));
 	memset(&prefix, 0, sizeof(prefix));
@@ -157,6 +159,7 @@ static int ipaddrlabel_modify(int cmd, int argc, char **argv)
 	while (argc > 0) {
 		if (strcmp(*argv, "prefix") == 0) {
 			NEXT_ARG();
+			p = *argv;
 			get_prefix(&prefix, *argv, preferred_family);
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
@@ -164,13 +167,21 @@ static int ipaddrlabel_modify(int cmd, int argc, char **argv)
 				invarg("dev is invalid\n", *argv);
 		} else if (strcmp(*argv, "label") == 0) {
 			NEXT_ARG();
+			l = *argv;
 			if (get_u32(&label, *argv, 0) || label == 0xffffffffUL)
 				invarg("label is invalid\n", *argv);
 		}
 		argc--;
 		argv++;
 	}
-
+	if (p == NULL) {
+		fprintf(stderr, "Not enough information: \"prefix\" argument is required.\n");
+		return -1;
+	}
+	if (l == NULL) {
+		fprintf(stderr, "Not enough information: \"label\" argument is required.\n");
+		return -1;
+	}
 	addattr32(&req.n, sizeof(req), IFAL_LABEL, label);
 	addattr_l(&req.n, sizeof(req), IFAL_ADDRESS, &prefix.data, prefix.bytelen);
 	req.ifal.ifal_prefixlen = prefix.bitlen;
-- 
1.5.0.6

