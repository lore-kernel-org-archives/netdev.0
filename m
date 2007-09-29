From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/5] net: Make rtnetlink infrastructure network namespace aware
Date: Sat, 29 Sep 2007 15:00:48 -0600
Message-ID: <m1myv56vb3.fsf@ebiederm.dsl.xmission.com>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com>
	<m1hcle9td8.fsf@ebiederm.dsl.xmission.com>
	<46FE72E3.3000402@trash.net>
	<m1tzpd8lfh.fsf@ebiederm.dsl.xmission.com>
	<46FE8FD3.2030308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:55990 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270AbXI2VBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 17:01:43 -0400
In-Reply-To: <46FE8FD3.2030308@trash.net> (Patrick McHardy's message of "Sat,
	29 Sep 2007 19:48:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Maybe I can save you some time: we used to do down_trylock()
> for the rtnl mutex, so senders would simply return if someone
> else was already processing the queue *or* the rtnl was locked
> for some other reason. In the first case the process already
> processing the queue would also process the new messages, but
> if it the rtnl was locked for some other reason (for example
> during module registration) the message would sit in the
> queue until the next rtnetlink sendmsg call, which is why
> rtnl_unlock does queue processing. Commit 6756ae4b changed
> the down_trylock to mutex_lock, so senders will now simply wait
> until the mutex is released and then call netlink_run_queue
> themselves. This means its not needed anymore.

Sounds reasonable.

I started looking through the code paths and I currently cannot
see anything that would leave a message on a kernel rtnl socket.

However I did a quick test adding a WARN_ON if there were any messages
found in the queue during rtnl_unlock and I found this code path
getting invoked from linkwatch_event.  So there is clearly something I
don't understand, and it sounds at odds just a bit from your
description.

If we can remove the extra queue processing that would be great,
as it looks like a nice way to simplify the locking and the special
cases in the code.

Eric
