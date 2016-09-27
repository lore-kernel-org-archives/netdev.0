From: Jorgen Hansen <jhansen@vmware.com>
Subject: [PATCH] VSOCK: Don't dec ack backlog twice for rejected connections
Date: Mon, 26 Sep 2016 23:59:53 -0700
Message-ID: <1474959593-15311-1-git-send-email-jhansen@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gregkh@linuxfoundation.org>, <davem@davemloft.net>,
        <pv-drivers@vmware.com>, <stefanha@redhat.com>,
        Jorgen Hansen <jhansen@vmware.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <virtualization@lists.linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-001.vmware.com ([208.91.0.189]:37511 "EHLO
        EX13-EDG-OU-001.vmware.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752303AbcI0G7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 02:59:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a pending socket is marked as rejected, we will decrease the
sk_ack_backlog twice. So don't decrement it for rejected sockets
in vsock_pending_work().

Testing of the rejected socket path was done through code
modifications.

Reported-by: Stefan Hajnoczi <stefanha@redhat.com>
Signed-off-by: Jorgen Hansen <jhansen@vmware.com>
Reviewed-by: Adit Ranadive <aditr@vmware.com>
Reviewed-by: Aditya Sarwade <asarwade@vmware.com>
---
 net/vmw_vsock/af_vsock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 17dbbe6..8a398b3 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -465,6 +465,8 @@ void vsock_pending_work(struct work_struct *work)
 
 	if (vsock_is_pending(sk)) {
 		vsock_remove_pending(listener, sk);
+
+		listener->sk_ack_backlog--;
 	} else if (!vsk->rejected) {
 		/* We are not on the pending list and accept() did not reject
 		 * us, so we must have been accepted by our user process.  We
@@ -475,8 +477,6 @@ void vsock_pending_work(struct work_struct *work)
 		goto out;
 	}
 
-	listener->sk_ack_backlog--;
-
 	/* We need to remove ourself from the global connected sockets list so
 	 * incoming packets can't find this socket, and to reduce the reference
 	 * count.
@@ -2010,5 +2010,5 @@ EXPORT_SYMBOL_GPL(vsock_core_get_transport);
 
 MODULE_AUTHOR("VMware, Inc.");
 MODULE_DESCRIPTION("VMware Virtual Socket Family");
-MODULE_VERSION("1.0.1.0-k");
+MODULE_VERSION("1.0.2.0-k");
 MODULE_LICENSE("GPL v2");
-- 
1.7.0
