From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: skbuff truesize incorrect.
Date: Tue, 27 May 2014 15:23:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724E565@AcuExch.aculab.com>
References: <537E4AFD.20304@mentor.com>
	<1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D1724C490@AcuExch.aculab.com>
 <20140523.161823.1006372695373018122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"jim_baxter@mentor.com" <jim_baxter@mentor.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kamal@canonical.com" <kamal@canonical.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"mszeredi@suse.cz" <mszeredi@suse.cz>,
	"fw@strlen.de" <fw@strlen.de>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57255 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752657AbaE0PYK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 11:24:10 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28716-09 for <netdev@vger.kernel.org>;
 Tue, 27 May 2014 16:24:01 +0100 (BST)
In-Reply-To: <20140523.161823.1006372695373018122.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Fri, 23 May 2014 08:52:13 +0000
> 
> > The hardware will put multiple ethernet frames into a single USB bulk data
> > message. To handle this the driver generates a URB that is (hopefully) long
> > enough for the longest USB message (typically 32k is assumed to be enough).
> > The URB that usb_net generated have the data in a linear skb - which then
> > has a large 'truesize'.
> >
> > Since USB bulk data are terminated by a short fragment there is actually
> > no need for the URB be long enough for the full message. Provided the
> > URB are multiples of the USB message size (1k for USB 3) the message
> > can be received into multiple URB - the driver just has to be willing
> > to merge URB buffers (as well as split them) when generating the ethernet
> > frames.
> 
> I think we could take a less invasive approach.
> 
> Use whatever order page is needed for that 32K chunk for the URB,
> but split up the compound page so that the individual pages can be
> accounted for separately.

Using 4k 'pages' would be fine (or even 1k).
All the USB interfaces support SG provided the fragments are all
aligned.
Recycling the unused 4k pages would probably be better than using
separate URB for each fragment.

Note that the xhci driver has to split buffers that cross 64k
boundaries into separate ring entries - and these must not cross
the end of the ring (thank you hardware engineers...).
So not receiving into the 'linear' part of an skb helps.

Although I suspect that 32k is excessive - provided the driver can
merge URB (as well as pages) to generate ethernet frames.

> Hook up the pages into the SKB frag array, and only account PAGE_SIZE
> into the SKB truesize for the individual pages actually used from
> the superpage.
> 
> This will largely retain the URB allocation and processing scheme,
> yet at the same time dramatically decrease the truesize overrage
> factor.

True, you still need to sort out how to handle multiple ethernet
frames in the same 4k page, and arbitrary page boundaries within a frame.

I suspect that using 1k or 2k pages and using 'copybreak' to never pass
up shared pages would give the best overall performance.

	David
