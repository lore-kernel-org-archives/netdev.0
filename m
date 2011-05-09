From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: future developments of usbnet
Date: Mon, 9 May 2011 08:46:49 -0700
Message-ID: <20110509084649.127ec0da@nehalam>
References: <BANLkTi=AGQyvG58n9FG2Axbz7Ue8a6E3kg@mail.gmail.com>
	<Pine.LNX.4.44L0.1105091130440.2002-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Oliver Neukum <oliver@neukum.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52854 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680Ab1EIPqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 11:46:52 -0400
In-Reply-To: <Pine.LNX.4.44L0.1105091130440.2002-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 May 2011 11:31:16 -0400 (EDT)
Alan Stern <stern@rowland.harvard.edu> wrote:

> On Mon, 9 May 2011, Ming Lei wrote:
> 
> > Hi,
> > 
> > 2011/5/9 Oliver Neukum <oliver@neukum.org>:
> > 
> > > Do we really need to avoid it, or do we just need to recover?
> > > If avoidance is needed, should we use NAPI?
> > 
> > IMO, OOM can recover it certainly but with much cost, so we should
> > avoid the case. I don't think NAPI can avoid it, because NAPI will
> > cause skb to be allocated without any limit if there are packets
> > coming, still no chance left for usbnet_bh to handle and free these
> > SKBs.
> 
> How do other network drivers handle this problem?  Can the same 
> strategy be used?
> 
> Alan Stern

Most Ethernet drivers have a fixed size receive ring and pass preallocated
memory (skb's or pages) for the hardware to fill in. When NAPI poll is run
it refills the ring and passes the data up to netif_receive_skb. NAPI allows
the poll routine to process a limited number of packets (weight) and after
that the poll loop exits and gets rerun by soft interrupt.  If data is
arriving faster than the kernel can process, eventually the receive ring
passed to hardware gets exhausted and the hardware drops packets.

There is no explicit memory bound limit, instead the flow control happens
when the receive ring gets full.
