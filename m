From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: [PATCH] 9p: trans_fd, read rework to use p9_parse_header
Date: Thu,  3 Sep 2015 11:28:20 +0200
Message-ID: <1441272500-18782-1-git-send-email-dominique.martinet@cea.fr>
References: <55E78BBC.3050405@landley.net>
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dominique Martinet <dominique.martinet@cea.fr>
To: v9fs-developer@lists.sourceforge.net, Rob Landley <rob@landley.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E78BBC.3050405@landley.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most of the changes here are no-op and just renaming to use a
fcall struct, needed for p9_parse_header

It fixes the unaligned memory access to read the tag and defers to
common functions for part of the protocol knowledge (although header
length is still hard-coded...)

Reported-By: Rob Landley <rob@landley.net>
Signed-Off-By: Dominique Martinet <dominique.martinet@cea.fr>
---
 net/9p/trans_fd.c | 75 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 40 insertions(+), 35 deletions(-)

It ended up alot bigger than I thought it'd be, submitting it anyway
but happy with either version - letting Eric decide what's better :)

diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index bced8c0..a270dcc 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -108,9 +108,7 @@ struct p9_poll_wait {
  * @unsent_req_list: accounting for requests that haven't been sent
  * @req: current request being processed (if any)
  * @tmp_buf: temporary buffer to read in header
- * @rsize: amount to read for current frame
- * @rpos: read position in current frame
- * @rbuf: current read buffer
+ * @rc: temporary fcall for reading current frame
  * @wpos: write position for current frame
  * @wsize: amount of data to write for current frame
  * @wbuf: current write buffer
@@ -131,9 +129,7 @@ struct p9_conn {
 	struct list_head unsent_req_list;
 	struct p9_req_t *req;
 	char tmp_buf[7];
-	int rsize;
-	int rpos;
-	char *rbuf;
+	struct p9_fcall rc;
 	int wpos;
 	int wsize;
 	char *wbuf;
@@ -305,49 +301,56 @@ static void p9_read_work(struct work_struct *work)
 	if (m->err < 0)
 		return;
 
-	p9_debug(P9_DEBUG_TRANS, "start mux %p pos %d\n", m, m->rpos);
+	p9_debug(P9_DEBUG_TRANS, "start mux %p pos %zd\n", m, m->rc.offset);
 
-	if (!m->rbuf) {
-		m->rbuf = m->tmp_buf;
-		m->rpos = 0;
-		m->rsize = 7; /* start by reading header */
+	if (!m->rc.sdata) {
+		m->rc.sdata = m->tmp_buf;
+		m->rc.offset = 0;
+		m->rc.capacity = 7; /* start by reading header */
 	}
 
 	clear_bit(Rpending, &m->wsched);
-	p9_debug(P9_DEBUG_TRANS, "read mux %p pos %d size: %d = %d\n",
-		 m, m->rpos, m->rsize, m->rsize-m->rpos);
-	err = p9_fd_read(m->client, m->rbuf + m->rpos,
-						m->rsize - m->rpos);
+	p9_debug(P9_DEBUG_TRANS, "read mux %p pos %zd size: %zd = %zd\n",
+		 m, m->rc.offset, m->rc.capacity,
+		 m->rc.capacity - m->rc.offset);
+	err = p9_fd_read(m->client, m->rc.sdata + m->rc.offset,
+			 m->rc.capacity - m->rc.offset);
 	p9_debug(P9_DEBUG_TRANS, "mux %p got %d bytes\n", m, err);
-	if (err == -EAGAIN) {
+	if (err == -EAGAIN)
 		goto end_clear;
-	}
 
 	if (err <= 0)
 		goto error;
 
-	m->rpos += err;
+	m->rc.offset += err;
 
-	if ((!m->req) && (m->rpos == m->rsize)) { /* header read in */
-		u16 tag;
+	/* header read in */
+	if ((!m->req) && (m->rc.offset == m->rc.capacity)) {
 		p9_debug(P9_DEBUG_TRANS, "got new header\n");
 
-		n = le32_to_cpu(*(__le32 *) m->rbuf); /* read packet size */
-		if (n >= m->client->msize) {
+		err = p9_parse_header(&m->rc, NULL, NULL, NULL, 0);
+		if (err) {
 			p9_debug(P9_DEBUG_ERROR,
-				 "requested packet size too big: %d\n", n);
+				 "error parsing header: %d\n", err);
+			goto error;
+		}
+
+		if (m->rc.size >= m->client->msize) {
+			p9_debug(P9_DEBUG_ERROR,
+				 "requested packet size too big: %d\n",
+				 m->rc.size);
 			err = -EIO;
 			goto error;
 		}
 
-		tag = le16_to_cpu(*(__le16 *) (m->rbuf+5)); /* read tag */
 		p9_debug(P9_DEBUG_TRANS,
-			 "mux %p pkt: size: %d bytes tag: %d\n", m, n, tag);
+			 "mux %p pkt: size: %d bytes tag: %d\n",
+			 m, m->rc.size, m->rc.tag);
 
-		m->req = p9_tag_lookup(m->client, tag);
+		m->req = p9_tag_lookup(m->client, m->rc.tag);
 		if (!m->req || (m->req->status != REQ_STATUS_SENT)) {
 			p9_debug(P9_DEBUG_ERROR, "Unexpected packet tag %d\n",
-				 tag);
+				 m->rc.tag);
 			err = -EIO;
 			goto error;
 		}
@@ -361,13 +364,15 @@ static void p9_read_work(struct work_struct *work)
 				goto error;
 			}
 		}
-		m->rbuf = (char *)m->req->rc + sizeof(struct p9_fcall);
-		memcpy(m->rbuf, m->tmp_buf, m->rsize);
-		m->rsize = n;
+		m->rc.sdata = (char *)m->req->rc + sizeof(struct p9_fcall);
+		memcpy(m->rc.sdata, m->tmp_buf, m->rc.capacity);
+		m->rc.capacity = m->rc.size;
 	}
 
-	/* not an else because some packets (like clunk) have no payload */
-	if ((m->req) && (m->rpos == m->rsize)) { /* packet is read in */
+	/* packet is read in
+	 * not an else because some packets (like clunk) have no payload
+	 */
+	if ((m->req) && (m->rc.offset == m->rc.capacity)) {
 		p9_debug(P9_DEBUG_TRANS, "got new packet\n");
 		spin_lock(&m->client->lock);
 		if (m->req->status != REQ_STATUS_ERROR)
@@ -375,9 +380,9 @@ static void p9_read_work(struct work_struct *work)
 		list_del(&m->req->req_list);
 		spin_unlock(&m->client->lock);
 		p9_client_cb(m->client, m->req, status);
-		m->rbuf = NULL;
-		m->rpos = 0;
-		m->rsize = 0;
+		m->rc.sdata = NULL;
+		m->rc.offset = 0;
+		m->rc.capacity = 0;
 		m->req = NULL;
 	}
 
-- 
1.8.3.1
