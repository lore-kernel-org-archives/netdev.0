From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 19:47:10 +0400
Message-ID: <20080527154710.GA6305@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527151259.GA11862@2ka.mipt.ru> <20080527152234.GA16419@2ka.mipt.ru> <200805271833.55880.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57080 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756113AbYE0PrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 11:47:16 -0400
Content-Disposition: inline
In-Reply-To: <200805271833.55880.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2008 at 06:33:55PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> Yes, I think I got the idea you are trying to use here. But, somehow I feel 
> uneasy with this approach :) Isn't it cleaner to keep the lock and try to 
> avoid the deadlock on the sendfile() side? Or is that unfeasible?

Well, providing some flags to ->sendpage() callbacks to say that they
should not grab locks is a bit ugly to me, I think we can fix splice
code not to do wrong things.

> I don't think we can drop the socket lock, it will introduce at least on type 
> of races: since the skb we are processing is still on the socket queue, any 
> entity accessing the socket queue will possible collide with us. 

Each access is being done under socket lock, so it should be safe. But
socket release path drops skb from the list before dropping its
reference counter, so we are not allowed to unlink it again, but we can
check if skb is linked or not and make a decision based on that.


-- 
	Evgeniy Polyakov
