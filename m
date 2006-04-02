From: Thomas Zeitlhofer <thomas.zeitlhofer@nt.tuwien.ac.at>
Subject: Re: bridge+netfilter broken for IP fragments in 2.6.16?
Date: Mon, 3 Apr 2006 00:56:25 +0200
Message-ID: <20060402225625.GA22612@swan.nt.tuwien.ac.at>
References: <20060401143011.GA28333@swan.nt.tuwien.ac.at> <443023C2.6020401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932426AbWDBW4b@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <443023C2.6020401@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 02, 2006 at 09:19:30PM +0200, Patrick McHardy wrote:
> Thomas Zeitlhofer wrote:
> > I have set up a bridge with two ports:
> > 
> > # brctl show br0
> > bridge name     bridge id               STP enabled     interfaces
> > br0             8000.000021f23d58       no              eth1
> >                                                         tap1
> > 
> > Using 2.6.16/.1 non fragmented IP packets are passing the bridge without
> > problems, but fragmented IP packets do not show up on the outgoing
> > interface. E.g., for fragmented traffic coming in from tap1 and going
> > out via eth1 tcpdump shows:
> > 
> >   1) on tap1: fragmented packets
> >   2) on br0: the defragmented packet (connection tracking)
> >   3) on eth1: no packet!?
> > 
> > This breaks IPsec connections for example.
> > 
> > 
> > Doing the same on 2.6.15.x shows:
> > 
> >   1) on tap1: fragmented packets
> >   2) on br0: the defragmented packet (connection tracking)
> >   3) on eth1: fragmented packets
> 
> Are you sure this is correct? I think in 2.6.15 you should see
> the fragments on br0 already.

Just verified it, at least in 2.6.15.6 tcpdump shows the defragmented
packet on br0.

> Anyway, since 2.6.16 ip_conntrack doesn't do refragmentation anymore
> but relies on fragmentation in the IP layer. Purely bridged packets
> don't go through the IP layer, so the bridge netfilter code needs to
> take care of fragmentation itself. Please try if this patch helps.

Your patch solves the problem - tcpdump now shows the refragmented
packets on eth1. Thanks for the quick solution.

Just a note, your patch does not work when bridge is compiled as a
module. In this case modprobe failes with "bridge: Unknown symbol
ip_fragment". Using CONFIG_BRIDGE=y works.

> > and IPsec connections are ok.
> 
> This is probably a different issue. 

I don't think so, with your patch IPsec connection can be established
again. The problem was that racoon generates UDP packets of length 2600
during isakmp phase 1 which did not pass the bridge. 

> Please describe your setup (IPsec, NAT and filtering).

The setup here is UML behind tap1 where br0 is used to bridge the
physical interface (eth1) to the UML's eth0 (=> tap1). The IPsec
connection is going from the UML to the outside world over the bridge.
NAT is not used and at the moment filtering is just used for
accounting. So nothing special, only two rules in the FORWARD chain
that accept all traffic in both directions.

--
Thomas
