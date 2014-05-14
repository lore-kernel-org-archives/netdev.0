From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: xen-netfront possibly rides the rocket too often
Date: Wed, 14 May 2014 21:06:41 +0100
Message-ID: <5373CCD1.4050509@citrix.com>
References: <537262AB.5010408@canonical.com> <5373C8D4.2010803@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
To: Stefan Bader <stefan.bader@canonical.com>,
	<xen-devel@lists.xenproject.org>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:57976 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaENUGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 16:06:44 -0400
In-Reply-To: <5373C8D4.2010803@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/05/14 20:49, Zoltan Kiss wrote:
> On 13/05/14 19:21, Stefan Bader wrote:
>> Since I am not deeply familiar with the networking code, I wonder
>> about two things:
>> - is there something that should limit the skb data length from all frags
>>    to stay below the 64K which the definition of MAX_SKB_FRAGS hints?
> I think netfront should be able to handle 64K packets at most.
>> - is multiple frags having offsets expected?
> Yes, since compound pages a frag could over the 4K page boundary. The
> problem is, that in the netback/front protocol the assumption is that
> every slot is a single page, because grant operations could be done only
> on a 4K page. And every slot ends up as a frag (expect maybe the first,
> it can happen it is grant copied straight to the linear buffer),
> therefore the frontend cannot send an skb which occupies more than
> MAX_SKB_FRAGS individual 4k page.
> The problem is known for a while, the solution is not, unfortunately.

I think the worst case scenario is when every frag and the linear buffer 
contains 2 bytes, which are overlapping a page boundary (that's 
(17+1)*2=36 so far), plus 15 of them have a 4k page in the middle of 
them, so, a 1+4096+1 byte buffer can span over 3 page. That's 51 
individual pages.
With the previous grant copy implementation there would be the option to 
modify backend and coalesce everything into a well formed skb. That 
would be a minor change there. But with grant mapping it's harder.
Slots of compound pages could be mapped to adjacent pages to Dom0, maybe 
somehow you can present them as compound pages in Dom0 as well. But in 
MFN space they wouldn't be contiguous, you need SWIOTLB or use IOMMU to 
hide that from the devices. Plus, what happens when you can't find 
adjacent pending slots?
I think we would be better off at the moment with trying to compact 
these skbs a bit. Usually they overflow the limit by one or two, which 
means we should reallocate one or two frag, or the linear buffer to 
decrease the number of 4K pages used.

Zoli
