From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sat, 21 May 2011 15:17:21 +0200
Message-ID: <4DD7BB61.9050200@gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com> <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com> <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com,
	ebiederm@xmission.com
To: Changli Gao <xiaosuo@gmail.com>, Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57925 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab1EUNRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 09:17:24 -0400
Received: by wwa36 with SMTP id 36so4833466wwa.1
        for <netdev@vger.kernel.org>; Sat, 21 May 2011 06:17:23 -0700 (PDT)
In-Reply-To: <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/05/2011 12:43, Changli Gao a =E9crit :
> On Sat, May 21, 2011 at 3:29 PM, Jiri Pirko<jpirko@redhat.com>  wrote=
:
>>
>> I do not see a reason why to not emulate that. To make paths as much
>> similar as they can be, that is the point of this patch.
>>
>> I think it would be better to fix an issue you are pointing at
>> rather that revert this.
>>
>
> In my opinion, the hardware accelerated VLAN RX is just a special cas=
e
> of the non hardware accelerated VLAN RX with header reordering. For
> promiscuous NICs and bridges, hw-accel-vlan-rx is just disabled.

I strongly agree with that.

The fact that a skb holds a VLAN tag is not a good enough reason to alw=
ays remove this tag before=20
giving the skb to protocol handlers.

If the user ask for VLAN tag removal, we should remove the tag, possibl=
y using hw-accel untagging if=20
available else software untagging. And if the user doesn't ask for tag =
removal, we should not untag.

In other words, if the user doesn't setup any vlan interface on top of =
another interface, there is=20
no reason to untag the skb : both hw-accel untagging and software untag=
ging should be disabled.

Also, the skb should be delivered untagged or tagged to protocol handle=
rs, depending on the=20
particular device the protocol handlers registered at. The same skb mig=
ht need to be delivered=20
tagged to a ptype_all handler registered at eth0 and untagged to a ptyp=
e_base handler registered at=20
eth0.100.

rx_handler still sounds the right place to do software untagging, becau=
se software untagging is a=20
per-device process. A vlan_untagging rx_handler should be installed on =
the devices that have vlan=20
child device and (that lack hw-accel or where hw-accel is disabled). Th=
is would also cause=20
__netif_receive_skb() not to hold any vlan specific code, which is clea=
ner.

I perfectly understand that this might require several rx_handlers per =
device, for advanced setup,=20
but I think for long that several rx_handlers is a powerful feature we =
need.

	Nicolas.
