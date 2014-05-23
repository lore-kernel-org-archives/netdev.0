From: David Miller <davem@davemloft.net>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 16:18:23 -0400 (EDT)
Message-ID: <20140523.161823.1006372695373018122.davem@davemloft.net>
References: <537E4AFD.20304@mentor.com>
	<1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D1724C490@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jim_baxter@mentor.com,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kamal@canonical.com,
	bhutchings@solarflare.com, edumazet@google.com, mszeredi@suse.cz,
	fw@strlen.de
To: David.Laight@ACULAB.COM
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724C490@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Laight <David.Laight@ACULAB.COM>
Date: Fri, 23 May 2014 08:52:13 +0000

> The hardware will put multiple ethernet frames into a single USB bulk data
> message. To handle this the driver generates a URB that is (hopefully) long
> enough for the longest USB message (typically 32k is assumed to be enough).
> The URB that usb_net generated have the data in a linear skb - which then
> has a large 'truesize'.
> 
> Since USB bulk data are terminated by a short fragment there is actually
> no need for the URB be long enough for the full message. Provided the
> URB are multiples of the USB message size (1k for USB 3) the message
> can be received into multiple URB - the driver just has to be willing
> to merge URB buffers (as well as split them) when generating the ethernet
> frames.

I think we could take a less invasive approach.

Use whatever order page is needed for that 32K chunk for the URB,
but split up the compound page so that the individual pages can be
accounted for separately.

Hook up the pages into the SKB frag array, and only account PAGE_SIZE
into the SKB truesize for the individual pages actually used from
the superpage.

This will largely retain the URB allocation and processing scheme,
yet at the same time dramatically decrease the truesize overrage
factor.

> What the driver needs to do us allocate URB with 2k (or 4k) buffers and
> only allocate the skb when processing the receive data.
> Unfortunately this is a major rework of usb_net.c

> Note that some of the usb ethernet drivers allocate large skb then
> lie about the truesize.

Which has to be fixed, as Eric explained.
