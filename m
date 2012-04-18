From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] ehea: do not dereference possible NULL port
Date: Wed, 18 Apr 2012 09:42:52 -0300
Message-ID: <20120418124252.GA2455@oc1711230544.ibm.com>
References: <1334673715-16338-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <1334673715-16338-4-git-send-email-cascardo@linux.vnet.ibm.com>
 <20120417.222912.1038252957653077871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:38842 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab2DRMnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 08:43:11 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Wed, 18 Apr 2012 09:42:58 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id E747D1DC004E
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 09:42:51 -0300 (BRT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3ICgbA030343574
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 09:42:38 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3IAggkI028713
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 07:42:42 -0300
Content-Disposition: inline
In-Reply-To: <20120417.222912.1038252957653077871.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 17, 2012 at 10:29:12PM -0400, David Miller wrote:
> From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> Date: Tue, 17 Apr 2012 11:41:55 -0300
> 
> > port may be NULL when we receive an interrupt too early in the probe.
> > 
> > commit 8c4877a4128e7931077b024a891a4b284d8756a3, in particular, has
> > introduced this problem in the case of port state change interrupt.
> > 
> > This causes crashes in some situations:
> 
> Never fix this kind of bug like this.  Do not make a tasklet or
> an irq handler pay the price of the probe not doing things in the
> right order.
> 
> Do not register asynchronous threads of control until all the
> state is setup properly.
> 
> That's the right way to fix this problem.
> 

Sure. That was in my plans too.

However, at first, I suspected this interrupt may have come from some
other port from ehca, for example, considering a possible firmware bug.
After more investigation, I found out that the real problem was some
physical ports in some odd states, that caused the IRQs before the ports
were enabled. Note that this is not really supposed to happen.

So, consider the possibility that we receive, for a reason like a
firmware bug, an interrupt is received and the EQE indicates a port
number we don't know about. We oops even if we have registered the IRQ
after enabling the ports.

So, I think it's better to be safe to just check for a NULL pointer in
the interrupt (which was being checked either way, just not in the right
place).

So, in fact, I just moved a pointer check because the pointer is now
being used when it wasn't before, due to the commit I referred to.

Would you apply this patch if I include the other one, registering the
IRQ later in the probe process?

Thanks for the comment.
Cascardo.
