From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sat, 21 May 2011 10:54:39 -0700
Message-ID: <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, ebiederm@xmission.com
To: =?UTF-8?Q?Nicolas_de_Peslo=C3=BCan?= <nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:48943 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896Ab1EURzA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 13:55:00 -0400
Received: by vxi39 with SMTP id 39so3293253vxi.19
        for <netdev@vger.kernel.org>; Sat, 21 May 2011 10:54:59 -0700 (PDT)
In-Reply-To: <4DD7BB61.9050200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 21, 2011 at 6:17 AM, Nicolas de Peslo=C3=BCan
<nicolas.2p.debian@gmail.com> wrote:
> Le 21/05/2011 12:43, Changli Gao a =C3=A9crit :
>>
>> On Sat, May 21, 2011 at 3:29 PM, Jiri Pirko<jpirko@redhat.com> =C2=A0=
wrote:
>>>
>>> I do not see a reason why to not emulate that. To make paths as muc=
h
>>> similar as they can be, that is the point of this patch.
>>>
>>> I think it would be better to fix an issue you are pointing at
>>> rather that revert this.
>>>
>>
>> In my opinion, the hardware accelerated VLAN RX is just a special ca=
se
>> of the non hardware accelerated VLAN RX with header reordering. For
>> promiscuous NICs and bridges, hw-accel-vlan-rx is just disabled.
>
> I strongly agree with that.
>
> The fact that a skb holds a VLAN tag is not a good enough reason to a=
lways
> remove this tag before giving the skb to protocol handlers.
>
> If the user ask for VLAN tag removal, we should remove the tag, possi=
bly
> using hw-accel untagging if available else software untagging. And if=
 the
> user doesn't ask for tag removal, we should not untag.
>
> In other words, if the user doesn't setup any vlan interface on top o=
f
> another interface, there is no reason to untag the skb : both hw-acce=
l
> untagging and software untagging should be disabled.

The problem is that for most hardware vlan stripping is actually the
common case, not the exception.  When you try to disable it frequently
there are hidden restrictions that cause problems.  A few examples:
* Some NICs can't disable stripping at all.
* Some NICs can only do tag insertion if stripping is configured on rec=
eive.
* Some NICs can only do hardware offloads (checksum, TSO) if tag
insertion is used on transmit.

So if you are using vlans then acceleration is pretty much a fact of
life and the best possible way we can deal with it is to make the
accelerated and non-accelerated cases behave as similarly as possible.

Before we were trying to dynamically enable/disable vlan acceleration
based on whether a vlan group was configured and that worked fine for
vlan devices because acceleration was enabled for it.  However, it
caused an endless series of problems for other devices (such as
bridging while trunking vlans) due to lost tags, driver bugs, and the
restrictions above.  Some of these can be fixed with driver changes
but the fact is that dynamically changing behavior just leads to
problems for the less common cases that are supposedly being fixed.
It's much better to do the same thing all the time.
