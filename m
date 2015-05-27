From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: try to not exhaust
 ip_local_port_range in connect()
Date: Wed, 27 May 2015 13:31:57 -0400 (EDT)
Message-ID: <20150527.133157.608781400542319039.davem@davemloft.net>
References: <1432504175.4060.155.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbE0Rcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:32:36 -0400
In-Reply-To: <1432504175.4060.155.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 24 May 2015 14:49:35 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> A long standing problem on busy servers is the tiny available TCP port
> range (/proc/sys/net/ipv4/ip_local_port_range) and the default
> sequential allocation of source ports in connect() system call.
> 
> If a host is having a lot of active TCP sessions, chances are
> very high that all ports are in use by at least one flow,
> and subsequent bind(0) attempts fail, or have to scan a big portion of
> space to find a slot.
> 
> In this patch, I changed the starting point in __inet_hash_connect()
> so that we try to favor even [1] ports, leaving odd ports for bind()
> users.
> 
> We still perform a sequential search, so there is no guarantee, but
> if connect() targets are very different, end result is we leave
> more ports available to bind(), and we spread them all over the range,
> lowering time for both connect() and bind() to find a slot.
> 
> This strategy only works well if /proc/sys/net/ipv4/ip_local_port_range
> is even, ie if start/end values have different parity.
> 
> Therefore, default /proc/sys/net/ipv4/ip_local_port_range was changed to
> 32768 - 60999 (instead of 32768 - 61000)
> 
> There is no change on security aspects here, only some poor hashing
> schemes could be eventually impacted by this change.
> 
> [1] : The odd/even property depends on ip_local_port_range values parity
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks fine, applied, thanks Eric.

Arguably, we might want to emit a warning if the user sets the port
range sysctl non-even.  But that's up to you.
