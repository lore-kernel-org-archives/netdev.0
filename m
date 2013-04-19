From: hayeswang <hayeswang@realtek.com>
Subject: RE: rtl8168e-vl dropping tftp ack
Date: Fri, 19 Apr 2013 15:49:55 +0800
Message-ID: <55FF74168B2A4152AD875C000535466F@realtek.com.tw>
References: <516EB23B.3080504@canonical.com> <20130417213251.GA13790@electric-eye.fr.zoreil.com> <516FC218.3060002@canonical.com> <20130418215501.GB8944@electric-eye.fr.zoreil.com> <DFF62ECF5DF14C65A71A35581D58FFA9@realtek.com.tw> <20130419061425.GA14843@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Stefan Bader' <stefan.bader@canonical.com>,
	<netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:50758 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756991Ab3DSHuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 03:50:06 -0400
In-Reply-To: <20130419061425.GA14843@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Friday, April 19, 2013 2:14 PM
> To: Hayeswang
> Cc: 'Stefan Bader'; netdev@vger.kernel.org; nic_swsd
> Subject: Re: rtl8168e-vl dropping tftp ack
[...]
> Tentative rationale: the first missing packet (112 at 
> 88.147981) is a 60
> bytes one whose tail does not contain zeroes only. Previous 60 bytes
> packets would exhibit no change of content if they were they 
> generously cut or paded with zeroes.

It still has problem no matter the paded value is zeros or not, because the
length of the IP header would be modified by hw when using hw checksum.

[...]
> 
> I don't get it: arp aside, the normal trace in the capture 
> file exhibits no
> sub-60 bytes packet. Could you reformulate ?
> 

In brief, when the packet < 60, that is skb->len < 60, the hw should pad the
packet to 60 bytes automatically. However, in my memory, the rtl8168e-vl
wouldn't do this, and the packet wouldn't be sent. Therefore, the patch would be
similar with the followings.

--- r8169.c.org 2013-04-19 22:35:40.785759473 +0800
+++ r8169.c     2013-04-19 22:38:24.227189535 +0800
@@ -5760,12 +5760,29 @@ static inline void rtl8169_tso_csum(stru
        } else if (skb->ip_summed == CHECKSUM_PARTIAL) {
                const struct iphdr *ip = ip_hdr(skb);

+               if (unlikely(skb->len < ETH_ZLEN &&
+                   (tp->mac_version == RTL_GIGA_MAC_VER_34))) {
+                       if (skb_padto(skb, ETH_ZLEN))
+                               return false;
+                       skb_checksum_help(skb);
+                       skb_put(skb, ETH_ZLEN - skb->len);
+                       return true;
+               }
+
                if (ip->protocol == IPPROTO_TCP)
                        opts[offset] |= info->checksum.tcp;
                else if (ip->protocol == IPPROTO_UDP)
                        opts[offset] |= info->checksum.udp;
                else
                        WARN_ON_ONCE(1);
+       } else {
+               if (unlikely(skb->len < ETH_ZLEN &&
+                   (tp->mac_version == RTL_GIGA_MAC_VER_34))) {
+                       if (skb_padto(skb, ETH_ZLEN))
+                               return false;
+                       skb_put(skb, ETH_ZLEN - skb->len);
+                       return true;
+               }
        }
 }
