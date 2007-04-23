From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 14:17:06 -0700 (PDT)
Message-ID: <20070423.141706.92341313.davem@davemloft.net>
References: <20070423132719.b7cf1c9e.akpm@linux-foundation.org>
	<20070423.133730.115642229.davem@davemloft.net>
	<20070423135639.26ca125a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44633
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754218AbXDWVQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 17:16:59 -0400
In-Reply-To: <20070423135639.26ca125a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 23 Apr 2007 13:56:39 -0700

> On Mon, 23 Apr 2007 13:37:30 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Mon, 23 Apr 2007 13:27:19 -0700
> > 
> > > On Mon, 23 Apr 2007 13:18:10 -0700 (PDT)
> > > David Miller <davem@davemloft.net> wrote:
> > > 
> > > > From: Andrew Morton <akpm@linux-foundation.org>
> > > > Date: Mon, 23 Apr 2007 13:07:34 -0700
> > > > 
> > > > > The interesting bit is:
> > > >  ...
> > > > > I think I saw the same problem maybe 1.5 weeks ago on this machine, but I
> > > > > didn't have time to investigate further.  So it's not some recent thing.
> > > > 
> > > > My initial reaction is that DNS responses are being lost or dropped
> > > > for some reason.
> > > 
> > > Plausible.   I'll try booting it with the ethernet unplugged.
> > 
> > That won't test the same scenerio.
> > 
> > If the network cable is unplugged, ARP responses won't arrive and
> > therefore sendmsg() calls will return with a host unreachable error.
> > 
> > The situation you need to recreate is specifically UDP packets getting
> > dropped.
> > 
> > The reason I wanted the tcpdump trace is so that we can see whether
> > the problem is UDP packets going out or going in which are being
> > mangled/dropped.
> > 
> > You don't need a hub to get a dump.  Instead you can run a caching
> > named on some other system, configure your FC6 box to use that system
> > for DNS via /etc/resolv.conf, then run tcpdump on the caching named
> > machine.
> 
> hm, fancy.
> 
> 
> 
> I unplugged the cable and the machine booted normally.  Lots of commands
> were hanging when I plugged it back in.
> 
> I plugged the cable back in and on one console ran
> 
> 	tcpdump -l -i eth0
> 
> but of course tcpdump didn't do anything because it wants to do reverse
> lookups.  But interestingly, tcpdump was taking maybe 15 seconds to respond
> to ^c and to killall.  tcpdump was stuck in udp_poll(), like statd was. 
> But I think it's significant that we're not taking signals while in that
> interruptible sleep.
> 
> I am able to ping the test machine from another host on the same network.
> 
> On the test machine I used `tcpdump -l -n -i eth0' and on another vt, ran
> `ping www.google.com'.  The test machine is 172.18.116.155
> 
> 13:40:53.755997 IP 172.18.116.155.32806 > 172.24.0.7.domain:  42807+ A? www.google.com. (32)

...

no reply from 172.24.0.7

> 13:40:58.751949 IP 172.18.116.155.32807 > 172.25.146.107.domain:  42807+ A? www.google.com. (32)

...

no reply from 172.25.146.107

> so it looks like we tried to send the query but we didn't see anything come back.

Right.
> 
> Is nscd the caching named which you're referring to?

I would respond, but I first checked how many responses show up when
giving "caching named fedora" to google, and decided that you can
figure it out yourself :-)

More seriously, you need to install the "caching-nameserver" package
it appears, on Fedora.

nscd is not named, nscd is a part of glibc

named is part of the 'bind' package, you know, the standard DNS daemon
implementation for the past say 15 years or so... 

Aparently this 'caching-nameserver' package will bring in 'bind' plus
some configuration files that will give you a caching nameserver
setup.

You might have to tweak things for bind to allow non-local
connections.  On the machine where you install 'caching-nameserver'
use 127.0.0.1 in /etc/resolv.conf and make sure DNS lookups work, then
you can test on the FC6 system by using the other systems's IP
address.

And that's enough sysadmin FAQ'age for me for one day... :-/
