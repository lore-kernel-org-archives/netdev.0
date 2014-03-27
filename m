From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Thu, 27 Mar 2014 16:02:09 -0700
Message-ID: <87fvm3nt3i.fsf@x220.int.ebiederm.org>
References: <87fvmgf2c7.fsf_-_@xmission.com>
	<20140318082358.60fc414c@nehalam.linuxnetplumber.net>
	<8738if8klj.fsf@xmission.com>
	<20140318.143712.1925745769166753460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36994 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754915AbaC0XCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 19:02:22 -0400
In-Reply-To: <20140318.143712.1925745769166753460.davem@davemloft.net> (David
	Miller's message of "Tue, 18 Mar 2014 14:37:12 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 18 Mar 2014 10:47:36 -0700
>
>> Most of the destructors today are fine (which doubly makes the warning
>> confusing).
>
> Not true by my estimation.  We absolutely do not want socket state being
> modified from hardware interrupts, and that's the most common destructor,
> releasing socket memory.

I definitely was not and am not suggesting that we change this.


I was just pointing out the difference between hard irq and soft irq
state for code is very slight, and I do not see anything that stands out
as hard irq unsafe.


Here is what I see when I read the destructors:

sock_rmem_free 
    is an antomic operation which is safe in all contexts.

sock_wfree
    appears safe in hard irq contect assuming the comment about
    of sk_free being safe in hard irq context is correct.

sock_rfree
    except for changing sk_foward_alloc without any kind of
    apparent serialization in sk_mem_uncharge appears safe.

sock_edemux 
    This just calls sock_put and inet_twsk_put
    sock_put just calls sk_put (which is documented as hard irq safe)
    Nothing in inet_twsk_put appears unsafe in hard irq context.

There are other destructors out there that definitely do things such
as call local_bh_disable that are unambiguously unsafe in hard irq
context but I had to look hard to find them.

Eric
