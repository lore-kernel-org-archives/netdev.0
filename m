From: Abhishek Kulkarni <adkulkar@umail.iu.edu>
Subject: [RESEND 2/2] net/9p: Insulate the client against an invalid error code sent by a 9p server.
Date: Wed, 29 Jul 2009 13:49:02 -0600
Message-ID: <1248896942-13027-2-git-send-email-adkulkar@umail.iu.edu>
References: <1248896942-13027-1-git-send-email-adkulkar@umail.iu.edu>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: v9fs-developer@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:15357 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362AbZG2Tyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 15:54:36 -0400
In-Reply-To: <1248896942-13027-1-git-send-email-adkulkar@umail.iu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A looney tunes server sending an invalid error code (which is !IS_ERR_VALUE)
can result in a client oops. So fix it by adding a check and converting unknown
or invalid error codes to -ESERVERFAULT.

Signed-off-by: Abhishek Kulkarni <adkulkar@umail.iu.edu>
---
:100644 100644 7bbd2d5... 5bf5f22... M	net/9p/client.c
:100644 100644 fdebe43... 5251851... M	net/9p/error.c
 net/9p/client.c |    7 +------
 net/9p/error.c  |    2 +-
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 7bbd2d5..5bf5f22 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -411,14 +411,9 @@ static int p9_check_errors(struct p9_client *c, struct p9_req_t *req)
 		if (c->dotu)
 			err = -ecode;
 
-		if (!err) {
+		if (!err || !IS_ERR_VALUE(err))
 			err = p9_errstr2errno(ename, strlen(ename));
 
-			/* string match failed */
-			if (!err)
-				err = -ESERVERFAULT;
-		}
-
 		P9_DPRINTK(P9_DEBUG_9P, "<<< RERROR (%d) %s\n", -ecode, ename);
 
 		kfree(ename);
diff --git a/net/9p/error.c b/net/9p/error.c
index fdebe43..5251851 100644
--- a/net/9p/error.c
+++ b/net/9p/error.c
@@ -239,7 +239,7 @@ int p9_errstr2errno(char *errstr, int len)
 		errstr[len] = 0;
 		printk(KERN_ERR "%s: server reported unknown error %s\n",
 			__func__, errstr);
-		errno = 1;
+		errno = ESERVERFAULT;
 	}
 
 	return -errno;
-- 
1.6.3.3

