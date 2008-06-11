From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Wed, 11 Jun 2008 17:57:18 +0400
Message-ID: <20080611135718.GA26914@ms2.inr.ac.ru>
References: <200806111658.41182.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McManus <mcmanus@ducksong.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Vitaliy Gusev <vgusev@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:59274 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752518AbYFKOkj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 10:40:39 -0400
Content-Disposition: inline
In-Reply-To: <200806111658.41182.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> While testing network namespace with 2.6.26 OpenVZ kernel port I found
> some problem with the patch commit ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 
> ("[TCP]: TCP_DEFER_ACCEPT updates - process as established")
...
> I asked Alexey Kuznetsov about this problem and he answered he didn't know 
> what to do yet.


I still do not.

The first idea was to add to tcp_done() check for
tcp_sk(sk)->defer_tcp_accept.request, which would mean that
even if socket is not SOCK_DEAD it still must be destroyed.
Ugly, but should work.


But when trying to do this I found that the patch has other flaws.

Major issue is that tcp_defer_accept_check() manipulates with not locked
listening socket. And from all that I know it is impossible to take
the lock in this context.

Also I see no accounting for those sockets. With this patch any server, which
set deferred accept, can be flooded with sockets until memory exhausts.
I did not test and would be glad to be mistaken.


Issue with locking can be solved by adding a separate spinlock for
manipulations with accept_queue. Apparently, accounting and killing
sockets, which become stale after closing listening socket and
are going to be alive for up to 65535 seconds, also goes under this lock.

Frankly, cost looks too high for this feature.

Hiding from accept() sockets with only out-of-order data only
is the only thing which is impossible with old approach. Is this really
so valuable? My opinion: no, this is nothing but a new loophole
to consume memory without control.

Alexey
