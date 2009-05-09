From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Sat, 09 May 2009 13:34:54 -0700 (PDT)
Message-ID: <20090509.133454.111098477.davem@davemloft.net>
References: <4A044BE7.3070308@cosmosbay.com>
	<20090508.144859.152310605.davem@davemloft.net>
	<4A057387.4080308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49728
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751005AbZEIUe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:34:58 -0400
In-Reply-To: <4A057387.4080308@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 09 May 2009 14:13:59 +0200

> BTW, oprofile for this kind of workload gives a surprising result.
> (timer stuff being *very* expensive)
> CPU doing the NAPI stuff has this profile :
> 
> 88688    88688          9.7805   9.7805    lock_timer_base
> 72692    161380         8.0165  17.7970    bnx2_poll_work
> 66958    228338         7.3842  25.1812    mod_timer
> 47980    276318         5.2913  30.4724    __wake_up
> 43312    319630         4.7765  35.2489    task_rq_lock

To me this seems to indicate that timers keep getting scheduled on
different cpus.

Probably it would be helped by google's packet-processing-locality
patches, or some variant thereof.

Consider the case where we always send some message on CPU A and
then process the ACK on CPU B.  We'll always be cancelling the
timer on a foreign cpu.
