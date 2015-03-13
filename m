From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: [PATCH 2/2] net/9p: add a privport option for RDMA transport.
Date: Fri, 13 Mar 2015 19:04:40 +0100
Message-ID: <1426269880-23860-2-git-send-email-dominique.martinet@cea.fr>
References: <1426269880-23860-1-git-send-email-dominique.martinet@cea.fr>
Cc: Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Dominique Martinet <dominique.martinet@cea.fr>
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426269880-23860-1-git-send-email-dominique.martinet@cea.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RDMA can use the same kind of weak security as TCP by checking the
client can bind to a privileged port, which is better than nothing
if TAUTH isn't implemented.

Signed-off-by: Dominique Martinet <dominique.martinet@cea.fr>
---

YES, this does not checkpatch, but I'm not changing all the old
Opt_* names just to add a new one unless I'm explicitely asked to.

 net/9p/trans_rdma.c | 52 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 44 insertions(+), 8 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 14ad43b..3533d2a 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -139,6 +139,7 @@ struct p9_rdma_opts {
 	int sq_depth;
 	int rq_depth;
 	long timeout;
+	int privport;
 };
 
 /*
@@ -146,7 +147,10 @@ struct p9_rdma_opts {
  */
 enum {
 	/* Options that take integer arguments */
-	Opt_port, Opt_rq_depth, Opt_sq_depth, Opt_timeout, Opt_err,
+	Opt_port, Opt_rq_depth, Opt_sq_depth, Opt_timeout,
+	/* Options that take no argument */
+	Opt_privport,
+	Opt_err,
 };
 
 static match_table_t tokens = {
@@ -154,6 +158,7 @@ static match_table_t tokens = {
 	{Opt_sq_depth, "sq=%u"},
 	{Opt_rq_depth, "rq=%u"},
 	{Opt_timeout, "timeout=%u"},
+	{Opt_privport, "privport"},
 	{Opt_err, NULL},
 };
 
@@ -175,6 +180,7 @@ static int parse_opts(char *params, struct p9_rdma_opts *opts)
 	opts->sq_depth = P9_RDMA_SQ_DEPTH;
 	opts->rq_depth = P9_RDMA_RQ_DEPTH;
 	opts->timeout = P9_RDMA_TIMEOUT;
+	opts->privport = 0;
 
 	if (!params)
 		return 0;
@@ -193,13 +199,13 @@ static int parse_opts(char *params, struct p9_rdma_opts *opts)
 		if (!*p)
 			continue;
 		token = match_token(p, tokens, args);
-		if (token == Opt_err)
-			continue;
-		r = match_int(&args[0], &option);
-		if (r < 0) {
-			p9_debug(P9_DEBUG_ERROR,
-				 "integer field, but no integer?\n");
-			continue;
+		if ((token != Opt_err) && (token != Opt_privport)) {
+			r = match_int(&args[0], &option);
+			if (r < 0) {
+				p9_debug(P9_DEBUG_ERROR,
+					 "integer field, but no integer?\n");
+				continue;
+			}
 		}
 		switch (token) {
 		case Opt_port:
@@ -214,6 +220,9 @@ static int parse_opts(char *params, struct p9_rdma_opts *opts)
 		case Opt_timeout:
 			opts->timeout = option;
 			break;
+		case Opt_privport:
+			opts->privport = 1;
+			break;
 		default:
 			continue;
 		}
@@ -607,6 +616,23 @@ static int rdma_cancelled(struct p9_client *client, struct p9_req_t *req)
 	return 0;
 }
 
+static int p9_rdma_bind_privport(struct p9_trans_rdma *rdma)
+{
+	struct sockaddr_in cl = {
+		.sin_family = AF_INET,
+		.sin_addr.s_addr = htonl(INADDR_ANY),
+	};
+	int port, err = -EINVAL;
+
+	for (port = P9_DEF_MAX_RESVPORT; port >= P9_DEF_MIN_RESVPORT; port--) {
+		cl.sin_port = htons((ushort)port);
+		err = rdma_bind_addr(rdma->cm_id, (struct sockaddr *)&cl);
+		if (err != -EADDRINUSE)
+			break;
+	}
+	return err;
+}
+
 /**
  * trans_create_rdma - Transport method for creating atransport instance
  * @client: client instance
@@ -642,6 +668,16 @@ rdma_create_trans(struct p9_client *client, const char *addr, char *args)
 	/* Associate the client with the transport */
 	client->trans = rdma;
 
+	/* Bind to a privileged port if we need to */
+	if (opts.privport) {
+		err = p9_rdma_bind_privport(rdma);
+		if (err < 0) {
+			pr_err("%s (%d): problem binding to privport: %d\n",
+			       __func__, task_pid_nr(current), -err);
+			goto error;
+		}
+	}
+
 	/* Resolve the server's address */
 	rdma->addr.sin_family = AF_INET;
 	rdma->addr.sin_addr.s_addr = in_aton(addr);
-- 
1.9.3
