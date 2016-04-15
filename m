From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: simplify sk_receive_queue locking
Date: Fri, 15 Apr 2016 17:22:42 -0400 (EDT)
Message-ID: <20160415.172242.1523123997949553597.davem@davemloft.net>
References: <6c4b2f1fab1e792537cc1661b130724d1ea26279.1460583258.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com, nhorman@tuxdriver.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbcDOVWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 17:22:45 -0400
In-Reply-To: <6c4b2f1fab1e792537cc1661b130724d1ea26279.1460583258.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 13 Apr 2016 19:12:29 -0300

> SCTP already serializes access to rcvbuf through its sock lock:
> sctp_recvmsg takes it right in the start and release at the end, while
> rx path will also take the lock before doing any socket processing. On
> sctp_rcv() it will check if there is an user using the socket and, if
> there is, it will queue incoming packets to the backlog. The backlog
> processing will do the same. Even timers will do such check and
> re-schedule if an user is using the socket.
> 
> Simplifying this will allow us to remove sctp_skb_list_tail and get ride
> of some expensive lockings.  The lists that it is used on are also
> mangled with functions like __skb_queue_tail and __skb_unlink in the
> same context, like on sctp_ulpq_tail_event() and sctp_clear_pd().
> sctp_close() will also purge those while using only the sock lock.
> 
> Therefore the lockings performed by sctp_skb_list_tail() are not
> necessary. This patch removes this function and replaces its calls with
> just skb_queue_splice_tail_init() instead.
> 
> The biggest gain is at sctp_ulpq_tail_event(), because the events always
> contain a list, even if it's queueing a single skb and this was
> triggering expensive calls to spin_lock_irqsave/_irqrestore for every
> data chunk received.
> 
> As SCTP will deliver each data chunk on a corresponding recvmsg, the
> more effective the change will be.
> Before this patch, with chunks with 30 bytes:
> netperf -t SCTP_STREAM -H 192.168.1.2 -cC -l 60 -- -m 30 -S 400000
> 400000 -s 400000 400000
> on a 10Gbit link with 1500 MTU:
 ...
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks.
