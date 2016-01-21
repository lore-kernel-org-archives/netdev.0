From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix NULL deref in tcp_v4_send_ack()
Date: Thu, 21 Jan 2016 11:20:44 -0800 (PST)
Message-ID: <20160121.112044.1230338700444998360.davem@davemloft.net>
References: <1453392174.1223.363.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, hkchu@google.com,
	ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbcAUTUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 14:20:45 -0500
In-Reply-To: <1453392174.1223.363.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Jan 2016 08:02:54 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Neal reported crashes with this stack trace :
> 
>  RIP: 0010:[<ffffffff8c57231b>] tcp_v4_send_ack+0x41/0x20f
> ...
>  CR2: 0000000000000018 CR3: 000000044005c000 CR4: 00000000001427e0
> ...
>   [<ffffffff8c57258e>] tcp_v4_reqsk_send_ack+0xa5/0xb4
>   [<ffffffff8c1a7caa>] tcp_check_req+0x2ea/0x3e0
>   [<ffffffff8c19e420>] tcp_rcv_state_process+0x850/0x2500
>   [<ffffffff8c1a6d21>] tcp_v4_do_rcv+0x141/0x330
>   [<ffffffff8c56cdb2>] sk_backlog_rcv+0x21/0x30
>   [<ffffffff8c098bbd>] tcp_recvmsg+0x75d/0xf90
>   [<ffffffff8c0a8700>] inet_recvmsg+0x80/0xa0
>   [<ffffffff8c17623e>] sock_aio_read+0xee/0x110
>   [<ffffffff8c066fcf>] do_sync_read+0x6f/0xa0
>   [<ffffffff8c0673a1>] SyS_read+0x1e1/0x290
>   [<ffffffff8c5ca262>] system_call_fastpath+0x16/0x1b
> 
> The problem here is the skb we provide to tcp_v4_send_ack() had to
> be parked in the backlog of a new TCP fastopen child because this child
> was owned by the user at the time an out of window packet arrived.
> 
> Before queuing a packet, TCP has to set skb->dev to NULL as the device
> could disappear before packet is removed from the queue.
> 
> Fix this issue by using the net pointer provided by the socket (being a
> timewait or a request socket).
> 
> IPv6 is immune to the bug : tcp_v6_send_response() already gets the net
> pointer from the socket if provided.
> 
> Fixes: 168a8f58059a ("tcp: TCP Fast Open Server - main code path")
> Reported-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
