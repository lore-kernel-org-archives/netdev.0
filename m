From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Thu, 15 Jan 2004 07:57:56 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401150745390.9658-100000@netcore.fi>
References: <Pine.LNX.4.58.0401141327420.24125@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yoshfuji@linux-ipv6.org, <davem@redhat.com>, <usagi-core@linux-ipv6.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0401141327420.24125@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Wed, 14 Jan 2004, Ville Nuorvala wrote:
> > Please check out draft-thaler-ipv6-ndproxy-xx.txt -- it used ND
> > proxying (similar to proxy ARP).
> 
> Oh yes, true. I actually checked out the draft some months ago...
> (And just re-read it :)
> 
> > I fear this change might break that..
> 
> I don't think it does. Here's why:

You may have misunderstood ND proxying.  It's just basically an
enhanced Proxy ARP which also works with IPv6.  And proxy arp is
implemented in the kernel. See below:
 
> The current proxy ND implementation in the kernel only captures multicast
> NS messages. A unicast NS (i.e. a NUD probe) won't be captured by the
> proxy, in stead it tries to _route_ it to the proxied node.

Practically all ND packets should be proxied, I think.

[...]
> The traditional proxy described in RFC 2461 is a router, what Thaler
> describes is closer to a bridge. The protocol described in Thaler's draft
> can't rely on routing for what it is doing, in stead it must AFAICS bypass
> the routing altogether, either inside the kernel, or by pushing the
> traffic through user space.

No, Thaler's ND proxy is *not* a bridge; functionally, it's quite
close, but from the implementation perspective, it's not.  All the
communication terminates (at the IP layer) at the ND proxy (and that's
why the TTL won't decrease, because practically the same request is
replicated on the other links with TTL=255).  Therefore, it can act as
a "router"  between two physical links, and the users of the links can
still use e.g. link-local addresses.

ND proxy doesn't "route" between physical segments, because by
definition, all the physical segments share a subnet, and there are no
specifics. On the other hand, it duplicates all ICMPv6 ND packets
across the links (unless there is a mapping in a cache), and expands 
the IP layer subnet (even, the link-local address domain!) to span 
multiple links.

> In contrast, since 2 always applies (i.e. you can't route link-locals)
> this patch only removes the unnecessary steps described in 3 before the
> error message is sent.

Proxying link-locals break fully ND proxying.  I grant you that it may 
not work out of the box at the moment (because it hasn't been 
implemented! :-) but we shouldn't be making steps in the wrong 
direction here.. :-)
 
-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
