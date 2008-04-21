From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
	version of Tomasz's patch set
Date: Mon, 21 Apr 2008 10:12:53 -0300
Message-ID: <20080421131253.GB12221@ghostprotocols.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <200804192242.33632.tomasz@grobelny.oswiecenia.net> <20080420165742.GA12221@ghostprotocols.net> <200804202212.12283.tomasz@grobelny.oswiecenia.net> <480C7E50.3050508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755736AbYDUNNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 09:13:04 -0400
Content-Disposition: inline
In-Reply-To: <480C7E50.3050508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Apr 21, 2008 at 01:45:20PM +0200, Patrick McHardy escreveu:
> Tomasz Grobelny wrote:
>> Dnia Sunday 20 of April 2008, Arnaldo Carvalho de Melo napisa=C5=82:
>>> Em Sat, Apr 19, 2008 at 10:42:32PM +0200, Tomasz Grobelny escreveu:
>>>>> When the patch failed to compile I thought about those alternativ=
es.
>>>>> Trying to extend the dccp_skb_cb over and above what is in there =
will
>>>>> be messy, since the IPv4/v6 parameters are required by other
>>>>> subsystems.
>>>> If inet{,6}_skb_parm is used only outside DCCP code then why at al=
l
>>>> should it be placed in struct dccp_skb_cb taking up quite a lot of
>>>> valuable space? Why not put it directly in struct sk_buff? Especia=
lly
>>>> that it is present in struct udp_skb_cb, struct tcp_skb_cb as well=
=2E
>>> Because all this is used in skb->cb[], a scratchpad for protocols t=
o
>>> use, we can go back to what we had before, that is to not reserve u=
se
>>> for inet6?_skb_parm but be sure to zero it before passing it to IP,=
 as
>>> we don't want IP to be confused with things being non zero there. T=
hen
>>> we can use all its space.
>>>
>> Several questions regarding this case:
>> 1. What about SCTP? It doesn't have inet6?_skb_parm in it's structur=
e that=20
>> is stored in skb->cb. So does it contain a potential bug (that is to=
 be=20
>> fixed) or is it not needed there or what?
>
> Judging by a quick grep, SCTP only uses the CB on input and
> appears to be fine.

Thanks for checking!

>> 2. If the sole purpose of this change was to keep skb->cb zeroed the=
n it=20
>> doesn't seem to me like the right solution. Wasting about 20 bytes i=
nstead=20
>> of zeroing them when needed I would consider at least weird. I under=
stand=20
>> that TCP and UDP may have enough space left but it just turned out t=
hat=20
>> DCCP doesn't.
>
> It was the safest solution that late in a release. It also
> avoids to memset the cb unnecessarily. If the room is not
> enough anymore, its easy to go back to using memset.

Nod, if we don't need the space reserved for the lower layer protocols
in DCCP it is actually the best solution, as we don't need to zero the
cb again before passing it to IP, it gets zeroed at alloc_skb time and
that is it. If we need the space, we have to pay the price of
memset before passing to IP.

The rule here is: all layers expect that the CB be zeroed, not all of
it, just the part that it uses. DCCP gets it zeroed, its only fair that
it passes it to IP zeroed, and hey, not all of it, just what IP uses :-=
)

>> 3. If it's IP layer that needs zeroes then why not clear skb->cb in =
IP layer?
>
> That would certainly work, but it adds unnecessary costs for
> the other protocols that don't need this.

Nod again.

- Arnaldo
