From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v2 PATCH 3/4] net: model specific announcing support
Date: Sat, 22 Oct 2011 13:38:57 +0800
Message-ID: <20111022053857.21526.82999.stgit@dhcp-8-146.nay.redhat.com>
References: <20111022053540.21526.61249.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pbonzini@redhat.com, rusty@rustcorp.com.au, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: aliguori@us.ibm.com, quintela@redhat.com, jan.kiszka@siemens.com,
	mst@redhat.com, qemu-devel@nongnu.org, blauwirbel@gmail.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111022053540.21526.61249.stgit@dhcp-8-146.nay.redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduce a function pointer in NetClientInfo which is
called during self announcement to do the model specific announcement
such as sending gratuitous packet. Previous method is kept when model
specific announcing fails or without it.

The first user would be virtio-net.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net.h    |    2 ++
 savevm.c |    8 +++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net.h b/net.h
index 4943d4b..1845f01 100644
--- a/net.h
+++ b/net.h
@@ -46,6 +46,7 @@ typedef ssize_t (NetReceive)(VLANClientState *, const uint8_t *, size_t);
 typedef ssize_t (NetReceiveIOV)(VLANClientState *, const struct iovec *, int);
 typedef void (NetCleanup) (VLANClientState *);
 typedef void (LinkStatusChanged)(VLANClientState *);
+typedef int (NetAnnounce)(VLANClientState *);
 
 typedef struct NetClientInfo {
     net_client_type type;
@@ -57,6 +58,7 @@ typedef struct NetClientInfo {
     NetCleanup *cleanup;
     LinkStatusChanged *link_status_changed;
     NetPoll *poll;
+    NetAnnounce *announce;
 } NetClientInfo;
 
 struct VLANClientState {
diff --git a/savevm.c b/savevm.c
index 8293ee6..de6a01a 100644
--- a/savevm.c
+++ b/savevm.c
@@ -89,10 +89,12 @@ static void qemu_announce_self_iter(NICState *nic, void *opaque)
 {
     uint8_t buf[60];
     int len;
+    NetAnnounce *func = nic->nc.info->announce;
 
-    len = announce_self_create(buf, nic->conf->macaddr.a);
-
-    qemu_send_packet_raw(&nic->nc, buf, len);
+    if (func == NULL || func(&nic->nc) != 0) {
+        len = announce_self_create(buf, nic->conf->macaddr.a);
+        qemu_send_packet_raw(&nic->nc, buf, len);
+    }
 }
 
 

