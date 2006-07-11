From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 10:31:08 +0200
Message-ID: <BAY103-F2177DD2985FD6E92BA8801B2680@phx.gbl>
References: <20060711064232.GA1490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www-test.bay2.hotmail.com ([65.54.246.78]:31443 "EHLO
	bay0-omc1-s6.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1750736AbWGKIbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 04:31:13 -0400
In-Reply-To: <20060711064232.GA1490@gondor.apana.org.au>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Hi Marco:

Hi Herbert, I'm very happy hearing you.

>On Mon, Apr 24, 2006 at 09:23:00AM +0000, Marco Berizzi wrote:
> >
> > What should I do? Mangling MSS with iptables  --set-mss ?
> > Altering MSS to 1440 did the trick. See:
> > http://marc.theaimsgroup.com/?l=linux-netdev&m=114373067423528&w=2
>
>Yes that's enough, although proper PMTU would be better.
>
> > and here is snmp when the sapgui client has told me that the
> > connections has been reset:
> >
> > root@Mimosa:/var/log# cat SNMP-CONN-RESET
> > Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors 
>ForwDatagrams
> > InUnknownProtos InDiscards InDelivers OutRequests OutDiscards 
>OutNoRoutes
> > ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails 
>FragCreates
> > Ip: 1 64 79257 0 31 48139 0 0 38799 56650 2 0 2 182 90 2 90 0 124
>
>OK, the number of reassemblies equals the number of FragOKs.  So it does
>not look like there is a problem within mimosa, i.e., Linux.
>
>I've looked at your packet dumps again and in fact there is not qualitative
>difference between WITHTCPDUMP and WITHOUTTCPDUMP.  What is different is
>that the latter seems to have experienced a higher packet loss rate at an
>early stage and therefore the sender has already backed off to a very long
>retry period.
>
>The fact that tcpdump makes a difference could simply be that it changes
>the timing of the fragment tramissions on mimosa which has an impact on
>the loss rate between mimosa and pleiadi.
>
>We can say these things for certain:
>
>1) The path between mimosa and pleiadi has a packet loss problem.  A small
>    burst of 10 or so fragments is enough to cause at least half of them to
>    be lost.  This problem may be specific to IPsec traffic (ISPs often
>    discriminate against traffic with protocols other than TCP/UDP).
>
>2) Fragmentation exacerbates the packet loss problem because it increases
>    the number of packets and a packet is lost if only one of its fragments
>    is lost.
>
>3) The fact that the TCP connections are not using PMTU causes 
>fragmentation
>    in the presence of IPsec.

What should I do to use PMTU?

>From what I've seen, there does not appear to be a bug in Linux that could
>explain the behaviour change that is seen when you run tcpdump.

Ok, thanks for the explanation. I have a couple of question.

1) If mimosa is switched to klips the problem disappear. Why?
2) I have done another test bypassing pleiadi. Only mimosa is involved.
Here is network schema (I hope it is clear):

customer private network 10.0.0.0/8
|
|
+ipsec customer gateway (nokia/checkpoint)
|==MTU=1444
|
|
|---ipsec tunnel 10.0.0.0/8<->172.29.128.0/28 (3DES/MD5)
|
|
|    +---win_XP + modem 56K + sapgui
|   /
|  /---ipsec tunnel 10.0.0.0/8<->road_warrior_ip(3DES/MD5/IPCOMP)
| /
|/
+upgraded ipsec gateway (mimosa) from klips to 2.6.17.4
|On mimosa I have inserted these this rule:
|Chain POSTROUTING (policy ACCEPT)
|target     prot opt source               destination
|SNAT       all  --  road-warrior-ip         10.0.0.0/8          
to:172.29.128.1
|
|
priv network (172.18.1.0/24)

Now, a windows XPsp2 roadwarrior connect to the internet with a slow 56k
analog modem, get a public dyn ip address, and establish an IPsec tunnel
to mimosa, then mimosa snat the rw dyn ip address to 172.29.128.1
When I try to connect to the sap server I get the same issue: without
tcpdump I get the connection reset, with tcpdump running all is fine.


