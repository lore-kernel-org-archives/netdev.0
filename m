From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 2/2] net-timestamp: Make the clone operation stand-alone
 from phy timestamping
Date: Wed, 03 Sep 2014 16:02:39 -0700
Message-ID: <54079E0F.5010604@intel.com>
References: <20140903155022.1896.59030.stgit@ahduyck-bv4.jf.intel.com>	 <20140903155357.1896.92538.stgit@ahduyck-bv4.jf.intel.com>	 <1409778438.26422.54.camel@edumazet-glaptop2.roam.corp.google.com> <1409781908.26422.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	davem@davemloft.net, willemb@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64858 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755820AbaICXCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 19:02:41 -0400
In-Reply-To: <1409781908.26422.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2014 03:05 PM, Eric Dumazet wrote:
> On Wed, 2014-09-03 at 14:07 -0700, Eric Dumazet wrote:
> 
>>
>> Normally, if one skb holds a reference to a socket, it should have
>> skb->destructor set to a cleanup function.
>>
>> Otherwise, we rely on callers following a convention, to release sk
>> reference.
>>
>> If you believe its needed, it should be dully documented.
> 
> 
> BTW, skb_orphan() would BUG() on this case (skb->destrutor == NULL and
> skb->sk != NULL)

That was why we were setting skb->sk to null before passing it to
sock_queue_err_skb.  I think I found the reason why things were done the
way they were.  It looks like skb_orphan is called in
sock_queue_err_skb.  So any destructor added would be fired there before
before being replaced.

The only part I am not sure about is if that would actually be any sort
of issue.  Do we really need to hold the extra reference to the socket
all the way through the sock_queue_err_skb call or can we just let it
get dropped with the call to skb_orphan and let the fact that the
message is being queued be good enough?

I'm not sure due to the comment about "before exiting rcu section, make
sure dst is refcounted".  It kind of implies I should be able to hand
off the reference counts without worrying about the socket being freed
out from under me.

Thanks,

Alex
