From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] netdev_ops
Date: Fri, 11 Jul 2003 21:04:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711200423.GL20424@parcelfarce.linux.theplanet.co.uk>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com> <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk> <20030711193215.GH16037@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com,
   greearb@candelatech.com, "David S. Miller" <davem@redhat.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20030711193215.GH16037@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2003 at 03:32:15PM -0400, Jeff Garzik wrote:
> 1) The _ops are either too limited in scope, or too wide in scope.

Couldn't agree more.  I blame acme -- he wants me to push it to be much
wider in scope.  Let's push _all_ the function pointers into netdev_ops.

But this is a mere step 1.  I don't have enough network-related clout
to do everything in one fell swoop.

> 2.c) If #2 is decided to be netdev_ops, and all func ptrs are moved into
> netdev_ops struct, then create the macro
> 	SET_NETDEV_OPS(dev, ops)
> 
> This allows full back compat, without ugliness in mainline tree.

Yes, that was my preferred approach.

> 3) The func ptrs _count() are totally bogus.  We have an unconditional
> indirect reference to a function call which does nothing but return a
> driver constant.
> 
> I personally think that having ethtool_ops members manually calling
> the ->get_drvinfo hook is a _lot_ cleaner than 10,000 foo_count hooks.

Disagree.  I'd like to completely get rid of the ->get_drvinfo hook and
have each hook return one thing.  DaveM claims that these things are not
always constants, and I believe him -- it's entirely possible different
revs of a chip (with the same driver) may have more or fewer registers
to return, for example.

We might want to put these counts directly in the net_device itself and
eliminate the function calls.  That would make sense.

> 4) I don't see why ethtool.h suddenly needs to include linux/types.h,
> when it hasn't needed it in all this time until now.

Otherwise you have to include <linux/types.h> before you include
<linux/ethtool.h> which sucks.  No relying on other people to do your
inclusions for you ;-)

> 5) net/socket.c changes appear unrelated to this patch.

You're right, they just happen to be in that tree.

> 6) (low prio)  Add documentation to
> Documentation/networking/netdevices.txt.  Most importantly, this
> documents locking/context.

An excellent idea.

> 7) (low prio)  All that similar code in net/core/ethtool.c can be
> template-ized with a macro, IMO.  Something like
>   DEF_ETHTOOL_GOP(get_coalesce, ETHTOOL_GCOALESCE, ethtool_coalesce);
>   DEF_ETHTOOL_SOP(set_coalesce, ethtool_coalesce);
>   (and templates for the ops that use edata)

Maybe.  I'm not a fan of templated ops as it makes it harder to grep.

> 8) (security)  get-eeprom op needs to check that offset+len is not
> invalid, and does not wrap.

Good idea, I'll add that check now.

> 9) phys_id op should return an error, for consistency if nothing else.
> It's simple for driver authors to unconditionally return 0 if their code
> has no failure cases, and it's a slow path so adding the return in the
> driver code is no big deal.

OK, ditto.

> 10) (low prio) since it's a slow path, what about replacing the switch
> statement in dev_ethtool() with a lookup table?  All the ethtool
> commands are low numbers.  If you do this, I would suggest using the gcc
> array initializer syntax:
> 	[ETHTOOL_GCOALESCE, ethtool_get_coalesce]
> 
> All the ethtool ops have the same prototype, after all.

Well, they don't have quite the same prototype ... that's part of the
point -- get the type safety going as early as possible.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
