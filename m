From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 1/2] sunrpc: do not pull udp headers on receive
Date: Thu,  7 Apr 2016 11:44:58 -0400
Message-ID: <1460043899-56894-2-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1460043899-56894-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fcooper@ti.com, samanthakumar@google.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:35185 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756682AbcDGPpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 11:45:06 -0400
Received: by mail-qg0-f65.google.com with SMTP id b32so7606500qgf.2
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 08:45:06 -0700 (PDT)
In-Reply-To: <1460043899-56894-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Commit e6afc8ace6dd modified the udp receive path by pulling the udp
header before queuing an skbuff onto the receive queue.

Sunrpc also calls skb_recv_datagram to dequeue an skb from a udp
socket. Modify this receive path to also no longer expect udp
headers.

Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")

Reported-by: Franklin S Cooper Jr. <fcooper@ti.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/sunrpc/socklib.c  | 2 +-
 net/sunrpc/svcsock.c  | 5 ++---
 net/sunrpc/xprtsock.c | 5 ++---
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 2df87f7..8ab40ba 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -155,7 +155,7 @@ int csum_partial_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
 	struct xdr_skb_reader	desc;
 
 	desc.skb = skb;
-	desc.offset = sizeof(struct udphdr);
+	desc.offset = 0;
 	desc.count = skb->len - desc.offset;
 
 	if (skb_csum_unnecessary(skb))
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1413cdc..71d6072 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -617,7 +617,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	svsk->sk_sk->sk_stamp = skb->tstamp;
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags); /* there may be more data... */
 
-	len  = skb->len - sizeof(struct udphdr);
+	len  = skb->len;
 	rqstp->rq_arg.len = len;
 
 	rqstp->rq_prot = IPPROTO_UDP;
@@ -641,8 +641,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		skb_free_datagram_locked(svsk->sk_sk, skb);
 	} else {
 		/* we can use it in-place */
-		rqstp->rq_arg.head[0].iov_base = skb->data +
-			sizeof(struct udphdr);
+		rqstp->rq_arg.head[0].iov_base = skb->data;
 		rqstp->rq_arg.head[0].iov_len = len;
 		if (skb_checksum_complete(skb))
 			goto out_free;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 65e7595..c1fc7b2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -995,15 +995,14 @@ static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
 	u32 _xid;
 	__be32 *xp;
 
-	repsize = skb->len - sizeof(struct udphdr);
+	repsize = skb->len;
 	if (repsize < 4) {
 		dprintk("RPC:       impossible RPC reply size %d!\n", repsize);
 		return;
 	}
 
 	/* Copy the XID from the skb... */
-	xp = skb_header_pointer(skb, sizeof(struct udphdr),
-				sizeof(_xid), &_xid);
+	xp = skb_header_pointer(skb, 0, sizeof(_xid), &_xid);
 	if (xp == NULL)
 		return;
 
-- 
2.8.0.rc3.226.g39d4020
