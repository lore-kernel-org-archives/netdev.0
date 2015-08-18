From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet: fix potential deadlock in reqsk_queue_unlink()
Date: Tue, 18 Aug 2015 07:25:16 -0700
Message-ID: <1439907916.6443.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439222953.1084.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150810.211821.2246516216165801977.davem@davemloft.net>
	 <1439497173.7960.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439498674.7960.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439505891.7960.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB7E6FA@AcuExch.aculab.com>
	 <1439905003.6443.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB7E83F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33291 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbbHROZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 10:25:19 -0400
Received: by pabyb7 with SMTP id yb7so133979550pab.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 07:25:18 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB7E83F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-18 at 13:57 +0000, David Laight wrote:
> s the purpose of del_timer_sync()
> 
> I wasn't worried about del_timer_sync().
> The problem is the call to timer_pending().
> 
> If the timer has just expired, and the timeout function is running
> (on another cpu) then timer_pending() will return false.

This case is not a problem. refcount will be properly handled. No leak,
no reuse, no crash.


> So any tidyup path (apart from that called by the timeout function itself)
> will fail to wait for the function to finish.
> 
> So, in effect, you've converted the code back into a call to del_timer().

This is fine.

> 
> timer_pending() should probably never be called without the relevant
> timer lock help - because the result is stale.

Thats absolutely not true. Please read again timer code and linux code,
you'll see lot of timer uses without a lock being held (unserialized use
of timers)

This is why we have mod_timer_pending() for example.
