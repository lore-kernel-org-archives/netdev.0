From: Tuomas Tynkkynen <tuomas@tuxera.com>
Subject: [PATCH 1/2] fs/9p: Compare qid.path in v9fs_test_inode
Date: Wed, 6 Sep 2017 17:59:07 +0300
Message-ID: <20170906145908.8082-2-tuomas@tuxera.com>
References: <20170906145908.8082-1-tuomas@tuxera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <v9fs-developer@lists.sourceforge.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S. Miller" <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>,
        Tuomas Tynkkynen <tuomas@tuxera.com>, <stable@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mpynet.fi ([82.197.21.84]:25008 "EHLO mx1.mpynet.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932714AbdIFPKe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 11:10:34 -0400
In-Reply-To: <20170906145908.8082-1-tuomas@tuxera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit fd2421f54423 ("fs/9p: When doing inode lookup compare qid details
and inode mode bits.") transformed v9fs_qid_iget() to use iget5_locked()
instead of iget_locked(). However, the test() callback is not checking
fid.path at all, which means that a lookup in the inode cache can now
accidentally locate a completely wrong inode from the same inode hash
bucket if the other fields (qid.type and qid.version) match.

Fixes: fd2421f54423 ("fs/9p: When doing inode lookup compare qid details and inode mode bits.")
Cc: stable@vger.kernel.org
Reviewed-by: Latchesar Ionkov <lucho@ionkov.net>
Signed-off-by: Tuomas Tynkkynen <tuomas@tuxera.com>
---
 fs/9p/vfs_inode.c      | 3 +++
 fs/9p/vfs_inode_dotl.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/fs/9p/vfs_inode.c b/fs/9p/vfs_inode.c
index 2a5de610dd8f..bdabb2765d1b 100644
--- a/fs/9p/vfs_inode.c
+++ b/fs/9p/vfs_inode.c
@@ -483,6 +483,9 @@ static int v9fs_test_inode(struct inode *inode, void *data)
 
 	if (v9inode->qid.type != st->qid.type)
 		return 0;
+
+	if (v9inode->qid.path != st->qid.path)
+		return 0;
 	return 1;
 }
 
diff --git a/fs/9p/vfs_inode_dotl.c b/fs/9p/vfs_inode_dotl.c
index 70f9887c59a9..7f6ae21a27b3 100644
--- a/fs/9p/vfs_inode_dotl.c
+++ b/fs/9p/vfs_inode_dotl.c
@@ -87,6 +87,9 @@ static int v9fs_test_inode_dotl(struct inode *inode, void *data)
 
 	if (v9inode->qid.type != st->qid.type)
 		return 0;
+
+	if (v9inode->qid.path != st->qid.path)
+		return 0;
 	return 1;
 }
 
-- 
2.13.0
