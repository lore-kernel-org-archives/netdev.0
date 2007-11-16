From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0
Date: Fri, 16 Nov 2007 14:26:19 -0500
Message-ID: <20071116142619.8746376e.billfink@mindspring.com>
References: <cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com>
	<20071115.152813.89410917.davem@davemloft.net>
	<cac0ab7d0711160030w149c7a7s2db55ac56d0a05cc@mail.gmail.com>
	<20071116.010548.94286711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: the.sator@gmail.com, kuznet@ms2.inr.ac.ru,
	linux-kernel@vger.kernel.org, jmorris@namei.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:34883 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756408AbXKPT0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 14:26:34 -0500
In-Reply-To: <20071116.010548.94286711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Nov 2007, David Miller wrote:

> From: "Jonas Danielsson" <the.sator@gmail.com>
> Date: Fri, 16 Nov 2007 09:30:11 +0100
> 
> > 2007/11/16, David Miller <davem@davemloft.net>:
> > > From: "Jonas Danielsson" <the.sator@gmail.com>
> > > Date: Thu, 15 Nov 2007 22:40:13 +0100
> > >
> > > > Is there a reason that the target hardware address isn't the target
> > > > hardware address?
> > 
> > > Because of this, in cases where a choice can be made Linux will
> > > advertise what is most likely to result in successful communication.
> > >
> > > This is likely why we are changing that target address to the one of
> > > the interface actually sending back the reply rather than the zero
> > > value you used.
> > >
> > > In fact I think this information can be useful to the sender of
> > > the DAD request.
> > >
> > 
> > There seem to be some confusion about what my patch really does. It
> > does not set the hardware address to a zero value.
> 
> I knew you were talking about the IP address not the hardware
> address.
> 
> > The reply from the Linux kernel in computer A, before the patch would look like:
> > 
> > Reply:
> > Opcode: reply (0x0002)
> > Sender HW: 00:AA.00:AA:00:AA
> > Sender IP:   192.168.0.1
> > Target HW:  00:AA:00:AA:00:AA
> > Target IP:    192.168.0.1
> 
> And this is exactly a sensible response in my opinion.

I don't see how you can say that, since it appears to be in violation
of RFC 826:

	"The target hardware address is included for completeness and
	network monitoring.  It has no meaning in the request form,
	since it is this number that the machine is requesting.  Its
	meaning in the reply form is the address of the machine making
	the request.  In some implementations (which do not get to look
	at the 14.byte ethernet header, for example) this may save some
	register shuffling or stack space by sending this field to the
	hardware driver as the hardware destination address of the
	packet."

Since the MAC address of the machine making the request is
00:BB:00:BB:00:BB, and not 00:AA:00:AA:00:AA, Linux appears to
be in violation of the ARP RFC.

Regarding the Target IP, RFC 826 says:

	"The target protocol address is necessary in the request form
	of the packet so that a machine can determine whether or not
	to enter the sender information in a table or to send a reply.
	It is not necessarily needed in the reply form if one assumes
	a reply is only provoked by a request.  It is included for
	completeness, network monitoring, and to simplify the suggested
	processing algorithm described above (which does not look at
	the opcode until AFTER putting the sender information in a
	table).

So it's ambiguous about the target IP address in an ARP reply packet,
but a value of 0.0.0.0 makes more logical sense to me than using
192.168.0.1 in this example case, since it should reflect the requestor
IP address, which is unknown in this case.

						-Bill
