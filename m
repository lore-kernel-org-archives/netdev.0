From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 07:56:27 +0100
Message-ID: <20061130065627.GE2003@elte.hu>
References: <2f14bf623344.456de60a@fnal.gov> <20061129.181950.31643130.davem@davemloft.net> <20061130061758.GA2003@elte.hu> <20061129.223055.05159325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wenji@fnal.gov, akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:33460 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1758394AbWK3G6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 01:58:40 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061129.223055.05159325.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> This is why my suggestion is to preempt_disable() as soon as we grab 
> the socket lock, [...]

independently of the issue at hand, in general the explicit use of 
preempt_disable() in non-infrastructure code is quite a heavy tool. Its 
effects are heavy and global: it disables /all/ preemption (even on 
PREEMPT_RT). Furthermore, when preempt_disable() is used for per-CPU 
data structures then [unlike for example to a spin-lock] the connection 
between the 'data' and the 'lock' is not explicit - causing all kinds of 
grief when trying to convert such code to a different preemption model. 
(such as PREEMPT_RT :-)

So my plan is to remove all "open-coded" use of preempt_disable() [and 
raw use of local_irq_save/restore] from the kernel and replace it with 
some facility that connects data and lock. (Note that this will not 
result in any actual changes on the instruction level because internally 
every such facility still maps to preempt_disable() on non-PREEMPT_RT 
kernels, so on non-PREEMPT_RT kernels such code will still be the same 
as before.)

	Ingo
