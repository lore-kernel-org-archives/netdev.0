From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Expose header length compution
 function
Date: Wed, 21 May 2014 08:51:09 -0700
Message-ID: <1400687469.5367.152.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399553434-25617-1-git-send-email-amirv@mellanox.com>
				<1399553434-25617-2-git-send-email-amirv@mellanox.com>
			 <20140509.162454.1317479460010270185.davem@davemloft.net>
			 <536E5DF4.8010908@gmail.com>
		 <1399744197.7973.11.camel@edumazet-glaptop2.roam.corp.google.com>
		 <536E9FE7.6060809@gmail.com>
	 <1400533291.5367.67.camel@edumazet-glaptop2.roam.corp.google.com>
	 <537CC05E.6030705@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>, amirv@mellanox.com,
	netdev@vger.kernel.org, idos@mellanox.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:42614 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbaEUPvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 11:51:11 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so1501655pdj.6
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 08:51:10 -0700 (PDT)
In-Reply-To: <537CC05E.6030705@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-21 at 08:03 -0700, Alexander Duyck wrote:

> So it looks like you did kind of what I expected you would, only you
> allocated a temporary sk_buff on the stack and then pointed the head to
> the start of the page.  I'm not really a fan of this approach though it
> does give me a couple ideas.
> 
> One thought I just had though, what if we were to do something like
> create an eth_build_skb function?

Well, it all depends if you use napi_get_frags() / napi_gro_frags(),
which are normally the way to get very fast GRO processing, since
you don't even have to allocate memory for the skbs at all, since
skb will likely be recycled in napi_reuse_skb()

>   It would essentially be a cross
> between eth_type_trans, your new eth_frame_headlen function, and
> build_skb.  It would allow us to avoid the unnecessary allocation of an
> skb on the stack and avoid any unnecessary data duplication since we
> already would be doing a number of the eth_type_trans steps in your
> eth_frame_headlen function.  The one limitation is that we would need to
> allocate a block of memory for the head, but that would be done after we
> figure out what the size of the header is.

'Allocating' an skb on stack has no cost. Exactly 0 added instructions.

It only increases the size of stack, and at this point we are before all
the networking stacks, so it is safe.

Have you seen the eBPF stuff adding more stack usage than this ?

#define MAX_BPF_STACK 512
