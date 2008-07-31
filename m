From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] ipv6: Fix ip6_xmit to send fragments if ipfragok is true
Date: Thu, 31 Jul 2008 13:55:57 +0800
Message-ID: <489153ED.9030701@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59626 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751701AbYGaF5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 01:57:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP used ip6_xmit() to send fragments after received ICMP packet too
big message. But while send packet used ip6_xmit, the skb->local_df is
not initialized. So when skb if enter ip6_fragment
<../cgi-bin/global.cgi?pattern=ip6_fragment&type=reference>(), the following
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

This bug come from patch (b5c15fc004ac83b7ad280acbe0fd4bbed7e2c8d4)
[IPV6]: Fix reversed local_df test in ip6_fragment
which commit by Herbert Xu.

This patch fixed the problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6407c64..a678c71 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -236,6 +236,10 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	skb_reset_network_header(skb);
 	hdr = ipv6_hdr(skb);
 
+	/* Allow local fragmentation. */
+	if (np && np->pmtudisc < IPV6_PMTUDISC_DO)
+		skb->local_df = 1;
+
 	/*
 	 *	Fill in the IPv6 header
 	 */






