From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 03/39] wimax: constants and definitions to interact with user space
Date: Tue, 2 Dec 2008 18:06:15 -0800
Message-ID: <200812021806.16278.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <999a8be21ed5a6c6d5960789783b38bf51dfd3c3.1227691434.git.inaky@linux.intel.com> <1227778899.3809.30.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:5961 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753228AbYLCCL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:28 -0500
In-Reply-To: <1227778899.3809.30.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Johannes Berg wrote:
> On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:

I've consolidated replies to some items in this email, instead of the
other ones, as some were repeated. These are mainly:

- using one policy per command

- licensing of the linux/wimax* headers

- the message channel

- the RP_RESULT to transfer results back to user space instead of
  using genl acks/nlerrs

> Explicitly licensing a header file that's used for userspace tools under
> GPL2 might seem to indicate that the tool must be GPL2'ed as well, this
> seems unintended. To be on the safe side, it seems that a lot of people
> would prefer this to be under something as simple as the ISC license
> just so that you can simply copy the file if necessary.
>
> I know this hasn't been done traditionally, but in wireless a lot of
> people are complaining and I know of one case where a complete header
> file was "reimplemented" from scratch because of such an issue.

This is a good point -- there are no issues in moving this to a BSD type.

> > +	WIMAX_GNL_ATTR_MAX = 5,
>
> This is another side effect of your decision of declaring attributes for
> each command. If you didn't, you could simply do

I could argue it is a side effect of netlink's implementation :)

The whole idea behind using a policy per command/signal is very simple
(and I realize now, very undocumented):

I want the attribute validator to do the validation job for me.a

Each command/signal have a list of arguments, each with a type, they
take. There is a policy for each that containst exactly that
list. When I get it from the user, I just need to validate it and if
there is something in there that should not, then that's an error.

So change the concept of "attribute maps to type" to "attribute type X
as an argument to command/signal Y".

However, if I had a single policy for *all* commands/signals, after
running the validator I'd have to check "does this attribute belong in
here"? for each one. I can do that manually (not) or I can have an
already working and proven piece of code do it for me. Makes it
easier. 

As well, it makes it easier to later expand each command/signal
signature without affecting others and keeping the namespace more or
less sane. Not that it is too complicated, but it makes it even easier.

> > + * Most of these map to an API call; _OP_ stands for operation, _RP_
> > + * for reply and _RE_ for report (aka: signal).
> > + */
> > +enum {
> > +	WIMAX_GNL_OP_MSG_FROM_USER,	/* User to kernel message */
> > +	WIMAX_GNL_OP_MSG_TO_USER,	/* Kernel to user message */
>
> What are those used for? Smells a lot like "iwpriv"...

Yes, that's what's they are, because there is still no known good
interface for the basic primitives (scan, connect, disconnect). That
will have to evolve or it might stay like that if there is no way to
find a common ground for those basic primitives [for others reading
out of context, see the reply to [PATCH 00/39] explaining why].

> > +	WIMAX_GNL_OP_OPEN,	/* Open a handle to a wimax device */
> > +	WIMAX_GNL_OP_UNUSED,	/* Unused */
> > +	WIMAX_GNL_OP_RFKILL,	/* Run wimax_rfkill() */
> > +	WIMAX_GNL_RP_IFINFO,	/* Reply to OPEN: Interface info */
> > +	WIMAX_GNL_RP_RESULT,	/* Reply: result of operation */
> > +	WIMAX_GNL_OP_RESET,	/* Run wimax_rfkill() */
> > +	WIMAX_GNL_RE_STATE_CHANGE,	/* Report: status change */
> > +	WIMAX_GNL_OP_MAX,
>
> That's not MAX, it's MAX+1, see the idiom above if you really need MAX.

This is used for something different. User space can use this to quick
check if this is a good message or not. It is actually redundant the
way it is being used now, so I just killed it.

> > +/* Message from user / to user */
> > +enum {
> > +	WIMAX_GNL_MSG_DATA = 1,
> > +};
>
> So this is iwpriv? Why bother with an enum if you're not doing
> kernel-doc?

Consistency with the rest of the stuff and that I try to avoid cpp
when possible :)

> > +enum wimax_rf_state {
> > +	WIMAX_RF_OFF = 0,	/* Radio is off, rfkill on/enabled */
> > +	WIMAX_RF_ON = 1,	/* Radio is on, rfkill off/disabled */
> > +	WIMAX_RF_QUERY = 2,
> > +};
> > +
> > +/* Attributes */
> > +enum {
> > +	WIMAX_GNL_RFKILL_STATE = 1,
> > +};
>
> What's wrong with making that 2, and using a single enum for all the
> attributes? It doesn't make a huge difference.

Described above.

> > +enum {
> > +	WIMAX_GNL_IFINFO_MC_GROUPS = 1,
> > +	WIMAX_GNL_IFINFO_MC_GROUP,
> > +	WIMAX_GNL_IFINFO_MC_NAME,
> > +	WIMAX_GNL_IFINFO_MC_ID,
> > +	WIMAX_GNL_IFINFO_MAX,		/* Used by user space */
>
> again, not MAX
> also what do you need MC_GROUP stuff for? genl mc groups
> are available via the genl controller, isn't that sufficient?

Couldn't get it to work -- in a prev message you mentioned to look
into the example done at the iw tarball. Will check and kill all this
(not that I like it precisely).

> > +/*
> > + * Attributes for the result-of-operation
> > + */
> > +enum {
> > +	WIMAX_GNL_RESULT_CODE = 1,
>
> This is a bit strange, what operations cannot just use the regular genl
> ack message? Are these asynchronous?

After going over other of your comments, I just realized I was using
libnl the wrong way. After a "aw crap" moment, it is working now, so I
killed all this.

> > +enum {
> > +	WIMAX_GNL_STCH_STATE_OLD = 1,
> > +	WIMAX_GNL_STCH_STATE_NEW,
> > +};
> > +
> > +
> > +/**
> > + * enum wimax_st - The different states of a WiMAX device
> > + * @__WIMAX_ST_NULL: The device structure has been allocated and zeroed,
> > + *     but still wimax_dev_add() hasn't been called. There is no state.
>
> That's not really available to userspace, is it? I mean, at that point
> wimax-genl will just not work?

Correct -- I just didn't want to break the state definition in two
parts for the internal (__WIMAX_*) vs external (WIMAX_*) states.

There is a note clarifying that in the kernel-doc.


-- 
Inaky

