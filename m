From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/8] gigaset: fix error return code
Date: Thu, 14 May 2009 00:44:17 +0200 (CEST)
Message-ID: <20090514-patch-03.tilman@imap.cc>
References: <20090514-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:38986 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760557AbZEMWoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:44:37 -0400
In-Reply-To: <20090514-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gigaset_register_to_LL() is expected to print a message and return 0
on failure. Make it do so consistently.

Impact: error handling bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/i4l.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 69a702f..9b22f9c 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -544,11 +544,11 @@ int gigaset_register_to_LL(struct cardstate *cs, const char *isdnid)
 
 	gig_dbg(DEBUG_ANY, "Register driver capabilities to LL");
 
-	//iif->id[sizeof(iif->id) - 1]=0;
-	//strncpy(iif->id, isdnid, sizeof(iif->id) - 1);
 	if (snprintf(iif->id, sizeof iif->id, "%s_%u", isdnid, cs->minor_index)
-	    >= sizeof iif->id)
-		return -ENOMEM; //FIXME EINVAL/...??
+	    >= sizeof iif->id) {
+		pr_err("ID too long: %s\n", isdnid);
+		return 0;
+	}
 
 	iif->owner = THIS_MODULE;
 	iif->channels = cs->channels;
@@ -568,8 +568,10 @@ int gigaset_register_to_LL(struct cardstate *cs, const char *isdnid)
 	iif->rcvcallb_skb = NULL;		/* Will be set by LL */
 	iif->statcallb = NULL;			/* Will be set by LL */
 
-	if (!register_isdn(iif))
+	if (!register_isdn(iif)) {
+		pr_err("register_isdn failed\n");
 		return 0;
+	}
 
 	cs->myid = iif->channels;		/* Set my device id */
 	return 1;
-- 
1.6.2.1.214.ge986c

