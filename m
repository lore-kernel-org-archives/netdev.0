From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Tue, 16 Jan 2007 11:08:51 +0300
Message-ID: <45AC8813.9000204@tls.msk.ru>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru> <20070115201001.GA9510@gondor.apana.org.au> <45ABF620.3070405@tls.msk.ru> <20070116032739.GA12746@gondor.apana.org.au> <20070116033849.GA12856@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:21436 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932444AbXAPII7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 03:08:59 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20070116033849.GA12856@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Jan 16, 2007 at 02:27:39PM +1100, Herbert Xu wrote:
>> I'm sorry but this dump does NOT look like it was taken from an
>> intermediate box.  I verified two bad checksums (chosen randomly)
>> and they were both correct but partial checksums.  This means that
>> this dump was most likely taken from the sending host.
> 
> I did see one strange bit:
> 
> 02:39:51.758803 IP (tos 0x0, ttl  63, id 41084, offset 0, flags [DF], length: 102) 192.168.1.1.25 > 81.13.94.6.21350: FP [bad tcp cksum 81b0 (->9ee8)!] 4271854025:4271
> 854075(50) ack 3772789166 win 272 <nop,nop,timestamp 145420525 6279830>
>         0x0000:  4500 0066 a07c 4000 3f06 2a59 c0a8 0101  E..f.|@.?.*Y....
>         0x0010:  510d 5e06 0019 5366 fe9f 51c9 e0e0 31ae  Q.^...Sf..Q...1.
>         0x0020:  8019 0110 81b0 0000 0101 080a 08aa f0ed  ................
>         0x0030:  005f d296 3235 3020 322e 302e 3020 4f6b  ._..250.2.0.0.Ok
>         0x0040:  3a20 7175 6575 6564 2061 7320 3631 3345  :.queued.as.613E
>         0x0050:  4137 4637 440d 0a32 3231 2032 2e30 2e30  A7F7D..221.2.0.0
>         0x0060:  2042 7965 0d0a                           .Bye..
> 
> Most of the bad checksums are from 81.13.94.6, which I presume is
> the host you were dumping on.  However, this packet is destined
> for it instead and yet it too has a partial (but correct) checksum.
> 
> So the question is where in your network is 192.168.1.1 and how is
> your network setup in terms of NAT?

This 192.168.* network is internal, and this very packet - I didn't
think it'll be there, but.. hum.

The network looks like this:

               internet
                  |          81.13.94.6 etc
             [ router ]  -  [ DMZ ]
                  |
               [ LAN ] 192.168.1.1 etc

The capture has been made on the router, on the interface which is
connected to a DMZ segment (so no netfilter stuff should be involved
at all; but there's no fancy netfilter setup between dmz and external
inteface, many packets don't even go to conntrack).

81.13.94.6 is a machine in the DMZ segment (it's www.corpit.ru, by the
way).


192.168.1.1 is a machine in LAN.

So the packet you're referring to belongs to a connection between
internal (on LAN) mailserver and a DMZ mailserver - and that one, --
at least I didn't think about capturing *that* traffic.  At least
most of the packets were between dmz and external interface.  That
to say - 192.168.1.1 machine also has this problem (as I mentioned
before - it happens on several different machines with different
kernels (all are 2.6.19 still - it doesn't happen with 2.6.18 or
before)), but it wasn't the main machine I did the testing on.

Ok.  Here's another trace, from that remote network that triggers
this thing more-or-less reliable (every 2nd transfer at least) --
http://www.corpit.ru/mjt/bh-bad-cksum-dmp.bin . It's a full session
between 216.168.29.244 - the requesting/receiving side -- and
81.13.94.6 -- our sending side (the file being transferred is some
trojan horse I found on a friend's PC, so be careful ;)

The last packet(s) -- they're repeated many times, ad infinitum,
because the receiving side discards incorrectly checksummed packets
and thus never sees the final part of the data -- here it's as
captured on the router (above, included in the trace):

10:52:35.702649 IP (tos 0x0, ttl  64, id 61117, offset 0, flags [DF], proto: TCP (6), length: 82)
 81.13.94.6.80 > 216.168.29.244.55354: FP, cksum 0x9185 (incorrect (-> 0x5c56),
 140062:140092(30) ack 125 win 2896 <nop,nop,timestamp 12118000 265951653>

And here it is again, captured on the RECEIVING side (on 216.168.29.244):

07:52:35.816545 IP (tos 0x0, ttl  48, id 61117, offset 0, flags [DF], proto: TCP (6), length: 82)
 81.13.94.6.80 > 216.168.29.244.55354: FP, cksum 0x9185 (incorrect (-> 0x5c56),
 140062:140092(30) ack 125 win 2896 <nop,nop,timestamp 12118000 265951653>

(the only difference in headers I see is in the TTL, which is expectable).

The transfer never finishes, it sits at 98% or so.  On the receiving side
(which is running FreeBSD), "bad checksums" statistics counter increases with
every FP packet.  It also makes no difference whenever tcpdump is running on
either side or on an intermediate host or not.

Thanks!

/mjt
