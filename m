From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] tcp: TCP_NOTSENT_LOWAT socket option
Date: Tue, 23 Jul 2013 08:44:04 -0700
Message-ID: <1374594244.3449.13.camel@edumazet-glaptop>
References: <1374550027.4990.141.camel@edumazet-glaptop>
	 <51EEA089.3040904@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:46073 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab3GWPoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 11:44:07 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj3so8577241pad.14
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 08:44:06 -0700 (PDT)
In-Reply-To: <51EEA089.3040904@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 08:26 -0700, Rick Jones wrote:

> I see that now the service demand increase is more like 8%, though there 
> is no longer a throughput increase.  Whether an 8% increase is not a bad 
> effect on the CPU usage of a single flow is probably in the eye of the 
> beholder.

Again, it seems you didn't understand the goal of this patch.

It's not trying to get lower cpu usage, but lower memory usage, _and_
proper logical splitting of the write queue.

> 
> Anyway, on a more "how to use netperf" theme, while the final confidence 
> interval width wasn't reported, given the combination of -l 20, -i 10,3 
> and perf stat reporting an elapsed time of 200 seconds, we can conclude 
> that the test went the full 10 iterations and so probably didn't 
> actually hit the desired confidence interval of 5% wide at 99% probability.
> 
> 17321.16 Mbit/s is ~132150 16 KB sends per second.  There were roughly 
> 13,379 context switches per second, so not quite 10 sends per context 
> switch (~161831 bytes , that then is something like 161831 KB per 
> context switch.  Does that then imply you could have achieved nearly the 
> same performance with test-specific -s 160K -S 160K -m 16K ? (perhaps a 
> bit more than that socket buffer size for contingencies and or what was 
> "stored"/sent in the pipe?)  Or, given that the SO_SNDBUF grew to 
> 1593240 bytes, was there really a need for  ~ 1593240 - 131072 or 
> ~1462168 sent bytes in flight most of the time?
> 

Heh, you are trying the old crap again ;)

Why should we care of setting buffer sizes at all, when we have
autotuning ;)

RTT can vary from 50us to 200ms, rate can vary dynamically as well, some
AQM can trigger with whatever policy, you can have sudden reorders
because some router chose to apply per packet load balancing :

- You do not want to hard code buffer sizes, but instead let TCP stack
tune it properly.

Sure, I can probably can find out what are the optimal settings for a
given workload and given network to get minimal cpu usage.

But the point is having the stack finds this automatically.

Further tweaks can be done to avoid a context switch per TSO packet for
example. If we allow 10 notsent packets, we can probably  wait to have 5
packets before doing a wakeup.

 
