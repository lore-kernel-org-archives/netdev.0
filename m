From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.24]S2io: Default to IntA interrupt type when there are less than 4 CPUs in the system.
Date: Fri, 10 Aug 2007 15:14:41 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702035B30@nekter>
References: <46BCA2B0.7020501@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	<netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Jeff Garzik" <jeff@garzik.org>, "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:8863 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755702AbXHJTST convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 15:18:19 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46BCA2B0.7020501@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We had found during performance measurement/analysis that with 2 cpus
and napi disabled, and the system transmitting (tcp), the cpus get too
busy due to receive interrupt handling, reducing performance by around
10%.
 
But then again, when the number of cpus increase, the interrupt scaling
is much better and msi-x gives better numbers.

We are modifying the driver to enable napi with msi-x, but this work is
in progress and may get released in a few months. 

The Xframe hardware has 8 independent dma channels for transmit and
receive, with doorbells for each channel. Multiple channels are in use
for a single netdev. In one of the variations of this driver that is not
released to netdev, the received packets are steered to a channel based
on hashing on a preconfigured criteria such as sockets on tcp_ipv4,
udp_ipv4, tcp_ipv6, udp_ipv6 or addresses in ipv4/6. The transmits are
handled in a similar manner. 

The current napi implementation looks like  -
driver_poll(struct net_device *dev, int *budget)

where as, something like -
driver_poll(struct context *context, int *budget)

would be ideal for hardware like ours. Each channel could schedule a
respective poller, rather than the current method which requires
synchronization between the poller and the channels.

Ram
> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org]
> Sent: Friday, August 10, 2007 10:39 AM
> To: Rick Jones
> Cc: Sivakumar Subramani; netdev@vger.kernel.org; support
> Subject: Re: [PATCH 2.6.24]S2io: Default to IntA interrupt type when
there
> are less than 4 CPUs in the system.
> 
> Rick Jones wrote:
> > Sivakumar Subramani wrote:
> >> - Default to IntA interrupt type when there are less than 4 CPUs in
> >> the system.
> >
> > It might be good to include _why_ in the comment(s).  I certainly am
> > curious to know the reason, and it would be good to have in there
for
> > "posterity" should the underlying conditions change.
> 
> Indeed.  I really want to know 'why'?
> 
> 	Jeff
> 
> 

