From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 16:15:15 +0100
Message-ID: <20091128151515.GA20476@sch.bme.hu>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com> <1259137434.9191.3.camel@nienna.balabit> <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com> <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from centaur.sch.bme.hu ([152.66.208.5]:49690 "EHLO
	centaur.sch.bme.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbZK1PiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 10:38:09 -0500
Content-Disposition: inline
In-Reply-To: <1259337932.3299.3.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On p, nov 27, 2009 at 11:05:32 -0500, jamal wrote:
> On Fri, 2009-11-27 at 09:26 +0100, KOVACS Krisztian wrote:
> > Hi,
> > 
> > On Thu, 2009-11-26 at 18:19 +0100, Andreas Schultz wrote:
> > > Hi,
> > > 
> > > git bisect shows that TPROXY has been broken by commit
> > > f7c6fd2465d8e6f4f89c5d1262da10b4a6d499d0, [PATCH] net: Fix RPF to work
> > > with policy routing
> > > 
> > > I had a look at the patch, and it seems logical that this would break TPROXY.
> > 
> > Indeed, that's a good catch. If this is indeed the problem you should be
> > able to work it around by disabling rpfilter on the ingress interface.
> > Does it work that way?
> 
> Not familiar with tproxy, but I suspect the system doesnt see the mark
> before policy routing happens. So probably the wrong route cache gets
> created. Easy to validate by dumping the route cache.
> If thats so, you have to set the mark in pre-route hook if it uses
> iptables.

It's already on prerouting, so that's not the problem.

The problem is that for tproxy to work we've used to have a rule like
this:

# ip rule add fwmark 1 lookup 100

plus a few iptables rules setting mark values.

The issue is that previously fib_validate_source ignored the mark set on
the skb, and thus when fib_validate_source() did a FIB lookup, it all went
fine, because it found a result of type RTN_UNICAST. However, with your
change, and because of the ip rule above not being specific enough now
it's returning with type RTN_LOCAL, and that's considered invalid and thus
the skb is dropped.

The workaround is using more specific ip rules that include the ingress
interface name:

# ip rule add dev eth0 fwmark 1 lookup 100

(repeat the above for each interface except lo.)

Andreas, would you mind giving it a try on your system?

-- 
KOVACS Krisztian
