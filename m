From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] libceph: fix deadlock in ceph_build_auth()
Date: Mon, 29 Jul 2013 06:58:08 +0400
Message-ID: <1375066688-12367-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Sage Weil <sage@inktank.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ceph_build_auth() locks ac->mutex and then calls ceph_auth_build_hello()
that locks the same mutex, i.e. bring itself to deadlock.

The patch moves actual code from ceph_auth_build_hello() to
ceph_build_hello_auth_request() that should be called with ac->mutex held
and makes ceph_build_auth() calling it.
ceph_auth_build_hello() is left with untouched semantics as a wrapper
around ceph_build_hello_auth_request().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 net/ceph/auth.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/ceph/auth.c b/net/ceph/auth.c
index 6b923bc..59594a6 100644
--- a/net/ceph/auth.c
+++ b/net/ceph/auth.c
@@ -98,14 +98,14 @@ int ceph_entity_name_encode(const char *name, void **p, void *end)
  * Initiate protocol negotiation with monitor.  Include entity name
  * and list supported protocols.
  */
-int ceph_auth_build_hello(struct ceph_auth_client *ac, void *buf, size_t len)
+static int ceph_build_hello_auth_request(struct ceph_auth_client *ac,
+					 void *buf, size_t len)
 {
 	struct ceph_mon_request_header *monhdr = buf;
 	void *p = monhdr + 1, *end = buf + len, *lenp;
 	int i, num;
 	int ret;
 
-	mutex_lock(&ac->mutex);
 	dout("auth_build_hello\n");
 	monhdr->have_version = 0;
 	monhdr->session_mon = cpu_to_le16(-1);
@@ -133,7 +133,6 @@ int ceph_auth_build_hello(struct ceph_auth_client *ac, void *buf, size_t len)
 	ceph_encode_32(&lenp, p - lenp - sizeof(u32));
 	ret = p - buf;
 out:
-	mutex_unlock(&ac->mutex);
 	return ret;
 
 bad:
@@ -141,6 +140,16 @@ bad:
 	goto out;
 }
 
+int ceph_auth_build_hello(struct ceph_auth_client *ac, void *buf, size_t len)
+{
+	int ret;
+
+	mutex_lock(&ac->mutex);
+	ret = ceph_build_hello_auth_request(ac, buf, len);
+	mutex_unlock(&ac->mutex);
+	return ret;
+}
+
 static int ceph_build_auth_request(struct ceph_auth_client *ac,
 				   void *msg_buf, size_t msg_len)
 {
@@ -260,7 +269,7 @@ int ceph_build_auth(struct ceph_auth_client *ac,
 
 	mutex_lock(&ac->mutex);
 	if (!ac->protocol)
-		ret = ceph_auth_build_hello(ac, msg_buf, msg_len);
+		ret = ceph_build_hello_auth_request(ac, msg_buf, msg_len);
 	else if (ac->ops->should_authenticate(ac))
 		ret = ceph_build_auth_request(ac, msg_buf, msg_len);
 	mutex_unlock(&ac->mutex);
-- 
1.8.1.2
