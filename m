From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next 1/2] net: Expose header length compution function
Date: Wed, 21 May 2014 08:03:58 -0700
Message-ID: <537CC05E.6030705@intel.com>
References: <1399553434-25617-1-git-send-email-amirv@mellanox.com>			<1399553434-25617-2-git-send-email-amirv@mellanox.com>		 <20140509.162454.1317479460010270185.davem@davemloft.net>		 <536E5DF4.8010908@gmail.com>	 <1399744197.7973.11.camel@edumazet-glaptop2.roam.corp.google.com>	 <536E9FE7.6060809@gmail.com> <1400533291.5367.67.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, amirv@mellanox.com,
	netdev@vger.kernel.org, idos@mellanox.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13564 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbaEUPFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 11:05:48 -0400
In-Reply-To: <1400533291.5367.67.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2014 02:01 PM, Eric Dumazet wrote:
> On Sat, 2014-05-10 at 14:53 -0700, Alexander Duyck wrote:
> 
>> I'm more of a fan of purpose built functions in hot-path.  In the case
>> of skb_flow_dissect, it is meant to collect the inputs for a Jenkins
>> hash.
> 
> Not really.
> 
> And having multiple flow dissectors is really a lot of trouble for us,
> and contributes to code bloat.
> 
>>   If we also expand it to get the length my concern is that it may
>> do both, but it won't be very efficient at doing either, and that
>> doesn't even take into account that somebody at some point might want
>> the flow dissector to not do things like coalesce IPv6 addresses to
>> support things like a Toeplitz hash which would slow things down further.
>>
>> I can wait for the patch. I don't really see what you're talking about
>> since we are trying to linearize the header portion of the buffers and
>> for jumbos frames all 2K of the buffer has been used so you can't do any
>> tricks like use a paged frag for the head.
> 

So it looks like you did kind of what I expected you would, only you
allocated a temporary sk_buff on the stack and then pointed the head to
the start of the page.  I'm not really a fan of this approach though it
does give me a couple ideas.

One thought I just had though, what if we were to do something like
create an eth_build_skb function?  It would essentially be a cross
between eth_type_trans, your new eth_frame_headlen function, and
build_skb.  It would allow us to avoid the unnecessary allocation of an
skb on the stack and avoid any unnecessary data duplication since we
already would be doing a number of the eth_type_trans steps in your
eth_frame_headlen function.  The one limitation is that we would need to
allocate a block of memory for the head, but that would be done after we
figure out what the size of the header is.

If I get a chance I might try coding it up on Friday to see what
something like that might look like.

Thanks,

Alex
