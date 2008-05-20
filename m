From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/4] proc: proc_get_inode should get module only once
Date: Tue, 20 May 2008 13:59:46 +0400
Message-ID: <1211277589-8565-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:15798 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765634AbYETKAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 06:00:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any file under /proc/net opened more than once leaked the refcounter
on the module it belongs to.

The problem is that module_get is called for each file opening while
module_put is called only when /proc inode is destroyed. So, lets put
module counter if we are dealing with already initialised inode.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Cc: David Miller <davem@davemloft.net>
Cc: Patrick McHardy <kaber@trash.net>
Acked-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Robert Olsson <robert.olsson@its.uu.se>
Acked-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/inode.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 6f4e8dc..b08d100 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -425,7 +425,8 @@ struct inode *proc_get_inode(struct super_block *sb, unsigned int ino,
 			}
 		}
 		unlock_new_inode(inode);
-	}
+	} else
+	       module_put(de->owner);
 	return inode;
 
 out_ino:
-- 
1.5.3.rc5

