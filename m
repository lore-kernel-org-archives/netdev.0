From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 respin] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Mon, 04 Aug 2008 23:14:49 -0700 (PDT)
Message-ID: <20080804.231449.199557608.davem@davemloft.net>
References: <20080804062813.GA4570@ff.dom.local>
	<20080803.234200.193697269.davem@davemloft.net>
	<20080804085734.GB12927@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39191
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751586AbYHEGOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 02:14:48 -0400
In-Reply-To: <20080804085734.GB12927@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 4 Aug 2008 08:57:34 +0000

> net_sched: Add qdisc __NET_XMIT_BYPASS flag
> 
> Patrick McHardy <kaber@trash.net> noticed that it would be nice to
> handle NET_XMIT_BYPASS by NET_XMIT_SUCCESS with an internal qdisc flag
> __NET_XMIT_BYPASS and to remove the mapping from dev_queue_xmit().
> 
> David Miller <davem@davemloft.net> spotted a serious bug in the first
> version of this patch.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.

After applying this I noticed that dst_input()'s usage of
plain NET_XMIT_BYPASS was bogus, and after killing that
there are no more references.

Thus I added the following commit.

commit cc6533e98a7f3cb7fce9d740da49195c7aa523a4
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Aug 4 23:04:08 2008 -0700

    net: Kill plain NET_XMIT_BYPASS.
    
    dst_input() was doing something completely absurd, looping
    on skb->dst->input() if NET_XMIT_BYPASS was seen, but these
    functions never return such an error.
    
    And as a result plain ole' NET_XMIT_BYPASS has no more
    references and can be completely killed off.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index abbf5d5..488c56e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -61,9 +61,6 @@ struct wireless_dev;
 #define NET_XMIT_DROP		1	/* skb dropped			*/
 #define NET_XMIT_CN		2	/* congestion notification	*/
 #define NET_XMIT_POLICED	3	/* skb is shot by police	*/
-#define NET_XMIT_BYPASS		4	/* packet does not leave via dequeue;
-					   (TC use only - dev_queue_xmit
-					   returns this as NET_XMIT_SUCCESS) */
 #define NET_XMIT_MASK		0xFFFF	/* qdisc flags in net/sch_generic.h */
 
 /* Backlog congestion levels */
diff --git a/include/net/dst.h b/include/net/dst.h
index c5c318a..8a8b71e 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -252,17 +252,7 @@ static inline int dst_output(struct sk_buff *skb)
 /* Input packet from network to transport.  */
 static inline int dst_input(struct sk_buff *skb)
 {
-	int err;
-
-	for (;;) {
-		err = skb->dst->input(skb);
-
-		if (likely(err == 0))
-			return err;
-		/* Oh, Jamal... Seems, I will not forgive you this mess. :-) */
-		if (unlikely(err != NET_XMIT_BYPASS))
-			return err;
-	}
+	return skb->dst->input(skb);
 }
 
 static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
