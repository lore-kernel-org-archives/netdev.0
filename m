From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Mon, 22 Jun 2009 05:43:15 +0000
Message-ID: <20090622054315.GA4928@ff.dom.local>
References: <20090621171141.GA2893@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mbizon@freebox.fr, dada1@cosmosbay.com, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:1142 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbZFVFnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 01:43:20 -0400
Received: by fg-out-1718.google.com with SMTP id d23so467018fga.17
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2009 22:43:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090621171141.GA2893@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21-06-2009 19:11, Neil Horman wrote:
> On Sat, Jun 20, 2009 at 04:47:48PM -0700, David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Sat, 20 Jun 2009 18:39:25 +0200
>>
>>> Jarek Poplawski wrote, On 06/20/2009 02:37 PM:
>>>
>>>> Neil Horman wrote, On 06/19/2009 07:18 PM:
>>>>
>>>>> Don't drop route if we're not caching	
>>> ...
>>>
>>>>>  route.c |   14 ++++++++++++--
>>>>>  1 file changed, 12 insertions(+), 2 deletions(-)
>>>>>
>>>>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>>>>> index cd76b3c..65b3a8b 100644
>>>>> --- a/net/ipv4/route.c
>>>>> +++ b/net/ipv4/route.c
>>>>> @@ -1085,8 +1085,16 @@ restart:
>>>>>  	now = jiffies;
>>>>>  
>>>>>  	if (!rt_caching(dev_net(rt->u.dst.dev))) {
>>>>> -		rt_drop(rt);
>>>
>>> One more question: if this rt is assigned to an skb, there is only
>>> skb_dst_drop() in kfree_skb(), but it seems we skip rt_free() part,
>>> or I miss something?
>> This whole code path was buggy, if it returns success it should
>> do as the normal success code path does which is assign for
>> non-SKB case to *rp, or skb_dst_set().
> 
> So I'm a bit confused.  I see how my patch corrects the path we take through
> rt_intern_hash, doing the same thing that we normally do in the success case.
> What I don't see is how we clean up those dst entries when we're done with them.
> Since their not placed in the route cache (assuming rt_caching returns zero),
> then don't we have a leak, since the garbage collector will never see it in the
> cache to reap.
> 
> Assuming thats the case, I was thinking about closing that leak by setting
> DST_NOHASH in rt_intern_hash for any dst_entry that was submitted when
> rt_caching returns zero.  Then in skb_dst_drop, we can check for dst->_refcnt
> == 0, and if flags & DST_NOHASH is true, then we can call dst_free on it.  Or
> does that remove the dst_entry before a caller might be done with it in some
> cases?

Maybe it can work, but it needs a thorough checking now and adds a new
code path to track later while looking for bugs. So, I wonder if it's
not better to link such dsts in rt_intern_hash anyway, probably as a
separate list, scanned only for expired entries.

Thanks,
Jarek P.
