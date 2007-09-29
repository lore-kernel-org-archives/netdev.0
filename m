From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/5] net: Make rtnetlink infrastructure network namespace
 aware
Date: Sat, 29 Sep 2007 19:48:03 +0200
Message-ID: <46FE8FD3.2030308@trash.net>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com>	<m1hcle9td8.fsf@ebiederm.dsl.xmission.com>	<46FE72E3.3000402@trash.net> <m1tzpd8lfh.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53104 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbXI2Rs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 13:48:27 -0400
In-Reply-To: <m1tzpd8lfh.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
> 
>>I'm wondering why this receive queue processing on unlock is still
>>necessary today, we don't do trylock in rtnetlink_rcv anymore, so
>>all senders will simply wait until the lock is released and then
>>process the queue.
> 
> 
> Good question, I should probably look.  I was lazy and didn't go back
> and audit why we were doing this.  I just coded a routine that I was
> certain would work.  It does appear that we are processing the queue
> with sk_data_read when we add a message, so this may be completely
> unnecessary.  I will go back and look.  If we can remove this bit
> things should be simpler.


Maybe I can save you some time: we used to do down_trylock()
for the rtnl mutex, so senders would simply return if someone
else was already processing the queue *or* the rtnl was locked
for some other reason. In the first case the process already
processing the queue would also process the new messages, but
if it the rtnl was locked for some other reason (for example
during module registration) the message would sit in the
queue until the next rtnetlink sendmsg call, which is why
rtnl_unlock does queue processing. Commit 6756ae4b changed
the down_trylock to mutex_lock, so senders will now simply wait
until the mutex is released and then call netlink_run_queue
themselves. This means its not needed anymore.

