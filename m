From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net 1/2] tun: read vnet_hdr_sz once
Date: Fri,  3 Feb 2017 18:20:48 -0500
Message-ID: <20170203232049.38982-2-willemdebruijn.kernel@gmail.com>
References: <20170203232049.38982-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35825 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752441AbdBCXU4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:20:56 -0500
Received: by mail-qt0-f193.google.com with SMTP id s58so7660845qtc.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 15:20:56 -0800 (PST)
In-Reply-To: <20170203232049.38982-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

When IFF_VNET_HDR is enabled, a virtio_net header must precede data.
Data length is verified to be greater than or equal to expected header
length tun->vnet_hdr_sz before copying.

Read this value once and cache locally, as it can be updated between
the test and use (TOCTOU).

Signed-off-by: Willem de Bruijn <willemb@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
CC: Eric Dumazet <edumazet@google.com>
---
 drivers/net/tun.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 2cd10b26b650..bfabe180053e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1170,9 +1170,11 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	if (tun->flags & IFF_VNET_HDR) {
-		if (len < tun->vnet_hdr_sz)
+		int vnet_hdr_sz = READ_ONCE(tun->vnet_hdr_sz);
+
+		if (len < vnet_hdr_sz)
 			return -EINVAL;
-		len -= tun->vnet_hdr_sz;
+		len -= vnet_hdr_sz;
 
 		if (!copy_from_iter_full(&gso, sizeof(gso), from))
 			return -EFAULT;
@@ -1183,7 +1185,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 
 		if (tun16_to_cpu(tun, gso.hdr_len) > len)
 			return -EINVAL;
-		iov_iter_advance(from, tun->vnet_hdr_sz - sizeof(gso));
+		iov_iter_advance(from, vnet_hdr_sz - sizeof(gso));
 	}
 
 	if ((tun->flags & TUN_TYPE_MASK) == IFF_TAP) {
@@ -1335,7 +1337,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		vlan_hlen = VLAN_HLEN;
 
 	if (tun->flags & IFF_VNET_HDR)
-		vnet_hdr_sz = tun->vnet_hdr_sz;
+		vnet_hdr_sz = READ_ONCE(tun->vnet_hdr_sz);
 
 	total = skb->len + vlan_hlen + vnet_hdr_sz;
 
-- 
2.11.0.483.g087da7b7c-goog
