From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/2] Revert "genetlink: fix family dump race"
Date: Thu, 22 Aug 2013 14:27:26 -0700
Message-ID: <CALnjE+rjaidk+KEw4VFA_C2LoXir7VBxRuaA0xajqGd+uUt1qw@mail.gmail.com>
References: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
	<1377094083-8122-2-git-send-email-johannes@sipsolutions.net>
	<20130822.132631.2273195424430844661.davem@davemloft.net>
	<1377203769.32535.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:33314 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753794Ab3HVV2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 17:28:01 -0400
Received: by mail-qe0-f48.google.com with SMTP id 1so1435087qec.21
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 14:27:26 -0700 (PDT)
In-Reply-To: <1377203769.32535.5.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 1:36 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Thu, 2013-08-22 at 13:26 -0700, David Miller wrote:
>
>> How to deal with the problem we were attempting to solve is still
>> under discussion.  It seems that even if we go to RCU we must also
>> address to module reference count issue.
>
> Yes, that's a separate issue. However, I think we should also check in
> more detail the dumpit locking issue Pravin pointed out - before his
> changes there was indeed the genl lock used as the cb_mutex. As I've
> said over in the other thread, I'm not sure that change was actually
> useful - it sounded like he confused kernel sockets and userland sockets
> here? (Or maybe I am?!)
>
> OTOH, we've already fixed the race conditions that resulted from his
> patch, at least in nl80211. You might remember the issue Linus ran into
> with the attrbuf, it's looking like that issue was because he changed
> generic netlink to no longer use the genl_lock as the cb_mutex.
>
>> I think the existing locking is very messy, and RCU looks a lot
>> cleaner and has potential for future improvements to the scalability
>> of dumps.
>
> I agree, though we're not all that interested in generic netlink family
> scalability I think, we have less than a dozen families, so this
> shouldn't really be an issue.
>
>> So I'd like to propose that we combine Johannes's RCU conversion
>> with some variant of the module reference count fix.
>>
>> Can you guys work together and come up with something I can apply?
>
> Sure, that in itself isn't really a problem, but if we don't take
> Pravin's patch to "revert" the cb_mutex change in his parallel_ops
> changes, then we definitely need to audit all generic netlink dumpit
> implementations in all users to see if they have similar races to
> nl80211. I originally thought that it was an nl80211 problem, but I'm
> now convinced that it wasn't. Still the new code in nl80211 is probably
> nicer, and we can probably make it parallel_ops now due to these changes
> but I'm not convinced we can audit all genl families.
>

I have sent fixes for genl-locking.

> If it wasn't that so much time has already passed since the parallel_ops
> changes I'd almost suggest reverting those altogether and addressing the
> locking properly ...
>
I think genl-parallel ops patch decouple genl-locking from netlink
lock which simplifies it. This also allows existing genl-family
gradually converted to parallel-ops. Once all are moved to parallel
ops, we can get rid of genl_mutex completely.

Passing mutex after one module to another is messy and confusing.
After genl-parallel op changes this is done only by rtnl module.
I will try to get rid of this cb_mutex parameter so that each layer
can have independent locks. I need to check rtnl module for that.
