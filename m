From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2.6] [IPV6] MCAST: Ensure to check multicast listener(s).
Date: Sun, 30 Mar 2008 17:58:35 +0900 (JST)
Message-ID: <20080330.175835.81268650.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55453 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbYC3I57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2008 04:57:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ip6_mc_input(), we need to check whether we have listener(s) for
the packet.

After commit ae7bf20a6316272acfcaef5d265b18aaa54b41e4, all packets
for multicast destinations are delivered to upper layer if
IFF_PROMISC or IFF_ALLMULTI is set.

In fact, bug was rather ancient; the original (before the commit)
intent of the dev->flags check was to skip the ipv6_chk_mcast_addr()
call, assuming L2 filters packets appropriately, but it was even not
true.

Let's explicitly check our multicast list.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 178aebc..98ab4f4 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -239,8 +239,7 @@ int ip6_mc_input(struct sk_buff *skb)
 	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCASTPKTS);
 
 	hdr = ipv6_hdr(skb);
-	deliver = unlikely(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) ||
-	    ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL);
+	deliver = ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL);
 
 	/*
 	 *	IPv6 multicast router mode isnt currently supported.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
