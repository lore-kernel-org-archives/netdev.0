From: Daniel Ritz <daniel.ritz@gmx.ch>
Subject: [PATCH 2.6] Fix IPv6 esp mem leak in esp6_input
Date: Sat, 2 Aug 2003 13:50:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308021350.23342.daniel.ritz@gmx.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-net <linux-net@vger.kernel.org>, "linux-netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

fixes a mem leak in esp6_input() in the error paths. and return -ENOMEM,
not -EINVAL when out of memory. against 2.6.0-test2-bk

--- 1.19/net/ipv6/esp6.c	Mon Jul 21 02:46:12 2003
+++ edited/net/ipv6/esp6.c	Sat Aug  2 13:02:11 2003
@@ -200,18 +200,24 @@
 
 	int hdr_len = skb->h.raw - skb->nh.raw;
 	int nfrags;
-	u8 ret_nexthdr = 0;
 	unsigned char *tmp_hdr = NULL;
+	int ret = 0;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6_esp_hdr)))
-		goto out;
+	if (!pskb_may_pull(skb, sizeof(struct ipv6_esp_hdr))) {
+		ret = -EINVAL;
+		goto out_nofree;
+	}
 
-	if (elen <= 0 || (elen & (blksize-1)))
-		goto out;
+	if (elen <= 0 || (elen & (blksize-1))) {
+		ret = -EINVAL;
+		goto out_nofree;
+	}
 
 	tmp_hdr = kmalloc(hdr_len, GFP_ATOMIC);
-	if (!tmp_hdr)
-		goto out;
+	if (!tmp_hdr) {
+		ret = -ENOMEM;
+		goto out_nofree;
+	}
 	memcpy(tmp_hdr, skb->nh.raw, hdr_len);
 
 	/* If integrity check is required, do this. */
@@ -226,12 +232,15 @@
 
 		if (unlikely(memcmp(sum, sum1, alen))) {
 			x->stats.integrity_failed++;
+			ret = -EINVAL;
 			goto out;
 		}
 	}
 
-	if ((nfrags = skb_cow_data(skb, 0, &trailer)) < 0)
+	if ((nfrags = skb_cow_data(skb, 0, &trailer)) < 0) {
+		ret = -EINVAL;
 		goto out;
+	}
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -251,8 +260,10 @@
 
 		if (unlikely(nfrags > MAX_SG_ONSTACK)) {
 			sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
-			if (!sg)
+			if (!sg) {
+				ret = -ENOMEM;
 				goto out;
+			}
 		}
 		skb_to_sgvec(skb, sg, sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen, elen);
 		crypto_cipher_decrypt(esp->conf.tfm, sg, sg, elen);
@@ -267,6 +278,7 @@
 			if (net_ratelimit()) {
 				printk(KERN_WARNING "ipsec esp packet is garbage padlen=%d, elen=%d\n", padlen+2, elen);
 			}
+			ret = -EINVAL;
 			goto out;
 		}
 		/* ... check padding bits here. Silly. :-) */ 
@@ -277,13 +289,13 @@
 		memcpy(skb->nh.raw, tmp_hdr, hdr_len);
 		skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 		ip6_find_1stfragopt(skb, &prevhdr);
-		ret_nexthdr = *prevhdr = nexthdr[1];
+		ret = *prevhdr = nexthdr[1];
 	}
-	kfree(tmp_hdr);
-	return ret_nexthdr;
 
 out:
-	return -EINVAL;
+	kfree(tmp_hdr);
+out_nofree:
+	return ret;
 }
 
 static u32 esp6_get_max_size(struct xfrm_state *x, int mtu)
