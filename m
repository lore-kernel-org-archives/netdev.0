From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH] sunrpc/cache: fix module refcnt leak in a failure path
Date: Tue, 02 Feb 2010 14:48:09 +0800
Message-ID: <4B67CAA9.4070108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: NeilBrown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't forget to release the module refcnt if seq_open()
returns failure.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/sunrpc/cache.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 39bddba..b7af6b2 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1233,8 +1233,10 @@ static int content_open(struct inode *inode, struct file *file,
 	if (!cd || !try_module_get(cd->owner))
 		return -EACCES;
 	han = __seq_open_private(file, &cache_content_op, sizeof(*han));
-	if (han == NULL)
+	if (han == NULL) {
+		module_put(cd->owner);
 		return -ENOMEM;
+	}
 
 	han->cd = cd;
 	return 0;
-- 
1.6.3
