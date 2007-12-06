From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: TCP event tracking via netlink...
Date: Thu, 6 Dec 2007 11:28:38 -0200
Message-ID: <20071206132838.GV4653@ghostprotocols.net>
References: <20071205.053031.87154402.davem@davemloft.net> <1196873587.10819.30.camel@localhost> <20071205163338.50aff45d@shemminger-laptop> <20071206.022058.153600766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, joe@perches.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160AbXLFN2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 08:28:54 -0500
Content-Disposition: inline
In-Reply-To: <20071206.022058.153600766.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Dec 06, 2007 at 02:20:58AM -0800, David Miller escreveu:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Wed, 5 Dec 2007 16:33:38 -0500
> 
> > On Wed, 05 Dec 2007 08:53:07 -0800
> > Joe Perches <joe@perches.com> wrote:
> > 
> > > > it occurred to me that we might want to do something
> > > > like a state change event generator.
> > > 
> > > This could be a basis for an interesting TCP
> > > performance tester.
> > 
> > That is what tcpprobe does but it isn't detailed enough to address SACK
> > issues.
> 
> Indeed, this could be done via the jprobe there.
> 
> Silly me I didn't do this in the implementation I whipped
> up, which I'll likely correct.

I have some experiments from the past on this area:

This is what is produced by ctracer + the ostra callgrapher when
tracking many sk_buff objects, tracing sk_buff routines and as well all
other structs that have a pointer to a sk_buff, i.e. where the sk_buff
can be get from the struct that has a pointer to it, tcp_sock is an
"alias" to struct inet_sock that is an "alias" to struct sock, etc, so
when tracing tcp_sock you also trace inet_connection_sock, inet_sock,
sock methods:

http://oops.ghostprotocols.net:81/acme/dwarves/callgraphs/sk_buff/many_objects/

With just one object (that is reused, so appears many times):

http://oops.ghostprotocols.net:81/acme/dwarves/callgraphs/sk_buff/0xffff8101013130e8/

Following struct sock methods:

http://oops.ghostprotocols.net:81/acme/dwarves/callgraphs/sock/many_objects/

http://oops.ghostprotocols.net:81/acme/dwarves/callgraphs/sock/0xf61bf500/

struct socket:

http://oops.ghostprotocols.net:81/acme/dwarves/callgraphs/socket/many_objects/

It works by using the DWARF information to generate a systemtap module
that in turn will create a relayfs channel where we store the traces and
a automatically reorganized struct with just the base types (int, char,
long, etc) and typedefs that end up being base types.

Example of the struct minisock recreated from the debugging information
and reorganized using the algorithms in pahole to save space, generated
by this tool, go to the bottom, where you'll find struct
ctracer__mini_sock and the collector, that from a full sized object
creates the mini struct.

http://oops.ghostprotocols.net:81/acme/dwarves/callgraphs/ctracer_collector.struct.sock.c

And the systemtap module (the tcpprobe on steroids) automatically
generated:

http://oops.ghostprotocols.net:81/acme/dwarves/callgraphs/ctracer_methods.struct.sock.stp

This requires more work to:

. reduce the overhead
. filter out undesired functions creating a "project" with the functions desired using
  some gui editor
. specify lists of fields to put on the internal state to be collected, again using a
  gui or plain ctracer-edit using vi, instead of getting just base types
. Be able to say: collect just the fields on the second and fourth cacheline
. collectors for complex objects such as spinlocks, socket lock, mutexes

But since people are wanting to work on tools to watch state
transitions, fields changing, etc, I thought I should dust off the ostra
experiments and the more recent dwarves ctracer work I'm doing on my
copious spare time 8)

In the callgrapher there are some more interesting stuff:

Interface to see where fields changed:

http://oops.ghostprotocols.net:81/acme/dwarves/callgraphs/sock/0xf61bf500/changes.html

In this page clicking on a field name, such as:

http://oops.ghostprotocols.net:81/acme/dwarves/callgraphs/sock/0xf61bf500/sk_forward_alloc.png

You'll get graphs over time.

Code is in the dwarves repo at:

http://master.kernel.org/git/?p=linux/kernel/git/acme/pahole.git;a=summary

Thanks,

- Arnaldo
