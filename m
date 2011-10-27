From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v3 PATCH 2/4] net: model specific announcing
	support
Date: Thu, 27 Oct 2011 16:48:45 +0800
Message-ID: <20111027084845.15020.31881.stgit@dhcp-8-146.nay.redhat.com>
References: <20111027084700.15020.24087.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: aliguori@us.ibm.com, mst@redhat.com, jan.kiszka@siemens.com,
	rusty@rustcorp.com.au, qemu-devel@nongnu.org, blauwirbel@gmail.com,
	stefanha@gmail.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20111027084700.15020.24087.stgit@dhcp-8-146.nay.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

This patch introduces a function pointer in NetClientInfo which is
called during self announcement to do the model specific announcing.

The first user would be virtio-net.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net.h    |    2 ++
 savevm.c |    8 +++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net.h b/net.h
index 9f633f8..7654769 100644
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
index 73ee6e2..46389b2 100644
--- a/savevm.c
+++ b/savevm.c
@@ -122,10 +122,12 @@ static void qemu_announce_self_iter(NICState *nic, void *opaque)
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
 
 
