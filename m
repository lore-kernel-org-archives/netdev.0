From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCHv2] ipv6: Fix ip6_xmit to send fragments if ipfragok is true
Date: Thu, 31 Jul 2008 17:55:29 +0800
Message-ID: <48918C11.5010004@cn.fujitsu.com>
References: <489153ED.9030701@cn.fujitsu.com> <20080731082053.GA6463@gondor.apana.org.au> <489181DC.40507@cn.fujitsu.com> <20080731092321.GA6907@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51432 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750895AbYGaJ5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 05:57:16 -0400
In-Reply-To: <20080731092321.GA6907@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP used ip6_xmit() to send fragments after received ICMP packet too
big message. But while send packet used ip6_xmit, the skb->local_df is
not initialized. So when skb if enter ip6_fragment(), the following
code will discard the skb.

ip6_fragment(...)
{
    if (!skb->local_df) {
        ...
        return -EMSGSIZE;
    }
    ...
}

SCTP do the following step:
1. send packet ip6_xmit(skb, ipfragok=0)
2. received ICMP packet too big message
3. if PMTUD_ENABLE: ip6_xmit(skb, ipfragok=1)

This patch fixed the problem by set local_df if ipfragok is true.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6407c64..0969f2a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -236,6 +236,10 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	skb_reset_network_header(skb);
 	hdr = ipv6_hdr(skb);
 
+	/* Allow local fragmentation. */
+	if (ipfragok)
+		skb->local_df = 1;
+
 	/*
 	 *	Fill in the IPv6 header
 	 */
-- 
1.5.3.8



