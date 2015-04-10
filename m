From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp/dccp: do not block bh too long in
 inet_twdr_twkill_work()
Date: Fri, 10 Apr 2015 08:31:01 -0700
Message-ID: <1428679861.25985.311.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428664747.25985.298.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36917 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932419AbbDJPbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 11:31:05 -0400
Received: by igblo3 with SMTP id lo3so785243igb.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 08:31:04 -0700 (PDT)
In-Reply-To: <1428664747.25985.298.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-10 at 04:19 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> I have seen inet_twdr_twkill_work() blocking softirq for
> periods up to 1.5 seconds, depending on number of timewait sockets.
> 
> This is an unacceptable source of latency.
> 
> Note that inet_twdr_do_twkill_work() releases death_lock spinlock
> for every tw handled, but does not take care of bh enabling.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

BTW, inet_twdr_twcal_tick() suffers from similar problem, with latencies
of ~25ms, when /proc/sys/net/ipv4/tcp_tw_recycle is enabled.

Since it holds death_lock for the whole run, all other cpus are spinning
on it.

I believe we simply should add a timer per timewait, as I did for
request sockets.

This would simplify the code a lot, and would get rid of this awful non
scalable timer wheel.
