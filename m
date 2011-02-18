From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 19:47:26 +0100
Message-ID: <20110218184725.GA2602@psychotron.redhat.com>
References: <20110218132524.GC2939@psychotron.redhat.com>
 <1298035791.6201.56.camel@edumazet-laptop>
 <20110218141456.GD2939@psychotron.redhat.com>
 <1298039252.6201.66.camel@edumazet-laptop>
 <4D5E8655.5070304@trash.net>
 <20110218145850.GF2939@psychotron.redhat.com>
 <4D5E953F.6010606@trash.net>
 <1298045670.6201.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	fubar@us.ibm.com, nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757076Ab1BRSsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 13:48:18 -0500
Content-Disposition: inline
In-Reply-To: <1298045670.6201.73.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Feb 18, 2011 at 05:14:30PM CET, eric.dumazet@gmail.com wrote:
>Le vendredi 18 f=E9vrier 2011 =E0 16:50 +0100, Patrick McHardy a =E9cr=
it :
>> On 18.02.2011 15:58, Jiri Pirko wrote:
>> > Fri, Feb 18, 2011 at 03:46:45PM CET, kaber@trash.net wrote:
>> >> Am 18.02.2011 15:27, schrieb Eric Dumazet:
>> >>> Le vendredi 18 f=E9vrier 2011 =E0 15:14 +0100, Jiri Pirko a =E9c=
rit :
>> >>>
>> >>>> Do not know how to do it better. As for percpu variable, not on=
ly
>> >>>> origdev would have to be remembered but also probably skb point=
er to
>> >>>> know if it's the first run on the skb or not. Can't really figu=
re out a
>> >>>> better solution. Can you?
>> >>>
>> >>> I'll try and let you know.
>> >>
>> >> Why not simply do a lookup on skb->iif?
>> >=20
>> > Well I was trying to avoid iterating over list of devices for each
>> > incoming frame.
>> >=20
>>=20
>> Well, there are a couple of holes on 64 bit, perhaps you can rearran=
ge
>> things and eliminate either iif or input_dev without increasing size
>> since they appear to be redundant.
>
>Jiri
>
>I dont understand why netif_rx() is needed in your patch.

I used netif_rx() because bridge and macvlan does that too. I did not s=
ee
a reason to not to do the same.

>
>Can we stack 10 bond devices or so ???
>
>If we avoid this stage and call the real thing (netif_receive_skb()),
>then we dont need adding a field in each skb, since it can be carried =
by
>a global variable (per cpu of course)
>
I'm probably missing something. How do netif_receive_skb() and
netif_rx() differ in this point of view, since both are calling:
"ret =3D enqueue_to_backlog(skb, cpu, &rflow->last_qtail);"
?

Still I see a problem with the percpu global variable. We would have to
store skb pointer there as well and in each __netif_receive_skb() call =
it
would have to be checked if it's different from the current one.
In that case store new skb and orig_Dev.

Leaving aside that global variables are evil in general, I still think
this is not nicer solution then to add skb->input_dev (although I
understand your arguments).


>bond_handle_frame() being called from __netif_receive_skb() I believe =
it
>can use netif_receive_skb() instead of netif_rx().
>
>Same remark for vlan_on_bond_hook()
>
>
>
