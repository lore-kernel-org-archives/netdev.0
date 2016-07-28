From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC v6 1/6] VSOCK: transport-specific vsock_transport functions
Date: Thu, 28 Jul 2016 15:36:30 +0100
Message-ID: <1469716595-13591-2-git-send-email-stefanha@redhat.com>
References: <1469716595-13591-1-git-send-email-stefanha@redhat.com>
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	=?UTF-8?q?Alex=20Benn=C3=A9e?= <alex.bennee@linaro.org>,
	marius vlad <marius.vlad0@gmail.com>, areis@redhat.com,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Ian Campbell <ian.campbell@docker.com>, ggarcia@abra.uab.cat,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>
To: kvm@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1469716595-13591-1-git-send-email-stefanha@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct vsock_transport contains function pointers called by AF_VSOCK
core code.  The transport may want its own transport-specific function
pointers and they can be added after struct vsock_transport.

Allow the transport to fetch vsock_transport.  It can downcast it to
access transport-specific function pointers.

The virtio transport will use this.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/net/af_vsock.h   | 3 +++
 net/vmw_vsock/af_vsock.c | 9 +++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index e9eb2d6..23f5525 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -165,6 +165,9 @@ static inline int vsock_core_init(const struct vsock_transport *t)
 }
 void vsock_core_exit(void);
 
+/* The transport may downcast this to access transport-specific functions */
+const struct vsock_transport *vsock_core_get_transport(void);
+
 /**** UTILS ****/
 
 void vsock_release_pending(struct sock *pending);
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index b96ac91..e34d96f 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1995,6 +1995,15 @@ void vsock_core_exit(void)
 }
 EXPORT_SYMBOL_GPL(vsock_core_exit);
 
+const struct vsock_transport *vsock_core_get_transport(void)
+{
+	/* vsock_register_mutex not taken since only the transport uses this
+	 * function and only while registered.
+	 */
+	return transport;
+}
+EXPORT_SYMBOL_GPL(vsock_core_get_transport);
+
 MODULE_AUTHOR("VMware, Inc.");
 MODULE_DESCRIPTION("VMware Virtual Socket Family");
 MODULE_VERSION("1.0.1.0-k");
-- 
2.7.4

