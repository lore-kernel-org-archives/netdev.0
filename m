From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/5] net/9p: Improve 19 size determinations
Date: Tue, 15 Aug 2017 14:00:06 +0200
Message-ID: <f9eeedc4-5d3d-6622-79f0-11174ea81c49@users.sourceforge.net>
References: <22a44d7c-cdb9-e206-4b2c-56e38cbf0de1@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
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
Date: Tue, 15 Aug 2017 09:36:20 +0200

Replace the specification of data structures by variable references
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/9p/client.c       | 19 +++++++++----------
 net/9p/protocol.c     |  6 +++---
 net/9p/trans_fd.c     | 10 +++++-----
 net/9p/trans_rdma.c   |  2 +-
 net/9p/trans_virtio.c |  5 ++---
 net/9p/util.c         |  2 +-
 6 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 2273181e9ba9..2ca55d4b0b7d 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -272,8 +272,8 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
 		while (tag >= c->max_tag) {
 			row = (tag / P9_ROW_MAXTAG);
 			c->reqs[row] = kcalloc(P9_ROW_MAXTAG,
-					sizeof(struct p9_req_t), GFP_ATOMIC);
-
+					       sizeof(*c->reqs[row]),
+					       GFP_ATOMIC);
 			if (!c->reqs[row]) {
 				spin_unlock_irqrestore(&c->lock, flags);
 				return ERR_PTR(-ENOMEM);
@@ -907,7 +907,7 @@ static struct p9_fid *p9_fid_create(struct p9_client *clnt)
 	unsigned long flags;
 
 	p9_debug(P9_DEBUG_FID, "clnt %p\n", clnt);
-	fid = kmalloc(sizeof(struct p9_fid), GFP_KERNEL);
+	fid = kmalloc(sizeof(*fid), GFP_KERNEL);
 	if (!fid)
 		return ERR_PTR(-ENOMEM);
 
@@ -918,7 +918,7 @@ static struct p9_fid *p9_fid_create(struct p9_client *clnt)
 	}
 	fid->fid = ret;
 
-	memset(&fid->qid, 0, sizeof(struct p9_qid));
+	memset(&fid->qid, 0, sizeof(fid->qid));
 	fid->mode = -1;
 	fid->uid = current_fsuid();
 	fid->clnt = clnt;
@@ -1015,7 +1015,7 @@ struct p9_client *p9_client_create(const char *dev_name, char *options)
 	char *client_id;
 
 	err = 0;
-	clnt = kmalloc(sizeof(struct p9_client), GFP_KERNEL);
+	clnt = kmalloc(sizeof(*clnt), GFP_KERNEL);
 	if (!clnt)
 		return ERR_PTR(-ENOMEM);
 
