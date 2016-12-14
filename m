From: Gao feng <omarapazanadi@gmail.com>
Subject: [PATCH] vsock: lookup and setup guest_cid inside vhost_vsock_lock
Date: Wed, 14 Dec 2016 19:24:36 +0800
Message-ID: <1481714676-18555-1-git-send-email-omarapazanadi@gmail.com>
Cc: stefanha@redhat.com, mst@redhat.com,
        Gao feng <omarapazanadi@gmail.com>
To: kvm@vger.kernel.org, netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Multi vsocks may setup the same cid at the same time.

Signed-off-by: Gao feng <omarapazanadi@gmail.com>
---
 drivers/vhost/vsock.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index e3b30ea..a08332b 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -50,11 +50,10 @@ static u32 vhost_transport_get_local_cid(void)
 	return VHOST_VSOCK_DEFAULT_HOST_CID;
 }
 
-static struct vhost_vsock *vhost_vsock_get(u32 guest_cid)
+static struct vhost_vsock *__vhost_vsock_get(u32 guest_cid)
 {
 	struct vhost_vsock *vsock;
 
-	spin_lock_bh(&vhost_vsock_lock);
 	list_for_each_entry(vsock, &vhost_vsock_list, list) {
 		u32 other_cid = vsock->guest_cid;
 
@@ -63,15 +62,24 @@ static struct vhost_vsock *vhost_vsock_get(u32 guest_cid)
 			continue;
 
 		if (other_cid == guest_cid) {
-			spin_unlock_bh(&vhost_vsock_lock);
 			return vsock;
 		}
 	}
-	spin_unlock_bh(&vhost_vsock_lock);
 
 	return NULL;
 }
 
+static struct vhost_vsock *vhost_vsock_get(u32 guest_cid)
+{
+	struct vhost_vsock *vsock;
+
+	spin_lock_bh(&vhost_vsock_lock);
+	vsock = __vhost_vsock_get(guest_cid);
+	spin_unlock_bh(&vhost_vsock_lock);
+
+	return vsock;
+}
+
 static void
 vhost_transport_do_send_pkt(struct vhost_vsock *vsock,
 			    struct vhost_virtqueue *vq)
@@ -562,11 +570,12 @@ static int vhost_vsock_set_cid(struct vhost_vsock *vsock, u64 guest_cid)
 		return -EINVAL;
 
 	/* Refuse if CID is already in use */
-	other = vhost_vsock_get(guest_cid);
-	if (other && other != vsock)
-		return -EADDRINUSE;
-
 	spin_lock_bh(&vhost_vsock_lock);
+	other = __vhost_vsock_get(guest_cid);
+	if (other && other != vsock) {
+		spin_unlock_bh(&vhost_vsock_lock);
+		return -EADDRINUSE;
+	}
 	vsock->guest_cid = guest_cid;
 	spin_unlock_bh(&vhost_vsock_lock);
 
-- 
2.5.5

