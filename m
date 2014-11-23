From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] vlan: Pass ethtool get_ts_info queries to real
 device.
Date: Sun, 23 Nov 2014 19:38:02 +0100
Message-ID: <20141123183802.GA5192@localhost.localdomain>
References: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
 <1416712512.7215.34.camel@decadent.org.uk>
 <20141123160533.GA4562@netboy>
 <1416763199.7215.53.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:65039 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbaKWSiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 13:38:08 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so3723253wiw.1
        for <netdev@vger.kernel.org>; Sun, 23 Nov 2014 10:38:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1416763199.7215.53.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 23, 2014 at 05:19:59PM +0000, Ben Hutchings wrote:
> > Unsafe? How?
> 
> I mean that the assumption is wrong in general.  So these changes will
> result in silent failure to enable RX timestamps, on some devices.

Silent failure is dissapointing, yes, but not unsafe. Nothing breaks.
 
> > The whole filter list with every last combination (at least, the ones
> > at the time) came directly from a early, limited HW design.  Sane,
> > modern PTP hardware provides time stamps regardless of whether a frame
> > is VLAN tagged or not.
> 
> I would hope so.  However, this is non-standard - IEEE802.1AS
> *explicitly forbids* the use of VLAN tags.

Yes, but still people are using them. People fail to understand that
VLAN tags are not meant for end stations. The power industry has
created IEEE 61850 which actually requires end stations to send and
receive VLAN tagged frames with VID!=0, in violation of 802.1. Then
they published a PTP profile running on VLAN tagged Layer2.

(For this reason alone, most hardware does handle tagged frames, and
that is also why the linuxptp stack accepts vlan tags when using Layer2
transport.)

Setting up vlan interfaces on an end station is already somewhat
fishy. People who do that can surely take care that their cards do
correctly handle vlan tagged frames.

Concerning this patch, I needed get_ts_info to work on a VLAN interface
in order to implement a grand master clock on a managed switch. I think
that is valid use case, and implementing a Linux based Transparent
Clock will also need this.

>  Linux's software PTP
> classifier also doesn't yet handle 802.1ad VLAN tags.

As soon as someone wants this, I don't see why it cannot be added.

> > I don't see any reason not to make our stack even more ugly just to cater
> > to broken hardware.
> 
> So failure to implement a non-standard extension is now 'broken'?

If your PTP traffic flows through a managed, transparent switch with
VLANs enabled, then the device will have to provide time stamps. This
is really a standard use case. Also the power profile mandates vlan.
 
> This is progress for some devices, false advertising for others.

And where do we draw the line with describing the limitations of poorly
made hardware classifiers? What if a card can time stamp IPv4 packets,
but not in the presence of IPv4 options?

Again, I don't mind if someone wants to add a bunch more combinations
to the rx_filters. But they are useless in the end. In practice, user
space software will ignore them anyhow, unless the software somehow
caters to hardware limitations. Really, look at the list in rx_filters,
and think about this. What is the stack supposed to do if SIOCGHWTSTAMP
returns HWTSTAMP_FILTER_PTP_V2_DELAY_REQ? It is madness, really.

Thanks,
Richard
