From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 5 Nov 2008 09:49:08 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60EC5@NASANEXMB10.na.qualcomm.com>
References: <1225898199.5273.125.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Johann Baudy <johaahn@gmail.com>, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:49624 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbYKERtN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 12:49:13 -0500
In-Reply-To: <1225898199.5273.125.camel@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Johann Baudy [mailto:johaahn@gmail.com]
> Sent: November-05-08 7:17 AM
> To: Patrick McHardy
> Cc: Lovich, Vitali; netdev@vger.kernel.org; Evgeniy Polyakov
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> Hi Patrick,
> 
> 
> > The reason why its not in there is to avoid the unnecessary
> > barrier when setting up the ring in packet_set_ring().
> 
> Is it a serious problem? packet_set_status() and packet_get_status()
> will be called from multiple places and we will obtain a write/read
> barrier at each call. I imagine that's more clean to insert those
> barriers inside status functions even if we add only one useless flush
> at the beginning. No?
You can put a smp_rmb after reading the status in packet_get_status, and a smp_wmb before setting the status in packet_set_status.  Avoiding it because packet_set_ring doesn't need it is an unnecessary optimization in my opinion; it's not the performance critical path so it's not going to cost anything (allocating the memory is far more expensive anyways than a memory barrier). 

> 
> >
> > The code is fishy though, I agree. Have a look at this discussion:
> >
> > http://marc.info/?l=linux-netdev&m=119383985207984&w=2
> >
> My approach was to use the mechanism of RX_RING where the kernel is
> allocating the buffer. In order to get something similar from kernel
> and
> user point of view. Moving kernel buffer to user space could be studied
> as global enhancement for RX_RING and TX_RING but that will need user
> application changes.
I'm not seeing a resolution in the above thread - is af_packet wrong in the order it flushes the pages?  It certainly seems like a valid question (I'm on x86, so this is an academic issue for me).
> 
> I'm wondering if I also need to use flush_dcache_page() before getting
> status buffer and attaching circular buffer pages to skb (both written
> by user).
> According to this quote in [cachetlb.txt] of flush_dcache_page part:
> 	Any time the kernel writes to a page cache page, _OR_
> 	the kernel is about to read from a page cache page and
> 	user space shared/writable mappings of this page potentially
> 	exist, this routine is called.
>  	...
> 	The phrase "kernel writes to a page cache page" means,
> 	...
> 	The corollary case is just as important, if there are users
> 	which have shared+writable mappings of this file, we must make
> 	sure that kernel reads of these pages will see the most recent
> 	stores done by the user.
> 
> Can someone confirm?
It sounds like you are correct - you need to call flush_dcache_page.  Presumably this can happen after you read the status flag, unless there's a possibility that you never actually get that update, in which case you should be safe and do it before, although I'm not sure then of how significant the performance impact is.  More importantly, I think is the comment in the documentation that the deferred flush must happen on the same CPU as where the stores occurred, so what I come away from this is that I don't think I understand the situation well enough with flush_dcache_page.
> 
> Thanks in advance,
> Johann
> 

Thanks,
Vitali
