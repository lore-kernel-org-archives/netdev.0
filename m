From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH] inet: race in wait for connect.
Date: Mon, 29 Oct 2007 19:29:06 -0200
Message-ID: <20071029212906.GE21178@ghostprotocols.net>
References: <20071029135222.2ad073ff@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57013 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbXJ2V3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 17:29:14 -0400
Content-Disposition: inline
In-Reply-To: <20071029135222.2ad073ff@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Oct 29, 2007 at 01:52:22PM -0700, Stephen Hemminger escreveu:
> Fix possible race while waiting for connections in accept. I don't
> know of a test case that could reproduce this directly.
> 
> The state of the socket should be checked before checking the queue.
> If the socket has left the TCP_LISTEN state, then the accept queue
> is no longer valid.

Well if it left from LISTEN to CLOSED inet_csk_listen_stop must have
been called, and that calls reqsk_queue_yank_acceptq, that sets it to
NULL, reqsk_queue_empty(&icsk->icsk_accept_queue) returns true and we
get to if (sk->sk_state != TCP_LISTEN), returning -EINVAL as with your
patch.  So I can't see a race, just one branch less in one case :-)

- Arnaldo
 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> --- a/net/ipv4/inet_connection_sock.c	2007-10-26 11:54:41.000000000 -0700
> +++ b/net/ipv4/inet_connection_sock.c	2007-10-29 08:34:03.000000000 -0700
> @@ -203,12 +203,12 @@ static int inet_csk_wait_for_connect(str
>  		if (reqsk_queue_empty(&icsk->icsk_accept_queue))
>  			timeo = schedule_timeout(timeo);
>  		lock_sock(sk);
> -		err = 0;
> -		if (!reqsk_queue_empty(&icsk->icsk_accept_queue))
> -			break;
>  		err = -EINVAL;
>  		if (sk->sk_state != TCP_LISTEN)
>  			break;
> +		err = 0;
> +		if (!reqsk_queue_empty(&icsk->icsk_accept_queue))
> +			break;
>  		err = sock_intr_errno(timeo);
>  		if (signal_pending(current))
>  			break;
