From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: tunneling in linux (was: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling)
Date: Sun, 16 Jan 2005 19:55:53 +0100
Message-ID: <20050116185553.GA21739@xi.wantstofly.org>
References: <20050112222437.GC14280@xi.wantstofly.org> <Pine.LNX.4.61.0501130944270.19573@netcore.fi> <20050113092351.GA23170@xi.wantstofly.org> <1105897020.1091.736.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Pekka Savola <pekkas@netcore.fi>,
        shemminger@osdl.org, shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <1105897020.1091.736.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Summarising private thread on netdev.

The main issue under discussion is whether to implement ethernet-over-IP
tunneling by using etherip, or whether using something like GRE would be
better.  The main argument against etherip is that its RFC has
'Informational' status (while the latest GRE RFC I could find, 2784, is
'Proposed Standard'.)

Another argument against etherip would be that OpenBSD apparently
mis-implemented etherip by putting the etherip version nibble in the
second nibble of the etherip header instead of the first, which would
probably prevent the linux and OpenBSD versions from interoperating,
negating the advantage of using etherip in the first place.

All I personally care about is that when I install a random linux distro
two years from now, that ethernet-over-IP tunneling will simply work, using
whatever protocol -- I don't care about which.

Any opinions?


If we do end up using GRE for ethernet tunneling, there's some work that
needs to be done.  For one, ip_gre in its current form would need a certain
amount of hacking for tunneling ethernet frames instead of IPv4/IPv6 as
it does now.  We might as rename it to plain 'gre' and move it out of
net/ipv4/ to net/core/ or something while we're at it.

The way we currently use (f.e. in iproute2) for finding out whether a
given netdevice is a tunnel or not is by looking at ARPHRD_*, but this
scheme breaks down for ethernet tunnels, since there is no other way of
distinguishing them from regular ethernet devices.  We could issue
SIOCGETTUNNEL and see if that succeeds, but that unfortunately aliases
with SIOCDEVPRIVATE which aliases to BOND_ENSLAVE_OLD, SIOCGMSTATS,
EQL_ENSLAVE, FRAD_GET_CONF, SIOCDEVPLIP, SIOCGPPPSTATS and a million
others, so you never know if the netdevice really interpreted it as
SIOCGETTUNNEL or no.

Other things that suck about tunneling?
- If we're going to overhaul the way tunneling works, we should try to
  remove the need for the gre0 interface as well.
- Tunneling over IPv6 should be implemented.
- How to share more code between sit/ipip/gre?

Ideas?



On Sun, Jan 16, 2005 at 12:37:00PM -0500, jamal wrote:

> > > Is there a particular reason why GRE tunnel is not sufficient? 
> > 
> > No particular reason, apart from not being aware that GRE provides
> > this functionality.
> 
> True that GRE can do all this (and they have thought out well the
> broadcasting etc) but i dont think it will harm to push this into the
> kernel if some odd OS like openbsd supports it. 
> 
> cheers,
> jamal
> 
> 
