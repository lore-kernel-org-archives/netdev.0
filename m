From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Tue, 05 Jun 2007 13:11:51 -0700 (PDT)
Message-ID: <20070605.131151.82049948.davem@davemloft.net>
References: <E1Hv980-0006gQ-00@dorka.pomaz.szeredi.hu>
	<20070605.000247.18308209.davem@davemloft.net>
	<E1HvTgf-0000sb-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56544
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758446AbXFEULh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 16:11:37 -0400
In-Reply-To: <E1HvTgf-0000sb-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 05 Jun 2007 09:42:41 +0200

> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> A recv() on an AF_UNIX, SOCK_STREAM socket can race with a
> send()+close() on the peer, causing recv() to return zero, even though
> the sent data should be received.
> 
> This happens if the send() and the close() is performed between
> skb_dequeue() and checking sk->sk_shutdown in unix_stream_recvmsg():
> 
> process A  skb_dequeue() returns NULL, there's no data in the socket queue
> process B  new data is inserted onto the queue by unix_stream_sendmsg()
> process B  sk->sk_shutdown is set to SHUTDOWN_MASK by unix_release_sock()
> process A  sk->sk_shutdown is checked, unix_release_sock() returns zero
> 
> I'm surprised nobody noticed this, it's not hard to trigger.  Maybe
> it's just (un)luck with the timing.
> 
> It's possible to work around this bug in userspace, by retrying the
> recv() once in case of a zero return value.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>

Looks good, applied.

Another way to fix this would have been to take the u->readlock
in unix_release() and unix_shutdown(), but that would have hurt
unix_dgram_recvmsg() which doesn't need to handle this race.
