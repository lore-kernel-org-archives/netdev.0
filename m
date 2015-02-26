From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/7] net: rxrpc: change call to
 sock_recv_ts_and_drops() on rxrpc recvmsg to sock_recv_timestamp()
Date: Wed, 25 Feb 2015 20:40:52 -0800
Message-ID: <1424925652.5565.145.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	 <1424916612-744-4-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, willemb@google.com, edumazet@google.com,
	shmulik.ladkani@gmail.com, marcel@holtmann.org,
	netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35917 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbBZEky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 23:40:54 -0500
Received: by ierx19 with SMTP id x19so11094880ier.3
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 20:40:53 -0800 (PST)
In-Reply-To: <1424916612-744-4-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 04:10 +0200, Eyal Birger wrote:
> Commit 3b885787ea4112 ("net: Generalize socket rx gap / receive queue overflow cmsg")
> allowed receiving packet dropcount information as a socket level option.
> RXRPC sockets recvmsg function was changed to support this by calling
> sock_recv_ts_and_drops() instead of sock_recv_timestamp().
> 
> However, protocol families wishing to receive dropcount should call
> sock_queue_rcv_skb() or set the dropcount specifically (as done
> in packet_rcv()). This was not done for rxrpc and thus this feature
> never worked on these sockets.
> 
> Formalizing this by not calling sock_recv_ts_and_drops() in rxrpc as
> part of an effort to move skb->dropcount into skb->cb[]
> 
> Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
> ---
>  net/rxrpc/ar-recvmsg.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
> index 4575485..d58ba70 100644
> --- a/net/rxrpc/ar-recvmsg.c
> +++ b/net/rxrpc/ar-recvmsg.c
> @@ -150,7 +150,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
>  				       &call->conn->trans->peer->srx, len);
>  				msg->msg_namelen = len;
>  			}
> -			sock_recv_ts_and_drops(msg, &rx->sk, skb);
> +			sock_recv_timestamp(msg, &rx->sk, skb);
>  		}

I guess this should be the last patch of the serie, as this will
overwrite skb->mark, and rxrpc seems to care about skb->mark 
