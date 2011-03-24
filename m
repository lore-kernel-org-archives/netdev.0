From: Andrew Strohman <astrohman@simplexinvestments.com>
Subject: vlan_get_tag()
Date: Thu, 24 Mar 2011 14:11:30 -0500
Message-ID: <AANLkTimg9hAq_ZeCLV1sM830z8T_yZ_-+cVUnYBEfk+M@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-tx1.globalrelay.net ([204.92.49.31]:64871 "EHLO
	mx-extq-a1.globalrelay.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751717Ab1CXTj6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 15:39:58 -0400
Received: from [10.20.0.25] (port=42821 helo=outbound.globalrelay.com)
	by mx-extq-a1.globalrelay.net with esmtp (GlobalRelay ExtQ)
	id 1Q2q7g-00061F-TT
	for netdev@vger.kernel.org; Thu, 24 Mar 2011 19:23:08 +0000
Received: from mail-bw0-f52.google.com ([209.85.214.52]:52109)
	by outbound.globalrelay.com with esmtps (TLSv1:RC4-SHA:128)
	(GlobalRelay MX RX)
	id 1Q2pwm-0002gZ-F2
	for netdev@vger.kernel.org; Thu, 24 Mar 2011 19:11:52 +0000
Received: by bwj24 with SMTP id 24so562510bwj.11
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2011 12:11:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Lately, I was messing around with the linux kernel code, and I wanted
to look up the Vlan ID for a given sk_buff. =A0 Instead of manually
pulling the ID out of the sk_buff object, I used this in
linux/include/linux/if_vlan.h


/**
 327 * vlan_get_tag - get the VLAN ID from the skb
 328 * @skb: skbuff to query
 329 * @vlan_tci: buffer to store vlaue
 330 *
 331 * Returns error if the skb is not VLAN tagged
 332 */
 333static inline int vlan_get_tag(const struct sk_buff *skb, u16 *vlan=
_tci)
 334{
 335        if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
 336                return __vlan_hwaccel_get_tag(skb, vlan_tci);
 337        } else {
 338                return __vlan_get_tag(skb, vlan_tci);
 339        }
 340}



Everything worked fine until I change the CoS value of my packets, and
then all the sudden the VLAN IDs that where returned from this
function were wrong.=A0 I believe I see why:

/**
 306 * __vlan_hwaccel_get_tag - get the VLAN ID that is in @skb->cb[]
 307 * @skb: skbuff to query
 308 * @vlan_tci: buffer to store vlaue
 309 *
 310 * Returns error if @skb->vlan_tci is not set correctly
 311 */
 312static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
 313                                         u16 *vlan_tci)
 314{
 315        if (vlan_tx_tag_present(skb)) {
 316                *vlan_tci =3D vlan_tx_tag_get(skb);
 317                return 0;
 318        } else {
 319                *vlan_tci =3D 0;
 320                return -EINVAL;
 321        }
 322}


#define vlan_tx_tag_get(__skb)          ((__skb)->vlan_tci & ~VLAN_TAG_=
PRESENT)



#define VLAN_TAG_PRESENT        VLAN_CFI_MASK
#define VLAN_CFI_MASK           0x1000 /* Canonical Format Indicator */



So, to me it seems like this function really returns the entire tci
with the CFI bit zeroed out, not the VLAN ID.  Perhaps, instead of
doing:  ((__skb)->vlan_tci & ~VLAN_TAG_PRESENT), it should do
((__skb)->vlan_tci & VLAN_VID_MASK)?

Andy
