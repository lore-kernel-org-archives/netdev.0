From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: RE: [PATCH] tipc: fix endianness on tipc subscriber messages
Date: Mon, 8 Mar 2010 14:32:38 -0800
Message-ID: <29C1DC0826876849BDD9F1C67ABA29430728D22A@ala-mail09.corp.ad.wrs.com>
References: <20100308200315.GE23634@hmsreliant.think-freely.org> <29C1DC0826876849BDD9F1C67ABA29430728D116@ala-mail09.corp.ad.wrs.com> <20100308210957.GH23634@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:32837 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755752Ab0CHWct convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 17:32:49 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20100308210957.GH23634@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil wrote: 

> > There are a couple of problems with this patch that need to be 
> > resolved before it can be applied to the upstream kernel.
> > 
> > 1) Neil's replacement of the htohl() call with the equivalent
> > htonl()/ntohl() calls, while well intentioned, was done without 
> > understanding why the htohl() calls were put there in the 
> first place.
> I'd love to hear what those reasons are.  You're formating 
> on-the-wire data to an endianness defined by the receiving 
> entity.  I'm hard pressed to imagine a reason why thats sane.

When TIPC evolved from using ioctl() as the API to the topology service
to a message-based interface it was felt that it would be desirable to
allow the fields in those messages to be formatted in host-byte order,
since that was what existing applications were already doing.  I presume
that the idea was to make the migration process as painless as possible,
and to avoid problems with future applications that didn't take
endianness into account.

However, since it was theoretically possible for an application to send
a message to a topology service on another node (whose endianness was
unknown), the node that received the message needed to be able to
recognize if a message contents had the "wrong" endianness and do the
necessary conversion.  That is what was implemented back in TIPC 1.5,
and this API still exists today which is why the htohl() conversions are
done the way they are.  (I can't say I'm a fan of the htohl() name ...
it would be nice to have something more meaningful.)

The difficulty with the patch you've made is that it will break existing
TIPC applications that adhere to the existing API (i.e. they don't do
endianness conversion on the messages they exchange with the topology
server) if the application is running on an architecture whose host byte
order isn't the same as network byte order.


> > In addition, the TIPC specification that he used to justify some of 
> > his decisions is out-dated, and doesn't reflect the latest 
> version of 
> > the TIPC protocol.  (I'll discuss this further in a 
> follow-up email.)
> > 
> Please, point out a more recent spec.  The one I referenced 
> is the most recent publically available spec that I can find. 
> although again, I'm hard pressed to believe that the spec has 
> changed to include a requirement to send data in receiver byte order.

The TIPC spec you're referencing was created a number of years ago when
Ericsson was endeavouring to get TIPC accepted by the IETF.  That effort
was unsuccessful, and when that happened Ericsson decided not to pursue
things further and let the spec become stale.  The document was kept on
the SourceForge website out of historical interest, and its description
was updated to state the spec wasn't a reliable indication of the
current state of the code.  The TIPC working group has continued
development of TIPC by letting the code "do the talking".


> > 2) Neil's alteration of the memcpy() in the subscription 
> cancelation 
> > routine is simply wrong.  The pieces of the data structure that he 
> > claims are local are not local, and must be checked to 
> ensure that the 
> > cancellation is done properly.
> > 
> 
> The origional memcmp checks sizeof(tipc_subscr) bytes of each 
> entry in the array.  tipc_subscr is defined as:
> struct tipc_subscr {
>         struct tipc_name_seq seq;       /* name sequence of 
> interest */
>         __u32 timeout;                  /* subscription 
> duration (in ms) */
>         __u32 filter;                   /* bitmask of filter 
> options */
>         char usr_handle[8];             /* available for 
> subscriber use */
> };
> 
> In subscr_subscribe (from which we also call subscr_cancel), 
> we allocate new entries for that list, only fillingout the 
> seq.type, seq.lower, seq.upper, timeout and filter.  So if 
> anyone locally changes usr_handle (which I see several places 
> that do), the memcmp won't match up properly.  Additionally, 
> I'm hard pressed to believe (and this would be supported by 
> the section of the spec that I referenced), timeout, and 
> filter also don't bear on the uniqueness of the subscriber 
> Id.  Of course a subsequent version of the spec might have 
> changed that, But if it is, please point it out to me.

When a subscription request message is received, a new subscription
object is created (struct subscription).  This routine copies over the
sequence, timeout, and filter fields from the original message, and
converts them to host byte order so they can be easily referenced later;
it doesn't copy over the usr_handle info because that is only meaningful
to the application that sent the request.  However, in addition, the
subscription object also copies the subscription request message (struct
tipc_subscr), which contains all of these fields in the sender's byte
order, including the usr_handle; this is done by the memcpy near the end
of subscr_subscribe().

Now when subscr_cancel() is invoked to try cancelling an existing
subscription, the caller passes in the cancellation message structure
(struct tipc_subscr) with the cancellation request bit forced off.  The
routine can then do a memcmp() against the copy of the original
subscription request (also struct tipc_subscr), ensuring that a match is
declared only if all of the fields specified in the cancellation message
match the fields in the original request.

Regards,
Al

