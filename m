From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] SUNRPC/cache: add module_put() on error path in cache_open()
Date: Sat, 23 Mar 2013 00:36:44 +0400
Message-ID: <1363984604-17739-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If kmalloc() fails in cache_open(), module cd->owner left locked.
The patch adds module_put(cd->owner) on this path.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 net/sunrpc/cache.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 25d58e76..1d3c514 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -986,8 +986,10 @@ static int cache_open(struct inode *inode, struct file *filp,
 	nonseekable_open(inode, filp);
 	if (filp->f_mode & FMODE_READ) {
 		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
-		if (!rp)
+		if (!rp) {
+			module_put(cd->owner);
 			return -ENOMEM;
+		}
 		rp->offset = 0;
 		rp->q.reader = 1;
 		atomic_inc(&cd->readers);
-- 
1.7.9.5
