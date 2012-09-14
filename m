From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net] tcp: flush DMA queue before sk_wait_data if rcv_wnd is zero
Date: Fri, 14 Sep 2012 16:59:52 +0200
Message-ID: <20120914170432.C8B8DC6405@unicorn.suse.cz>
Cc: "Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	"James Morris" <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>, <netdev@vger.kernel.org>,
	<mkubecek@suse.cz>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36187 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344Ab2INREe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 13:04:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If recv() syscall is called for a TCP socket so that
  - IOAT DMA is used
  - MSG_WAITALL flag is used
  - requested length is bigger than sk_rcvbuf
  - enough data has already arrived to bring rcv_wnd to zero
then when tcp_recvmsg() gets to calling sk_wait_data(), receive
window can be still zero while sk_async_wait_queue exhausts
enough space to keep it zero. As this queue isn't cleaned until
the tcp_service_net_dma() call, sk_wait_data() cannot receive
any data and blocks forever.

If zero receive window and non-empty sk_async_wait_queue is
detected before calling sk_wait_data(), process the queue first.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Cc: <stable@vger.kernel.org>
---
 net/ipv4/tcp.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2109ff4..bf9a8ab 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1762,8 +1762,14 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		}
 
 #ifdef CONFIG_NET_DMA
-		if (tp->ucopy.dma_chan)
-			dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
+		if (tp->ucopy.dma_chan) {
+			if (tp->rcv_wnd == 0 &&
+			    !skb_queue_empty(&sk->sk_async_wait_queue)) {
+				tcp_service_net_dma(sk, true);
+				tcp_cleanup_rbuf(sk, copied);
+			} else
+				dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
+		}
 #endif
 		if (copied >= target) {
 			/* Do not sleep, just process backlog. */
-- 
1.7.10.4
