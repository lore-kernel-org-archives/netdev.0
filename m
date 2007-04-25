From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink locking warnings in 2.6.21-rc7-mm1
Date: Wed, 25 Apr 2007 15:17:39 +0200
Message-ID: <462F54F3.9050306@trash.net>
References: <E1HgVxj-0003U6-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63953 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992760AbXDYNSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 09:18:05 -0400
In-Reply-To: <E1HgVxj-0003U6-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
> 
>>I think I see what might be the problem, nlk->cb_mutex is set
>>to "rtnl_mutex" and this is used for other purposes in various
>>code paths here, maybe there is a double mutex_unlock() or
>>similar due to that?
> 
> 
> Indeed, the RTNL is held during the processing of all RTNETLINK
> messages so we'd be trying to lock it recursively here which is
> not allowed.


No, it is released before calling netlink_dump_start().

> Actually I'm not quite sure what the benefit is for allowing an
> override CB mutex.  Since we still have to take it and we always
> allocate memory for a mutex anyway this would seem to be strictly
> worse than just using our own mutex.


The idea was that netlink families that don't want to consistently
hold the same mutex used for queue processing during the entire
dump operation can still have per-socket mutexes just to protect
the callback data and have concurrent dump continuations.

