From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC v4 1/5] VSOCK: transport-specific vsock_transport functions
Date: Tue, 22 Dec 2015 17:07:34 +0800
Message-ID: <1450775258-18287-2-git-send-email-stefanha@redhat.com>
References: <1450775258-18287-1-git-send-email-stefanha@redhat.com>
Cc: Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	matt.ma@linaro.org, virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>
To: kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932166AbbLVJHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 04:07:51 -0500
In-Reply-To: <1450775258-18287-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index 7fd1220..9783a38 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1994,6 +1994,15 @@ void vsock_core_exit(void)
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
2.5.0
