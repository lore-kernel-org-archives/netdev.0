From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3] fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Wed, 19 Nov 2014 11:50:46 +0100
Message-ID: <1465171.AHCWU7rWts@wuerfel>
References: <20141117013448.GA26743@midget.suse.cz> <20141119103413.GA19092@midget.suse.cz> <20141119103814.GB19092@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:58094 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754080AbaKSKvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 05:51:07 -0500
In-Reply-To: <20141119103814.GB19092@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 19 November 2014 11:38:14 Jiri Bohac wrote:
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
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Looks correct to me and simple enough,

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

> diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
> index a0c7536..d0725d9 100644
> --- a/net/ipx/af_ipx.c
> +++ b/net/ipx/af_ipx.c
> @@ -1764,6 +1764,7 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
>  	struct ipxhdr *ipx = NULL;
>  	struct sk_buff *skb;
>  	int copied, rc;
> +	int locked = 1;
>  
>  	lock_sock(sk);
>  	/* put the autobinding in */
> @@ -1790,6 +1791,8 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
>  	if (sock_flag(sk, SOCK_ZAPPED))
>  		goto out;
>  
> +	release_sock(sk);
> +	locked = 0;
>  	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
>  				flags & MSG_DONTWAIT, &rc);
>  	if (!skb) {
> @@ -1825,7 +1828,8 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
>  out_free:
>  	skb_free_datagram(sk, skb);
>  out:
> -	release_sock(sk);
> +	if (locked)
> +		release_sock(sk);
>  	return rc;
>  }

I don't like the idea of having a local flag for this, and would still
prefer the simpler version of taking the lock again even if it's not
needed, but your version is probably good enough unless Dave wants
you to do a v4 for this.

	Arnd
