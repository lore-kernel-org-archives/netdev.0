From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPsec and Path MTU
Date: Thu, 17 Jun 2004 15:29:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617152921.730892c7.davem@redhat.com>
References: <20040615124334.GA25164@gondor.apana.org.au>
	<20040616195653.GC29781@ms2.inr.ac.ru>
	<20040616231317.GA5742@gondor.apana.org.au>
	<20040617190158.GA10925@ms2.inr.ac.ru>
	<20040617213832.GC14089@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040617213832.GC14089@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Jun 2004 07:38:32 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Suppose that the MTU of 192.168.0.1 is 1500, and that the calculated MTU
> for the bundle is 1430.
> 
> If there is a host 10.10.10.10 on the Internet or behind some sort
> a VPN where the path from 192.168.0.1 to it has an MTU of 1200,
> then by sending a 1430-byte packet to 10.10.10.10 from 192.168.0.2,
> we will get back an ICMP packet saying that the largest MTU for
> 192.168.0.2-10.10.10.10 is 1200.
> 
> This will be successfully stored in the route entry.  But the route
> entry's MTU is not used at all since the MTU of the bundle is deduced
> from the MTU of the path, 192.168.0.1.  So we'll continue to send large
> packets to 10.10.10.10.

This is what Alexey is talking about.  When we send a packet out for
an IPSEC rule, we have to remember the inner (per-transform pre-tunnel)
IP addresses (keyed by outer IP address and ESP/AH spi) in order to get
the ICMP PMTU messages handled correctly.  We don't do this right now,
it's difficult and complicated work.

Tunnels are where do absolutely the wrong thing right now and PMTU does
not work.

What happens in your example is:

	PACKET
	 transformed to --> [new IP hdr, ESP][Transformed PACKET]

ICMP's come back addressed to the IP address in "new IP hdr"
above.  We need a way to go from that, plus the ESP spi, to the
inner transformed IP header information.

That is the missing link, and what we're not doing now.

It's an issue not specific to making the gateway be the sender of
the packet, it's an issue with tunnels in all cases currently.
