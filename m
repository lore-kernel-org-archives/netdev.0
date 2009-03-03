From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] netlink: invert error code in netlink_set_err()
Date: Wed, 04 Mar 2009 00:35:35 +0100
Message-ID: <20090303233535.7346.25867.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46765 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750764AbZCCXfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2009 18:35:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The callers of netlink_set_err() currently pass a negative value
as parameter for the error code. However, sk->sk_err wants a
positive error value. Without this patch, skb_recv_datagram() called
by netlink_recvmsg() may return a positive value to report an error.

Another choice to fix this is to change callers to pass a positive
error value, but this seems a bit inconsistent and error prone
to me. Indeed, the callers of netlink_set_err() assumed that the
(usual) negative value for error codes was fine before this patch :).

This patch also includes some documentation in docbook format
for netlink_set_err() to avoid this sort of confusion.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---

 net/netlink/af_netlink.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2760b62..09e5008 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1092,6 +1092,13 @@ out:
 	return 0;
 }
 
+/**
+ * netlink_set_err - report error to broadcast listeners
+ * @ssk: the kernel netlink socket, as returned by netlink_kernel_create()
+ * @pid: the PID of a process that we want to skip (if any)
+ * @groups: the broadcast group that will notice the error
+ * @code: error code, must be negative (as usual in kernelspace)
+ */
 void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 {
 	struct netlink_set_err_data info;
@@ -1101,7 +1108,8 @@ void netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 	info.exclude_sk = ssk;
 	info.pid = pid;
 	info.group = group;
-	info.code = code;
+	/* sk->sk_err wants a positive error value */
+	info.code = -code;
 
 	read_lock(&nl_table_lock);
 

