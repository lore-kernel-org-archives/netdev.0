From: Patrick McHardy <kaber@trash.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version
 of Tomasz's patch set
Date: Mon, 21 Apr 2008 13:45:20 +0200
Message-ID: <480C7E50.3050508@trash.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804192242.33632.tomasz@grobelny.oswiecenia.net> <20080420165742.GA12221@ghostprotocols.net> <200804202212.12283.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38228 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440AbYDULp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 07:45:26 -0400
In-Reply-To: <200804202212.12283.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tomasz Grobelny wrote:
> Dnia Sunday 20 of April 2008, Arnaldo Carvalho de Melo napisa=C5=82:
>> Em Sat, Apr 19, 2008 at 10:42:32PM +0200, Tomasz Grobelny escreveu:
>>>> When the patch failed to compile I thought about those alternative=
s.
>>>> Trying to extend the dccp_skb_cb over and above what is in there w=
ill
>>>> be messy, since the IPv4/v6 parameters are required by other
>>>> subsystems.
>>> If inet{,6}_skb_parm is used only outside DCCP code then why at all
>>> should it be placed in struct dccp_skb_cb taking up quite a lot of
>>> valuable space? Why not put it directly in struct sk_buff? Especial=
ly
>>> that it is present in struct udp_skb_cb, struct tcp_skb_cb as well.
>> Because all this is used in skb->cb[], a scratchpad for protocols to
>> use, we can go back to what we had before, that is to not reserve us=
e
>> for inet6?_skb_parm but be sure to zero it before passing it to IP, =
as
>> we don't want IP to be confused with things being non zero there. Th=
en
>> we can use all its space.
>>
> Several questions regarding this case:
> 1. What about SCTP? It doesn't have inet6?_skb_parm in it's structure=
 that is=20
> stored in skb->cb. So does it contain a potential bug (that is to be =
fixed)=20
> or is it not needed there or what?

Judging by a quick grep, SCTP only uses the CB on input and
appears to be fine.

> 2. If the sole purpose of this change was to keep skb->cb zeroed then=
 it=20
> doesn't seem to me like the right solution. Wasting about 20 bytes in=
stead of=20
> zeroing them when needed I would consider at least weird. I understan=
d that=20
> TCP and UDP may have enough space left but it just turned out that DC=
CP=20
> doesn't.

It was the safest solution that late in a release. It also
avoids to memset the cb unnecessarily. If the room is not
enough anymore, its easy to go back to using memset.

> 3. If it's IP layer that needs zeroes then why not clear skb->cb in I=
P layer?

That would certainly work, but it adds unnecessary costs for
the other protocols that don't need this.
