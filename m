From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: IPv6 over firewire
Date: Sat, 12 Jan 2013 15:37:55 +0100
Message-ID: <20130112153755.3fd96d58@stein>
References: <50EF1AEB.1080704@gmail.com>
	<20130110210912.09c62d38@stein>
	<50F10E94.9090302@gmail.com>
	<20130112102452.13babc65@stein>
	<50F140F7.60503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:59825 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab3ALOiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 09:38:14 -0500
In-Reply-To: <50F140F7.60503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 12 Stephan Gatzka wrote:
> > Or the (optional!) callback could be a new member of struct ndisc_options.
> 
> Hm, right now I have no opinion on that. Where does
> whatever_type *callback comes from? Is it an exported method of the 
> firewire net driver or the new function pointer in struct netdevice?

The networking core or IPv6 core would never ever use an EXPORT() from an
interface driver like firewire-net or from a bus architecture driver like
firewire-core.

The interface driver uses definitions and declarations from the networking/
IP/ ARP... core:
  - functions implemented in the core and EXPORTed from there,
  - data types defined in core headers and filled with data by the
    interface driver,
  - callback function types defined in core headers, used in data types
    which are defined in core headers; respective callbacks implemented in
    interface drivers, pointers to the implementations filled in by the
    interface drivers into respective data objects.
So the firewire-net bridge driver uses the firewire-core API below it and
the networking and IP APIs above it.

Whether a callback is needed at all is not obvious to me.  If one is
needed, then it is not obvious to me whether it should be reachable via a
function pointer in struct net_device, or via a function pointer in one of
the pointer table structs that are appended to struct net_device, or via a
function pointer in e.g. struct ndisc_options, or via a function pointer
typed argument of a function which is EXPORTed by the networking/ IPv6
core.

> > However, does net/ipv6/ndisc.c really need to be aware of the RFC 3146
> > Neighbor Discovery related packet header layouts?  Isn't it possible to
> > rewrite these headers in-place in drivers/firewire/net.c?
> 
> 
> Yes, it it possible, but yoshfuji strongly voted against rewriting ndisc 
> packets in firewire net driver to maintain extensibility to protocols. 
> Especially IPSEC can just not work if I rewrite the packets in the driver.

OK, then net/ipv6/ndisc.c shall be taught to write (and read?) those
packets, and drivers/firewire/net.c shall fill in all data that are going
to be needed by ndisc.c into new arguments of existing or new exported
core functions, or into new members of whichever networking struct
would be most suitable for that.  Or the networking core gets to those
data indirectly by calling a callback.

Apparently the Linux IPv6 core needs to learn a little bit about RFC 3146.
But it doesn't need to (and should not) learn anything about the Linux
IEEE 1394 implementation, that's what I am trying to convey. :-)
-- 
Stefan Richter
-=====-===-= ---= -==--
http://arcgraph.de/sr/
