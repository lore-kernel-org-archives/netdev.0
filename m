From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 04:59:49 +0200
Message-ID: <4DD87C25.4030701@gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com> <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com> <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com> <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, ebiederm@xmission.com
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57176 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430Ab1EVC7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 22:59:54 -0400
Received: by wwa36 with SMTP id 36so5141279wwa.1
        for <netdev@vger.kernel.org>; Sat, 21 May 2011 19:59:53 -0700 (PDT)
In-Reply-To: <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/05/2011 19:54, Jesse Gross a =C3=A9crit :
> On Sat, May 21, 2011 at 6:17 AM, Nicolas de Peslo=C3=BCan
> <nicolas.2p.debian@gmail.com>  wrote:
>> Le 21/05/2011 12:43, Changli Gao a =C3=A9crit :
>>>
>>> On Sat, May 21, 2011 at 3:29 PM, Jiri Pirko<jpirko@redhat.com>    w=
rote:
>>>>
>>>> I do not see a reason why to not emulate that. To make paths as mu=
ch
>>>> similar as they can be, that is the point of this patch.
>>>>
>>>> I think it would be better to fix an issue you are pointing at
>>>> rather that revert this.
>>>>
>>>
>>> In my opinion, the hardware accelerated VLAN RX is just a special c=
ase
>>> of the non hardware accelerated VLAN RX with header reordering. For
>>> promiscuous NICs and bridges, hw-accel-vlan-rx is just disabled.
>>
>> I strongly agree with that.
>>
>> The fact that a skb holds a VLAN tag is not a good enough reason to =
always
>> remove this tag before giving the skb to protocol handlers.
>>
>> If the user ask for VLAN tag removal, we should remove the tag, poss=
ibly
>> using hw-accel untagging if available else software untagging. And i=
f the
>> user doesn't ask for tag removal, we should not untag.
>>
>> In other words, if the user doesn't setup any vlan interface on top =
of
>> another interface, there is no reason to untag the skb : both hw-acc=
el
>> untagging and software untagging should be disabled.
>
> The problem is that for most hardware vlan stripping is actually the
> common case, not the exception.  When you try to disable it frequentl=
y
> there are hidden restrictions that cause problems.  A few examples:
> * Some NICs can't disable stripping at all.
> * Some NICs can only do tag insertion if stripping is configured on r=
eceive.
> * Some NICs can only do hardware offloads (checksum, TSO) if tag
> insertion is used on transmit.
>
> So if you are using vlans then acceleration is pretty much a fact of
> life and the best possible way we can deal with it is to make the
> accelerated and non-accelerated cases behave as similarly as possible=
=2E
>
> Before we were trying to dynamically enable/disable vlan acceleration
> based on whether a vlan group was configured and that worked fine for
> vlan devices because acceleration was enabled for it.  However, it
> caused an endless series of problems for other devices (such as
> bridging while trunking vlans) due to lost tags, driver bugs, and the
> restrictions above.  Some of these can be fixed with driver changes
> but the fact is that dynamically changing behavior just leads to
> problems for the less common cases that are supposedly being fixed.
> It's much better to do the same thing all the time.

Thanks for clarifying.

So, because many limited/buggy hardware exist, we must mimic the behavi=
or in software. 'Sounds good=20
to me.

And because some setups may still require the skb not to be untagged, m=
ay be we need the ability to=20
re-tag the skb in some situations... When a protocol handler or rx_hand=
ler is explicitly registered=20
on a net_device which expect to receive tagged skb, we should deliver t=
agged skb to it... Arguably,=20
this may sound incredible for the general case, but may be required for=
 not-so-special cases like=20
bridge or protocol analyzer.

Of course, I don't say we should always re-tag: if no protocol handler =
nor rx_handler were=20
registered on the parent interface, we don't need the extra work of re-=
tagging.

What I say is that it shouldn't be the job of protocol handlers or rx_h=
andlers that expect the skb=20
to be tagged to fix the improper untagging. A generic feature should do=
 it when necessary.

And all this being said, it doesn't mean that we should pollute __netif=
_receive_skb with special=20
code for vlan handling.

May be, as suggested by Eric W. Biederman in the V1 thread for this pat=
ch, software untagging for=20
the first level of header should happen before __netif_receive_skb if w=
e only try to mimic hardware=20
behavior.

And possible later untagging (due to vlan nesting) should be done gener=
ically inside=20
__netif_receive_skb, using rx_handler when appropriate. This would clea=
nup the general case where no=20
vlan is involved at all.

	Nicolas.
