From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] nfc: check sock state in llcp_sock_getname()
Date: Fri,  1 Jan 2016 16:34:17 -0800
Message-ID: <1451694857-21873-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1451694857-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, linux-wireless@vger.kernel.org,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35150 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbcABAe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jan 2016 19:34:29 -0500
In-Reply-To: <1451694857-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

llcp_sock_getname() checks llcp_sock->dev to make sure
llcp_sock is already connected or bound, however, we could
be in the middle of llcp_sock_bind() where llcp_sock->dev
is bound and llcp_sock->service_name_len is set,
but llcp_sock->service_name is not, in this case we would
lead to copy some bytes from a NULL pointer.

We should just check if sk->sk_state is still closed since
both connect() and bind() will update this state at the end.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/nfc/llcp_sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index ecf0a01..5a91997 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -500,7 +500,7 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct nfc_llcp_sock *llcp_sock = nfc_llcp_sock(sk);
 	DECLARE_SOCKADDR(struct sockaddr_nfc_llcp *, llcp_addr, uaddr);
 
-	if (llcp_sock == NULL || llcp_sock->dev == NULL)
+	if (llcp_sock == NULL || sk->sk_state == LLCP_CLOSED)
 		return -EBADFD;
 
 	pr_debug("%p %d %d %d\n", sk, llcp_sock->target_idx,
-- 
1.8.3.1
