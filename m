From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] af-unix: fix use-after-free with concurrent
 readers while splicing
Date: Sun, 15 Nov 2015 13:17:27 -0500 (EST)
Message-ID: <20151115.131727.1107378090051512985.davem@davemloft.net>
References: <1447168995-25820-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbbKOSR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 13:17:29 -0500
In-Reply-To: <1447168995-25820-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 10 Nov 2015 16:23:15 +0100

> During splicing an af-unix socket to a pipe we have to drop all
> af-unix socket locks. While doing so we allow another reader to enter
> unix_stream_read_generic which can read, copy and finally free another
> skb. If exactly this skb is just in process of being spliced we get a
> use-after-free report by kasan.
> 
> First, we must make sure to not have a free while the skb is used during
> the splice operation. We simply increment its use counter before unlocking
> the reader lock.
> 
> Stream sockets have the nice characteristic that we don't care about
> zero length writes and they never reach the peer socket's queue. That
> said, we can take the UNIXCB.consumed field as the indicator if the
> skb was already freed from the socket's receive queue. If the skb was
> fully consumed after we locked the reader side again we know it has been
> dropped by a second reader. We indicate a short read to user space and
> abort the current splice operation.
> 
> This bug has been found with syzkaller
> (http://github.com/google/syzkaller) by Dmitry Vyukov.
> 
> Fixes: 2b514574f7e8 ("net: af_unix: implement splice for stream af_unix sockets")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
