From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/4] [IPV6] XFRM: Fix decoding session with preceding
 extension header(s).
Date: Wed, 19 Apr 2006 00:21:06 +0900 (JST)
Message-ID: <20060419.002106.40818414.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	takamiya@po.ntts.co.jp, kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:4371 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932275AbWDRPSZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 11:18:25 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6] XFRM: Fix decoding session with preceding extension header(s).

We did not correctly decode session with preceding extension
header(s).  This was because we had already pulled preceding
headers, skb->nh.raw + 40 + 1 - skb->data was minus, and
pskb_may_pull() failed.

We now have IP6CB(skb)->nhoff and skb->h.raw, and we can
start parsing / decoding upper layer protocol from current
position.

Tracked down by Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
and tested by Kazunori Miyazawa <kazunori@miyazawa.org>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---

 net/ipv6/xfrm6_policy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

2556f141ba4ee513141aaf2a984e98e1e06a8c44
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 588922b..88c840f 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -191,10 +191,10 @@ error:
 static inline void
 _decode_session6(struct sk_buff *skb, struct flowi *fl)
 {
-	u16 offset = sizeof(struct ipv6hdr);
+	u16 offset = skb->h.raw - skb->nh.raw;
 	struct ipv6hdr *hdr = skb->nh.ipv6h;
 	struct ipv6_opt_hdr *exthdr;
-	u8 nexthdr = skb->nh.ipv6h->nexthdr;
+	u8 nexthdr = skb->nh.raw[IP6CB(skb)->nhoff];
 
 	memset(fl, 0, sizeof(struct flowi));
 	ipv6_addr_copy(&fl->fl6_dst, &hdr->daddr);
-- 
1.0.8
