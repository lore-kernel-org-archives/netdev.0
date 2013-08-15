From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 1/2] libceph: fix error handling in handle_reply()
Date: Thu, 15 Aug 2013 08:51:58 +0300
Message-ID: <20130815055158.GA23580@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sage Weil <sage@inktank.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We've tried to fix the error paths in this function before, but there
is still a hidden goto in the ceph_decode_need() macro which goes to the
wrong place.  We need to release the "req" and unlock a mutex before
returning.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index dbc0a73..559a832 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -1488,14 +1488,14 @@ static void handle_reply(struct ceph_osd_client *osdc, struct ceph_msg *msg,
 	dout("handle_reply %p tid %llu req %p result %d\n", msg, tid,
 	     req, result);
 
-	ceph_decode_need(&p, end, 4, bad);
+	ceph_decode_need(&p, end, 4, bad_put);
 	numops = ceph_decode_32(&p);
 	if (numops > CEPH_OSD_MAX_OP)
 		goto bad_put;
 	if (numops != req->r_num_ops)
 		goto bad_put;
 	payload_len = 0;
-	ceph_decode_need(&p, end, numops * sizeof(struct ceph_osd_op), bad);
+	ceph_decode_need(&p, end, numops * sizeof(struct ceph_osd_op), bad_put);
 	for (i = 0; i < numops; i++) {
 		struct ceph_osd_op *op = p;
 		int len;
@@ -1513,7 +1513,7 @@ static void handle_reply(struct ceph_osd_client *osdc, struct ceph_msg *msg,
 		goto bad_put;
 	}
 
-	ceph_decode_need(&p, end, 4 + numops * 4, bad);
+	ceph_decode_need(&p, end, 4 + numops * 4, bad_put);
 	retry_attempt = ceph_decode_32(&p);
 	for (i = 0; i < numops; i++)
 		req->r_reply_op_result[i] = ceph_decode_32(&p);
