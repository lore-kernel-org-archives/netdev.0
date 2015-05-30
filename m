From: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Subject: Re: Ingress tc filters with IPSec
Date: Sat, 30 May 2015 16:12:25 -0400 (EDT)
Message-ID: <104173314.255471.1433016745917.JavaMail.open-xchange@oxuslxltgw07.lxa.perfora.net>
References: <1432965132.4289.10.camel@jasiiieee.pacifera.com> <1432967091.4289.12.camel@jasiiieee.pacifera.com>
Reply-To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:64757 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756485AbbE3UM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 May 2015 16:12:27 -0400
Received: from oxuslxltgw07.lxa.perfora.net ([172.19.206.9]) by
 mrelay.perfora.net (mreueus001) with ESMTPSA (Nemesis) id
 0Lop6D-1Za1gH0Tbn-00gqNG for <netdev@vger.kernel.org>; Sat, 30 May 2015
 22:12:26 +0200
In-Reply-To: <1432967091.4289.12.camel@jasiiieee.pacifera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On May 30, 2015 at 2:24 AM "John A. Sullivan III"
> <jsullivan@opensourcedevel.com> wrote:
>
>
> On Sat, 2015-05-30 at 01:52 -0400, John A. Sullivan III wrote:
> > Argh! yet another obstacle from my ignorance. We are attempting ingress
> > traffic shaping using IFB interfaces on traffic coming via GRE / IPSec.
> > Filters and hash tables are working fine with plain GRE including
> > stripping the header. We even got the ematch filter working so that the
> > ESP packets are the only packets not redirected to IFB.
> >
> > But, regardless of whether we redirect ESP packets to IFB, the filters
> > never see the decrypted packets. I thought the packets passed through
> > the interface twice - first encrypted and they decrypted. However,
> > tcpdump only shows the ESP packets on the interface.
> >
> > How do we apply filters to the packets after decryption? Thanks - John
>
> I see what changed. In the past, this seemed to work but we were using
> tunnel mode. We were trying to use transport mode in this application
> but that seems to prevent the decrypted packet contents from appearing
> again on the interface. Reverting to tunnel mode made the contents
> visible again and our filters are working as expected - John

Alas, this is still a problem since we are using VRRP and the tunnel end points
are the virtual IP addresses.  That makes StrongSWAN choke on selector matching
in tunnel mode so back to trying to make transport mode work.

I am guessing we do not see the second pass of the packet because it is only
encrypted and not encapsulated.  So my hunch is that we ned to pass the ESP
packet into the ifb qdisc but need to look elsewhere the packet for the filter
matching information.  We know that matching on the normal offsets does not work
so I am hoping the decrypted packet is decipherable by the filter matching logic
but just still has all the ESP transport header attached.

Normally, to extract the contents of my GRE tunnel, I would place them into a
separate hash table with the GRE header stripped off and then filter them into
TCP and UDP hast tables:

tc filter add dev ifb0 parent 11:0 protocol ip prio 2 u32 match ip protocol 47
0xff match u16 0x0800 0xffff at 22 link 11: offset at 0 mask 0f00 shift 6 plus 4
eat

So we match the GRE protocol and determine that GRE is carrying an IP packet.
 With the ESP transport header and IV (AES = 16B) interposed between the IP
header and the GRE header, I suppose the first part of this filter becomes:

tc filter add dev ifb0 parent 11:0 protocol ip prio 2 u32 match ip protocol 47
0xff match u16 0x0800 0xffff at 46

but what do I do with the second half to find the start of the TCP/UDP header?
Is it still offset at 0 because tc filter somehow knows where the interior IP
header starts or should it be offset at 48 to account for the GRE + ESP headers?
Or is there a better way to filter ingress traffic on GRE/IPSec tunnels? Thanks
- John
