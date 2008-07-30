From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Wed, 30 Jul 2008 11:35:52 +0200
Message-ID: <1217410552.30512.144.camel@ecld0pohly>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com>
	 <1217290080-4251-2-git-send-email-opurdila@ixiacom.com>
	 <1217343163.30512.34.camel@ecld0pohly>
	 <200807291849.24945.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27579 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760946AbYG3Jhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 05:37:46 -0400
In-Reply-To: <200807291849.24945.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-07-29 at 18:49 +0300, Octavian Purdila wrote:
> > Is the driver expected to check 
> > the socket flags whenever it gets a chance?
> >
> 
> If/when the driver chooses, it will start using hardware timestamps and the 
> hardware timestamp will always (or when possible) be stored in skb->tstamp.

It's the app which chooses when to enable the feature, so we need a way
to communicate that.

> > A simple on/off flag is not sufficient, either: for example, the Intel
> > 82576 chip only has one RX register that is locked until read by the
> > driver. When time stamping all incoming packets, relevant time stamps
> > may get lost under high load. The hardware can be configured to only
> > time stamp packets of interest, which helps considerably. 
> 
> Ok, I see... How about adding a new SIOCSHWTSTAMPFILTER ioctl:
> 
> #define HWTSTAMP_FILTER_PTP_L2 0x01
> #define HWTSTAMP_FILTER_PTP_L4 0x02
> ...
> struct hwtstamp_filter {
> 	char type;
> };
> 
> If needed we could later expand hwtstamp_filter to include ether_types, 
> ip_types, udp/tcp ports, etc.

Yes, that'll work. Regarding the design of the ioctl() call and its
parameter, how do we preserve backwards compatibility as new fields get
added?

The initial list of defines could be:

/** time stamp no incoming packet at all */
#define HWTSTAMP_FILTER_NONE 0x00

/** time stamp any incoming packet */
#define HWTSTAMP_FILTER_ALL 0x01

/** PTP v1, UDP, any kind of event packet */
#define HWTSTAMP_FILTER_PTP_V1_L4_EVENT 0x02
/** PTP v1, UDP, Sync packet */
#define HWTSTAMP_FILTER_PTP_V1_L4_SYNC 0x03
/** PTP v1, UDP, Delay_req packet */
#define HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ 0x04

/** PTP v2, UDP, any kind of event packet */
#define HWTSTAMP_FILTER_PTP_V2_L4_EVENT 0x05
/** PTP v2, UDP, Sync packet */
#define HWTSTAMP_FILTER_PTP_V2_L4_SYNC 0x06
/** PTP v2, UDP, Delay_req packet */
#define HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ 0x07

/** 802.AS1, Ethernet, any kind of event packet */
#define HWTSTAMP_FILTER_PTP_V2_L2_EVENT 0x08
/** 802.AS1, Ethernet, Sync packet */
#define HWTSTAMP_FILTER_PTP_V2_L2_SYNC 0x09
/** 802.AS1, Ethernet, Delay_req packet */
#define HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ 0x0A

/** PTP v2/802.AS1, any layer, any kind of event packet */
#define HWTSTAMP_FILTER_PTP_V2_EVENT 0x0B
/** PTP v2/802.AS1, any layer, Sync packet */
#define HWTSTAMP_FILTER_PTP_V2_SYNC 0x0C
/** PTP v2/802.AS1, any layer, Delay_req packet */
#define HWTSTAMP_FILTER_PTP_V2_DELAY_REQ 0x0D

The "any event packet" is useful for "dumb" PTP daemons which want to
avoid reconfiguring the driver as they switch from master to slave or
vice versa. In V1 there was no mapping to L2, so that is missing from
the list.

I prefer an enumeration over flags because by design, only valid
combinations are possible.

> > It may also be 
> > important to know for the application whether the hardware is really
> > capable of delivering what it is asked for.
> >
> 
> I am not sure if I understood this, but the ioctl return code should do it, 
> right?

Correct. The semantic of the call would be that it's a hint to the
driver what the app wants. It must time stamp the indicated packets, but
if it is not capable of filtering exactly as requested, then it is free
to also time stamp additional ones. If it cannot implement the requested
functionality, EINVAL is returned.

The app is encourage to be as specific as possible. For example, the
HWTSTAMP_FILTER_PTP_V1_L4_EVENT mode is not supported by the new Intel
NIC. The daemon has to select either HWTSTAMP_FILTER_PTP_V1_L4_SYNC or
HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ, as needed.

> > > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > > index 299ec4b..f19ed43 100644
> > > --- a/include/linux/skbuff.h
> > > +++ b/include/linux/skbuff.h
> > > @@ -199,7 +199,8 @@ typedef unsigned char *sk_buff_data_t;
> > >   *	@next: Next buffer in list
> > >   *	@prev: Previous buffer in list
> > >   *	@sk: Socket we are owned by
> > > - *	@tstamp: Time we arrived
> > > + *	@tstamp: Time we arrived; representation might be hardware specific,
> > > do + *	        not access directly but via skb_get_tstamp
> >
> > Given that the semantic of the "tstamp" member has changed and any
> > existing code which still accesses it directly is broken, should the
> > member perhaps be renamed to trigger compiler errors in such a case?
> > Just a thought.
> 
> I am ok with that, but I don't know if this is an acceptable practice :)

Neither do I. Any comments from the experts? However, if we follow
Ingo's proposal that change wouldn't be necessary anyway.

> BTW, the TX timestamps patch I've sent yesterday is also very closely related 
> to PTP, and since you have experience with PTP I am wondering how the 
> proposed interface looks to you.

See my comments regarding the software time stamping fallback in the
other mail that I just sent. I'll also have to look at the patch in more
detail.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

