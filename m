From: Jason Baron <jbaron@akamai.com>
Subject: macvlan: optimizing the receive path?
Date: Thu, 02 Oct 2014 16:28:13 -0400
Message-ID: <542DB55D.3090601@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:58162 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752655AbaJBUfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 16:35:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was just wondering why the netif_rx(skb) call in macvlan_handle_frame()
was necessary? IE:

macvlan_handle_frame()
{
       ........

        skb->dev = dev;
        skb->pkt_type = PACKET_HOST;

****>ret = netif_rx(skb);

out:
        macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
        return RX_HANDLER_CONSUMED;
}


I think the point of going through netif_rx() is to ensure that we throttle
incoming packets, but hasn't that already been accomplished in this path?
That is if the packets are arriving from the physical NIC, we've already
throttled them by this point. Otherwise, if they are coming via
macvlan_queue_xmit(), it calls either 'dev_forward_skb()', which ends
up calling netif_rx_internal(), or else in broadcast mode there is
to be throttling via macvlan_broadcast_enqueue().

So I suspect there is a code path that I am missing but the netif_rx() call in
question essentially re-queues packets coming from off the box. I've tried the
simple patch below to optimize this path, and obviously performs a lot better
in my limited testing.

Thanks,

-Jason

--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -321,8 +321,8 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
        skb->dev = dev;
        skb->pkt_type = PACKET_HOST;
 
-       ret = netif_rx(skb);
-
+      macvlan_count_rx(vlan, len, true, 0);
+      return RX_HANDLER_ANOTHER;
 out:
        macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
        return RX_HANDLER_CONSUMED;
