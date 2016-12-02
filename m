From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: arp_filter and IPv6 ND
Date: Fri, 2 Dec 2016 19:39:34 +0100
Message-ID: <96111ae8-9b68-943f-c9be-8fccdd614c8b@stressinduktion.org>
References: <CAAeewD82Lfo7c=vLHR7p3oxJ8d0OgWrijKmNn8EPFKq7fN7AMg@mail.gmail.com>
 <3bf09622-afa5-506c-8407-e3e1a70341c0@stressinduktion.org>
 <CAAeewD_2tfNHhWmtwXb_28DicmipReimRvGqv1Q6PQ0AjkBPGw@mail.gmail.com>
 <cead0544-5a5b-ccd0-e02d-abb44a41c054@stressinduktion.org>
 <CAAeewD_erNdBw-zjPP9iFuju6FDgAgWrMKhMXPb58nqa0r22rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Saku Ytti <saku@ytti.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59002 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752006AbcLBSji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:39:38 -0500
In-Reply-To: <CAAeewD_erNdBw-zjPP9iFuju6FDgAgWrMKhMXPb58nqa0r22rA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 02.12.2016 18:51, Saku Ytti wrote:
> On 2 December 2016 at 18:45, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> 
>> next-hop-self attribute on your neighbor in that direction? BGP in
>> general doesn't lead to ND entry installs, protocols like IS-IS afair
>> can short circuit here.
> 
> That's the whole problem, Linux does not think of ND or ARP as
> interface specific thing, but as global thing. ND and ARP will happily
> answer to query from any interface if any other interface has said IP.
> I'm not sure why the Loopback ended up in Cisco ND Cache, answer is
> either Cisco queried for it or Linux did gratuitous answer. I believe
> gratuitous.
> 
>> Hmm, I would keep the Loopback announcements out of the BGP.
> 
> It's extremely common way to do anycast, but not interesting for the
> topic at hand.

Okay, sorry, I understood that you terminate the bgp sessions on those
IPs and use them for router-ids. But they are merely service IPs bound
to the loopback interface. I take it back and even for end system bgp
speakers/service announcement that is fine.

>> For enterprise and cloud stuff it is certainly very surprising, as some
>> isolations don't work as expected. OTOH it is really easy to build up
>> home networks and things are more plug and play.
> 
> Can you give me practical example when the behaviour is desirable, my
> imagination is failing me. I'm not arguing, I just want to understand
> it, as I've never had the need myself.

The major difference is that you e.g. keep connectivity in some
scenarios where strong end systems would fail.

E.g. you can use IP addresses bound to other interfaces to send replys
on another interface. This can be useful if you have a limited amount of
IP addresses on the system but much more interfaces. Especially if they
are limited in scope, like in IPv6.

Basically Cisco's feature of "unnumbered interface" is always provided
in Linux. And there are certainly cases where you would want to use it,
e.g. emulate private-vlan feature for network separation.

Also in the BGP setup, you might have it easier to establish loopback
neighbor contact by just using static on-link routes, without caring
about more complex numbering there (otherwise you pretty soon introduce
OSPF or some other routing protocol to do the recursive forward resolution).

> I've never ran into setup which needs it, but cursory googling shows
> several people having broken networks because of the behaviour. If it
> is needed, I'm sure it's esoteric setup and perhaps saner default
> would that extra sysctl config is needed to get this interface
> agnostic ARP/ND behaviour.

Yes, it is a very problematic situation at internet exchanges and weak
end behavior must be disabled there as it causes havoc.

As global IPv6 addresses are more or less global, such problems actually
shouldn't exist, as no conflicting IP addresses should show up. Link
Local addresses are anyway handled in a strong end manner. Thus if the
Cisco router would install your routing entry you would probably not
have noticed. :)

>> Some RFCs require that for some router implementations (CPE), on the
>> other hand weak end model in Linux was probably inherited by IPv4. The
>> addition of duplicate address detection (which of course only makes
>> sense in strong end systems) to IPv6, basically shows that IPv6 is more
>> or less designed to be a strong end system model.
>>
>> Anyway, a patch to suppress ndisc requests on those interfaces will
>> probably be accepted.
> 
> Grand, not that I feel comfortable writing it. I'd rather see the
> whole suppression functionality moved to neighbour.c from being AFI
> specific.

Yes sure, please provide a patch. A separate sysctl is necessary anyway
because the current one is within the ipv4 procfs directory hierarchy.

Bye,
Hannes
