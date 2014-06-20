From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] NFC: Read frag at a time when sending packets
Date: Thu, 19 Jun 2014 23:23:16 -0400
Message-ID: <1403234596-19149-1-git-send-email-sasha.levin@oracle.com>
Cc: linux-wireless@vger.kernel.org, linux-nfc@ml01.01.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	sameo@linux.intel.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Right now userspace can pass a large chunk of data and the kernel
will attempt to allocate all of it to copy it in from userspace.

The problem is that there is no upper limit on the size userspace
can pass. Right now userspace can even force a machine to run out
of memory by forcing the kernel to allocate large chunks of memory.

To avoid imposing a limit, instead of allocating the entire block,
we can allocate just the size of the biggest frag possible and read
it from userspace one frag at a time.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---

 ** WARNING: COMPLETELY UNTESTED ** (I don't have the hardware).

 net/nfc/llcp_commands.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/nfc/llcp_commands.c b/net/nfc/llcp_commands.c
index a3ad69a..da68924 100644
--- a/net/nfc/llcp_commands.c
+++ b/net/nfc/llcp_commands.c
@@ -727,27 +727,27 @@ int nfc_llcp_send_ui_frame(struct nfc_llcp_sock *sock, u8 ssap, u8 dsap,
 	if (local == NULL)
 		return -ENODEV;
 
-	msg_data = kzalloc(len, GFP_KERNEL);
+	remote_miu = sock->remote_miu > LLCP_MAX_MIU ?
+			local->remote_miu : sock->remote_miu;
+
+	msg_data = kzalloc(remote_miu, GFP_KERNEL);
 	if (msg_data == NULL)
 		return -ENOMEM;
 
-	if (memcpy_fromiovec(msg_data, msg->msg_iov, len)) {
-		kfree(msg_data);
-		return -EFAULT;
-	}
-
 	remaining_len = len;
 	msg_ptr = msg_data;
 
 	do {
-		remote_miu = sock->remote_miu > LLCP_MAX_MIU ?
-				local->remote_miu : sock->remote_miu;
-
 		frag_len = min_t(size_t, remote_miu, remaining_len);
 
 		pr_debug("Fragment %zd bytes remaining %zd",
 			 frag_len, remaining_len);
 
+		if (memcpy_fromiovec(msg_data, msg->msg_iov, frag_len)) {
+			kfree(msg_data);
+			return -EFAULT;
+		}
+
 		pdu = nfc_alloc_send_skb(sock->dev, &sock->sk, MSG_DONTWAIT,
 					 frag_len + LLCP_HEADER_SIZE, &err);
 		if (pdu == NULL) {
-- 
1.7.10.4
