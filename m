From: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Subject: Re: Ingress tc filters with IPSec
Date: Sat, 30 May 2015 16:51:11 -0400 (EDT)
Message-ID: <1049785273.242077.1433019071636.JavaMail.open-xchange@oxuslxltgw05.lxa.perfora.net>
References: <1432965132.4289.10.camel@jasiiieee.pacifera.com> <1432967091.4289.12.camel@jasiiieee.pacifera.com> <104173314.255471.1433016745917.JavaMail.open-xchange@oxuslxltgw07.lxa.perfora.net>
Reply-To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.196]:60820 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750965AbbE3UvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 May 2015 16:51:12 -0400
Received: from oxuslxltgw05.lxa.perfora.net ([172.19.206.7]) by
 mrelay.perfora.net (mreueus002) with ESMTPSA (Nemesis) id
 0LfiMW-1ZQyWL3k8g-00pOwn for <netdev@vger.kernel.org>; Sat, 30 May 2015
 22:51:11 +0200
In-Reply-To: <104173314.255471.1433016745917.JavaMail.open-xchange@oxuslxltgw07.lxa.perfora.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On May 30, 2015 at 4:12 PM "jsullivan@opensourcedevel.com"
> <jsullivan@opensourcedevel.com> wrote:
>
>
>
> > On May 30, 2015 at 2:24 AM "John A. Sullivan III"
> > <jsullivan@opensourcedevel.com> wrote:
> >
> >
> > On Sat, 2015-05-30 at 01:52 -0400, John A. Sullivan III wrote:
> > > Argh! yet another obstacle from my ignorance. We are attempting ingress
> > > traffic shaping using IFB interfaces on traffic coming via GRE / IPSec.
> > > Filters and hash tables are working fine with plain GRE including
> > > stripping the header. We even got the ematch filter working so that the
> > > ESP packets are the only packets not redirected to IFB.
> > >
> > > But, regardless of whether we redirect ESP packets to IFB, the filters
> > > never see the decrypted packets. I thought the packets passed through
> > > the interface twice - first encrypted and they decrypted. However,
> > > tcpdump only shows the ESP packets on the interface.
> > >
> > > How do we apply filters to the packets after decryption? Thanks - John
> >
> > I see what changed. In the past, this seemed to work but we were using
> > tunnel mode. We were trying to use transport mode in this application
> > but that seems to prevent the decrypted packet contents from appearing
> > again on the interface. Reverting to tunnel mode made the contents
> > visible again and our filters are working as expected - John
>
> Alas, this is still a problem since we are using VRRP and the tunnel end
> points
> are the virtual IP addresses. That makes StrongSWAN choke on selector matching
> in tunnel mode so back to trying to make transport mode work.
>
> I am guessing we do not see the second pass of the packet because it is only
> encrypted and not encapsulated. So my hunch is that we ned to pass the ESP
> packet into the ifb qdisc but need to look elsewhere the packet for the filter
> matching information. We know that matching on the normal offsets does not
> work
> so I am hoping the decrypted packet is decipherable by the filter matching
> logic
> but just still has all the ESP transport header attached.
>
> Normally, to extract the contents of my GRE tunnel, I would place them into a
> separate hash table with the GRE header stripped off and then filter them into
> TCP and UDP hast tables:
>
> tc filter add dev ifb0 parent 11:0 protocol ip prio 2 u32 match ip protocol 47
> 0xff match u16 0x0800 0xffff at 22 link 11: offset at 0 mask 0f00 shift 6 plus
> 4
> eat
>
> So we match the GRE protocol and determine that GRE is carrying an IP packet.
> With the ESP transport header and IV (AES = 16B) interposed between the IP
> header and the GRE header, I suppose the first part of this filter becomes:
>
> tc filter add dev ifb0 parent 11:0 protocol ip prio 2 u32 match ip protocol 47
> 0xff match u16 0x0800 0xffff at 46
>
> but what do I do with the second half to find the start of the TCP/UDP header?
> Is it still offset at 0 because tc filter somehow knows where the interior IP
> header starts or should it be offset at 48 to account for the GRE + ESP
> headers?
> Or is there a better way to filter ingress traffic on GRE/IPSec tunnels?
> Thanks
> - John

Alas, this is not working.  I set a continue action for the ESP traffic:

tc filter replace dev ifb0 parent 11:0 protocol ip prio 1 u32 match ip protocol
50 0xff action continue

and that seems to be matching:

filter parent 11: protocol ip pref 1 u32 fh 802::800 order 2048 key ht 802 bkt 0
terminal flowid ???  (rule hit 3130003 success 2931853)
  match 00320000/00ff0000 at 8 (success 2931853 ) 
	action order 1: gact action continue
	 random type none pass val 0
	 index 1 ref 1 bind 1 installed 294 sec

And I even reduced the GRE filter to just look for the GRE protocol in the IP
header:

tc filter add dev ifb0 parent 11:0 protocol ip prio 2 u32 match ip protocol 47
0xff link 11: offset at 48 mask 0f00 shift 6 plus 4 eat

but it does not appear to be matching at all:

filter parent 11: protocol ip pref 2 u32 fh 800::800 order 2048 key ht 800 bkt 0
link 11:  (rule hit 3130012 success 0)
  match 002f0000/00ff0000 at 8 (success 0 ) 
    offset 0f00>>6 at 48 plus 4  eat 

Any suggestions about how to traffic shape ingest traffic coming off an ESP
Transport connection? Thanks - John
