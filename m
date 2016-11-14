From: Jussi Peltola <plz@plz.fi>
Subject: Re: [PATCH] Fixup packets with incorrect ethertype sent by ZTE MF821D
Date: Mon, 14 Nov 2016 02:22:18 +0200
Message-ID: <20161114002218.GW2745@pokute.pelzi.net>
References: <20161113134753.GR2745@pokute.pelzi.net>
 <87zil3cq9i.fsf@miraculix.mork.no>
 <20161113172525.GS2745@pokute.pelzi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.dynaco.fi ([185.82.144.207]:41602 "EHLO
        smtp-out1.dynaco.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752264AbcKNAWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 19:22:32 -0500
Content-Disposition: inline
In-Reply-To: <20161113172525.GS2745@pokute.pelzi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So here's another stab. The comments and the current implementation are
not in sync: any non-multicast address starting with a null octet gets
rewritten, while the comment specifically mentions 00:a0:c6:00:00:00. It
is certainly not elegant but re-writing all unicast destinations with
our address does come to mind instead of special cases.

This patch fails to handle the invalid destinations in either way so I
will send another one if you think it's worthwhile to go on. And it
seems I forgot htons but I need this device for work now so a better
patch must wait :)

commit 35d3a46b7f1ece70e24386acbdd16af4507cb5f3
Author: Jussi Peltola <plz@plz.fi>
Date:   Mon Nov 14 01:45:32 2016 +0200

    Attempt to fix up packets with a broken ethernet header
    
    Signed-off-by: Jussi Peltola <plz@plz.fi>

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 3ff76c6..7308d6b 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -153,25 +153,57 @@ static const u8 default_modem_addr[ETH_ALEN] = {0x02, 0x50, 0xf3};
 
 static const u8 buggy_fw_addr[ETH_ALEN] = {0x00, 0xa0, 0xc6, 0x00, 0x00, 0x00};
 
-/* Make up an ethernet header if the packet doesn't have one.
+/* Check if the ethernet header has an unknown ethertype, and return a
+ * guess of the correct one based on the L3 header, or zero if the type was
+ * known or detection failed.
+ */
+static __be16 detect_bogus_header(struct sk_buff *skb) {
+       struct ethhdr *eth_hdr = (struct ethhdr*) skb->data;
+
+       switch (eth_hdr->h_proto) {
+       case ETH_P_IP:
+       case ETH_P_IPV6:
+       case ETH_P_ARP:
+               return 0;
+       default:
+               switch (skb->data[14] & 0xf0) {
+               case 0x40:
+                       return htons(ETH_P_IP);
+               case 0x60:
+                       return htons(ETH_P_IPV6);
+               default:
+                       /* pass on undetectable packets */
+                       return 0;
+               }
+       }
+       /*NOTREACHED*/
+       return 0;
+}
+
+/* Make up an ethernet header if the packet doesn't have a correct one.
  *
  * A firmware bug common among several devices cause them to send raw
  * IP packets under some circumstances.  There is no way for the
  * driver/host to know when this will happen.  And even when the bug
  * hits, some packets will still arrive with an intact header.
  *
- * The supported devices are only capably of sending IPv4, IPv6 and
+ * The supported devices are only capable of sending IPv4, IPv6 and
  * ARP packets on a point-to-point link. Any packet with an ethernet
  * header will have either our address or a broadcast/multicast
- * address as destination.  ARP packets will always have a header.
+ * address as destination. ARP packets will always have a header.
  *
  * This means that this function will reliably add the appropriate
- * header iff necessary, provided our hardware address does not start
+ * header if necessary, provided our hardware address does not start
  * with 4 or 6.
  *
  * Another common firmware bug results in all packets being addressed
  * to 00:a0:c6:00:00:00 despite the host address being different.
- * This function will also fixup such packets.
+ *
+ * Some devices will send packets with garbage source/destination MACs and
+ * ethertypes.
+ *
+ * This function will try to fix up all such packets.
+ *
  */
 static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
@@ -179,8 +211,8 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
        bool rawip = info->flags & QMI_WWAN_FLAG_RAWIP;
        __be16 proto;
 
-       /* This check is no longer done by usbnet */
-       if (skb->len < dev->net->hard_header_len)
+       /* Shorter is definitely invalid and breaks subsequent tests */
+       if (skb->len < 15)
                return 0;
 
        switch (skb->data[0] & 0xf0) {
@@ -190,17 +222,17 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
        case 0x60:
                proto = htons(ETH_P_IPV6);
                break;
-       case 0x00:
+       default:
                if (rawip)
                        return 0;
                if (is_multicast_ether_addr(skb->data))
                        return 1;
-               /* possibly bogus destination - rewrite just in case */
-               skb_reset_mac_header(skb);
-               goto fix_dest;
-       default:
-               if (rawip)
-                       return 0;
+               proto = detect_bogus_header(skb);
+               if (proto) {
+                       /* remove terminally broken header */
+                       skb_pull(skb, ETH_HLEN);
+                       break;
+               }
                /* pass along other packets without modifications */
                return 1;
        }
@@ -208,17 +240,17 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
                skb->dev = dev->net; /* normally set by eth_type_trans */
                skb->protocol = proto;
                return 1;
+       } else {
+               /* push a made-up header */
+               if (skb_headroom(skb) < ETH_HLEN)
+                       return 0;
+               skb_push(skb, ETH_HLEN);
+               skb_reset_mac_header(skb);
+               eth_hdr(skb)->h_proto = proto;
+               eth_zero_addr(eth_hdr(skb)->h_source);
+               memcpy(eth_hdr(skb)->h_dest, dev->net->dev_addr, ETH_ALEN);
+               return 1;
        }
-
-       if (skb_headroom(skb) < ETH_HLEN)
-               return 0;
-       skb_push(skb, ETH_HLEN);
-       skb_reset_mac_header(skb);
-       eth_hdr(skb)->h_proto = proto;
-       eth_zero_addr(eth_hdr(skb)->h_source);
-fix_dest:
-       memcpy(eth_hdr(skb)->h_dest, dev->net->dev_addr, ETH_ALEN);
-       return 1;
 }
 
 /* very simplistic detection of IPv4 or IPv6 headers */
