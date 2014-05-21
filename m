From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Expose header length compution
 function
Date: Wed, 21 May 2014 10:41:57 -0700
Message-ID: <1400694117.5367.159.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399553434-25617-1-git-send-email-amirv@mellanox.com>
					<1399553434-25617-2-git-send-email-amirv@mellanox.com>
				 <20140509.162454.1317479460010270185.davem@davemloft.net>
				 <536E5DF4.8010908@gmail.com>
			 <1399744197.7973.11.camel@edumazet-glaptop2.roam.corp.google.com>
			 <536E9FE7.6060809@gmail.com>
		 <1400533291.5367.67.camel@edumazet-glaptop2.roam.corp.google.com>
		 <537CC05E.6030705@intel.com>
	 <1400687469.5367.152.camel@edumazet-glaptop2.roam.corp.google.com>
	 <537CD80F.2090909@intel.com>
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
Received: from mail-pb0-f54.google.com ([209.85.160.54]:47110 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbaEURl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 13:41:58 -0400
Received: by mail-pb0-f54.google.com with SMTP id jt11so1635121pbb.27
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 10:41:58 -0700 (PDT)
In-Reply-To: <537CD80F.2090909@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-21 at 09:45 -0700, Alexander Duyck wrote:

> We have had stack smashing issues in the past with the ixgbe interrupt
> handlers and it wasn't consuming much memory on the stack as I recall. 
> I prefer to err on the side of caution.

Well, if we can not temporarily use 256 bytes in a leaf function in rx
handler of a driver, how IP + TCP stack will ever work ?

> Also the more I think about it I am not really comfortable putting a
> partially initialized sk_buff through any function calls.  It seems like
> it is setting somebody up for a failure because if at some point the
> code changes and needs some other field out of the skb it won't be
> initialized here unless they catch this tricky bit of code.

We are speaking of flow_dissect, which is a leaf function if 
data_len = 0

The fields I setup are the only ones that can be read from flow
dissection.

We look at a frame, given a starting point (network header) and protocol
(skb->protocol).

Apparent complexity is apparent only : skb_header_pointer() is basically
a nop if data_len = 0

Sure, you can add a

#ifdef DEBUG_FLOW_DISSECT
   memset(&skb, 0x6b, sizeof(skb));
#endif

And I did/tried that before sending the patch ;)
