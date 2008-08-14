From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver code
Date: Thu, 14 Aug 2008 16:28:37 +0300
Message-ID: <84144f020808140628m31d6d099t1fecdb1701c0bbdc@mail.gmail.com>
References: <20080813095324.GA15055@ben.ifi.uio.no>
	 <20080813.033749.165504341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, vegardno@ifi.uio.no,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, adobriyan@gmail.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:26822 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbYHNN2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 09:28:39 -0400
Received: by yx-out-2324.google.com with SMTP id 8so331054yxm.1
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 06:28:38 -0700 (PDT)
In-Reply-To: <20080813.033749.165504341.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Aug 13, 2008 at 1:37 PM, David Miller <davem@davemloft.net> wrote:
> From: Vegard Nossum <vegardno@ifi.uio.no>
> Date: Wed, 13 Aug 2008 11:53:24 +0200
>
>> [PATCH] netconsole: avoid deadlock on printk from driver code
>>
>> I encountered a hard-to-debug deadlock when I pulled out the plug of my
>> RealTek 8139 which was also running netconsole: The driver wants to print
>> a "link down" message. However, this triggers netconsole, which wants to
>> print the message using the same device. Here is a backtrace:
>
> See my other reply, this is absolutely the wrong way to go about
> this.
>
> You only have two sane options:
>
> 1) Defer the link status printk message into a deferred context,
>   such as a workqueue, so that you can do it outside of the
>   lock.

It's not just the link status. We have assert() and debugging printks
there under tp->lock as well which can also trigger the deadlock
condition.

On Wed, Aug 13, 2008 at 1:37 PM, David Miller <davem@davemloft.net> wrote:
> 2) Do your locking differently so that the link status handling
>   locking does not bisect the locking used for packet transmit
>   in ->hard_start_xmit().
>
> #2 is the reason why most other drivers don't have this silly
> bug, they don't hold TX path locks when handling link status
> and printing out such messages.

Yeah, that works for the link status case, but not for things like the
printks in rtl8139_tx_interrupt()... Hmm.

                             Pekka
