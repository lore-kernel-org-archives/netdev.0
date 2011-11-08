From: Nick Bowler <nbowler@elliptictech.com>
Subject: [PATCH 2/2] ah: Read nexthdr value before overwriting it in ahash input callback.
Date: Tue,  8 Nov 2011 17:12:45 -0500
Message-ID: <1320790365-29152-3-git-send-email-nbowler@elliptictech.com>
References: <1320790365-29152-1-git-send-email-nbowler@elliptictech.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320790365-29152-1-git-send-email-nbowler@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The AH4/6 ahash input callbacks read out the nexthdr field from the AH
header *after* they overwrite that header.  This is obviously not going
to end well.  Fix it up.

Signed-off-by: Nick Bowler <nbowler@elliptictech.com>
---
 net/ipv4/ah4.c |    4 ++--
 net/ipv6/ah6.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 33ca186..c7056b2 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -262,12 +262,12 @@ static void ah_input_done(struct crypto_async_request *base, int err)
 	if (err)
 		goto out;
 
+	err = ah->nexthdr;
+
 	skb->network_header += ah_hlen;
 	memcpy(skb_network_header(skb), work_iph, ihl);
 	__skb_pull(skb, ah_hlen + ihl);
 	skb_set_transport_header(skb, -ihl);
-
-	err = ah->nexthdr;
 out:
 	kfree(AH_SKB_CB(skb)->tmp);
 	xfrm_input_resume(skb, err);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ede4d9d..7a33aaa 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -464,12 +464,12 @@ static void ah6_input_done(struct crypto_async_request *base, int err)
 	if (err)
 		goto out;
 
+	err = ah->nexthdr;
+
 	skb->network_header += ah_hlen;
 	memcpy(skb_network_header(skb), work_iph, hdr_len);
 	__skb_pull(skb, ah_hlen + hdr_len);
 	skb_set_transport_header(skb, -hdr_len);
-
-	err = ah->nexthdr;
 out:
 	kfree(AH_SKB_CB(skb)->tmp);
 	xfrm_input_resume(skb, err);
-- 
1.7.3.4
