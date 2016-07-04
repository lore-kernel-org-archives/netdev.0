From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] tun: fix build warnings
Date: Mon,  4 Jul 2016 13:53:38 +0800
Message-ID: <1467611618-4046-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, sfr@canb.auug.org.au,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbcGDFxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 01:53:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Rothwell reports a build warnings(powerpc ppc64_defconfig)

drivers/net/tun.c: In function 'tun_do_read.part.5':
/home/sfr/next/next/drivers/net/tun.c:1491:6: warning: 'err' may be
used uninitialized in this function [-Wmaybe-uninitialized]
   int err;

This is because tun_ring_recv() may return an uninitialized err, fix this.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 7475215..5eadb7a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1447,12 +1447,13 @@ static struct sk_buff *tun_ring_recv(struct tun_file *tfile, int noblock,
 {
 	DECLARE_WAITQUEUE(wait, current);
 	struct sk_buff *skb = NULL;
+	int error = 0;
 
 	skb = skb_array_consume(&tfile->tx_array);
 	if (skb)
 		goto out;
 	if (noblock) {
-		*err = -EAGAIN;
+		error = -EAGAIN;
 		goto out;
 	}
 
@@ -1464,11 +1465,11 @@ static struct sk_buff *tun_ring_recv(struct tun_file *tfile, int noblock,
 		if (skb)
 			break;
 		if (signal_pending(current)) {
-			*err = -ERESTARTSYS;
+			error = -ERESTARTSYS;
 			break;
 		}
 		if (tfile->socket.sk->sk_shutdown & RCV_SHUTDOWN) {
-			*err = -EFAULT;
+			error = -EFAULT;
 			break;
 		}
 
@@ -1479,6 +1480,7 @@ static struct sk_buff *tun_ring_recv(struct tun_file *tfile, int noblock,
 	remove_wait_queue(&tfile->wq.wait, &wait);
 
 out:
+	*err = error;
 	return skb;
 }
 
-- 
2.7.4
