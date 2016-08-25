From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net] sunrpc: fix UDP memory accounting
Date: Thu, 25 Aug 2016 18:42:35 +0200
Message-ID: <32a391a2469b4161dc2375c6b6374b8229b3dd37.1472126188.git.pabeni@redhat.com>
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
        "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
        Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jan Stancek <jstancek-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The commit f9b2ee714c5c ("SUNRPC: Move UDP receive data path
into a workqueue context"), as a side effect, moved the
skb_free_datagram() call outside the scope of the related socket
lock, but UDP sockets require such lock to be held for proper
memory accounting.
Fix it by replacing skb_free_datagram() with
skb_free_datagram_locked().

Fixes: f9b2ee714c5c ("SUNRPC: Move UDP receive data path into a workqueue context")
Reported-and-tested-by: Jan Stancek <jstancek-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 net/sunrpc/xprtsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8ede3bc..bf16883 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1074,7 +1074,7 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 		skb = skb_recv_datagram(sk, 0, 1, &err);
 		if (skb != NULL) {
 			xs_udp_data_read_skb(&transport->xprt, sk, skb);
-			skb_free_datagram(sk, skb);
+			skb_free_datagram_locked(sk, skb);
 			continue;
 		}
 		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
