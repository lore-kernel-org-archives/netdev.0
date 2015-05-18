From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 2/6] neigh: fix a possible leak issue of neigh
 entry
Date: Mon, 18 May 2015 11:24:20 +0800
Message-ID: <55595B64.70702@windriver.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>	<1431672946-300-3-git-send-email-ying.xue@windriver.com>	<1431691962.27831.90.camel@edumazet-glaptop2.roam.corp.google.com> <20150515.113950.1408734283430265055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<alexei@purestorage.com>, <joern@purestorage.com>, <ja@ssi.bg>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54014 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbbERDYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:24:39 -0400
In-Reply-To: <20150515.113950.1408734283430265055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2015 11:39 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 15 May 2015 05:12:42 -0700
> 
>> On Fri, 2015-05-15 at 14:55 +0800, Ying Xue wrote:
>>> Once modifying a pending timer of a neighbour, it's insufficient to
>>> post a warning message. Instead we should not take the neighbour's
>>> reference count at the same time, otherwise, it causes an issue that
>>> the neighbour cannot be freed forever.
>>>
>>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>>> ---
>>>  net/core/neighbour.c |    9 +++++----
>>>  1 file changed, 5 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>>> index 3de6542..5595db3 100644
>>> --- a/net/core/neighbour.c
>>> +++ b/net/core/neighbour.c
>>> @@ -164,10 +164,11 @@ static int neigh_forced_gc(struct neigh_table *tbl)
>>>  
>>>  static void neigh_add_timer(struct neighbour *n, unsigned long when)
>>>  {
>>> -	neigh_hold(n);
>>> -	if (unlikely(mod_timer(&n->timer, when))) {
>>> -		printk("NEIGH: BUG, double timer add, state is %x\n",
>>> -		       n->nud_state);
>>> +	if (likely(!mod_timer(&n->timer, when))) {
>>> +		neigh_hold(n);
>>> +	} else {
>>> +		pr_warn("NEIGH: BUG, double timer add, state is %x\n",
>>> +			n->nud_state);
>>>  		dump_stack();
>>>  	}
>>>  }
>>
>>
>> NACK
> 
> Indeed, major NACK.  And you've been told this change is unacceptable
> multiple times already, and you've been told exactly why as well.
> 

Eric, according to your below comments for the single patch,

http://www.spinics.net/lists/netdev/msg328828.html

I supposed the reason why you rejected it was because the issue of "neigh
use-after-free" was not resolved yet. More importantly, you did not explicitly
explain why the patch was wrong although I stated the problem the patch tries to
fix is different with the one discussed in the thread:

http://www.spinics.net/lists/netdev/msg323883.html

So, regarding my understanding for your comment, the patch can be acceptable if
the issue of "neigh use-after-free" is solved.

Since then I started to investigate its root cause and created the first patch
attempting to fix it. This is why I involve the patch into the series again.

If the issue of "neigh use-after-free" is fixed by the first patch although you
said the atomic_read() was not safe for us, is the patch still wrong? If it's
really wrong, can you please give more detailed explanation to help me
understand why the change is wrong and but why a similar timer usage in
sk_reset_timer() is not wrong?

Thanks,
Ying
