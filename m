From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: orinoco driver causes *lots* of lockdep spew
Date: Thu, 03 Aug 2006 23:54:41 +1000
Message-ID: <E1G8der-0001fm-00@gondolin.me.apana.org.au>
References: <1154607380.2965.25.camel@laptopd505.fenrus.org>
Cc: davej@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	linville@tuxdriver.com, jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:20491 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932401AbWHCNzP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 09:55:15 -0400
To: arjan@infradead.org (Arjan van de Ven)
In-Reply-To: <1154607380.2965.25.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven <arjan@infradead.org> wrote:
> 
> this is another one of those nasty buggers;

Good catch.  It's really time that we fix this properly rather than
adding more kludges to the core code.

Dave, once this goes in you can revert the previous netlink workaround
that added the _bh suffix.

[WIRELESS]: Send wireless netlink events with a clean slate

Drivers expect to be able to call wireless_send_event in arbitrary
contexts.  On the other hand, netlink really doesn't like being
invoked in an IRQ context.  So we need to postpone the sending of
netlink skb's to a tasklet.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au> 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/wireless.c b/net/core/wireless.c
index d2bc72d..de0bde4 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -82,6 +82,7 @@ #include <linux/seq_file.h>
 #include <linux/init.h>			/* for __init */
 #include <linux/if_arp.h>		/* ARPHRD_ETHER */
 #include <linux/etherdevice.h>		/* compare_ether_addr */
+#include <linux/interrupt.h>
 
 #include <linux/wireless.h>		/* Pretty obvious */
 #include <net/iw_handler.h>		/* New driver API */
@@ -1842,6 +1843,18 @@ #endif	/* CONFIG_NET_WIRELESS_RTNETLINK 
  */
 
 #ifdef WE_EVENT_RTNETLINK
+static struct sk_buff_head wireless_nlevent_queue;
+
+static void wireless_nlevent_process(unsigned long data)
+{
+	struct sk_buff *skb;
+
+	while ((skb = skb_dequeue(&wireless_nlevent_queue)))
+		netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_ATOMIC);
+}
+
+static DECLARE_TASKLET(wireless_nlevent_tasklet, wireless_nlevent_process, 0);
+
 /* ---------------------------------------------------------------- */
 /*
  * Fill a rtnetlink message with our event data.
@@ -1904,8 +1917,17 @@ static inline void rtmsg_iwinfo(struct n
 		return;
 	}
 	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
-	netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_ATOMIC);
+	skb_queue_tail(&wireless_nlevent_queue, skb);
+	tasklet_schedule(&wireless_nlevent_tasklet);
+}
+
+static int __init wireless_nlevent_init(void)
+{
+	skb_queue_head_init(&wireless_nlevent_queue);
+	return 0;
 }
+
+subsys_initcall(wireless_nlevent_init);
 #endif	/* WE_EVENT_RTNETLINK */
 
 /* ---------------------------------------------------------------- */
