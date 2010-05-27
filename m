From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Subject: [PATCH 3/3] vhost: fix the memory leak which will happen when
 memory_access_ok fails
Date: Thu, 27 May 2010 19:03:56 +0900
Message-ID: <20100527190356.cbf2aac7.yoshikawa.takuya@oss.ntt.co.jp>
References: <20100527185803.0c0213a1.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:48090 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757884Ab0E0KDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 06:03:33 -0400
In-Reply-To: <20100527185803.0c0213a1.yoshikawa.takuya@oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to free newmem when vhost_set_memory() fails to complete.

Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
---
 drivers/vhost/vhost.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 9633a3c..1241a22 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -337,8 +337,10 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 		return -EFAULT;
 	}
 
-	if (!memory_access_ok(d, newmem, vhost_has_feature(d, VHOST_F_LOG_ALL)))
+	if (!memory_access_ok(d, newmem, vhost_has_feature(d, VHOST_F_LOG_ALL))) {
+		kfree(newmem);
 		return -EFAULT;
+	}
 	oldmem = d->memory;
 	rcu_assign_pointer(d->memory, newmem);
 	synchronize_rcu();
-- 
1.7.0.4

