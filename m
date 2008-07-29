From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Tue, 29 Jul 2008 18:49:24 +0300
Message-ID: <200807291849.24945.opurdila@ixiacom.com>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com> <1217290080-4251-2-git-send-email-opurdila@ixiacom.com> <1217343163.30512.34.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:10561 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752011AbYG2Pv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 11:51:56 -0400
In-Reply-To: <1217343163.30512.34.camel@ecld0pohly>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Patrick,

Thanks for taking the time to go over this.

> > New socket option and socket control message are added as well
> > (SO_TIMESTAMPHW and SCM_TIMESTAMPHW).
>
> How is a network driver notified that it is expected to do hardware time
> stamping? The connection between the socket option and the driver isn't
> quite clear to me (which might very well be due to my lack of experience
> in this area - please bear with me...). 

I don't have much experience either so this might not be even close to a good 
solution :)

> Is the driver expected to check 
> the socket flags whenever it gets a chance?
>

If/when the driver chooses, it will start using hardware timestamps and the 
hardware timestamp will always (or when possible) be stored in skb->tstamp. 
Then, when copying the data in userspace, we will look at the socket flag and 
if the socket has requested a hw timestamp we will directly copy the 
skb->tstamp, otherwise if a regular timestamp has been requested, we will 
convert it to a regular timestamp via the new added get_tstamp driver method.

I don't know if it is required to add an on/off switch for hardware 
timestamping with this architecture, but if it is, we have some choices about 
how to do this:
- via ethtool
- via new SIOCSHWTSTAMP{ON/OFF} ioctls
- via module parameters

> IMHO it would be necessary to attach this configuration change not just
> to a socket, but also to a message which is then routed to the right
> device driver.
>
> A simple on/off flag is not sufficient, either: for example, the Intel
> 82576 chip only has one RX register that is locked until read by the
> driver. When time stamping all incoming packets, relevant time stamps
> may get lost under high load. The hardware can be configured to only
> time stamp packets of interest, which helps considerably. 

Ok, I see... How about adding a new SIOCSHWTSTAMPFILTER ioctl:

#define HWTSTAMP_FILTER_PTP_L2 0x01
#define HWTSTAMP_FILTER_PTP_L4 0x02
...
struct hwtstamp_filter {
	char type;
};

If needed we could later expand hwtstamp_filter to include ether_types, 
ip_types, udp/tcp ports, etc.

> It may also be 
> important to know for the application whether the hardware is really
> capable of delivering what it is asked for.
>

I am not sure if I understood this, but the ioctl return code should do it, 
right?

> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 299ec4b..f19ed43 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -199,7 +199,8 @@ typedef unsigned char *sk_buff_data_t;
> >   *	@next: Next buffer in list
> >   *	@prev: Previous buffer in list
> >   *	@sk: Socket we are owned by
> > - *	@tstamp: Time we arrived
> > + *	@tstamp: Time we arrived; representation might be hardware specific,
> > do + *	        not access directly but via skb_get_tstamp
>
> Given that the semantic of the "tstamp" member has changed and any
> existing code which still accesses it directly is broken, should the
> member perhaps be renamed to trigger compiler errors in such a case?
> Just a thought.

I am ok with that, but I don't know if this is an acceptable practice :)

BTW, the TX timestamps patch I've sent yesterday is also very closely related 
to PTP, and since you have experience with PTP I am wondering how the 
proposed interface looks to you.

Thanks,
tavi
