From: Reilly Grant <grantr@vmware.com>
Subject: [PATCH v2] VSOCK: Support VM sockets connected to the hypervisor.
Date: Thu, 14 Mar 2013 14:55:41 -0700
Message-ID: <1363298141-25394-1-git-send-email-grantr@vmware.com>
References: <1363117219-21911-1-git-send-email-grantr@vmware.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, Reilly Grant <grantr@vmware.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363117219-21911-1-git-send-email-grantr@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The resource ID used for VM socket control packets (0) is already
used for the VMCI_GET_CONTEXT_ID hypercall so a new ID (15) must be
used when the guest sends these datagrams to the hypervisor.

The hypervisor context ID must also be removed from the internal
blacklist.

Signed-off-by: Reilly Grant <grantr@vmware.com>
Acked-by: Andy King <acking@vmware.com>
---

I am an idiot and didn't commit the fix for two typos before generating
this patch. Please accept this corrected version.

 net/vmw_vsock/vmci_transport.c | 16 +++++++++++++---
 net/vmw_vsock/vmci_transport.h |  3 +++
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index a70ace8..faf81b8 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -123,6 +123,14 @@ static s32 vmci_transport_error_to_vsock_error(s32 vmci_error)
 	return err > 0 ? -err : err;
 }
 
+static u32 vmci_transport_peer_rid(u32 peer_cid)
+{
+	if (VMADDR_CID_HYPERVISOR == peer_cid)
+		return VMCI_TRANSPORT_HYPERVISOR_PACKET_RID;
+
+	return VMCI_TRANSPORT_PACKET_RID;
+}
+
 static inline void
 vmci_transport_packet_init(struct vmci_transport_packet *pkt,
 			   struct sockaddr_vm *src,
@@ -140,7 +148,7 @@ vmci_transport_packet_init(struct vmci_transport_packet *pkt,
 	pkt->dg.src = vmci_make_handle(VMADDR_CID_ANY,
 				       VMCI_TRANSPORT_PACKET_RID);
 	pkt->dg.dst = vmci_make_handle(dst->svm_cid,
-				       VMCI_TRANSPORT_PACKET_RID);
+				       vmci_transport_peer_rid(dst->svm_cid));
 	pkt->dg.payload_size = sizeof(*pkt) - sizeof(pkt->dg);
 	pkt->version = VMCI_TRANSPORT_PACKET_VERSION;
 	pkt->type = type;
@@ -511,6 +519,9 @@ static bool vmci_transport_is_trusted(struct vsock_sock *vsock, u32 peer_cid)
 
 static bool vmci_transport_allow_dgram(struct vsock_sock *vsock, u32 peer_cid)
 {
+	if (VMADDR_CID_HYPERVISOR == peer_cid)
+		return true;
+
 	if (vsock->cached_peer != peer_cid) {
 		vsock->cached_peer = peer_cid;
 		if (!vmci_transport_is_trusted(vsock, peer_cid) &&
@@ -631,7 +642,6 @@ static int vmci_transport_recv_dgram_cb(void *data, struct vmci_datagram *dg)
 static bool vmci_transport_stream_allow(u32 cid, u32 port)
 {
 	static const u32 non_socket_contexts[] = {
-		VMADDR_CID_HYPERVISOR,
 		VMADDR_CID_RESERVED,
 	};
 	int i;
@@ -670,7 +680,7 @@ static int vmci_transport_recv_stream_cb(void *data, struct vmci_datagram *dg)
 	 */
 
 	if (!vmci_transport_stream_allow(dg->src.context, -1)
-	    || VMCI_TRANSPORT_PACKET_RID != dg->src.resource)
+	    || vmci_transport_peer_rid(dg->src.context) != dg->src.resource)
 		return VMCI_ERROR_NO_ACCESS;
 
 	if (VMCI_DG_SIZE(dg) < sizeof(*pkt))
diff --git a/net/vmw_vsock/vmci_transport.h b/net/vmw_vsock/vmci_transport.h
index 1bf9918..fd88ea8 100644
--- a/net/vmw_vsock/vmci_transport.h
+++ b/net/vmw_vsock/vmci_transport.h
@@ -28,6 +28,9 @@
 /* The resource ID on which control packets are sent. */
 #define VMCI_TRANSPORT_PACKET_RID 1
 
+/* The resource ID on which control packets are sent to the hypervisor. */
+#define VMCI_TRANSPORT_HYPERVISOR_PACKET_RID 15
+
 #define VSOCK_PROTO_INVALID        0
 #define VSOCK_PROTO_PKT_ON_NOTIFY (1 << 0)
 #define VSOCK_PROTO_ALL_SUPPORTED (VSOCK_PROTO_PKT_ON_NOTIFY)
-- 
1.8.1.5
