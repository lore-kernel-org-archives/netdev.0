From: Patrick McHardy <kaber@trash.net>
Subject: Re: Request for help with iproute2 bugs.
Date: Mon, 23 Nov 2009 12:03:41 +0100
Message-ID: <4B0A6C0D.9030402@trash.net>
References: <20091123103742.GA14713@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020703090008060403000208"
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37401 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756841AbZKWLDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 06:03:36 -0500
In-Reply-To: <20091123103742.GA14713@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020703090008060403000208
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Andreas Henriksson wrote:
> http://bugs.debian.org/532727
>   iproute: "tc filter add ... protocol ip fw" broken?
> 

This one is caused by a regression in iproute2. The attached patch
should fix it.

--------------020703090008060403000208
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit b3d80773099c13f60598857901cb2724c210614f
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 23 12:00:46 2009 +0100

    f_fw: fix compat mode
    
    The kernel takes a lack of options as indication that the fw classifier
    should operate in compatibility mode, where marks are mapped directly to
    classids.
    
    Commit e22b42a (tc mask patch) broke this by adding an empty TCA_OPTIONS
    attribute even if no handle is specified. Restore the old behaviour.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/tc/f_fw.c b/tc/f_fw.c
index b511735..cc8ea2d 100644
--- a/tc/f_fw.c
+++ b/tc/f_fw.c
@@ -38,15 +38,13 @@ static int fw_parse_opt(struct filter_util *qu, char *handle, int argc, char **a
 	struct tc_police tp;
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
+	__u32 mask = 0;
+	int mask_set = 0;
 
 	memset(&tp, 0, sizeof(tp));
 
-	tail = NLMSG_TAIL(n);
-	addattr_l(n, 4096, TCA_OPTIONS, NULL, 0);
-
 	if (handle) {
 		char *slash;
-		__u32 mask = 0;
 		if ((slash = strchr(handle, '/')) != NULL)
 			*slash = '\0';
 		if (get_u32(&t->tcm_handle, handle, 0)) {
@@ -58,13 +56,19 @@ static int fw_parse_opt(struct filter_util *qu, char *handle, int argc, char **a
 				fprintf(stderr, "Illegal \"handle\" mask\n");
 				return -1;
 			}
-			addattr32(n, MAX_MSG, TCA_FW_MASK, mask);
+			mask_set = 1;
 		}
 	}
 
 	if (argc == 0)
 		return 0;
 
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 4096, TCA_OPTIONS, NULL, 0);
+
+	if (mask_set)
+		addattr32(n, MAX_MSG, TCA_FW_MASK, mask);
+
 	while (argc > 0) {
 		if (matches(*argv, "classid") == 0 ||
 		    matches(*argv, "flowid") == 0) {

--------------020703090008060403000208--
