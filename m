From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net 2/2] macvtap: read vnet_hdr_size once
Date: Fri,  3 Feb 2017 18:20:49 -0500
Message-ID: <20170203232049.38982-3-willemdebruijn.kernel@gmail.com>
References: <20170203232049.38982-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35835 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752856AbdBCXU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:20:57 -0500
Received: by mail-qt0-f195.google.com with SMTP id s58so7660926qtc.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 15:20:57 -0800 (PST)
In-Reply-To: <20170203232049.38982-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

When IFF_VNET_HDR is enabled, a virtio_net header must precede data.
Data length is verified to be greater than or equal to expected header
length tun->vnet_hdr_sz before copying.

Macvtap functions read the value once, but unless READ_ONCE is used,
the compiler may ignore this and read multiple times. Enforce a single
read and locally cached value to avoid updates between test and use.

Signed-off-by: Willem de Bruijn <willemb@google.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/macvtap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 402618565838..c27011bbe30c 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -681,7 +681,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	size_t linear;
 
 	if (q->flags & IFF_VNET_HDR) {
-		vnet_hdr_len = q->vnet_hdr_sz;
+		vnet_hdr_len = READ_ONCE(q->vnet_hdr_sz);
 
 		err = -EINVAL;
 		if (len < vnet_hdr_len)
@@ -820,7 +820,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 
 	if (q->flags & IFF_VNET_HDR) {
 		struct virtio_net_hdr vnet_hdr;
-		vnet_hdr_len = q->vnet_hdr_sz;
+		vnet_hdr_len = READ_ONCE(q->vnet_hdr_sz);
 		if (iov_iter_count(iter) < vnet_hdr_len)
 			return -EINVAL;
 
-- 
2.11.0.483.g087da7b7c-goog
