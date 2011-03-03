From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: remove skb_share_check in handle_frame
Date: Thu, 03 Mar 2011 09:37:58 +0100
Message-ID: <4D6F5366.7000104@gmail.com>
References: <20110301062250.GB2855@psychotron.redhat.com> <20110301092907.GG2855@psychotron.redhat.com> <20110301203843.GN11864@gospo.rdu.redhat.com> <20110302100354.GB2858@psychotron.brq.redhat.com> <4D6EACF6.2040005@gmail.com> <20110302211238.GC3360@psychotron.redhat.com> <4D6EBC7B.8040502@gmail.com> <20110303061433.GA2835@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	davem@davemloft.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55381 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755545Ab1CCIiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 03:38:02 -0500
Received: by wyg36 with SMTP id 36so816858wyg.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 00:38:01 -0800 (PST)
In-Reply-To: <20110303061433.GA2835@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/03/2011 07:14, Jiri Pirko a =E9crit :
> Wed, Mar 02, 2011 at 10:54:03PM CET, nicolas.2p.debian@gmail.com wrot=
e:
[snip]
>> All those handlers that call netif_rx() or __netif_receive_skb()
>> sound horrible to me. Can you imagine the global overhead of the
>> above receive path?
>>
>> The reason why I suggested you introduce the goto another_round is
>> because most - if not all - stacking configurations could/should be
>> handled simply by returning the right skb from the rx_handler and le=
t
>> __netif_receive_skb() loop. And by having the right orig_dev logic
>> inside __netif_receive_skb(), it could be possible to remove the
>> current vlan_on_bond_hook hack.
>
> Well that wouldn't solve the problem. if we just got anorther_round t=
he
> packed would not be delivered to bond0.100 but only to bond0. That's
> also unwanted. Well, this think shouldn't have been added here in the
> first place :(

Yes, the packet would be delivered "exact match" to bond0, and this is =
what the bonding ARP handler=20
expects, because it registered at this level, then deliver "exact match=
 or NULL" to bond0.100, if=20
appropriate, to whatever other protocol handlers.

There is a subtile difference between ptype_all and ptype_base delivery=
:

- The ptype_all handlers will receive the frame between two call to rx_=
handlers.
- The ptype_base handlers will receive the frame after all rx_handlers =
(and hard coded handlers like=20
vlan) were called.

So a ptype_all handler might receive vlan tagged frame, if it register =
below the interface that=20
untag the frame, while a ptype_base handler will always receive the unt=
agged frame, because=20
ptype_base delivery is done at the end of __netif_receive_skb().

I don't know whether it is desirable, but it used to be required for th=
e bonding ARP monitor to work.

May be we should add some extra properties to protocol handler, so they=
 can tell=20
__netif_receive_skb() what they expect :

- a property to tell whether the protocol handler want the exact frame =
that cross the interface they=20
registered on or the final frame, after all rx_handlers.
- a property to tell what they expect a the orig_dev value : the lowest=
 interface known to=20
__netif_receive_skb() (f_packet) or the interface one level below the i=
nterface they registered on=20
(bonding ARP monitor).

Having those properties, I consider we would be in a position to remove=
 most special hacks we=20
currently have to handle particular stacking configuration.

	Nicolas.
