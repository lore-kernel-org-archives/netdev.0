From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/5] net/9p: Adjust a jump target in p9_client_attach()
Date: Tue, 15 Aug 2017 14:02:15 +0200
Message-ID: <ace81690-0817-7271-13eb-e510c83d7daa@users.sourceforge.net>
References: <22a44d7c-cdb9-e206-4b2c-56e38cbf0de1@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Ron Minnich <rminnich@sandia.gov>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <22a44d7c-cdb9-e206-4b2c-56e38cbf0de1@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 15 Aug 2017 11:17:23 +0200

Adjust jump labels so that the function implementation becomes smaller.

Delete an extra variable assignment and a check (at the end of
this function).

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/9p/client.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 6c2fc796edfb..38c08171acc6 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -1133,25 +1133,23 @@ struct p9_fid *p9_client_attach(struct p9_client *clnt, struct p9_fid *afid,
 	p9_debug(P9_DEBUG_9P, ">>> TATTACH afid %d uname %s aname %s\n",
 		 afid ? afid->fid : -1, uname, aname);
 	fid = p9_fid_create(clnt);
-	if (IS_ERR(fid)) {
-		err = PTR_ERR(fid);
-		fid = NULL;
-		goto error;
-	}
+	if (IS_ERR(fid))
+		return fid;
+
 	fid->uid = n_uname;
 
 	req = p9_client_rpc(clnt, P9_TATTACH, "ddss?u", fid->fid,
 			afid ? afid->fid : P9_NOFID, uname, aname, n_uname);
 	if (IS_ERR(req)) {
 		err = PTR_ERR(req);
-		goto error;
+		goto destroy_fid;
 	}
 
 	err = p9pdu_readf(req->rc, clnt->proto_version, "Q", &qid);
 	if (err) {
 		trace_9p_protocol_dump(clnt, req->rc);
 		p9_free_req(clnt, req);
-		goto error;
+		goto destroy_fid;
 	}
 
 	p9_debug(P9_DEBUG_9P, "<<< RATTACH qid %x.%llx.%x\n",
@@ -1161,10 +1159,8 @@ struct p9_fid *p9_client_attach(struct p9_client *clnt, struct p9_fid *afid,
 
 	p9_free_req(clnt, req);
 	return fid;
-
-error:
-	if (fid)
-		p9_fid_destroy(fid);
+destroy_fid:
+	p9_fid_destroy(fid);
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL(p9_client_attach);
-- 
2.14.0
