From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 9/22] xfrm offload v2: Split AH header initialization from zeroing of mutable fields
Date: Mon, 10 Jan 2005 10:37:00 -0500
Message-ID: <20040110014300.18@ori.thedillows.org>
References: <20040110014300.17@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:49:43-05:00 dave@thedillows.org 
#   Seperate AH header initialization from the zeroing of mutable
#   IP header fields in preparation for offloading the crypto
#   processing of the packet.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# net/ipv4/ah4.c
#   2005/01/10 00:49:27-05:00 dave@thedillows.org +18 -12
#   Seperate AH header initialization from the zeroing of mutable
#   IP header fields in preparation for offloading the crypto
#   processing of the packet.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/net/ipv4/ah4.c b/net/ipv4/ah4.c
--- a/net/ipv4/ah4.c	2005-01-10 01:19:00 -05:00
+++ b/net/ipv4/ah4.c	2005-01-10 01:19:00 -05:00
@@ -69,6 +69,20 @@
 	top_iph = skb->nh.iph;
 	iph = &tmp_iph.iph;
 
+	ah = (struct ip_auth_hdr *)((char *)top_iph+top_iph->ihl*4);
+	ah->nexthdr = top_iph->protocol;
+
+	top_iph->tot_len = htons(skb->len);
+	top_iph->protocol = IPPROTO_AH;
+
+	ahp = x->data;
+	ah->hdrlen  = (XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + 
+				   ahp->icv_trunc_len) >> 2) - 2;
+
+	ah->reserved = 0;
+	ah->spi = x->id.spi;
+	ah->seq_no = htonl(x->replay.oseq + 1);
+
 	iph->tos = top_iph->tos;
 	iph->ttl = top_iph->ttl;
 	iph->frag_off = top_iph->frag_off;
@@ -81,23 +95,11 @@
 			goto error;
 	}
 
-	ah = (struct ip_auth_hdr *)((char *)top_iph+top_iph->ihl*4);
-	ah->nexthdr = top_iph->protocol;
-
 	top_iph->tos = 0;
-	top_iph->tot_len = htons(skb->len);
 	top_iph->frag_off = 0;
 	top_iph->ttl = 0;
-	top_iph->protocol = IPPROTO_AH;
 	top_iph->check = 0;
 
-	ahp = x->data;
-	ah->hdrlen  = (XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + 
-				   ahp->icv_trunc_len) >> 2) - 2;
-
-	ah->reserved = 0;
-	ah->spi = x->id.spi;
-	ah->seq_no = htonl(++x->replay.oseq);
 	ahp->icv(ahp, skb, ah->auth_data);
 
 	top_iph->tos = iph->tos;
@@ -108,6 +110,10 @@
 		memcpy(top_iph+1, iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
 	}
 
+	/* Delay incrementing the replay sequence until we know we're going
+	 * to send this packet to prevent gaps.
+	 */
+	x->replay.oseq++;
 	ip_send_check(top_iph);
 
 	err = 0;
