From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: [PATCH] 9p: trans_fd, initialize recv fcall properly if not set
Date: Thu,  3 Sep 2015 11:38:49 +0200
Message-ID: <1441273129-20185-1-git-send-email-dominique.martinet@cea.fr>
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dominique Martinet <dominique.martinet@cea.fr>
To: v9fs-developer@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nautica.notk.org ([91.121.71.147]:40050 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752877AbbICJiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2015 05:38:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That code really should never be called (rc is allocated in
tag_alloc), but if it had been it couldn't have worked...

Signed-off-by: Dominique Martinet <dominique.martinet@cea.fr>
---
 net/9p/trans_fd.c | 3 +++
 1 file changed, 3 insertions(+)

To be honest, I think it might be better to just bail out if we get in
this switch (m->req->rc == NULL after p9_tag_lookup) and not try to
allocate more, because if we get there it's likely a race condition and
silently re-allocating will end up in more troubles than trying to
recover is worth.
Thoughts ?

diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index a270dcc..0d9831a 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -363,6 +363,9 @@ static void p9_read_work(struct work_struct *work)
 				err = -ENOMEM;
 				goto error;
 			}
+			m->req->rc.capacity = m->client->msize;
+			m->req->rc.sdata = (char*)m->req->rc +
+						sizeof(struct p9_fcall);
 		}
 		m->rc.sdata = (char *)m->req->rc + sizeof(struct p9_fcall);
 		memcpy(m->rc.sdata, m->tmp_buf, m->rc.capacity);
-- 
1.8.3.1
