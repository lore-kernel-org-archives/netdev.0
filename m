From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: wrt. core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()
Date: Mon, 9 Sep 2013 19:14:56 -0700
Message-ID: <CAHo-OoysAJRagNagE4KF-5AXyFHt+X8tahmnRfgaNhww6V-ifw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux NetDev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Isaku Yamahata <yamahata@valinux.co.jp>, decot@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f176.google.com ([209.85.128.176]:41967 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753Ab3IJCO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 22:14:56 -0400
Received: by mail-ve0-f176.google.com with SMTP id jx11so4011422veb.21
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 19:14:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merged in v3.11-rc1:

commit 06a23fe31ca3992863721f21bdb0307af93da807
Author: Isaku Yamahata <yamahata@valinux.co.jp>
Date:   Tue Jul 2 20:30:10 2013 +0900

    core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()

    The dev_forward_skb() assignment of pkt_type should be done
    after the call to eth_type_trans().

    ip-encapsulated packets can be handled by localhost. But skb->pkt_type
    can be PACKET_OTHERHOST when packet comes via veth into ip tunnel device.
    In that case, the packet is dropped by ip_rcv().
    Although this example uses gretap. l2tp-eth also has same issue.
    For l2tp-eth case, add dummy device for ip address and ip l2tp command.

    ...

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1659,6 +1659,12 @@ int dev_forward_skb(struct net_device *dev,
struct sk_buff *skb)
        }
        skb_scrub_packet(skb);
        skb->protocol = eth_type_trans(skb, dev);
+
+       /* eth_type_trans() can set pkt_type.
+        * clear pkt_type _after_ calling eth_type_trans()
+        */
+       skb->pkt_type = PACKET_HOST;
+
        return netif_rx(skb);
 }
 EXPORT_SYMBOL_GPL(dev_forward_skb);

Appears to me to be bogus.

AFAICT, this results in (at least) veth devices effectively ignoring
destination mac addresses,
since eth_type_trans is what sets PACKET_BROADCAST/MULTICAST/HOST/OTHERHOST,
and this makes everything functionally equivalanet to having a dst mac
address equal to the devices mac address.

(might also affect macvlan and L2TP)

- Maciej
