From: Andreas Jellinghaus <aj@dungeon.inka.de>
Subject: Re: port-based filtering of ESP packets with in-kernel IPsec?
Date: 30 Jul 2003 16:51:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1059576701.4586.20.camel@simulacron>
References: <1059540296.16545.305.camel@k7.localnet>
	 <20030730142411.GD4553@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netfilter@lists.netfilter.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030730142411.GD4553@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

if you are using ipsec from kernel 2.6.* there is no "ipsec0"
interface, and thus using netfilter isn't as easy as it was with
freeswan.

three ways to solve the problem, only tried the first one so far:
1.) configure ipsec in tunnel mode, add your tunnel ip to 
    the outgoing interface, change the default route to
    set the source ip to the tunnel ip.
note: there is no routing step after encapsulating a packet
with ipsec, there was one with freeswan, so this is different.

2.) set a fwmark on an esp packet, it should be there after
    unpacking/decryption. didn't try this one.

3.) do not use the build in tunneling. use an explicit ipip tunnel.
	that way you have the interface, can use it in netfilter,
	can route into it, and the interface will set the right
	source address.

[netfilter]
incoming encrypted packets are seen as ESP/AH in INPUT
and then as decrypted packet in INPUT or FORWARD.

outgoing packets are only seen as ESP in OUTPUT.

> > Since ESP packets that reach the mangle INPUT chain are destined for a
> > local process, why not unencapsulate them just before that point?  

INPUT only means the ESP will be decrypted/unecapsulated.
after that the decrypted packet will show up in INPUT or FORWARD.

> no. My preferred solution was something like adding a netfilter hook to
> the xfrm4 engine, exactly after decapsulation / decryption of one layer,
> i.e.  after xfrm_type.input was called. 
>
> iptables could then register the INPUT chain (or probably even a
> seperate POSTXFRM chain) in order to filter on the respective packets.

you can already filter incoming packets. The problem is you
don't know if they came in that way they look now, or if they
came in via ESP packets and got decrypted.

maybe decryption/unencapsulating could leave a mark on the
packet, so we know packets without that mark came in without
ipsec and are bad / attempts to access resources without ipsec?
(maybe fwmark works on that. or an explicit ipip tunnel, so you
have "ipip0" or something as incoming interface).

> Any comments are appreciated.

Regards, Andreas
