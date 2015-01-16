From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipv4: Fix incorrect free in ICMP receive
Date: Fri, 16 Jan 2015 04:52:55 -0800
Message-ID: <1421412775.11734.117.camel@edumazet-glaptop2.roam.corp.google.com>
References: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:60550 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbbAPMw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 07:52:57 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so20428068ieb.3
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 04:52:56 -0800 (PST)
In-Reply-To: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-16 at 07:48 +0000, subashab@codeaurora.org wrote:
> An exception is seen in ICMP ping receive path where the skb
> destructor sock_rfree() tries to access a freed socket. This happens
> because ping_rcv() releases socket reference with sock_put() and this
> internally frees up the socket. Later icmp_rcv() will try to free the
> skb and as part of this, skb destructor is called and panics as the
> socket is freed already in ping_rcv().
> 
> WARN stack trace @       WARN_ON(atomic_read(&sk->sk_rmem_alloc));
> dump_backtrace+0x0/0x248
> show_stack+0x10/0x1c
> dump_stack+0x1c/0x28
> warn_slowpath_common+0x74/0x9c
> warn_slowpath_null+0x14/0x20
> inet_sock_destruct+0x130/0x1a0
> __sk_free+0x1c/0x168
> sk_free+0x24/0x30
> ping_rcv+0xf4/0x124
> icmp_rcv+0x224/0x2c4
> ip_local_deliver_finish+0x108/0x214
> ip_local_deliver+0x88/0xa0
> ip_rcv_finish+0x234/0x284
> ip_rcv+0x258/0x2e8
> __netif_receive_skb_core+0x640/0x6b4
> <snip>
> 
> -->|exception
> -007|sk_mem_uncharge
> -007|sock_rfree
> -008|skb_release_head_state
> -009|skb_release_all
> -009|__kfree_skb
> -010|kfree_skb
> -011|icmp_rcv
> -012|ip_local_deliver_finish
> 
> Fix this by orphaning the skb's before freeing the socket
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
>  net/ipv4/af_inet.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index b507a47..0c58f0e5 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -147,6 +147,12 @@ EXPORT_SYMBOL(ipv4_config);
>  void inet_sock_destruct(struct sock *sk)
>  {
>  	struct inet_sock *inet = inet_sk(sk);
> +	struct sk_buff *skb;
> +
> +	skb_queue_walk(&sk->sk_receive_queue, skb)
> +		skb_orphan(skb);
> +	skb_queue_walk(&sk->sk_error_queue, skb)
> +		skb_orphan(skb);
> 
>  	__skb_queue_purge(&sk->sk_receive_queue);
>  	__skb_queue_purge(&sk->sk_error_queue);

Sorry this makes absolutely no sense to me.

skb_queue_purge() is also calling skb_orphan() on all skb.

And no, sock_put() does not free the socket.
We release a refcount that was acquired when we did the socket lookup.
