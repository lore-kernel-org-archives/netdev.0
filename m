From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] netdev_ops
Date: Fri, 11 Jul 2003 15:32:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711193215.GH16037@gtf.org>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com> <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, greearb@candelatech.com,
   "David S. Miller" <davem@redhat.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
Content-Disposition: inline
In-Reply-To: <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Comments:

1) The _ops are either too limited in scope, or too wide in scope.

We have a bunch of function pointers in struct net_device.
We are adding a bunch more func ptrs in a new struct foo_ops.

If it is called ethtool_ops, I can support the addition of
	struct ethtool_ops *etops;
to struct net_device.

However, if we call it netdev_ops, the structure's name no longer
describes its purpose.  If we call it netdev_ops, we should move ALL the
function pointers in struct net_device into netdev_ops as well, and deal
with the associated driver breakage.

So, either change the name back to ethtool_ops, or go all the way.
The current name to me implies a job half-done.

Personally, I would prefer the more radical "move all funcptrs into
netdev_ops".  This is closer to other Linux kernel APIs.


2) Yes, we do want a feature macro for this.

David, I respectfully disagree with "no back compat" type arguments.
Besides h/w vendors who want to support distros currently in the field
(read: not the latest kernel), _I_ am personally impacted by API
divergence.  As I have said (and proven) many times, I personally spend
time keeping the more popular ethernet drivers in sync, 2.4 <-> 2.5.
Each time a 2.5-specific change is added that is not easily massaged by
a back compat macro, it costs me time.  Hand-applying patches is not fun.

2.a) There is established precedent:  grep for HAVE_xxx in netdevice.h
and look at the ton of hits you get.

2.b) If #1 is decided to be ethtool_ops, create HAVE_ETHTOOL_OPS macro

2.c) If #2 is decided to be netdev_ops, and all func ptrs are moved into
netdev_ops struct, then create the macro
	SET_NETDEV_OPS(dev, ops)

This allows full back compat, without ugliness in mainline tree.


3) The func ptrs _count() are totally bogus.  We have an unconditional
indirect reference to a function call which does nothing but return a
driver constant.

I personally think that having ethtool_ops members manually calling
the ->get_drvinfo hook is a _lot_ cleaner than 10,000 foo_count hooks.

3.a) Further, we will inevitably be adding more counts in the future.
If we wanted to be truly expandable, and you really don't like the
counts being in struct ethtool_gdrvinfo, then create a struct
ethtool_counts that puts all the constants in one place.


4) I don't see why ethtool.h suddenly needs to include linux/types.h,
when it hasn't needed it in all this time until now.


5) net/socket.c changes appear unrelated to this patch.


6) (low prio)  Add documentation to
Documentation/networking/netdevices.txt.  Most importantly, this
documents locking/context.


7) (low prio)  All that similar code in net/core/ethtool.c can be
template-ized with a macro, IMO.  Something like
  DEF_ETHTOOL_GOP(get_coalesce, ETHTOOL_GCOALESCE, ethtool_coalesce);
  DEF_ETHTOOL_SOP(set_coalesce, ethtool_coalesce);
  (and templates for the ops that use edata)


8) (security)  get-eeprom op needs to check that offset+len is not
invalid, and does not wrap.


9) phys_id op should return an error, for consistency if nothing else.
It's simple for driver authors to unconditionally return 0 if their code
has no failure cases, and it's a slow path so adding the return in the
driver code is no big deal.


10) (low prio) since it's a slow path, what about replacing the switch
statement in dev_ethtool() with a lookup table?  All the ethtool
commands are low numbers.  If you do this, I would suggest using the gcc
array initializer syntax:
	[ETHTOOL_GCOALESCE, ethtool_get_coalesce]

All the ethtool ops have the same prototype, after all.


Comments?
