From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sat, 21 May 2011 09:11:05 +0800
Message-ID: <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com> <20110412.141645.112604563.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net, jesse@nicira.com, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34955 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600Ab1EUBL1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 21:11:27 -0400
Received: by bwz15 with SMTP id 15so3372526bwz.19
        for <netdev@vger.kernel.org>; Fri, 20 May 2011 18:11:26 -0700 (PDT)
In-Reply-To: <20110412.141645.112604563.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2011 at 5:16 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Jiri Pirko <jpirko@redhat.com>
> Date: Fri, =A08 Apr 2011 07:48:33 +0200
>
>> Now there are 2 paths for rx vlan frames. When rx-vlan-hw-accel is
>> enabled, skb is untagged by NIC, vlan_tci is set and the skb gets in=
to
>> vlan code in __netif_receive_skb - vlan_hwaccel_do_receive.
>>
>> For non-rx-vlan-hw-accel however, tagged skb goes thru whole
>> __netif_receive_skb, it's untagged in ptype_base hander and reinject=
ed
>>
>> This incosistency is fixed by this patch. Vlan untagging happens ear=
ly in
>> __netif_receive_skb so the rest of code (ptype_all handlers, rx_hand=
lers)
>> see the skb like it was untagged by hw.
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>
>> v1->v2:
>> =A0 =A0 =A0 remove "inline" from vlan_core.c functions
>
> Ok, I've applied this, let's see what happens :-)
>

I think we should revert it.

=46ile: net/8021q/vlan_core.c:

161         skb_pull_rcsum(skb, VLAN_HLEN);

skb->data and skb->len are updated, but network_header and
transport_header are left unchanged. This will break the assumption in
net_sched.

  for example:
  file: cls_u32.c
  104         unsigned int off =3D skb_network_offset(skb);
  After this patch, skb_network_offset may be negative.

162         vlan_set_encap_proto(skb, vhdr);
163
164         skb =3D vlan_check_reorder_header(skb);
vlan_check_reorder_header assume skb->dev is a vlan_dev. Even though
the correct dev is assigned temporarily, we should not reorder the
header here as HW accelerated vlan RX does, as this may breaks the
bridging comes later.

165         if (unlikely(!skb))
166                 goto err_free;

The hardware accelerated vlan RX doesn't always do the "right" things
as it strips the vlan header, so we should not emulate it in software
all the time.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
