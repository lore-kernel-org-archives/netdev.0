From: Ben Greear <greearb@candelatech.com>
Subject: Re: How is IPv6 dhcp supposed to work?
Date: Tue, 17 Jun 2014 16:16:01 -0700
Message-ID: <53A0CC31.6090707@candelatech.com>
References: <53A0B617.6070600@candelatech.com> <1403044471.16272.20.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:47927 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920AbaFQXQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 19:16:02 -0400
In-Reply-To: <1403044471.16272.20.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2014 03:34 PM, Dan Williams wrote:
> On Tue, 2014-06-17 at 14:41 -0700, Ben Greear wrote:
>> I'm trying to understand how DHCP for ipv6 is supposed to work.
>>
>> I am able to get a global-scope address and prefix from
>> dhclient, but dhclient is not providing a gateway address.
> 
> That's because it doesn't; DHCPv6 isn't supposed to be used standalone
> for global IPv6 connectivity.  That's what router advertisements are
> for.  The normal flow is this:
> 
> 1) your router advertisement provides your prefix, prefix length (eg
> subnet mask), and default gateway/router
> 
> 2) your prefix gets combined with your local Interface Identifier (often
> your MAC address or a hashed version of your MAC, or delivered via PPP,
> or hashed InfiniBand port GUID, or GRE tunnel address, etc) to provide
> your global IPv6 address.  See
> net/ipv6/addrconf.c::ipv6_generate_eui64().
> 
> 3) the RA can also provide search domains, DNS servers, routes, MTU,
> etc.
> 
> 4) if there's anything else your administrator really wants to use DHCP
> for (NTP servers, etc) then they set the M (Managed) or O (Other Config)
> bits in the router advertisement.
> 
> 5) In both cases, that requests that the client run DHCPv6; in M mode
> you do get a lease from the DHCP server and that address becomes
> preferred, in the O case no lease is obtained but other options can be
> delivered
> 
> 6) In all cases, the default gateways (and their respective priorities)
> are always delivered by Router Advertisements; there can be multiple
> default gateways in the broadcast domain for redundancy, and the network
> administrator sets their relative priority.
> 
>> I see the dhclient interface doing a Router Solicitation, but
>> I don't see any answers.
>>
>> Are we supposed to run radvd or something like that as well?
> 
> Yes.  If you're not using static addressing, then you must run radvd to
> deliver router advertisements to your network.  See 'man radvd.conf' for
> more information on configuring the additional options that DHCP used to
> be used for (RDNSS, DNSSL, AdvLinkMTU, route, etc).
> 
>> Or is there some other automated magic that is supposed to
>> find the default gateway?
> 
> Router Advertisements via radvd.  You probably want to evaluate whether
> you really need DHCPv6 at all, since RA can deliver most of the options
> that people use DHCP for.

Thanks for the detailed answer.  A user told me that 'dhcpv6 didn't work'.

And it doesn't, but I think maybe they were using the equivalent of radvd
anyway....trying to verify that.

Now, I still have troubles though.  I see the router solicit, and router advertisement,
but 'ip monitor route' doesn't show any default route being added (and neither does
the route show up in some other way I know to look.)

I'm using routing rules, veth pairs, and such stuff, and have some local code
hacks, so maybe it's my fault.  Don't think I've mucked with IPv6 much though...

Does that router advert below look proper?  I'm going printk diving in
the IPv6 stack in the meantime...


[root@simech2-f17x64 lanforge]# cat pkt.txt
No.     Time        Source                Destination           Protocol Length Info
     34 229.636063  fe80::e4be:86ff:fe27:a33 ff02::1               ICMPv6   110    Router Advertisement from e6:be:86:27:0a:33

Frame 34: 110 bytes on wire (880 bits), 110 bytes captured (880 bits)
Ethernet II, Src: e6:be:86:27:0a:33 (e6:be:86:27:0a:33), Dst: IPv6mcast_00:00:00:01 (33:33:00:00:00:01)
Internet Protocol Version 6, Src: fe80::e4be:86ff:fe27:a33 (fe80::e4be:86ff:fe27:a33), Dst: ff02::1 (ff02::1)
Internet Control Message Protocol v6
    Type: Router Advertisement (134)
    Code: 0
    Checksum: 0x6088 [correct]
    Cur hop limit: 64
    Flags: 0x00
    Router lifetime (s): 300
    Reachable time (ms): 0
    Retrans timer (ms): 0
    ICMPv6 Option (Prefix information : 2001:78::1/64)
        Type: Prefix information (3)
        Length: 4 (32 bytes)
        Prefix Length: 64
        Flag: 0xe0
        Valid Lifetime: 86400
        Preferred Lifetime: 14400
        Reserved
        Prefix: 2001:78::1 (2001:78::1)
    ICMPv6 Option (Source link-layer address : e6:be:86:27:0a:33)
        Type: Source link-layer address (1)
        Length: 1 (8 bytes)
        Link-layer address: e6:be:86:27:0a:33 (e6:be:86:27:0a:33)


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
