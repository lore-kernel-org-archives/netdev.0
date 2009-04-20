From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/3] tun: fix tun_chr_aio_read so that aio works
Date: Mon, 20 Apr 2009 14:25:59 +0300
Message-ID: <20090420112559.GA6715@dhcp-1-124.tlv.redhat.com>
References: <cover.1240125603.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60301 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754739AbZDTL1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 07:27:08 -0400
Content-Disposition: inline
In-Reply-To: <cover.1240125603.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aio_read gets const struct iovec * but tun_chr_aio_read casts this to struct
iovec * and modifies the iovec. As a result, attempts to use io_submit
to get packets from a tun device fail with weird errors such as EINVAL.

Fix by using the new skb_copy_datagram_const_iovec.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 16716ae..24c19c2 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -679,7 +679,7 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 /* Put packet to the user space buffer */
 static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 				       struct sk_buff *skb,
-				       struct iovec *iv, int len)
+				       const struct iovec *iv, int len)
 {
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;
@@ -693,7 +693,7 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 			pi.flags |= TUN_PKT_STRIP;
 		}
 
-		if (memcpy_toiovec(iv, (void *) &pi, sizeof(pi)))
+		if (memcpy_toiovecend(iv, (void *) &pi, 0, sizeof(pi)))
 			return -EFAULT;
 		total += sizeof(pi);
 	}
@@ -726,14 +726,15 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 			gso.csum_offset = skb->csum_offset;
 		} /* else everything is zero */
 
-		if (unlikely(memcpy_toiovec(iv, (void *)&gso, sizeof(gso))))
+		if (unlikely(memcpy_toiovecend(iv, (void *)&gso, total,
+					       sizeof(gso))))
 			return -EFAULT;
 		total += sizeof(gso);
 	}
 
 	len = min_t(int, skb->len, len);
 
-	skb_copy_datagram_iovec(skb, 0, iv, len);
+	skb_copy_datagram_const_iovec(skb, 0, iv, total, len);
 	total += len;
 
 	tun->dev->stats.tx_packets++;
@@ -788,7 +789,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
 		}
 		netif_wake_queue(tun->dev);
 
-		ret = tun_put_user(tun, skb, (struct iovec *) iv, len);
+		ret = tun_put_user(tun, skb, iv, len);
 		kfree_skb(skb);
 		break;
 	}
-- 
1.6.0.6

