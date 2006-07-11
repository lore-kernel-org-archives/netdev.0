From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 16:42:32 +1000
Message-ID: <20060711064232.GA1490@gondor.apana.org.au>
References: <E1FXVdb-0003Tt-00@gondolin.me.apana.org.au> <BAY103-F290B963EE35123CC2E6DB8B2BE0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:64010 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965085AbWGKGmf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 02:42:35 -0400
To: Marco Berizzi <pupilla@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY103-F290B963EE35123CC2E6DB8B2BE0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marco:

On Mon, Apr 24, 2006 at 09:23:00AM +0000, Marco Berizzi wrote:
> 
> What should I do? Mangling MSS with iptables  --set-mss ?
> Altering MSS to 1440 did the trick. See:
> http://marc.theaimsgroup.com/?l=linux-netdev&m=114373067423528&w=2

Yes that's enough, although proper PMTU would be better.
 
> and here is snmp when the sapgui client has told me that the
> connections has been reset:
> 
> root@Mimosa:/var/log# cat SNMP-CONN-RESET
> Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams 
> InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes 
> ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
> Ip: 1 64 79257 0 31 48139 0 0 38799 56650 2 0 2 182 90 2 90 0 124

OK, the number of reassemblies equals the number of FragOKs.  So it does
not look like there is a problem within mimosa, i.e., Linux.

I've looked at your packet dumps again and in fact there is not qualitative
difference between WITHTCPDUMP and WITHOUTTCPDUMP.  What is different is
that the latter seems to have experienced a higher packet loss rate at an
early stage and therefore the sender has already backed off to a very long
retry period.

The fact that tcpdump makes a difference could simply be that it changes
the timing of the fragment tramissions on mimosa which has an impact on
the loss rate between mimosa and pleiadi.

We can say these things for certain:

1) The path between mimosa and pleiadi has a packet loss problem.  A small
   burst of 10 or so fragments is enough to cause at least half of them to
   be lost.  This problem may be specific to IPsec traffic (ISPs often
   discriminate against traffic with protocols other than TCP/UDP).

2) Fragmentation exacerbates the packet loss problem because it increases
   the number of packets and a packet is lost if only one of its fragments
   is lost.

3) The fact that the TCP connections are not using PMTU causes fragmentation
   in the presence of IPsec.

>From what I've seen, there does not appear to be a bug in Linux that could
explain the behaviour change that is seen when you run tcpdump.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
