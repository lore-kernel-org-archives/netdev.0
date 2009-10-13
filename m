From: Joyce Yu <Joyce.Yu@Sun.COM>
Subject: [PATCH] [NIU] VLAN does not work with niu driver
Date: Mon, 12 Oct 2009 22:41:36 -0700
Message-ID: <4AD41310.7040209@Sun.COM>
Reply-To: Joyce.Yu@Sun.COM
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brmea-mail-1.Sun.COM ([192.18.98.31]:34697 "EHLO
	brmea-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756618AbZJMFmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 01:42:19 -0400
Received: from fe-amer-09.sun.com ([192.18.109.79])
	by brmea-mail-1.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n9D5fc8I007926
	for <netdev@vger.kernel.org>; Tue, 13 Oct 2009 05:41:38 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KRF00700UFEPS00@mail-amer.sun.com> for netdev@vger.kernel.org; Mon,
 12 Oct 2009 23:41:38 -0600 (MDT)
Received: from [129.145.154.82] ([unknown] [129.145.154.82])
 by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 with ESMTPSA id <0KRF000ATUHDI710@mail-amer.sun.com> for
 netdev@vger.kernel.org; Mon, 12 Oct 2009 23:41:38 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From 0bb77e878758bd72051577bcc568e2b95c87c203 Mon Sep 17 00:00:00 2001
From: Joyce Yu <joyce.yu@sun.com>
Date: Mon, 12 Oct 2009 11:03:54 -0700
Subject: [PATCH] VLAN does not work with niu driver
Signed-off-by: Joyce Yu <joyce.yu@sun.com>

---
 drivers/net/niu.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index f9364d0..9559e42 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3480,6 +3480,7 @@ static int niu_process_rx_pkt(struct napi_struct 
*napi, struct niu *np,
        unsigned int index = rp->rcr_index;
        struct sk_buff *skb;
        int len, num_rcr;
+       struct vlan_ethhdr *veth;

        skb = netdev_alloc_skb(np->dev, RX_SKB_ALLOC_SIZE);
        if (unlikely(!skb))
@@ -3545,7 +3546,15 @@ static int niu_process_rx_pkt(struct napi_struct 
*napi, struct niu *np,
        rp->rcr_index = index;

        skb_reserve(skb, NET_IP_ALIGN);
-       __pskb_pull_tail(skb, min(len, NIU_RXPULL_MAX));
+       __pskb_pull_tail(skb, min(len, VLAN_ETH_HLEN));
+
+       veth = (struct vlan_ethhdr *)skb->data;
+       if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
+               skb->tail -= 4;
+               skb->data_len += 4;
+               skb_shinfo(skb)->frags[0].page_offset -= 4;
+               skb_shinfo(skb)->frags[0].size += 4;
+       }

        rp->rx_packets++;
        rp->rx_bytes += skb->len;
--
1.6.4

-- 


