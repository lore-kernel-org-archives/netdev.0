From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 06/14] libceph: use list_for_each_entry_safe
Date: Fri, 18 Dec 2015 23:33:30 +0800
Message-ID: <40510e6829654a5a4726650c63bf00d88c037593.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>,
	Sage Weil <sage@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry_safe() instead of list_for_each_safe() to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/ceph/messenger.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 9981039..c664b7f 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -3361,9 +3361,8 @@ static void ceph_msg_free(struct ceph_msg *m)
 static void ceph_msg_release(struct kref *kref)
 {
 	struct ceph_msg *m = container_of(kref, struct ceph_msg, kref);
-	LIST_HEAD(data);
-	struct list_head *links;
-	struct list_head *next;
+	LIST_HEAD(head);
+	struct ceph_msg_data *data, *next;
 
 	dout("%s %p\n", __func__, m);
 	WARN_ON(!list_empty(&m->list_head));
@@ -3376,12 +3375,9 @@ static void ceph_msg_release(struct kref *kref)
 		m->middle = NULL;
 	}
 
-	list_splice_init(&m->data, &data);
-	list_for_each_safe(links, next, &data) {
-		struct ceph_msg_data *data;
-
-		data = list_entry(links, struct ceph_msg_data, links);
-		list_del_init(links);
+	list_splice_init(&m->data, &head);
+	list_for_each_entry_safe(data, next, &head, links) {
+		list_del_init(&data->links);
 		ceph_msg_data_destroy(data);
 	}
 	m->data_length = 0;
-- 
2.5.0
