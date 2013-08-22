From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] Revert "genetlink: fix family dump race"
Date: Thu, 22 Aug 2013 22:36:09 +0200
Message-ID: <1377203769.32535.5.camel@jlt4.sipsolutions.net>
References: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
	 <1377094083-8122-2-git-send-email-johannes@sipsolutions.net>
	 <20130822.132631.2273195424430844661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch,
	Pravin Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:36254 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab3HVUgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 16:36:16 -0400
In-Reply-To: <20130822.132631.2273195424430844661.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-22 at 13:26 -0700, David Miller wrote:

> How to deal with the problem we were attempting to solve is still
> under discussion.  It seems that even if we go to RCU we must also
> address to module reference count issue.

Yes, that's a separate issue. However, I think we should also check in
more detail the dumpit locking issue Pravin pointed out - before his
changes there was indeed the genl lock used as the cb_mutex. As I've
said over in the other thread, I'm not sure that change was actually
useful - it sounded like he confused kernel sockets and userland sockets
here? (Or maybe I am?!)

OTOH, we've already fixed the race conditions that resulted from his
patch, at least in nl80211. You might remember the issue Linus ran into
with the attrbuf, it's looking like that issue was because he changed
generic netlink to no longer use the genl_lock as the cb_mutex.

> I think the existing locking is very messy, and RCU looks a lot
> cleaner and has potential for future improvements to the scalability
> of dumps.

I agree, though we're not all that interested in generic netlink family
scalability I think, we have less than a dozen families, so this
shouldn't really be an issue.

> So I'd like to propose that we combine Johannes's RCU conversion
> with some variant of the module reference count fix.
> 
> Can you guys work together and come up with something I can apply?

Sure, that in itself isn't really a problem, but if we don't take
Pravin's patch to "revert" the cb_mutex change in his parallel_ops
changes, then we definitely need to audit all generic netlink dumpit
implementations in all users to see if they have similar races to
nl80211. I originally thought that it was an nl80211 problem, but I'm
now convinced that it wasn't. Still the new code in nl80211 is probably
nicer, and we can probably make it parallel_ops now due to these changes
but I'm not convinced we can audit all genl families.

If it wasn't that so much time has already passed since the parallel_ops
changes I'd almost suggest reverting those altogether and addressing the
locking properly ...

johannes
