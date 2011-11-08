From: Nick Bowler <nbowler@elliptictech.com>
Subject: [PATCH 1/2] ah: Correctly pass error codes in ahash output callback.
Date: Tue,  8 Nov 2011 17:12:44 -0500
Message-ID: <1320790365-29152-2-git-send-email-nbowler@elliptictech.com>
References: <1320790365-29152-1-git-send-email-nbowler@elliptictech.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320790365-29152-1-git-send-email-nbowler@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The AH4/6 ahash output callbacks pass nexthdr to xfrm_output_resume
instead of the error code.  This appears to be a copy+paste error from
the input case, where nexthdr is expected.  This causes the driver to
continuously add AH headers to the datagram until either an allocation
fails and the packet is dropped or the ahash driver hits a synchronous
fallback and the resulting monstrosity is transmitted.

Correct this issue by simply passing the error code unadulterated.

Signed-off-by: Nick Bowler <nbowler@elliptictech.com>
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
1.7.3.4
