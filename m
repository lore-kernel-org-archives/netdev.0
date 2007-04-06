From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [Kgdb-bugreport] [PATCH] 8139too: harden against TX ring overflow
Date: Fri, 06 Apr 2007 18:40:23 +0400
Message-ID: <46165BD7.2090605@ru.mvista.com>
References: <E1HZdZ2-000620-00@gondolin.me.apana.org.au> <200704060901.28628.amitkale@linsyssoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kgdb-bugreport@lists.sourceforge.net,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, jgarzik@pobox.com, mhuth@mvista.com
To: "Amit S. Kale" <amitkale@linsyssoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:37922 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1767672AbXDFOjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 10:39:24 -0400
In-Reply-To: <200704060901.28628.amitkale@linsyssoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Amit S. Kale wrote:

>>>This driver's 4-packet deep TX queue is too sensible to the "careless"
>>>callers ignoring its state (like netpoll in trapped mode), so add "queue
>>>full" check at the start of the hard_start_xmit() method (only under
>>>#ifndef RTL8139_NDEBUG, otherwise the queue will get stuck once dirty
>>>pointer gets out of sync); switch to using appropriate mnemonics for the
>>>return values while at it.

>>Could you please describe this netpoll scenario in more detail?
>>More importantly, why wouldn't we fix netpoll instead?

> We're trying to figure out a way of fixing netpoll. Don't know what the 
> solution is yet.

> Here is what happens: in KGDB we set netpoll trapped flag. This prevents 
> stopping and starting of a netdev queue. Interfaces that have a small ring 
> (8139) run into a problem because of this. When the ring goes full, it can't 
> stop the queue. This doesn't make sense since in absence of ring descriptors, 
> the device can't transmit any more packets. Sergie had posted one more patch 
> last week that lets us start and stop queues in trapped state.
> 
> This patch fixes the 8139 side behavior in this context.

    Not really -- the patch doesn't seem necessary in this context.  It's just 
an attempt to make the driver more robust against out-of-sync dirty pointer 
and posting packets to already stopped queue -- that check constituting the 
second part is still necessary in certain out-of-sync pointer situation where 
the queue may erroneously be woken up, i.e. with the difference between the 
dirty_tx and cur_tx is multiple of 4 by the end of loop (well, I guess that 
has happened only with netpoll in trapped mode so far).  Remember that all 
these checks are done only when the driver debugging is enabled (it *is* 
enabled by default though).

> -Amit

MBR, Sergei
