From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Prevent from potential dead lock for inet_listen_lock
Date: Sun, 29 Jun 2008 21:12:28 -0700 (PDT)
Message-ID: <20080629.211228.179045031.davem@davemloft.net>
References: <485B7384.1090204@cn.fujitsu.com>
	<20080627.193234.134186954.davem@davemloft.net>
	<48685019.90706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: guijianfeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38106
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750777AbYF3EM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 00:12:28 -0400
In-Reply-To: <48685019.90706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Date: Mon, 30 Jun 2008 11:16:41 +0800

>   How about the following call trace.
> dccp_v4_rcv
>   -> sk_receive_skb(sk, skb, 1);
>     -> sk->sk_backlog_rcv(sk, skb);(dccp_v4_do_rcv)
>       -> dccp_rcv_state_process()
> 	-> dccp_rcv_request_sent_state_process(sk, skb, dh, len);
> 	  -> icsk->icsk_af_ops->rebuild_header(sk); (inet_sk_rebuild_header)
> 	    -> inet_sk_reselect_saddr(sk))
> 	      -> __sk_prot_rehash(sk);
> 		-> sk->sk_prot->hash(sk);
> 		  -> inet_hash(struct sock *sk)
> 	            -> __inet_hash(struct sock *sk)
> 		      -> inet_listen_wlock(hashinfo);
> 			-> write_lock(&hashinfo->lhash_lock);

You're not answering my question.

I'll ask my question one more time.

How can this happen for a LISTENING SOCKET?  Ie. with
sk_state == TCP_LISTEN.

Only listening sockets go into inet_listen_wlock().

This DCCP call trace you're showing sets the sk_state to DCCP_PARTOPEN
right before that ->rebuild_header() call. (DCCP_PARTOPEN is defined
to be equal to TCP_MAX_STATES in include/linux/dccp.h)

So this call chain is absolutely impossible.

We specifically forbid listening sockets from calling hash or unhash
in BH context.  And this is exactly what makes the locking legal.

You had to have a reason for writing this patch.  You saw something,
either a deadlock or a lockdep trace.  My theory is that you saw
lockdep triggered erroneously because it can't see what prevents BH
contexts from invoking inet_listen_wlock().

Or did you just write this patch in response to pure code reading?
