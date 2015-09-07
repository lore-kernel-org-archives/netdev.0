From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: [PATCH v2] 9p: trans_fd, bail out if recv fcall if missing
Date: Mon,  7 Sep 2015 17:06:54 +0200
Message-ID: <1441638414-25798-1-git-send-email-dominique.martinet@cea.fr>
References: <CAFkjPT=1TAq5S_TBgKa_UyGs2CfhDKOWEqc9HyhKHw89vO_ZOQ@mail.gmail.com>
Cc: Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dominique Martinet <dominique.martinet@cea.fr>
To: v9fs-developer@lists.sourceforge.net,
	Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFkjPT=1TAq5S_TBgKa_UyGs2CfhDKOWEqc9HyhKHw89vO_ZOQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

req->rc is pre-allocated early on with p9_tag_alloc and shouldn't be missing

Signed-off-by: Dominique Martinet <dominique.martinet@cea.fr>
---
 net/9p/trans_fd.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

Feel free to adapt error code/message if you can think of something better.

diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index a270dcc..a6d89c0 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -356,13 +356,12 @@ static void p9_read_work(struct work_struct *work)
 		}
 
 		if (m->req->rc == NULL) {
-			m->req->rc = kmalloc(sizeof(struct p9_fcall) +
-						m->client->msize, GFP_NOFS);
-			if (!m->req->rc) {
-				m->req = NULL;
-				err = -ENOMEM;
-				goto error;
-			}
+			p9_debug(P9_DEBUG_ERROR,
+				 "No recv fcall for tag %d (req %p), disconnecting!\n",
+				 m->rc.tag, m->req);
+			m->req = NULL;
+			err = -EIO;
+			goto error;
 		}
 		m->rc.sdata = (char *)m->req->rc + sizeof(struct p9_fcall);
 		memcpy(m->rc.sdata, m->tmp_buf, m->rc.capacity);
-- 
1.8.3.1
