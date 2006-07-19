From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Wed, 19 Jul 2006 10:30:20 +0400
Message-ID: <20060719063020.GA29287@2ka.mipt.ru>
References: <20060718081625.GA13830@2ka.mipt.ru> <20060718230121.GA31474@ms2.inr.ac.ru> <20060719053841.GA24744@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58009 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932513AbWGSGav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 02:30:51 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060719053841.GA24744@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 19, 2006 at 09:38:41AM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> There is no socket spinlock anymore.
> Above lock is skb_queue lock which is held inside
> skb_dequeue/skb_queue_tail calls.
>  
> > > one mutex for netchannel's bucket 
> > 
> > Equivalent of socket user lock.
> 
> No, it is an equivalent for hash lock in socket table.


Futher lock description:
low-level netchannels input uses RCU, where RCU and hash lock are
used in socket code. Userspace can bind file descriptor to netchannel,
so there will be no locks at all (netchannel bucket mutex is held, when 
netchannel lookup happens). That basically means that if two readers call 
netchannel_recv() simultaneously, there will be som troubles, so in that 
case netchannel bucket mutex is equivalent to socket lock (if netchannel
mutex is used).

But main thing here is that there is no need to protect against bh
context, and nothing is locked and processed in bh context at all.

This leads to complete removal of atomic allocations in netchannel code.

-- 
	Evgeniy Polyakov
