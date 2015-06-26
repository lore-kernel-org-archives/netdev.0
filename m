From: Phil Hofer <philhofer@igneoussystems.com>
Subject: Re: [PATCH] improve mvneta (Marvell 370) driver TCPv6 performance [1]
Date: Fri, 26 Jun 2015 13:31:09 -0700
Message-ID: <CAEvQe-QUHodbnEB3jhqGn7yRBoNbb-Lvi37xoK7O6XWLeyaUNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Oren Laskin <orenlaskin@igneoussystems.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35137 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbbFZUbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 16:31:10 -0400
Received: by igblr2 with SMTP id lr2so20717360igb.0
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 13:31:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've made some changes based on advice from Willy Tarreau.
The changes don't influence the IPv6 performance numbers on our board
relative to the previous patch. I still get about 90% of IPv4
performance.

Enabling NETIF_F_TSO6 still causes problems; that will probably have
to be addressed in a separate patch. I still haven't figured out why
that breaks the driver.

Signed off: Phil Hofer <philhofer@igneoussystems.com>

diff --git a/drivers/net/ethernet/marvell/mvneta.c
b/drivers/net/ethernet/marvell/mvneta.c
index 5bdf782..3e0a90a 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -338,7 +338,8 @@ struct mvneta_port {
 #define MVNETA_RXD_ERR_LEN             BIT(18)
 #define MVNETA_RXD_ERR_RESOURCE                (BIT(17) | BIT(18))
 #define MVNETA_RXD_ERR_CODE_MASK       (BIT(17) | BIT(18))
-#define MVNETA_RXD_L3_IP4              BIT(25)
+#define MVNETA_RXD_L3_IP               BIT(24)
+#define MVNETA_RXD_IP_HEAD_OK          BIT(25)
 #define MVNETA_RXD_FIRST_LAST_DESC     (BIT(26) | BIT(27))
 #define MVNETA_RXD_L4_CSUM_OK          BIT(30)

@@ -1235,13 +1236,17 @@ static u32 mvneta_txq_desc_csum(int l3_offs,
int l3_proto,
        command =  l3_offs    << MVNETA_TX_L3_OFF_SHIFT;
        command |= ip_hdr_len << MVNETA_TX_IP_HLEN_SHIFT;

+       /* IPv6 packet header checksumming
+        * is not supported, but TCPv6 header
+        * checksumming *is* supported.
+        */
        if (l3_proto == htons(ETH_P_IP))
                command |= MVNETA_TXD_IP_CSUM;
-       else
+       else if (l3_proto == htons(ETH_P_IPV6))
                command |= MVNETA_TX_L3_IP6;

        if (l4_proto == IPPROTO_TCP)
-               command |=  MVNETA_TX_L4_CSUM_FULL;
+               command |= MVNETA_TX_L4_CSUM_FULL;
        else if (l4_proto == IPPROTO_UDP)
                command |= MVNETA_TX_L4_UDP | MVNETA_TX_L4_CSUM_FULL;
        else
@@ -1288,13 +1293,16 @@ static void mvneta_rx_error(struct mvneta_port *pp,
 static void mvneta_rx_csum(struct mvneta_port *pp, u32 status,
                           struct sk_buff *skb)
 {
-       if ((status & MVNETA_RXD_L3_IP4) &&
-           (status & MVNETA_RXD_L4_CSUM_OK)) {
+       /* IPHeadOk will be set for IPv6
+        * and IPv4 packets with proper
+        * checksums.
+        */
+       if ((status & MVNETA_RXD_IP_HEAD_OK) &&
+               (status & MVNETA_RXD_L4_CSUM_OK)) {
                skb->csum = 0;
                skb->ip_summed = CHECKSUM_UNNECESSARY;
                return;
        }
-
        skb->ip_summed = CHECKSUM_NONE;
 }

@@ -3129,7 +3137,7 @@ static int mvneta_probe(struct platform_device *pdev)

        netif_napi_add(dev, &pp->napi, mvneta_poll, NAPI_POLL_WEIGHT);

-       dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
+       dev->features = NETIF_F_SG | NETIF_F_IP_CSUM |
NETIF_F_IPV6_CSUM | NETIF_F_TSO;
        dev->hw_features |= dev->features;
        dev->vlan_features |= dev->features;
        dev->priv_flags |= IFF_UNICAST_FLT;


On Fri, Jun 26, 2015 at 12:57 PM, Phil Hofer
<philhofer@igneoussystems.com> wrote:
> My apologies.
>
> I have a follow-up on the way with some of Willy's suggested changes as well.
>
> On Fri, Jun 26, 2015 at 11:52 AM, Thomas Petazzoni
> <thomas.petazzoni@free-electrons.com> wrote:
>> Hello Phil,
>>
>> On Fri, 26 Jun 2015 11:12:03 -0700, Phil Hofer wrote:
>>> TCP performance over IPv6 was only about 60% of IPv4 performance. This
>>> patch makes up most (but not all) of the difference.
>>>
>>> Signed off by: Thomas Petazzoni (thomas.petazzoni@free-electrons.com)
>>
>> What makes you think you can use my Signed-off-by for a patch that I
>> haven't written? It should be your Signed-off-by here, certainly not
>> mine.
>>
>> Also, the e-mail address should be between <...>, not between (...).
>>
>> Thanks!
>>
>> Thomas
>> --
>> Thomas Petazzoni, CTO, Free Electrons
>> Embedded Linux, Kernel and Android engineering
>> http://free-electrons.com
