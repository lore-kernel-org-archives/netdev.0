From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Wed, 18 Feb 2009 21:21:07 +0000
Message-ID: <1234992067.7692.38.camel@Maple>
References: <200902172001.41804.arvidjaar@mail.ru>
	 <20090217.142946.232071526.davem@davemloft.net>
	 <25143.1234932076@turing-police.cc.vt.edu>
	 <20090217.212919.259912220.davem@davemloft.net>
	 <20090218135537.GF3600@mini-me.lan>
	 <06F54D7E-EE07-49C9-AD8F-B46BD6B02ABA@oracle.com> <499C5486.5020807@hp.com>
	 <499C681A.6000008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Theodore Tso <tytso@mit.edu>, Valdis.Kletnieks@vt.edu,
	arvidjaar@mail.ru, rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:33180 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbZBRVV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 16:21:28 -0500
In-Reply-To: <499C681A.6000008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-18 at 14:57 -0500, Brian Haley wrote: 
> Vlad Yasevich wrote:
> > Having worked in other environments where ipv6 has to be explicitly
> > enabled per interface, I've thought that this level of control was
> > always missing from linux.  
> 
> There does seem to be a sysctl for it, just doesn't seem to work.

While this sysctl is definitely useful, I don't think it meets the needs
of those users and distributions that are currently blacklisting the
ipv6 module.  Even if you disable IPv6 on all interfaces, apps will
still be able to create AF_INET6 sockets, and thus some apps will break
or do inappropriate things because there isn't real IPv6 connectivity.

I've tried to put together an RFC patch that turned off all
externally-visible IPv6 behavior that could break something, but I keep
running into distasteful choices.

The current default behavior must be preserved--if you drop this patch
into an existing distribution, the IPv6 stack must come up the way it
always has.  Thus the knob (let's call it ip6_disable) must default
false.

It seems desirable to make this a per-net-namespace knob.  But that
means each new net will be initialized before the distribution has a
chance to disable the IPv6 part.  This will lead to neighbor solicits
going out for link-local addresses, which some people can't accept.

The only alternative I can think of is to make it a module parameter,
which would leverage people's current habit to disable IPv6 via the
module configuration files, but doesn't fit well into a virtualized
world.

Exactly what to disable is unclear too.  Turning off neighbor and router
solicits, responding to same, etc.--almost certainly.  Refusing to
create AF_INET6 sockets--definitely.  Erroring on ioctl() and netlink
API calls related to IPv6--probably.  Hiding /proc entries for IPv6--I
don't know.  

Ideally, once ip6_disable was set true, every API, /proc and /sys
entries, etc. would look just like the ipv6 module was not loaded.  But
to do this, while still initializing most of the IPv6 code (so that
those hooks from other modules won't do unexpected things) is very
invasive.

So it seems to me that the only practical solution is to live with
blacklisting module ipv6 until the apps are fixed and sending IPv6
packets isn't considered a crime.

  --  John

