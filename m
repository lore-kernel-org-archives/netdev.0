From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] 9p: client code cleanup
Date: Tue, 19 Oct 2010 09:48:16 -0700
Message-ID: <20101019094816.7898beff@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39296 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754595Ab0JSQsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 12:48:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make p9_client_version static since only used in one file.
Remove p9_client_auth because it is defined but never used.
Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/9p/client.h |    3 ---
 net/9p/client.c         |    6 ++----
 2 files changed, 2 insertions(+), 7 deletions(-)

--- a/include/net/9p/client.h	2010-10-19 09:23:32.679670429 -0700
+++ b/include/net/9p/client.h	2010-10-19 09:23:34.483850813 -0700
@@ -212,15 +212,12 @@ struct p9_dirent {
 
 int p9_client_statfs(struct p9_fid *fid, struct p9_rstatfs *sb);
 int p9_client_rename(struct p9_fid *fid, struct p9_fid *newdirfid, char *name);
-int p9_client_version(struct p9_client *);
 struct p9_client *p9_client_create(const char *dev_name, char *options);
 void p9_client_destroy(struct p9_client *clnt);
 void p9_client_disconnect(struct p9_client *clnt);
 void p9_client_begin_disconnect(struct p9_client *clnt);
 struct p9_fid *p9_client_attach(struct p9_client *clnt, struct p9_fid *afid,
 					char *uname, u32 n_uname, char *aname);
-struct p9_fid *p9_client_auth(struct p9_client *clnt, char *uname,
-						u32 n_uname, char *aname);
 struct p9_fid *p9_client_walk(struct p9_fid *oldfid, int nwname, char **wnames,
 								int clone);
 int p9_client_open(struct p9_fid *fid, int mode);
--- a/net/9p/client.c	2010-10-19 09:23:32.715674029 -0700
+++ b/net/9p/client.c	2010-10-19 09:24:16.184019417 -0700
@@ -671,7 +671,7 @@ static void p9_fid_destroy(struct p9_fid
 	kfree(fid);
 }
 
-int p9_client_version(struct p9_client *c)
+static int p9_client_version(struct p9_client *c)
 {
 	int err = 0;
 	struct p9_req_t *req;
@@ -730,7 +730,6 @@ error:
 
 	return err;
 }
-EXPORT_SYMBOL(p9_client_version);
 
 struct p9_client *p9_client_create(const char *dev_name, char *options)
 {
@@ -887,54 +886,6 @@ error:
 }
 EXPORT_SYMBOL(p9_client_attach);
 
-struct p9_fid *
-p9_client_auth(struct p9_client *clnt, char *uname, u32 n_uname, char *aname)
-{
-	int err;
-	struct p9_req_t *req;
-	struct p9_qid qid;
-	struct p9_fid *afid;
-
-	P9_DPRINTK(P9_DEBUG_9P, ">>> TAUTH uname %s aname %s\n", uname, aname);
-	err = 0;
-
-	afid = p9_fid_create(clnt);
-	if (IS_ERR(afid)) {
-		err = PTR_ERR(afid);
-		afid = NULL;
-		goto error;
-	}
-
-	req = p9_client_rpc(clnt, P9_TAUTH, "dss?d",
-			afid ? afid->fid : P9_NOFID, uname, aname, n_uname);
-	if (IS_ERR(req)) {
-		err = PTR_ERR(req);
-		goto error;
-	}
-
-	err = p9pdu_readf(req->rc, clnt->proto_version, "Q", &qid);
-	if (err) {
-		p9pdu_dump(1, req->rc);
-		p9_free_req(clnt, req);
-		goto error;
-	}
-
-	P9_DPRINTK(P9_DEBUG_9P, "<<< RAUTH qid %x.%llx.%x\n",
-					qid.type,
-					(unsigned long long)qid.path,
-					qid.version);
-
-	memmove(&afid->qid, &qid, sizeof(struct p9_qid));
-	p9_free_req(clnt, req);
-	return afid;
-
-error:
-	if (afid)
-		p9_fid_destroy(afid);
-	return ERR_PTR(err);
-}
-EXPORT_SYMBOL(p9_client_auth);
-
 struct p9_fid *p9_client_walk(struct p9_fid *oldfid, int nwname, char **wnames,
 	int clone)
 {
