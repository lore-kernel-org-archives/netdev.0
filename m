From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/13 net-3.1-stable] ah: Correctly pass error codes in
 ahash output callback.
Date: Tue, 06 Dec 2011 16:32:59 -0500 (EST)
Message-ID: <20111206.163259.530515244936796347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038Ab1LFVdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:01 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LWxsh024094
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:33:00 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Nick Bowler <nbowler@elliptictech.com>

[ Upstream commit 069294e813ed5f27f82613b027609bcda5f1b914 ]

The AH4/6 ahash output callbacks pass nexthdr to xfrm_output_resume
instead of the error code.  This appears to be a copy+paste error from
the input case, where nexthdr is expected.  This causes the driver to
continuously add AH headers to the datagram until either an allocation
fails and the packet is dropped or the ahash driver hits a synchronous
fallback and the resulting monstrosity is transmitted.

Correct this issue by simply passing the error code unadulterated.

Signed-off-by: Nick Bowler <nbowler@elliptictech.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ah4.c |    2 --
 net/ipv6/ah6.c |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index c1f4154..33ca186 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -136,8 +136,6 @@ static void ah_output_done(struct crypto_async_request *base, int err)
 		memcpy(top_iph+1, iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
 	}
 
-	err = ah->nexthdr;
-
 	kfree(AH_SKB_CB(skb)->tmp);
 	xfrm_output_resume(skb, err);
 }
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 2195ae6..ede4d9d 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -324,8 +324,6 @@ static void ah6_output_done(struct crypto_async_request *base, int err)
 #endif
 	}
 
-	err = ah->nexthdr;
-
 	kfree(AH_SKB_CB(skb)->tmp);
 	xfrm_output_resume(skb, err);
 }
-- 
1.7.7.3