@@ -1157,7 +1157,7 @@ struct p9_fid *p9_client_attach(struct p9_client *clnt, struct p9_fid *afid,
 	p9_debug(P9_DEBUG_9P, "<<< RATTACH qid %x.%llx.%x\n",
 		 qid.type, (unsigned long long)qid.path, qid.version);
 
-	memmove(&fid->qid, &qid, sizeof(struct p9_qid));
+	memmove(&fid->qid, &qid, sizeof(qid));
 
 	p9_free_req(clnt, req);
 	return fid;
@@ -1227,7 +1227,7 @@ struct p9_fid *p9_client_walk(struct p9_fid *oldfid, uint16_t nwname,
 			wqids[count].version);
 
 	if (nwname)
-		memmove(&fid->qid, &wqids[nwqids - 1], sizeof(struct p9_qid));
+		memmove(&fid->qid, &wqids[nwqids - 1], sizeof(fid->qid));
 	else
 		fid->qid = oldfid->qid;
 
@@ -1697,7 +1697,7 @@ struct p9_wstat *p9_client_stat(struct p9_fid *fid)
 {
 	int err;
 	struct p9_client *clnt;
-	struct p9_wstat *ret = kmalloc(sizeof(struct p9_wstat), GFP_KERNEL);
+	struct p9_wstat *ret = kmalloc(sizeof(*ret), GFP_KERNEL);
 	struct p9_req_t *req;
 	u16 ignored;
 
@@ -1749,8 +1749,7 @@ struct p9_stat_dotl *p9_client_getattr_dotl(struct p9_fid *fid,
 {
 	int err;
 	struct p9_client *clnt;
-	struct p9_stat_dotl *ret = kmalloc(sizeof(struct p9_stat_dotl),
-								GFP_KERNEL);
+	struct p9_stat_dotl *ret = kmalloc(sizeof(*ret), GFP_KERNEL);
 	struct p9_req_t *req;
 
 	p9_debug(P9_DEBUG_9P, ">>> TGETATTR fid %d, request_mask %lld\n",
diff --git a/net/9p/protocol.c b/net/9p/protocol.c
index 16e10680518c..b8dc30f7de07 100644
--- a/net/9p/protocol.c
+++ b/net/9p/protocol.c
@@ -200,7 +200,7 @@ p9pdu_vreadf(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				struct p9_wstat *stbuf =
 				    va_arg(ap, struct p9_wstat *);
 
-				memset(stbuf, 0, sizeof(struct p9_wstat));
+				memset(stbuf, 0, sizeof(*stbuf));
 				stbuf->n_uid = stbuf->n_muid = INVALID_UID;
 				stbuf->n_gid = INVALID_GID;
 
@@ -286,7 +286,7 @@ p9pdu_vreadf(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				if (!errcode) {
 					*wqids =
 					    kmalloc(*nwqid *
-						    sizeof(struct p9_qid),
+						    sizeof(**wqids),
 						    GFP_NOFS);
 					if (*wqids == NULL)
 						errcode = -ENOMEM;
@@ -316,7 +316,7 @@ p9pdu_vreadf(struct p9_fcall *pdu, int proto_version, const char *fmt,
 				struct p9_stat_dotl *stbuf =
 				    va_arg(ap, struct p9_stat_dotl *);
 
-				memset(stbuf, 0, sizeof(struct p9_stat_dotl));
+				memset(stbuf, 0, sizeof(*stbuf));
 				errcode =
 				    p9pdu_readf(pdu, proto_version,
 					"qQdugqqqqqqqqqqqqqqq",
diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index 3c272e5bc9ea..4a709146ae24 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -805,8 +805,8 @@ static int parse_opts(char *params, struct p9_fd_opts *opts)
 
 static int p9_fd_open(struct p9_client *client, int rfd, int wfd)
 {
-	struct p9_trans_fd *ts = kzalloc(sizeof(struct p9_trans_fd),
-					   GFP_KERNEL);
+	struct p9_trans_fd *ts = kzalloc(sizeof(*ts), GFP_KERNEL);
+
 	if (!ts)
 		return -ENOMEM;
 
@@ -832,7 +832,7 @@ static int p9_socket_open(struct p9_client *client, struct socket *csocket)
 	struct p9_trans_fd *p;
 	struct file *file;
 
-	p = kzalloc(sizeof(struct p9_trans_fd), GFP_KERNEL);
+	p = kzalloc(sizeof(*p), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
@@ -983,7 +983,7 @@ p9_fd_create_tcp(struct p9_client *client, const char *addr, char *args)
 
 	err = csocket->ops->connect(csocket,
 				    (struct sockaddr *)&sin_server,
-				    sizeof(struct sockaddr_in), 0);
+				    sizeof(sin_server), 0);
 	if (err < 0) {
 		pr_err("%s (%d): problem connecting socket to %s\n",
 		       __func__, task_pid_nr(current), addr);
@@ -1020,7 +1020,7 @@ p9_fd_create_unix(struct p9_client *client, const char *addr, char *args)
 		return err;
 	}
 	err = csocket->ops->connect(csocket, (struct sockaddr *)&sun_server,
-			sizeof(struct sockaddr_un) - 1, 0);
+				    sizeof(sun_server) - 1, 0);
 	if (err < 0) {
 		pr_err("%s (%d): problem connecting socket: %s: %d\n",
 		       __func__, task_pid_nr(current), addr, err);
diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index f98b6aae308b..6422a3775ff5 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -576,7 +576,7 @@ static struct p9_trans_rdma *alloc_rdma(struct p9_rdma_opts *opts)
 {
 	struct p9_trans_rdma *rdma;
 
-	rdma = kzalloc(sizeof(struct p9_trans_rdma), GFP_KERNEL);
+	rdma = kzalloc(sizeof(*rdma), GFP_KERNEL);
 	if (!rdma)
 		return NULL;
 
diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 8a2cf9748398..ac6ad9d344a6 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -359,8 +359,7 @@ static int p9_get_mapped_pages(struct virtio_chan *chan,
 
 		nr_pages = DIV_ROUND_UP((unsigned long)p + len, PAGE_SIZE) -
 			   (unsigned long)p / PAGE_SIZE;
-
-		*pages = kmalloc(sizeof(struct page *) * nr_pages, GFP_NOFS);
+		*pages = kmalloc(sizeof(**pages) * nr_pages, GFP_NOFS);
 		if (!*pages)
 			return -ENOMEM;
 
@@ -550,7 +549,7 @@ static int p9_virtio_probe(struct virtio_device *vdev)
 		return -EINVAL;
 	}
 
-	chan = kmalloc(sizeof(struct virtio_chan), GFP_KERNEL);
+	chan = kmalloc(sizeof(*chan), GFP_KERNEL);
 	if (!chan) {
 		err = -ENOMEM;
 		goto fail;
diff --git a/net/9p/util.c b/net/9p/util.c
index 59f278e64f58..2c53173bdf1c 100644
--- a/net/9p/util.c
+++ b/net/9p/util.c
@@ -54,7 +54,7 @@ struct p9_idpool *p9_idpool_create(void)
 {
 	struct p9_idpool *p;
 
-	p = kmalloc(sizeof(struct p9_idpool), GFP_KERNEL);
+	p = kmalloc(sizeof(*p), GFP_KERNEL);
 	if (!p)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.14.0
