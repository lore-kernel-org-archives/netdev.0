From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Restore correct value to gso_size
Date: Tue, 14 Apr 2009 20:42:49 +0800
Message-ID: <20090414124249.GA31314@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Wagner <mwagner@redhat.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39725 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756058AbZDNMmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 08:42:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

gro: Restore correct value to gso_size

Since everybody has been focusing on baremetal GRO performance
no one noticed when I added a bug that zapped gso_size for all
GRO packets.  This only gets picked up when you forward the skb
out of an interface.

Thanks to Mark Wagner for noticing this bug when testing kvm.

Reported-by: Mark Wagner <mwagner@redhat.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 91d792d..55628cc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2328,8 +2328,10 @@ static int napi_gro_complete(struct sk_buff *skb)
 	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
 	int err = -ENOENT;
 
-	if (NAPI_GRO_CB(skb)->count == 1)
+	if (NAPI_GRO_CB(skb)->count == 1) {
+		skb_shinfo(skb)->gso_size = 0;
 		goto out;
+	}
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
@@ -2348,7 +2350,6 @@ static int napi_gro_complete(struct sk_buff *skb)
 	}
 
 out:
-	skb_shinfo(skb)->gso_size = 0;
 	return netif_receive_skb(skb);
 }

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
