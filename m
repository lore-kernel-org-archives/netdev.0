From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] tipc: fix endianness on tipc subscriber messages
Date: Mon, 8 Mar 2010 20:45:03 -0500
Message-ID: <20100309014503.GB2080@localhost.localdomain>
References: <20100308200315.GE23634@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA29430728D116@ala-mail09.corp.ad.wrs.com>
 <20100308210957.GH23634@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA29430728D22A@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Stephens, Allan" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43945 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756256Ab0CIBpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 20:45:10 -0500
Content-Disposition: inline
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA29430728D22A@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 08, 2010 at 02:32:38PM -0800, Stephens, Allan wrote:
> Neil wrote: 
> 
> > > There are a couple of problems with this patch that need to be 
> > > resolved before it can be applied to the upstream kernel.
> > > 
> > > 1) Neil's replacement of the htohl() call with the equivalent
> > > htonl()/ntohl() calls, while well intentioned, was done without 
> > > understanding why the htohl() calls were put there in the 
> > first place.
> > I'd love to hear what those reasons are.  You're formating 
> > on-the-wire data to an endianness defined by the receiving 
> > entity.  I'm hard pressed to imagine a reason why thats sane.
> 
> When TIPC evolved from using ioctl() as the API to the topology service
> to a message-based interface it was felt that it would be desirable to
> allow the fields in those messages to be formatted in host-byte order,
> since that was what existing applications were already doing.  I presume
> that the idea was to make the migration process as painless as possible,
> and to avoid problems with future applications that didn't take
> endianness into account.
> 
So you made a decision to make broken applications continue to work by breaking
the protocol stack, and in so doing violated the specification.  Thats wrong.
The right thing to do is fix the stack to conform to the spec, identify the
broken applications, then fix them to conform to the specification.

> However, since it was theoretically possible for an application to send
> a message to a topology service on another node (whose endianness was
> unknown), the node that received the message needed to be able to
> recognize if a message contents had the "wrong" endianness and do the
> necessary conversion.  That is what was implemented back in TIPC 1.5,
Thats a big mistake.  The right thing to do is to make it clear to the
applications that they need to send everything in network byte order, and assume
everything receive is in network byte order.  Then the application doesn't have
to care what the receivers byte order is.  Anything less than that is completely
broken.  Supporting backwards compatibility with broken applications by further
breaking things is just more broken.

> and this API still exists today which is why the htohl() conversions are
> done the way they are.  (I can't say I'm a fan of the htohl() name ...
> it would be nice to have something more meaningful.)
> 
htohl is perfectly meaningful, its just wrong.

> The difficulty with the patch you've made is that it will break existing
> TIPC applications that adhere to the existing API (i.e. they don't do
> endianness conversion on the messages they exchange with the topology
> server) if the application is running on an architecture whose host byte
> order isn't the same as network byte order.
> 
Well, thats broken, but the fix isn't to allow them to continue to support
munging byte order for them, its to make them fix their own brokenness.  You may
not be able to break the API for your customers, but upstream can.  I won't
speak for Dave or anyone else on the list, but for me, convincing me this isn't
needed will require a technical argument, not a business one.  Show me that this
code doesn't violate the latest draft RFC as published.

> 
> > > In addition, the TIPC specification that he used to justify some of 
> > > his decisions is out-dated, and doesn't reflect the latest 
> > version of 
> > > the TIPC protocol.  (I'll discuss this further in a 
> > follow-up email.)
> > > 
> > Please, point out a more recent spec.  The one I referenced 
> > is the most recent publically available spec that I can find. 
> > although again, I'm hard pressed to believe that the spec has 
> > changed to include a requirement to send data in receiver byte order.
> 
> The TIPC spec you're referencing was created a number of years ago when
> Ericsson was endeavouring to get TIPC accepted by the IETF.  That effort
> was unsuccessful, and when that happened Ericsson decided not to pursue
> things further and let the spec become stale.  The document was kept on
> the SourceForge website out of historical interest, and its description
> was updated to state the spec wasn't a reliable indication of the
> current state of the code.  The TIPC working group has continued
> development of TIPC by letting the code "do the talking".
> 
Setting asside how unacceptable I find that, I find a flaw in your logic here.
you assert the code defines the specification, yet from your statements above,
we can't change the behavior of the code (read: we can't change the
specification, because using applications have already assumed the code behaves
the way it currently does).  As such, it would seem that we can do little more
with tipc than maintain exact bug-for-bug compatibility, in perpituity, and
thats unacceptable.  Either we:
1) Fix the bugs we find, using the latest published specification
2) Drop tipc from the kernel, since we don't really know how it should work

Seriously, if you're tree is the definitive source on how tipc works, drop it
from upstream, maintain it yourself, and save others the grief of having to fix
anything with it.

> 
> > > 2) Neil's alteration of the memcpy() in the subscription 
> > cancelation 
> > > routine is simply wrong.  The pieces of the data structure that he 
> > > claims are local are not local, and must be checked to 
> > ensure that the 
> > > cancellation is done properly.
> > > 
> > 
> > The origional memcmp checks sizeof(tipc_subscr) bytes of each 
> > entry in the array.  tipc_subscr is defined as:
> > struct tipc_subscr {
> >         struct tipc_name_seq seq;       /* name sequence of 
> > interest */
> >         __u32 timeout;                  /* subscription 
> > duration (in ms) */
> >         __u32 filter;                   /* bitmask of filter 
> > options */
> >         char usr_handle[8];             /* available for 
> > subscriber use */
> > };
> > 
> > In subscr_subscribe (from which we also call subscr_cancel), 
> > we allocate new entries for that list, only fillingout the 
> > seq.type, seq.lower, seq.upper, timeout and filter.  So if 
> > anyone locally changes usr_handle (which I see several places 
> > that do), the memcmp won't match up properly.  Additionally, 
> > I'm hard pressed to believe (and this would be supported by 
> > the section of the spec that I referenced), timeout, and 
> > filter also don't bear on the uniqueness of the subscriber 
> > Id.  Of course a subsequent version of the spec might have 
> > changed that, But if it is, please point it out to me.
> 
> When a subscription request message is received, a new subscription
> object is created (struct subscription).  This routine copies over the
> sequence, timeout, and filter fields from the original message, and
> converts them to host byte order so they can be easily referenced later;
> it doesn't copy over the usr_handle info because that is only meaningful
> to the application that sent the request.  However, in addition, the
> subscription object also copies the subscription request message (struct
> tipc_subscr), which contains all of these fields in the sender's byte
> order, including the usr_handle; this is done by the memcpy near the end
> of subscr_subscribe().
> 
> Now when subscr_cancel() is invoked to try cancelling an existing
> subscription, the caller passes in the cancellation message structure
> (struct tipc_subscr) with the cancellation request bit forced off.  The
> routine can then do a memcmp() against the copy of the original
> subscription request (also struct tipc_subscr), ensuring that a match is
> declared only if all of the fields specified in the cancellation message
> match the fields in the original request.
> 
Yes, I see that, but where in the spec (section 5.2 IIRC defines the subscriber
data), include the timeout, filter and user handle as components of the
