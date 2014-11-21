From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] ipx: fix locking regression in ipx_sendmsg and
 ipx_recvmsg
Date: Fri, 21 Nov 2014 14:46:55 -0500 (EST)
Message-ID: <20141121.144655.1028344293385336290.davem@davemloft.net>
References: <20141119103814.GB19092@midget.suse.cz>
	<20141119.154400.1045032776950540216.davem@davemloft.net>
	<20141119220549.GA26133@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, acme@ghostprotocols.net, netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbaKUTq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 14:46:58 -0500
In-Reply-To: <20141119220549.GA26133@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Wed, 19 Nov 2014 23:05:49 +0100

> This fixes an old regression introduced by commit
> b0d0d915 (ipx: remove the BKL).
> 
> When a recvmsg syscall blocks waiting for new data, no data can be sent on the
> same socket with sendmsg because ipx_recvmsg() sleeps with the socket locked.
> 
> This breaks mars-nwe (NetWare emulator):
> - the ncpserv process reads the request using recvmsg
> - ncpserv forks and spawns nwconn
> - ncpserv calls a (blocking) recvmsg and waits for new requests
> - nwconn deadlocks in sendmsg on the same socket 
> 
> Commit b0d0d915 has simply replaced BKL locking with
> lock_sock/release_sock. Unlike now, BKL got unlocked while
> sleeping, so a blocking recvmsg did not block a concurrent
> sendmsg.
> 
> Only keep the socket locked while actually working with the socket data and
> release it prior to calling skb_recv_datagram(). 
> 
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Applied.
