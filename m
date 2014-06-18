From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: How is IPv6 dhcp supposed to work?
Date: Wed, 18 Jun 2014 10:18:33 +0200
Message-ID: <53A14B59.2020907@6wind.com>
References: <53A0B617.6070600@candelatech.com> <1403044471.16272.20.camel@dcbw.local> <53A0CC31.6090707@candelatech.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:50173 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756377AbaFRISh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 04:18:37 -0400
Received: by mail-wg0-f46.google.com with SMTP id y10so442468wgg.29
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 01:18:35 -0700 (PDT)
In-Reply-To: <53A0CC31.6090707@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/06/2014 01:16, Ben Greear a =C3=A9crit :
> On 06/17/2014 03:34 PM, Dan Williams wrote:
>> On Tue, 2014-06-17 at 14:41 -0700, Ben Greear wrote:
>>> I'm trying to understand how DHCP for ipv6 is supposed to work.
>>>
>>> I am able to get a global-scope address and prefix from
>>> dhclient, but dhclient is not providing a gateway address.
>>
>> That's because it doesn't; DHCPv6 isn't supposed to be used standalo=
ne
>> for global IPv6 connectivity.  That's what router advertisements are
>> for.  The normal flow is this:
>>
>> 1) your router advertisement provides your prefix, prefix length (eg
>> subnet mask), and default gateway/router
>>
>> 2) your prefix gets combined with your local Interface Identifier (o=
ften
>> your MAC address or a hashed version of your MAC, or delivered via P=
PP,
>> or hashed InfiniBand port GUID, or GRE tunnel address, etc) to provi=
de
>> your global IPv6 address.  See
>> net/ipv6/addrconf.c::ipv6_generate_eui64().
>>
>> 3) the RA can also provide search domains, DNS servers, routes, MTU,
>> etc.
>>
>> 4) if there's anything else your administrator really wants to use D=
HCP
>> for (NTP servers, etc) then they set the M (Managed) or O (Other Con=
fig)
>> bits in the router advertisement.
>>
>> 5) In both cases, that requests that the client run DHCPv6; in M mod=
e
>> you do get a lease from the DHCP server and that address becomes
>> preferred, in the O case no lease is obtained but other options can =
be
>> delivered
>>
>> 6) In all cases, the default gateways (and their respective prioriti=
es)
>> are always delivered by Router Advertisements; there can be multiple
>> default gateways in the broadcast domain for redundancy, and the net=
work
>> administrator sets their relative priority.
>>
>>> I see the dhclient interface doing a Router Solicitation, but
>>> I don't see any answers.
>>>
>>> Are we supposed to run radvd or something like that as well?
>>
>> Yes.  If you're not using static addressing, then you must run radvd=
 to
>> deliver router advertisements to your network.  See 'man radvd.conf'=
 for
>> more information on configuring the additional options that DHCP use=
d to
>> be used for (RDNSS, DNSSL, AdvLinkMTU, route, etc).
>>
>>> Or is there some other automated magic that is supposed to
>>> find the default gateway?
>>
>> Router Advertisements via radvd.  You probably want to evaluate whet=
her
>> you really need DHCPv6 at all, since RA can deliver most of the opti=
ons
>> that people use DHCP for.
>
> Thanks for the detailed answer.  A user told me that 'dhcpv6 didn't w=
ork'.
>
> And it doesn't, but I think maybe they were using the equivalent of r=
advd
> anyway....trying to verify that.
>
> Now, I still have troubles though.  I see the router solicit, and rou=
ter advertisement,
> but 'ip monitor route' doesn't show any default route being added (an=
d neither does
> the route show up in some other way I know to look.)
>
> I'm using routing rules, veth pairs, and such stuff, and have some lo=
cal code
> hacks, so maybe it's my fault.  Don't think I've mucked with IPv6 muc=
h though...
Naive question, what is the value of accept_ra?
cat /proc/sys/net/ipv6/conf/*/accept_ra

See Documentation/networking/ip-sysctl.txt
