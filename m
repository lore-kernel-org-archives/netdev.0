From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/13 net-3.1-stable] ah: Read nexthdr value before
 overwriting it in ahash input callback.
Date: Tue, 06 Dec 2011 16:33:04 -0500 (EST)
Message-ID: <20111206.163304.1292747670002149683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038Ab1LFVdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:07 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LX5pL024106
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:33:05 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Nick Bowler <nbowler@elliptictech.com>

[ Upstream commit b7ea81a58adc123a4e980cb0eff9eb5c144b5dc7 ]

The AH4/6 ahash input callbacks read out the nexthdr field from the AH
header *after* they overwrite that header.  This is obviously not going
to end well.  Fix it up.

Signed-off-by: Nick Bowler <nbowler@elliptictech.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
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
1.7.7.3
