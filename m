From: David Miller <davem@davemloft.net>
Subject: Re: Spurious "TCP: too many of orphaned sockets", unable to
 allocate sockets
Date: Wed, 25 Aug 2010 00:59:29 -0700 (PDT)
Message-ID: <20100825.005929.15250658.davem@davemloft.net>
References: <20100825071626.GA13681@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, miltonm@bga.com
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53204
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752058Ab0HYH7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 03:59:12 -0400
In-Reply-To: <20100825071626.GA13681@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Wed, 25 Aug 2010 17:16:26 +1000

> We have a machine running a network test that regularly hits:
> 
> TCP: too many of orphaned sockets
> 
> Which comes from:
> 
>                 int orphan_count = percpu_counter_read_positive(
>                                                 sk->sk_prot->orphan_count);
> 
>                 sk_mem_reclaim(sk);
>                 if (tcp_too_many_orphans(sk, orphan_count)) {
...
> 2. Even with this fixed we could hit the original issue. We have been known to
> test on 1024 thread boxes and we would have the possibility of 32 * 1024
> = 32k slack in the percpu counters. On this box tcp_max_orphans will be
> 64k after the fix which is a bit close for comfort. Should we do anything here?

Solution seems simple, if the too many orphan check triggers, simply
redo the check using the expensive but more accurate per-cpu counter
read (which avoids the skew) to make sure.
