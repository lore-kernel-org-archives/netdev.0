From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/5] [NETLINK]: Fix use after free in netlink_recvmsg
Date: Thu, 03 May 2007 10:53:15 +0100
Message-ID: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, kaber@trash.net, dhowells@redhat.com
To: akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the user passes in MSG_TRUNC the skb is used after getting freed.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/netlink/af_netlink.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 42d2fb9..7419f70 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1245,16 +1245,14 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 		siocb->scm = &scm;
 	}
 	siocb->scm->creds = *NETLINK_CREDS(skb);
+	if (flags & MSG_TRUNC)
+		copied = skb->len;
 	skb_free_datagram(sk, skb);
 
 	if (nlk->cb && atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf / 2)
 		netlink_dump(sk);
 
 	scm_recv(sock, msg, siocb->scm, flags);
-
-	if (flags & MSG_TRUNC)
-		copied = skb->len;
-
 out:
 	netlink_rcv_wake(sk);
 	return err ? : copied;

