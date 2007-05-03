From: Patrick McHardy <kaber@trash.net>
Subject: [NETLINK 01/04]: Fix use after free in netlink_recvmsg
Date: Thu,  3 May 2007 02:04:14 +0200 (MEST)
Message-ID: <20070503000257.30775.79601.sendpatchset@localhost.localdomain>
References: <20070503000256.30775.81929.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	howells@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48175 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767266AbXECAEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 20:04:15 -0400
In-Reply-To: <20070503000256.30775.81929.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NETLINK]: Fix use after free in netlink_recvmsg

When the user passes in MSG_TRUNC the skb is used after getting freed.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 831e920626706afd5ced0c72ca15c8af340bc157
tree 1320e7a446a55e826f671d32e6b9f35e302eeb0d
parent dc87c3985e9b442c60994308a96f887579addc39
author Patrick McHardy <kaber@trash.net> Wed, 02 May 2007 20:18:57 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 02 May 2007 20:18:57 +0200

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
