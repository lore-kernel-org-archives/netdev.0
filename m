From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove sock_iocb
Date: Thu, 29 Jan 2015 00:01:25 -0800 (PST)
Message-ID: <20150129.000125.1532086382063848714.davem@davemloft.net>
References: <1422464693-7827-1-git-send-email-hch@lst.de>
	<20150128.232211.1157376728217761804.davem@davemloft.net>
	<20150129075721.GD29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbbA2IB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 03:01:26 -0500
In-Reply-To: <20150129075721.GD29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Thu, 29 Jan 2015 07:57:21 +0000

> You know, that's getting _really_ interesting.  The thing is, now
> there's only one ->sendmsg() instance using iocb argument at all,
> and it's a really weird one.  TIPC.  Which only compares it with
> NULL, and that - to tell the normal calls (== done by sock_sendmsg()
> et.al.) from tipc_{accept,connect}()-generated ones.  And the way
> it's used is
>         if (iocb)
>                 lock_sock(sk);
> in tipc_send_stream().  IOW, "tipc_accept() and tipc_connect() would like
> to use the guts of tipc_send_stream(), but they are already holding the
> socket locked; let's just pass NULL iocb (which net/socket.c never does)
> to tell it to leave the fucking lock alone, thank you very much".
> 
> And no ->recvmsg() are using iocb at all now.  How about we take the
> guts of tipc_send_stream() into a helper function and have tipc_accept/connect
> use _that_?  Then we could drop iocb argument completely and for ->sendmsg()
> it would be the difference between 4 and 3 arguments, which has interesting
> effects on certain register-starved architectures...
> 
> While we are at it, size (both for sendmsg and recvmsg) is always equal to
> iov_iter_count(&msg->msg_iter), so that's not the only redundant argument
> there...

No objections from me.
