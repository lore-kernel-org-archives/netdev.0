From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [Devel] Re: [PATCH 2/5] net: Make rtnetlink infrastructure network
 namespace aware
Date: Mon, 01 Oct 2007 12:26:52 +0400
Message-ID: <4700AF4C.6020509@sw.ru>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com>	<m1hcle9td8.fsf@ebiederm.dsl.xmission.com>	<46FE72E3.3000402@trash.net>	<m1tzpd8lfh.fsf@ebiederm.dsl.xmission.com>	<46FE8FD3.2030308@trash.net>	<m1myv56vb3.fsf@ebiederm.dsl.xmission.com> <46FFC34A.3020701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:53774 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752184AbXJAIZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 04:25:49 -0400
In-Reply-To: <46FFC34A.3020701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Eric W. Biederman wrote:
>> Patrick McHardy <kaber@trash.net> writes:
>>
>>
>>> Maybe I can save you some time: we used to do down_trylock()
>>> for the rtnl mutex, so senders would simply return if someone
>>> else was already processing the queue *or* the rtnl was locked
>>> for some other reason. In the first case the process already
>>> processing the queue would also process the new messages, but
>>> if it the rtnl was locked for some other reason (for example
>>> during module registration) the message would sit in the
>>> queue until the next rtnetlink sendmsg call, which is why
>>> rtnl_unlock does queue processing. Commit 6756ae4b changed
>>> the down_trylock to mutex_lock, so senders will now simply wait
>>> until the mutex is released and then call netlink_run_queue
>>> themselves. This means its not needed anymore.
>>
>> Sounds reasonable.
>>
>> I started looking through the code paths and I currently cannot
>> see anything that would leave a message on a kernel rtnl socket.
>>
>> However I did a quick test adding a WARN_ON if there were any messages
>> found in the queue during rtnl_unlock and I found this code path
>> getting invoked from linkwatch_event.  So there is clearly something I
>> don't understand, and it sounds at odds just a bit from your
>> description.
> 
> 
> That sounds like a bug. Did you place the WARN_ON before or after
> the mutex_unlock()?

The presence of the message in the queue during rtnl_unlock is quite
possible as normal user->kernel message processing path for rtnl is the
following:

netlink_sendmsg
   netlink_unicast
      netlink_sendskb
          skb_queue_tail
          netlink_data_ready
              rtnetlink_rcv
                  mutex_lock(&rtnl_mutex);
                  netlink_run_queue(sk, qlen, &rtnetlink_rcv_msg);
                  mutex_unlock(&rtnl_mutex);

so, the presence of the packet in the rtnl queue on rtnl_unlock is
normal race with a rtnetlink_rcv for me.

Regards,
	Den
