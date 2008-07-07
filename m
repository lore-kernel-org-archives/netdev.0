From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC] support for IEEE 1588
Date: Mon, 07 Jul 2008 14:34:11 +0200
Message-ID: <1215434051.17113.125.camel@ecld0pohly>
References: <200807040147.11148.opurdila@ixiacom.com>
	 <1215178641.7277.71.camel@localhost>
	 <200807050321.26877.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48517 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804AbYGGMeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 08:34:13 -0400
In-Reply-To: <200807050321.26877.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-07-05 at 03:21 +0300, Octavian Purdila wrote:
> On Friday 04 July 2008, Patrick Ohly wrote:
[cookie for TX time stamp]
> For the PTPd, this is probably not required, but it will help with 
> applications that have multiple outstanding TX packets. 

I think it is relevant also for PTPd: without such a cookie the next
SYNC cannot be sent unless the previous time stamp was obtained
successfully. If the packet is lost without triggering the hardware time
stamping (which I have seen happen in practice under load), then the
PTPd would get stuck. With a cookie it can send SYNCs at the normal
intervals and be sure not to mix up time stamps.

This is more of a theoretical problem, though: if there is no time stamp
after two seconds, the corresponding packet most likely got lost and it
is fairly safe to send a new SYNC and to assume that the next time stamp
will be for that SYNC.

> > > - when the driver will send the packet will get the stamp from the TX
> > > completion ring; the driver will then propagate the stamp either to
> > > (a) the skb stamp field, or (b) some special structure - this to avoid
> > > keeping the skb around
> > > - the special structure or the skb will be linked to a special queue in
> > > the socket and a POLLPRI event will be generated
> > > - the application will use recvmsg and will receive a new control message
> > > which contains the timestamp from the socket special queue
> >
> > Sounds a bit complicated to me. The trick currently used by PTPd might
> > be more elegant and/or require less changes: it enables looping of
> > outgoing packets with IP_MULTICAST_LOOP. The RX timestamp of the looped
> > packet is then used as approximation for the TX time stamp of the
> > original outgoing packet. Clearly this is inaccurate, in particular
> > under load, but it is very easy to use.
> >
> 
> I am probably missing something: I thought IP_MULTICAST_LOOP is done in 
> software... If so, how would the hardware be able to timestamp?

I was just using IP_MULTICAST_LOOP+SO_TIMESTAMP as an example of how a
similar mechanism could work for hardware time stamping.

> > When a driver gets a skb with the request to generate a TX time stamp,
> > it could send the packet, upon completion obtain the time stamp from the
> > hardware and feed the packet and the time stamp back to the upper layers
> > as if it had just been received. Would that work?
> >
> > The user space then obtains TX time stamps just like RX time stamps and
> > can use the payload to determine what kind of time stamp it got. That
> > also avoids the need for special cookies to detect packet loss or
> > reordering.
> >
> 
> For a generic protocols (not PTP) I think this will not work: e.g an UDP 
> packet could be dropped or hit the wrong socket (due to missmatch between the 
> source and destination port).

Right. Perhaps that could be solved with an additional control message
which specifies where the bounced packet is to be sent to, but that is
not much (not at all?) easier than the cookie approach.

I'm confident that adapting PTPd to the cookie approach wouldn't be
difficult, so if you want to implement it, then go for it.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

The email footer below is automatically added to comply with company
policy; this particular email is not confidental and does not have a
limited set of recipients. Therefore it can be redistributed and
discussed without restrictions.

