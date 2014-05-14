From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net RFC] xen-netback: Fix grant ref resolution in RX path
Date: Wed, 14 May 2014 14:25:14 +0100
Message-ID: <53736EBA.7050401@citrix.com>
References: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com>	 <1399997635.7973.56.camel@edumazet-glaptop2.roam.corp.google.com>	 <53734F9F.2010101@citrix.com> <1400067318.7973.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <linux@eikelenboom.it>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:65332 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755627AbaENNZT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 09:25:19 -0400
In-Reply-To: <1400067318.7973.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/05/14 12:35, Eric Dumazet wrote:
> On Wed, 2014-05-14 at 12:12 +0100, Zoltan Kiss wrote:
>> On 13/05/14 17:13, Eric Dumazet wrote:
>>>
>>> The 'cleanup' of stale ubufs should be right after __pskb_pull_tail().
>> We can't fix every place in the kernel where frags might be changed,
>> especially with a netback specific stuff, so unfortunately that won't work
>>>
>>> This is the function that can 'consume frags' after all.
>>>
>>> Its not clear that you catch all cases, like skbs being purged in case
>>> of device dismantle.
>> We need this list for two reason:
>> a) give back the pages to the sending guest (kfree/skb_copy_ubufs)
>
> So If networking stack takes a reference on one particular frag, or
> releases a ref on a frag, how is it done exactly ?
Releasing a frag (= put_page) is not a problem, it will be given back to 
the guest when the skb is freed up. But taking an another ref is bad, 
because the destructor_arg is on shinfo, an another skb won't have the 
information about how to release that frag. That's why skb_orphan_frags 
exist, it triggers a local copy of the frags to be done, and release 
them back, so later on this feature doesn't cause a trouble. skb_clone 
does that as first thing, for example.
But of course it should be carefully checked that functions which place 
frags into another frags arrays should call orphan_frags, e.g. I guess 
skb_shift does such thing. That's what I intend to start another thread 
about.
>
> Are you 'giving back' page to the guest later because ubuf chain is now
> obsolete ???
>
>
>> b) find out the grant refs when the skb is sent to another vif
>> b) is handled by this patch. For a) netback doesn't mind if granted
>> frags were removed and/or local ones were injected. It only needs to
>> give back the pages, it doesn't matter how the skb ended up.
>
>> The only other problematic point if frags are passed around between
>> skbs, I'll write a separate mail about it.
>
> Well, it seems this is exactly the point.
> You give 'very special skb' to the stack, expecting stack will never do
> any frag games, like in skb_try_coalesce()
That's another function which needs an orphan_frag. Btw. usually these 
functions doesn't touch these packets, as they don't reach the upper 
layers of the stack, unless a frontend wants a socket connection to the 
backend domain.
