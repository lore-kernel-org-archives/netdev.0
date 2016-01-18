From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Mon, 18 Jan 2016 11:27:03 +0100
Message-ID: <20160118112703.6eac71ca@redhat.com>
References: <20160115142223.1e92be75@redhat.com>
	<20160115.154721.458450438918273509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	alexei.starovoitov@gmail.com, borkmann@iogearbox.net,
	marek@cloudflare.com, hannes@stressinduktion.org, fw@strlen.de,
	pabeni@redhat.com, john.r.fastabend@intel.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57096 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754449AbcARK1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2016 05:27:09 -0500
In-Reply-To: <20160115.154721.458450438918273509.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jan 2016 15:47:21 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Fri, 15 Jan 2016 14:22:23 +0100
> 
> > This was only at the driver level.  I also would like some API towards
> > the stack.  Maybe we could simple pass a skb-list?
> 
> Datastructures are everything so maybe we can create some kind of SKB
> bundle abstractions.  Whether it's a lockless array or a linked list
> behind it doesn't really matter.
> 
> We could have two categories: Related and Unrelated.
> 
> If you think about GRO and routing keys you might see what I am getting
> at. :-)

Yes, I think I get it.  I like the idea of Related and Unrelated.
We already have GRO packets which is in the "Related" category/type.

I'm wondering about the API between driver and "GRO-layer" (calling
napi_gro_receive):

Down in the driver layer (RX), I think it is too early to categorize
Related/Unrelated SKB's, because we want to delay touching packet-data
as long as possible (waiting for the prefetcher to get data into
cache).

We could keep the napi_gro_receive() call.  But in-order to save
icache, then the driver could just create it's own simple loop around
napi_gro_receive().  This loop's icache and extra function call per
packet would cost something.

The down side is: The GRO layer will have no-idea how many "more"
packets are coming.  Thus, it depends on a "flush" API, which for
"xmit_more" didn't work out that well.

The NAPI drivers actually already have a flush API (calling
napi_complete_done()), BUT it does not always get invoked, e.g. if the
driver have more work to do, and want to keep polling.
 I'm not sure we want to delay "flushing" packets queued in the GRO
layer for this long(?).


The simplest solution to get around this (flush and driver loop
complexity), would be to create a SKB-list down in the driver, and
call napi_gro_receive() with this list.  Simply extending napi_gro_receive()
with a SKB list loop.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
