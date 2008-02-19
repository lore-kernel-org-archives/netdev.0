From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 19 Feb 2008 09:03:12 +0000
Message-ID: <47BA9B50.8040404@katalix.com>
References: <47B17BCD.2070903@katalix.com>	<20080214130016.GA2583@ff.dom.local>	<47BA0214.40703@katalix.com> <20080218.202934.79548477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:36716 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567AbYBSJDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 04:03:19 -0500
In-Reply-To: <20080218.202934.79548477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Mon, 18 Feb 2008 22:09:24 +0000
> 
>> Here's a new version of the patch. The patch avoids disabling irqs
>> and fixes the sk_dst_get() usage that DaveM mentioned. But even with
>> this patch, lockdep still complains if hundreds of ppp sessions are
>> inserted into a tunnel as rapidly as possible (lockdep trace is
>> below). I can stop these errors by wrapping the call to ppp_input()
>> in pppol2tp_recv_dequeue_skb() with local_irq_save/restore. What is
>> a better fix?
> 
> Firstly, let's fix one thing at a time.  Leave the sk_dst_get()
> thing alone until we can prove that it's part of the lockdep
> traces.

In reproducing the problem, I obtained several lockdep traces that 
implicated sk_dst_get(). I changed the code to use __sk_dst_check() as 
you suggested and they went away. At that point, I was hopeful the 
locking issues were fixed. But after several minutes of 
creating/deleting hundreds of ppp sessions, lockdep dumped another 
error. It is that error that I posted yesterday.

> Next, I can't see why ppp_input() needs to be invoked with
> interrupts disabled.  There are many other things that invoke
> that in software interrupt context, such as pppoe.

I agree. I'm seeking advice on what the underlying cause is of this new 
trace.

> Please provide the lockdep traces without the ppp_input() IRQ
> disabling so this can be properly analyzed.

The trace _was_ without ppp_input IRQ disabling. The trace doesn't occur 
if I disable IRQs around the ppp_input() call. The patch I sent showed 
the changes I made before running the tests that created the new lockdep 
trace. I'm sorry this wasn't clear.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

