From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH v2] net: fix a double free issue for neighbour entry
Date: Wed, 20 May 2015 16:39:38 +0800
Message-ID: <555C484A.7080807@windriver.com>
References: <1432085113-25063-1-git-send-email-ying.xue@windriver.com> <1432099637.4060.12.camel@edumazet-glaptop2.roam.corp.google.com> <555C313E.1020003@windriver.com> <alpine.LFD.2.11.1505201050590.1557@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <alexei@purestorage.com>,
	<joern@purestorage.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:65454 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229AbbETIkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 04:40:03 -0400
In-Reply-To: <alpine.LFD.2.11.1505201050590.1557@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2015 04:07 PM, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 20 May 2015, Ying Xue wrote:
> 
>> On 05/20/2015 01:27 PM, Eric Dumazet wrote:
>>> Sorry, this atomic_read() makes no sense to me.
>>>
>>> When rcu is used, this is perfectly fine to use an object which refcount
>>> is 0. If you believe the opposite, then point me to relevant
>>> Documentation/RCU/ file.
>>>
>>
>> However, the reality for us is that rcu_read_lock() can guarantee that a neigh
>> object is not freed within the area covered by rcu read lock, but it cannot
>> prevent neigh_destroy() from being executed in another context at the same time.
> 
> 	The situation is that one writer decided that
> entry is to be removed. Reader comes and tries to become
> second writer. It should check refcnt==0 or dead==1 as
> in your last patch, always under write_lock.

Yes, this way is absolutely safe for us! But, for example, if we check refcnt==0
in write_lock protection, the checking is a bit late. Instead, if the checking
is advanced to ip_finish_output2(), we can _early_ find the fact that we cannot
use the neigh entry looked up by __ipv4_neigh_lookup_noref(). Of course, doing
the check with atomic_read() is unsafe _really_, but once atomic_read() returned
value tells us neigh refcnt is zero, the result is absolutely true. This is
because refcnt is always decremented from a certain value which is bigger than 0
to 0. Therefore, if atomic_read() tells us a neigh's refcnt is 0, we should
definitely create a new one; on the contrary, if it tells us a neigh's refcnt is
not zero, it doesn't mean the refcnt is really equal to 0 because atomic_read()
might read a stale refcnt value. In this situation, the condition of
!atomic_read(&neigh->refcnt)) is really useless for us. This is why I try to
involve another condition check of dead==1 to prevent it from happening in
version 2. Meanwhile, as the checking of dead==1 is conducted under write lock,
this is absolutely safe for us.

 Second and next
> writers should not try to change state, timers, etc.
> Such writers are possible only if they were readers because
> only they can find entry that is unlinked by another writer.
> 
> 	And we want to keep the readers free of any memory
> barriers as they can cost hundreds of clocks. We are lucky
> that the neigh states allow RCU readers to run without any 
> atomic_inc_not_zero calls because memory barriers are not
> cheap.
> 

Yes, I agreed with you.

Regards,
Ying

> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
> 
