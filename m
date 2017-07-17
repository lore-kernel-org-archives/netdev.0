From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] libceph: potential NULL dereference in ceph_msg_data_create()
Date: Mon, 17 Jul 2017 11:13:35 +0300
Message-ID: <20170717081335.3hhaj2k2frpq7gfa@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Ilya Dryomov <idryomov@gmail.com>, Alex Elder <elder@inktank.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If kmem_cache_zalloc() returns NULL then the INIT_LIST_HEAD(&data->links);
will Oops.  The callers aren't really prepared for NULL returns so it
doesn't make a lot of difference in real life.

Fixes: 5240d9f95dfe ("libceph: replace message data pointer with list")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 0c31035bbfee..b7cc615d42ef 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -3203,8 +3203,10 @@ static struct ceph_msg_data *ceph_msg_data_create(enum ceph_msg_data_type type)
 		return NULL;
 
 	data = kmem_cache_zalloc(ceph_msg_data_cache, GFP_NOFS);
-	if (data)
-		data->type = type;
+	if (!data)
+		return NULL;
+
+	data->type = type;
 	INIT_LIST_HEAD(&data->links);
 
 	return data;
