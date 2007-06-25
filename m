From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: lock_sock_nested in sctp_sock_migrate
Date: Mon, 25 Jun 2007 16:24:23 -0400
Message-ID: <46802477.5030005@hp.com>
References: <20070622221446.GB7547@mami.zabbo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org,
	Arjan van de Ven <arjan@linux.intel.com>
To: Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:39939 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334AbXFYUY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 16:24:26 -0400
In-Reply-To: <20070622221446.GB7547@mami.zabbo.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zach Brown wrote:
> I'm not sure that I've gotten either the sctp or lockdep details right,
> but with this patch I don't get lockdep yelling at me any more :)
> 
> ------
> 
> sctp: lock_sock_nested in sctp_sock_migrate
> 
> sctp_sock_migrate() grabs the socket lock on a newly allocated socket while
> holding the socket lock on an old socket.  lockdep worries that this might
> be a recursive lock attempt.
> 
>  task/3026 is trying to acquire lock:
>   (sk_lock-AF_INET){--..}, at: [<ffffffff88105b8c>] sctp_sock_migrate+0x2e3/0x327 [sctp]
>  but task is already holding lock:
>   (sk_lock-AF_INET){--..}, at: [<ffffffff8810891f>] sctp_accept+0xdf/0x1e3 [sctp]
> 
> This patch tells lockdep that this locking is safe by using
> lock_sock_nested().

Hm... This is another case of of two different sockets taking the same lock...

Arjan,  did this every get fixed, or is the nested locking the right solution
to this?

Thanks
-vlad

> 
> Signed-off-by: Zach Brown <zach.brown@oracle.com>
> 
> diff -r 8adcfdf2545b net/sctp/socket.c
> --- a/net/sctp/socket.c	Fri Jun 22 11:11:33 2007 -0700
> +++ b/net/sctp/socket.c	Fri Jun 22 15:05:22 2007 -0700
> @@ -6084,8 +6084,11 @@ static void sctp_sock_migrate(struct soc
>  	 * queued to the backlog.  This prevents a potential race between
>  	 * backlog processing on the old socket and new-packet processing
>  	 * on the new socket.
> -	 */
> -	sctp_lock_sock(newsk);
> +	 *
> +	 * The caller has just allocated newsk so we can guarantee that other
> +	 * paths won't try to lock it and then oldsk.
> +	 */
> +	lock_sock_nested(newsk, SINGLE_DEPTH_NESTING);
>  	sctp_assoc_migrate(assoc, newsk);
>  
>  	/* If the association on the newsk is already closed before accept()
> 

