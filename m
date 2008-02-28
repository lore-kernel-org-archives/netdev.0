From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 03/15] [SUNRPC]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:55:40 +0800
Message-ID: <47C6932C.90907@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52099 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbYB1K6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 05:58:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/sunrpc/cache.c |   14 ++++++--------
 net/sunrpc/stats.c |    3 +--
 2 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 636c8e0..b5f2786 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -316,31 +316,29 @@ static int create_cache_proc_entries(struct cache_detail *cd)
 	cd->proc_ent->owner = cd->owner;
 	cd->channel_ent = cd->content_ent = NULL;
 
-	p = create_proc_entry("flush", S_IFREG|S_IRUSR|S_IWUSR, cd->proc_ent);
+	p = proc_create("flush", S_IFREG|S_IRUSR|S_IWUSR,
+			cd->proc_ent, &cache_flush_operations);
 	cd->flush_ent = p;
 	if (p == NULL)
 		goto out_nomem;
-	p->proc_fops = &cache_flush_operations;
 	p->owner = cd->owner;
 	p->data = cd;
 
 	if (cd->cache_request || cd->cache_parse) {
-		p = create_proc_entry("channel", S_IFREG|S_IRUSR|S_IWUSR,
-				      cd->proc_ent);
+		p = proc_create("channel", S_IFREG|S_IRUSR|S_IWUSR,
+				cd->proc_ent, &cache_file_operations);
 		cd->channel_ent = p;
 		if (p == NULL)
 			goto out_nomem;
-		p->proc_fops = &cache_file_operations;
 		p->owner = cd->owner;
 		p->data = cd;
 	}
 	if (cd->cache_show) {
-		p = create_proc_entry("content", S_IFREG|S_IRUSR|S_IWUSR,
-				      cd->proc_ent);
+		p = proc_create("content", S_IFREG|S_IRUSR|S_IWUSR,
+				cd->proc_ent, &content_file_operations);
 		cd->content_ent = p;
 		if (p == NULL)
 			goto out_nomem;
-		p->proc_fops = &content_file_operations;
 		p->owner = cd->owner;
 		p->data = cd;
 	}
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 5a16875..c6061a4 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -229,9 +229,8 @@ do_register(const char *name, void *data, const struct file_operations *fops)
 	rpc_proc_init();
 	dprintk("RPC:       registering /proc/net/rpc/%s\n", name);
 
-	ent = create_proc_entry(name, 0, proc_net_rpc);
+	ent = proc_create(name, 0, proc_net_rpc, fops);
 	if (ent) {
-		ent->proc_fops = fops;
 		ent->data = data;
 	}
 	return ent;
-- 
WCN


