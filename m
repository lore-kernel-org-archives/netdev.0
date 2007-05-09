From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1 take 2] Unified socket storage. (with small bench).
Date: Wed, 9 May 2007 13:57:40 +0400
Message-ID: <20070509095740.GB10028@2ka.mipt.ru>
References: <20070508174331.GA13591@2ka.mipt.ru> <20070508.234828.95506666.davem@davemloft.net> <20070509093443.GA10028@2ka.mipt.ru> <20070509.024445.71552569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57083 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754916AbXEIJ54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 05:57:56 -0400
Content-Disposition: inline
In-Reply-To: <20070509.024445.71552569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 09, 2007 at 02:44:45AM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Wed, 9 May 2007 13:34:43 +0400
> 
> > On Tue, May 08, 2007 at 11:48:28PM -0700, David Miller (davem@davemloft.net) wrote:
> > > One thing that will need to be adjust for current tree is the UDP
> > > hashing mechanism.  But as far as I can tell your code should be able
> > > to handle the new scheme (we now hash UDP by saddr+port when
> > > possible, and this reminds me that IPV6 is broken and needs some
> > > repairs).
> > 
> > Yes, udp with multicast can be a problem, but it can be solved exactly
> > the same way I implemented netlink broadcast (simple solution) -
> > multicast sockets are placed into own list/hash table/trie with special
> > bit in key/whatever and accessed when needed.
> 
> Actually, I am not talking about multicast. :)
> 
> In 2.6.22 what happens now in UDP is that if a non-wildcard rcv_saddr
> is specified, we try to hash using the rcv_saddr and the port.  But
> when binding we have to check first if an existing port+wildcard bind
> exists.
> 
> See __udp_lib_get_port() in Linus's current tree.

I saw that discussion in netdev@, it is a good solution, but it could be
moved further.

> > > What exactly does the 'stages' arg mean?  Is this a method to handle
> > > partially bound sockets?
> > 
> > It is a fallback to select a listening socket, which has remote
> > addr/port as zero, so when socket it selected from tree, lookup wants to
> > first get established socket with given remote identity and if this
> > fails, it tries to select a wildcard one.
> 
> This kind of logic also has implications for UDP. :-)

That is only because we have very different way of working with udp.
In udp hash table we can have multiple sockets bound to different ip
addresses, but with the same port, so it will be placed into the same
hash chain. With trie each socket will have differnet key, since
addresses are different (or bound device number), so it automatically
fixes problem with broken hash for udp (which is a bit fixed with
extended hashing).

User can also specify remote address for given socket (actually
netchannels use this in netfilter implementation), in that case only
given set of ids (remote/local addr/port) will be used to select a 
socket, which can be a some kind of simple netfilter...

-- 
	Evgeniy Polyakov
