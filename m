From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Fri, 26 Oct 2012 07:06:11 +0200
Message-ID: <1351227971.6537.278.camel@edumazet-glaptop>
References: <1351212356-11964-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliot Hughes <enh@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:42800 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756165Ab2JZFGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 01:06:17 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so72142wib.1
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 22:06:14 -0700 (PDT)
In-Reply-To: <1351212356-11964-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-25 at 17:45 -0700, Vijay Subramanian wrote:
> If server socket is slow to accept() connections, request_socks can represent
> connections for which the three-way handshake is already done.  From client's
> point of view, the connection is in ESTABLISHED state but on server side, socket
> is not in accept_queue or ESTABLISHED state.  When the syn-ack timer expires,
> because of the order in which tests are performed, server can retransmit the
> synack repeatedly. Following patch prevents the server from retransmitting the
> synack needlessly (and prevents client from replying with ack).  This reduces
> traffic when server is slow to accept() connections.
> 
> If the server socket has received the third ack during connection establishment,
> this is remembered in inet_rsk(req)->acked.  The request_sock will expire in
> around 30 seconds and will be dropped if it does not move into accept_queue.
> 
> With help from Eric Dumazet.
> 
> Reported-by: Elliot Hughes <enh@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
> Ignoring "WARNING: line over 80 characters" in the interest of readability.
> 
> Eric,
> What about your earlier patch that modified sk_acceptq_is_full()?

Acked-by: Eric Dumazet <edumazet@google.com>

Please note Elliott Hughes takes two t, and by the way didnt reported
this particular problem. but the fact that client got the SYNACK message
while socket was not yet available to the server side.

About earlier patch, this would break :

tcp_abort_on_overflow - BOOLEAN
        If listening service is too slow to accept new connections,
        reset them. Default state is FALSE. It means that if overflow
        occurred due to a burst, connection will recover. Enable this
        option _only_ if you are really sure that listening daemon
        cannot be tuned to accept connections faster. Enabling this
        option can harm clients of your server.

And even if tcp_abort_on_overflow is TRUE, earlier patch would break
some ability to have a momentary burst of SYN packets above the listen()
backlog.
