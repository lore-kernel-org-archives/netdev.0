From: "Ono, Kumiko" <kumiko@cs.columbia.edu>
Subject: Re: garbage of TCP sock mem in sockstat?
Date: Wed, 02 May 2007 18:03:26 -0400
Message-ID: <46390AAE.8020304@cs.columbia.edu>
References: <46185FFC.8020104@cs.columbia.edu> <20070430.003842.26533021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs.columbia.edu ([128.59.16.20]:51938 "EHLO cs.columbia.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993176AbXEBWDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 18:03:31 -0400
In-Reply-To: <20070430.003842.26533021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks a lot for your response.

However, it is still unclear, since the allocated memory for TCP socket 
buffers, which I saw via sockstat, shows zero when calling send() after 
recv() as shown in the previous email.

Do you mean that it is necessary to hold the receive buffer allocation 
for future packet when calling only recv(), but not necessary when 
calling send() after recv()?

> On the other hand, when a server calls read() and send() for echoing messages for all connections, the sockstat shows that all the socket buffers are deallocated after competing echoing as follows:
> 
> TCP: inuse 13 orphan 0 tw 0 alloc 19 mem 0
> TCP: inuse 1237 orphan 0 tw 0 alloc 1243 mem 0
> TCP: inuse 2461 orphan 0 tw 0 alloc 2467 mem 0
> TCP: inuse 3688 orphan 0 tw 0 alloc 3694 mem 0
> TCP: inuse 4912 orphan 0 tw 0 alloc 4918 mem 268
> TCP: inuse 5012 orphan 0 tw 0 alloc 5018 mem 101
> TCP: inuse 5012 orphan 0 tw 0 alloc 5018 mem 0

Regards,
Kumiko

David Miller wrote:
> From: Kumiko Ono <kumiko@cs.columbia.edu>
> Date: Sat, 07 Apr 2007 23:22:36 -0400
> 
>> Could anybody tell me why the garbage in the memory for TCP socket 
>> buffers remains? Is this a problem on deallocation of socket buffers, or 
>> just on sockstat?  Or I'm missing something?
> 
> It is not garbage, it is simply holding on to the receive buffer
> allocation in anticipation of future packet receives for that
> socket.
> 
> The values in the global pool, which you saw via sockstat, are
> allocated from on a per-socket basis into a per-socket allocation
> quota.  Packets attached to that socket have to take from this
> quota.
> 
> The idea is that once you get a per-socket allocation, you use
> that until you need more.  When you release, you keep the
> per-socket allocation unless we are under global memory
> pressure.
> 
> This prevents having to go to allocate from the global pool
> too often which is very expensive especially on SMP since
> it is a shared datastructure and requires locking.

