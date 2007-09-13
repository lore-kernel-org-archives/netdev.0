From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/4] [IPV6]: Fix oops during flushing corked datagrams.
Date: Thu, 13 Sep 2007 09:30:51 +0900 (JST)
Message-ID: <20070913.093051.04296781.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44027 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbXIMA3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 20:29:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When we corking sub-datagrams, we do not clone skb->dst for sub-datagrams
other than the first one, so we get oops if we have multiple sub-datagrams
here.

One possible way to fix this is to clone skb->dst for all sub-datagrams,
but we do not take this approach because skb->dst is not used in other
places and it is more natural to increment statistics once per a datagram.

Also applicable for stable releases.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 4704b5f..6530044 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1423,8 +1423,15 @@ void ip6_flush_pending_frames(struct sock *sk)
 	struct sk_buff *skb;
 
 	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
-		IP6_INC_STATS(ip6_dst_idev(skb->dst),
-			      IPSTATS_MIB_OUTDISCARDS);
+		if (skb->dst) {
+			/*
+			 * Note: we count standard stats once per "datagram"
+			 * and skb->dst is set only for the first 
+			 * sub-datagram of the datagram.
+			 */
+			IP6_INC_STATS(ip6_dst_idev(skb->dst),
+				      IPSTATS_MIB_OUTDISCARDS);
+		}
 		kfree_skb(skb);
 	}
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
