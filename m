From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Thu, 22 May 2008 22:14:01 +0400
Message-ID: <20080522181401.GA14056@2ka.mipt.ru>
References: <20080522064058.GB7777@2ka.mipt.ru> <31256957387BB54C8B9AFE88AA5C0564044A1834@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Keyur Chudgar <kchudgar.linux@gmail.com>, netdev@vger.kernel.org
To: Keyur Chudgar <kchudgar@amcc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53432 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757275AbYEVSOR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 14:14:17 -0400
Content-Disposition: inline
In-Reply-To: <31256957387BB54C8B9AFE88AA5C0564044A1834@SDCEXCHANGE01.ad.amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 22, 2008 at 11:00:23AM -0700, Keyur Chudgar (kchudgar@amcc.com) wrote:
> Hi,
> 
> Following is what I would like to understand.  I am working with an
> ethernet MAC that is capable of chaining multiple buffers (fixed size)
> together to form a single packet.  For example, a packet size of 2k
> would fit into 1k size hardware buffers.  So, at initialization time, I
> configure the MAC buffer descriptor in the following way.  I allocate 2
> skb's (ie. dev_alloc_skb(1024)) and pass the skb.data pointers to the

A nitpick: hope it is not NIC initialization time, since skb can live
very long time in stack and if you statically bind single skb to
hardware descriptor during NIC init time you will be very short on skbs.

> mac buffer descriptors as shown in the diagram below.
> 
> 	-------------	-------------------
> 	| skb1->data |--->| First part of   |
> 	--------------	| Packet in buf1	|
> 				|------------------
> 
> 	-------------	-------------------
> 	| skb2->data |--->| Second part of  |
> 	--------------	| same packet in	|
> 				| buf2		|
> 				|------------------
> 
> So, when a packet is received by the MAC, it will give me (rx portion of
> the driver) the two descriptors associated with that single packet size
> of 2k.  Here, I would like to avoid copying.  To this end, what options
> do I have available to me at the driver level so that stack gets a
> single skb with multiple chained buffers.  In short, I would like to
> represent a single packet comprised of multiple SKB's.  So, when the
> stack free's this packet, it will have to have a way of freeing all of
> the underlying SKB's.
>  
> Will your previous suggestion apply for the above scenerio?  If not, do
> I have any other options than to do memcpy on Rx, in the driver.  

You have to chain second skb into frag_list of the first one.
But it is not preferred solution, better attach a page to each hardware
descriptor and put pages from each part into single skb via skb_fill_page_desc().
Or you can play with parts of the pages for DMA if your hardware does
not allow to DMA big portions from single descriptor (like in your
example above where each HW descriptor is limited to 1k).

-- 
	Evgeniy Polyakov
