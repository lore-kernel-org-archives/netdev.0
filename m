From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to stalled
 CPU task )
Date: Fri, 14 Sep 2012 21:22:41 +0800
Message-ID: <50532FA1.3070706@gmail.com>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com> <1345634026.5158.1084.camel@edumazet-glaptop> <CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com> <1345640757.5158.1321.camel@edumazet-glaptop> <CAF6-1L5hKU-VM0E5vCwExJ4kb8YB=ndotgfH7pbpxO6Q7+JHUQ@mail.gmail.com> <k2q0ck$rpr$1@ger.gmane.org> <1347455135.13103.949.camel@edumazet-glaptop> <CAF6-1L6RJkV6u4Rc2uDMQGUG23EGRKrdWSzTiHEYO9Z9ioGtaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040102090303070508030509"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:65301 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab2INNWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 09:22:47 -0400
Received: by obbuo13 with SMTP id uo13so6196163obb.19
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 06:22:46 -0700 (PDT)
In-Reply-To: <CAF6-1L6RJkV6u4Rc2uDMQGUG23EGRKrdWSzTiHEYO9Z9ioGtaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040102090303070508030509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 09/14/2012 01:35 AM, Sylvain Munaut wrote:
> Hi,
>
>> Yes, but I have some worries of why it is needed.
>>
>> Isnt it covering a bug elsewhere ?
>
> That may very well be.
>
> Of the few test servers I have running the same kernel, I just found
> the one with netconsole active to be "stuck".
>
> Not frozen, but all user process are hanged up and it's spitting
> message about processes and CPU being "stuck". The trace is different
> in each case depending on what the process was actually doing at the
> time it got stuck.
>
> No message sent to the netconsole with the root cause and nothing was
> written in the logs ...
>

Yeah, in this case, kdump is your friend. :)

Anyway, I think Eric is right, the bug may be in other place. I am 
wondering if the attached patch could help? It seems in netpoll tx path, 
we miss the chance of calling ->ndo_select_queue().

Please give it a try.

Thanks!

--------------040102090303070508030509
Content-Type: text/x-patch;
 name="netpoll-txq.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="netpoll-txq.diff"

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ae3153c0..72661f6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1403,6 +1403,9 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 		f(dev, &dev->_tx[i], arg);
 }
 
+extern struct netdev_queue *netdev_pick_tx(struct net_device *dev,
+					   struct sk_buff *skb);
+
 /*
  * Net namespace inlines
  */
diff --git a/net/core/dev.c b/net/core/dev.c
index b1e6d63..d76bf73 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2381,8 +2381,8 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 #endif
 }
 
-static struct netdev_queue *dev_pick_tx(struct net_device *dev,
-					struct sk_buff *skb)
+struct netdev_queue *netdev_pick_tx(struct net_device *dev,
+				    struct sk_buff *skb)
 {
 	int queue_index;
 	const struct net_device_ops *ops = dev->netdev_ops;
@@ -2556,7 +2556,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 
 	skb_update_prio(skb);
 
-	txq = dev_pick_tx(dev, skb);
+	txq = netdev_pick_tx(dev, skb);
 	q = rcu_dereference_bh(txq->qdisc);
 
 #ifdef CONFIG_NET_CLS_ACT
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index dd67818..77a0388 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -328,7 +328,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 	if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
 		struct netdev_queue *txq;
 
-		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+		txq = netdev_pick_tx(dev, skb);
 
 		/* try until next clock tick */
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;

--------------040102090303070508030509--
