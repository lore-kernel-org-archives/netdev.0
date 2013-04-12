From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from spin_lock_mutex
Date: Fri, 12 Apr 2013 08:27:31 +0200
Message-ID: <5167A953.1020900@acm.org>
References: <5166BDAA.3000603@acm.org> <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com> <5166F35B.1040200@acm.org> <20130411191409.GA9790@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gerard.telenet-ops.be ([195.130.132.48]:51796 "EHLO
	gerard.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955Ab3DLG1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 02:27:36 -0400
In-Reply-To: <20130411191409.GA9790@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/13 21:14, Neil Horman wrote:
>      This resulted from my commit ca99ca14c which introduced a mutex_trylock
>      operation in a path that could execute in interrupt context.  When mutex
>      debugging is enabled, the above warns the user when we are in fact exectuting in
>      interrupt context.
>
>      I think this is a false positive however.  The check is intended to catch users
>      who might be issuing sleeping calls in irq context, but the use of mutex_trylock
>      here is guaranteed not to sleep.
>
>      We could fix this by replacing the DEBUG_LOCK_WARN_ON check in spin_lock_mutex
>      with a __might_sleep call in the appropriate parent mutex operations, but for
>      the sake of effiency (which It seems is why the check was put in the spin lock
>      code only when debug is enabled), lets split the spin_lock_mutex call into two
>      components, where the outer component does the debug checking.  Then
>      mutex_trylock can just call the inner part as its callable from irq context
>      safely.

Sorry but I'm not yet convinced that it's safe to invoke mutex_trylock() 
from IRQ context. Please have a look at the implementation of 
mutex_set_owner(), which is invoked by mutex_trylock(). 
mutex_set_owner() stores the value of the "current" pointer into 
lock->owner. The value of "current" does not have a meaning in IRQ context.

Bart.
