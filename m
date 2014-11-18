From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: ipx: fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Tue, 18 Nov 2014 14:37:26 +0100
Message-ID: <8698539.evYG7fs8jS@wuerfel>
References: <20141117013448.GA26743@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:50492 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113AbaKRNhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 08:37:41 -0500
In-Reply-To: <20141117013448.GA26743@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 17 November 2014 02:34:48 Jiri Bohac wrote:
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
> Similarly, a potentially sleeping sendmsg() could block calls to recvmsg().
> 
> Only keep the socket locked while actually working with the socket data and
> release it prior to calling skb_recv_datagram() / ipxitf_send().
> 
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Hi Jiri,

I'm very sorry about the regression my patch introduced, glad you worked
it out. Your patch looks correct to me, but I suspect we can do it in
a simpler way, based on what I found I did in the respective appletalk
and x25 BKL removal patches. From all I can tell, those do not have
the same problem, which is a relief to me.

Some questions:

> @@ -1745,12 +1745,16 @@ static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
>  		memcpy(usipx->sipx_node, ipxs->dest_addr.node, IPX_NODE_LEN);
>  	}
>  
> +	/* releases sk */
>  	rc = ipxrtr_route_packet(sk, usipx, msg->msg_iov, len,
>  				 flags & MSG_DONTWAIT);
>  	if (rc >= 0)
>  		rc = len;
> -out:
> +	goto out;
> +
> +out_release:
>  	release_sock(sk);
> +out:
>  	return rc;
>  }
>  

Does ipxrtr_route_packet() actually sleep while waiting for the network,
or is it possible that you only need to change the recvmsg path?

If you need to change this function, have you considered doing it
one of these two ways:

a) only change the ipxrtr_route_packet function to release the lock
   before sleeping and then reaquiring it but not change ipx_sendmsg

b) figure out whether ipx_sendmsg actually relies on the lock at all,
   and if it doesn't then remove the locking, or limit the scope to
   the parts that do.


> @@ -1776,20 +1780,21 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
>  #ifdef CONFIG_IPX_INTERN
>  		rc = -ENETDOWN;
>  		if (!ipxs->intrfc)
> -			goto out; /* Someone zonked the iface */
> +			goto out_release; /* Someone zonked the iface */
>  		memcpy(uaddr.sipx_node, ipxs->intrfc->if_node, IPX_NODE_LEN);
>  #endif	/* CONFIG_IPX_INTERN */
>  
>  		rc = __ipx_bind(sock, (struct sockaddr *)&uaddr,
>  			      sizeof(struct sockaddr_ipx));
>  		if (rc)
> -			goto out;
> +			goto out_release;
>  	}
>  
>  	rc = -ENOTCONN;
>  	if (sock_flag(sk, SOCK_ZAPPED))
> -		goto out;
> +		goto out_release;
>  
> +	release_sock(sk);
>  	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
>  				flags & MSG_DONTWAIT, &rc);
>  	if (!skb) {

Same thing here: I think your patch could be simplified if you just
release the socket lock before calling skb_recv_datagram and get
it back afterwards, and it would be much simpler if you could
show that the lock is not needed at all.

	Arnd
