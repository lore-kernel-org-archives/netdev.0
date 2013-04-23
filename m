From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 16:11:23 -0700
Message-ID: <1366758683.8964.37.camel@edumazet-glaptop>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
	 <1366749094-5982-1-git-send-email-willemb@google.com>
	 <20130423.184140.2020239496583590253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:55874 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab3DWXL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 19:11:26 -0400
Received: by mail-pa0-f53.google.com with SMTP id bh4so781172pad.26
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 16:11:25 -0700 (PDT)
In-Reply-To: <20130423.184140.2020239496583590253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 18:41 -0400, David Miller wrote:
> From: Willem de Bruijn <willemb@google.com>
> Date: Tue, 23 Apr 2013 16:31:34 -0400
> 
> > - disable the kconfig option by default, as it is workload specific.
> 
> If this logic only kicks in during overload, I see no reason why we
> shouldn't have this protection enabled unconditionally, all the time.
> 
> Does it hurt performance under normal workloads?
> 
> If the new logic is controlled by overload thresholds then it should
> have no impact whatsoever in non-overload scenerios.

Exact.

I guess we should at least not include this code on !SMP builds

This adds some code, but as long as you don't write into
flow_limit_cpu_bitmap/flow_limit_table_len we wont allocate the memory,
thus this is disabled.

Then, if enabled, it only kicks if the number of queued packets is above
half the max backlog (netdev_max_backlog >> 1)

So on non overload scenario, cost is 0.

On overload scenario, the loaded cpu keeps a 512 bytes array hot in his
cache. (fl->history[])
