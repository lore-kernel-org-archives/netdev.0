From: Jussi Peltola <plz@plz.fi>
Subject: [PATCH] Fixup packets with incorrect ethertype sent by ZTE MF821D
Date: Sun, 13 Nov 2016 15:47:53 +0200
Message-ID: <20161113134753.GR2745@pokute.pelzi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.dynaco.fi ([185.82.144.207]:40411 "EHLO
        smtp-out1.dynaco.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933365AbcKMN4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 08:56:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This brokenness appears reliably after running "rdisc6 wwan0" but I have
not debugged if this is related to timing or the format of the router
solicitation. Before receiving a router solicitation, v4 is received
correctly and v6 does not work. After sending the MF821D a router
solicitation with rdisc6, v4 is broken but v6 works. With this patch
(which I am using to write this message) a dual-stack context is usable.

commit 2c25237d19c0c9741c6ebec854def99b88618eac
Author: Jussi Peltola <plz@plz.fi>
Date:   Sun Nov 13 15:41:50 2016 +0200

    Fixup packets with incorrect ethertype sent by ZTE MF821D
    
    Signed-off-by: Jussi Peltola <plz@plz.fi>

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 3ff76c6..edd8172 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -172,6 +172,12 @@ static const u8 buggy_fw_addr[ETH_ALEN] = {0x00, 0xa0, 0xc6, 0x00, 0x00, 0x00};
  * Another common firmware bug results in all packets being addressed
  * to 00:a0:c6:00:00:00 despite the host address being different.
  * This function will also fixup such packets.
+ *
+ * At least the ZTE MF821D sends IPv4 packets with a bogus ethertype
+ * of 0x63bc, 0xe3bc, 0x63bd or 0xe3bd, and bogus source and
+ * destination MACs after it has received an IPv6 router solicitation
+ * (IPv6 is transmitted correctly). This function will also fix up
+ * such packets.
  */
 static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
@@ -195,12 +201,21 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
                        return 0;
                if (is_multicast_ether_addr(skb->data))
                        return 1;
+
                /* possibly bogus destination - rewrite just in case */
                skb_reset_mac_header(skb);
                goto fix_dest;
        default:
                if (rawip)
                        return 0;
+
+               /* Bogus ethertype and src/dst mac for v4 on ZTE MF821D */
+               if ((skb->data[12] & 0x7f) == 0x63
+                && (skb->data[13] & 0xfe) == 0xbc) {
+                       proto = htons(ETH_P_IP);
+                       goto reset_mac;
+               }
+
                /* pass along other packets without modifications */
                return 1;
        }
@@ -213,6 +228,7 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
        if (skb_headroom(skb) < ETH_HLEN)
                return 0;
        skb_push(skb, ETH_HLEN);
+reset_mac:
        skb_reset_mac_header(skb);
        eth_hdr(skb)->h_proto = proto;
        eth_zero_addr(eth_hdr(skb)->h_source);
