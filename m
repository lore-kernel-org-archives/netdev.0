From: Abhishek Kulkarni <adkulkar@umail.iu.edu>
Subject: [PATCH] [net/9p] Possible regression in p9_client_stat
Date: Mon, 13 Jul 2009 07:49:50 -0600
Message-ID: <1247492991-26009-1-git-send-email-adkulkar@umail.iu.edu>
Cc: ericvh@gmail.com, Abhishek Kulkarni <adkulkar@umail.iu.edu>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755952AbZGMNuR@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a possible regression with p9_client_stat where it can try to kfree an ERR_PTR
after an erroneous p9pdu_readf. Also remove an unnecessary data buffer increment
in p9_client_read.

Signed-off-by: Abhishek Kulkarni <adkulkar@umail.iu.edu>
---
:100644 100644 dd43a82... cc25e63... M	net/9p/client.c
 net/9p/client.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index dd43a82..cc25e63 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -1098,7 +1098,6 @@ p9_client_read(struct p9_fid *fid, char *data, char __user *udata, u64 offset,
 
 	if (data) {
 		memmove(data, dataptr, count);
-		data += count;
 	}
 
 	if (udata) {
@@ -1192,9 +1191,9 @@ struct p9_wstat *p9_client_stat(struct p9_fid *fid)
 
 	err = p9pdu_readf(req->rc, clnt->dotu, "wS", &ignored, ret);
 	if (err) {
-		ret = ERR_PTR(err);
 		p9pdu_dump(1, req->rc);
-		goto free_and_error;
+		p9_free_req(clnt, req);
+		goto error;
 	}
 
 	P9_DPRINTK(P9_DEBUG_9P,
@@ -1211,8 +1210,6 @@ struct p9_wstat *p9_client_stat(struct p9_fid *fid)
 	p9_free_req(clnt, req);
 	return ret;
 
-free_and_error:
-	p9_free_req(clnt, req);
 error:
 	kfree(ret);
 	return ERR_PTR(err);
-- 
1.6.0.4
