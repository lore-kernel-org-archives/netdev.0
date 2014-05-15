From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Thu, 15 May 2014 10:38:16 +0200
Message-ID: <1721040118.20140515103816@eikelenboom.it>
References: <537262AB.5010408@canonical.com> <5373C8D4.2010803@citrix.com> <5373CCD1.4050509@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stefan Bader <stefan.bader@canonical.com>,
	xen-devel@lists.xenproject.org, netdev <netdev@vger.kernel.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:52781 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaEOIiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 04:38:21 -0400
In-Reply-To: <5373CCD1.4050509@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wednesday, May 14, 2014, 10:06:41 PM, you wrote:

> On 14/05/14 20:49, Zoltan Kiss wrote:
>> On 13/05/14 19:21, Stefan Bader wrote:
>>> Since I am not deeply familiar with the networking code, I wonder
>>> about two things:
>>> - is there something that should limit the skb data length from all frags
>>>    to stay below the 64K which the definition of MAX_SKB_FRAGS hints?
>> I think netfront should be able to handle 64K packets at most.
>>> - is multiple frags having offsets expected?
>> Yes, since compound pages a frag could over the 4K page boundary. The
>> problem is, that in the netback/front protocol the assumption is that
>> every slot is a single page, because grant operations could be done only
>> on a 4K page. And every slot ends up as a frag (expect maybe the first,
>> it can happen it is grant copied straight to the linear buffer),
>> therefore the frontend cannot send an skb which occupies more than
>> MAX_SKB_FRAGS individual 4k page.
>> The problem is known for a while, the solution is not, unfortunately.

> I think the worst case scenario is when every frag and the linear buffer 
> contains 2 bytes, which are overlapping a page boundary (that's 
> (17+1)*2=36 so far), plus 15 of them have a 4k page in the middle of 
> them, so, a 1+4096+1 byte buffer can span over 3 page. That's 51 
> individual pages.
> With the previous grant copy implementation there would be the option to 
> modify backend and coalesce everything into a well formed skb. That 
> would be a minor change there. But with grant mapping it's harder.
> Slots of compound pages could be mapped to adjacent pages to Dom0, maybe 
> somehow you can present them as compound pages in Dom0 as well. But in 
> MFN space they wouldn't be contiguous, you need SWIOTLB or use IOMMU to 
> hide that from the devices. Plus, what happens when you can't find 
> adjacent pending slots?
> I think we would be better off at the moment with trying to compact 
> these skbs a bit. Usually they overflow the limit by one or two, which 
> means we should reallocate one or two frag, or the linear buffer to 
> decrease the number of 4K pages used.

How does virtio-net handle this, the would probably have ran into the same problems ?

--
Sander

> Zoli
