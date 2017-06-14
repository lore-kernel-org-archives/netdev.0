From: =?UTF-8?Q?Jan_Grash=c3=b6fer?= <jan.grashoefer@gmail.com>
Subject: Receiving raw packets (incl. VLAN tags) on raw sockets
Date: Wed, 14 Jun 2017 14:47:56 +0200
Message-ID: <e06dbb47-2d1c-03ca-4cd7-cc958b6a939e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: aeppert@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:33805 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbdFNMsK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 08:48:10 -0400
Received: by mail-wr0-f182.google.com with SMTP id 77so41142104wrb.1
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 05:48:09 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

trying to ingest packets to a network monitoring tool using AF_Packet, I
noticed that VLAN tags are stripped off even if VLAN offloading is
disabled. As described in [1] the tags are stripped that early in the
receive path that raw sockets do not receive the packets as seen on the
wire. However, the man pages [2] state:

> SOCK_RAW packets are passed to and from the device driver without any
> changes in the packet data.

So at least the docs are wrong here. While the VLAN information is
present in the tpacket_hdr, the packets themselves are manipulated by
the kernel. In my case, for example, I need to pass on each packet (in
form of a packet) and thus would have to reinsert the tag manually,
which is definitely undesirable.

As I am dealing with a monitoring application, the following patch that
disables untagging VLANs in promisc mode fixes the issue for me:

diff --git a/net/core/dev.c b/net/core/dev.c
index 54f8c16..ec5b1c5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4104,8 +4104,9 @@ static int __netif_receive_skb_core(struct sk_buff
*skb, bool pfmemalloc)

        __this_cpu_inc(softnet_data.processed);

-       if (skb->protocol == cpu_to_be16(ETH_P_8021Q) ||
-           skb->protocol == cpu_to_be16(ETH_P_8021AD)) {
+       if ((skb->protocol == cpu_to_be16(ETH_P_8021Q) ||
+           skb->protocol == cpu_to_be16(ETH_P_8021AD)) &&
+           skb->dev->promiscuity < 1) {
                skb = skb_vlan_untag(skb);
                if (unlikely(!skb))
                        goto out;
