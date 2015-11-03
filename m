From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 22:44:45 +0100
Message-ID: <201511032244.45831.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <56374593.6000200@hartkopp.net> <201511021916.18117.marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Marc Kleine-Budde" <mkl@pengutronix.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Andrey Vostrikov <andrey.vostrikov@cogentembedded.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:56484 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932492AbbKCVor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:44:47 -0500
In-Reply-To: <201511021916.18117.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, November 02, 2015 at 07:16:18 PM, Marek Vasut wrote:
> On Monday, November 02, 2015 at 12:14:27 PM, Oliver Hartkopp wrote:
> > On 02.11.2015 10:47, Marc Kleine-Budde wrote:
> > > On 11/02/2015 12:16 AM, Marek Vasut wrote:
> > >> The ARINC-429 is a technical standard, which describes, among others,
> > >> a data bus used by airplanes. The standard contains much more, since
> > >> it is based off the ISO/OSI model, but this patch implements just the
> > >> data bus protocol.
> > >> 
> > >> This stack is derived from the SocketCAN implementation, already
> > >> present in the kernel and thus behaves in a very similar fashion.
> > >> Thus far, we support sending RAW ARINC-429 datagrams, configuration
> > >> of the RX and TX clock speed and filtering.
> > >> 
> > >> The ARINC-429 datagram is four-byte long. The first byte is always the
> > >> LABEL, the function of remaining three bytes can vary, so we handle it
> > >> as an opaque PAYLOAD. The userspace tools can send these datagrams via
> > >> a standard socket.
> > >> 
> > >> A LABEL-based filtering can be configured on each socket separately in
> > >> a way comparable to CAN -- user uses setsockopt() to push a list of
> > >> label,mask tuples into the kernel and the kernel will deliver a
> > >> datagram to the socket if (<received_label> & mask) == (label &
> > >> mask), otherwise the datagram is not delivered.
> > > 
> > > What's difference compared to CAN besides a different MTU? The CAN
> > > stack is already capable to handle CAN and CAN-FD frames. Would it
> > > make sense to integrate the ARINC-429 into the existing CAN stack?
> > 
> > That was my first impression too.
> 
> Hi!
> 
> > What about defining some overlay data structure to map ARINC-429 frames
> > into CAN frames?
> 
> I agree about the code reuse, it was stupid to do such a blatant copy of
> the code all right. I don't think it's such a great idea to outright place
> ARINC support into the CAN stack though. They're two different busses
> after all. Please see below.
> 
> > E.g. we could write the ARINC 32 bit data completely into data[0..3] and
> > additionally copy the 8 bit label information (or should it better be 10
> > bit including the Source/Destination Identifiers?) additionally into the
> > can_id.
> > 
> >  From what I can see the filtering by label is similar to filtering by
> > 
> > can_id. And you would be able to use the can-gw functionality too.
> 
> This is correct.
> 
> > The only real difference is the bitrate configuration of the ARINC
> > interface.
> 
> There might be additional ARINC-specific configuration bits involved,
> but thus far, that's correct.
> 
> > I wonder if a similar approach would fit here as we discussed with the
> > University of Prague for a LIN implementation using the PF_CAN
> 
> > infrastructure:
> OT: Hey, there is no "University of Prague", there are two universities in
> Prague to boot -- Charles University and Czech Technical University -- you
> mean the later ;-)
> 
> > http://rtime.felk.cvut.cz/can/lin-bus/
> > 
> > It could probably boil down to a 'CAN interface' that is named arinc0
> > which implements the serial driver like in slcan.c or sllin.c ...
> 
> I was thinking about this and I mostly agree with you. Obviously, copying
> the code this way was dumb. On the other hand, ARINC and CAN are two
> different sort of busses, so I'd propose something slightly different here
> to avoid confusion and prevent the future extensions (or protocols) from
> adding unrelated cruft into the CAN stack.
> 
> I would propose we (read: me) create some sort of "common" core, which
> would contain the following:
>  - drivers/net/: big part of the device interface here is common
>                  big part of the virtual interface here is common
>                  -> CAN or ARINC can just add their own specific callbacks
> and be done with it
> 
>  - net/: there's a lot of common parts as well, like the filtering can be
>          unified such that it can be used by both. A big part of the socket
>          handling is also similar.
> 
> This would also let the slcan or sllin or whatever stuff they made at CVUT
> just plug into this "common" core part.
> 
> Now I wonder if we should introduce AF_ARINC or stick to AF_CAN for both.
> I'd be much happier to keep those two separate, again, to avoid confusion.
> 
> What do you think please ?

So, what do you think about this approach -- pulling out common core code from
CAN (so it can be re-used for ARINC) and having both of those (CAN and ARINC)
implement just a thin layer of adaptation code for this core ? Would this make
sense to you?
