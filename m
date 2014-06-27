From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] pktgen: Fill the payload optionally with a pattern
Date: Fri, 27 Jun 2014 21:22:01 +0100
Message-ID: <53ADD269.5050802@citrix.com>
References: <1403642415-9560-1-git-send-email-zoltan.kiss@citrix.com>	<20140625.175417.231387590142784357.davem@davemloft.net>	<53AD32E3.7030405@schaman.hu> <20140627.123028.1903125579029261105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <steffen.klassert@secunet.com>, <minipli@googlemail.com>,
	<dborkman@redhat.com>, <tgraf@suug.ch>, <joe@perches.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140627.123028.1903125579029261105.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/06/14 20:30, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@schaman.hu>
> Date: Fri, 27 Jun 2014 10:01:23 +0100
>
>> On 26/06/14 01:54, David Miller wrote:
>>> From: Zoltan Kiss <zoltan.kiss@citrix.com>
>>> Date: Tue, 24 Jun 2014 21:40:15 +0100
>>>
>>>> Introduces a new flag called PATTERN, which puts a non-periodic,
>>>> predicatble
>>>> pattern into the payload. This was useful to reproduce an otherwise
>>>> intermittent
>>>> bug in xen-netback [1], where checksum checking doesn't help.
>>>> The pattern is a repetition of " %lu", a series of increasing numbers
>>>> divided by
>>>> space. The value of the number is the size of the preceding payload
>>>> area. E.g.
>>>> " 1 3 5"..." 1000 1005 1010"
>>>> If the pattern is used, every frag will have its own page, unlike
>>>> before, so it
>>>> needs more memory.
>>>>
>>>> [1] 5837574: xen-netback: Fix grant ref resolution in RX path
>>>>
>>>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>>> You are changing the page allocation strategy regardless of the
>>> pattern
>>> setting, this is undesirable.
>>>
>>> It may be significantly faster to use the same page for all the frags,
>>> and this is absolutely critical for pktgen usage where every
>>> nanosecond
>>> of performance counts.
>> If the PATTERN flag is not used, it always using the pages[0] page, so
>> it falls back to the original way.
>
> That's now what I see.
>
> If the size exceeds a page, the current code will use the same page over
> and over again.
>
> Your new code always increments 'i' and allocates a new page, regardless
> of whether the PATTERN flag is set.
>
> Or do I misread your changes?

My first patch uses fragpage to index the pages array, and it is always 
0, if the PATTERN frag were not specified. (i was incremented by the old 
code as well btw.)
The second one (see it in the other thread) adds individual frag size 
and offset, if that exceeds PAGE_SIZE, then it always reallocate the 
page, but I guess that's not a terrible thing, as the aim here is not 
performance testing, but finding bugs. But I can add a further checking 
to compare the allocation order of the current page with the required one.
Also, I think I should keep the __GFP_ZERO flags for every page 
allocation. Even if I fill up the frag with a pattern, it's better to 
have a deterministic content on the rest of the page, just in case some 
royal screwup leaks data from the rest of the page.
Also, turning off the PATTERN flag doesn't reallocate the pages, so the 
next packet will have the pattern from the previous instead of zeros.

Zoli
