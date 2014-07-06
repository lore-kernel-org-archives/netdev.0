From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] appletalk: Set skb with destructor
Date: Sun, 06 Jul 2014 23:42:12 +0200
Message-ID: <1404682932.4501.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140705202821.GA25880@mwanda>
	 <1404647816-7564-1-git-send-email-andrey.krieger.utkin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	acme@ghostprotocols.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404647816-7564-1-git-send-email-andrey.krieger.utkin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-07-06 at 14:56 +0300, Andrey Utkin wrote:
> The sock ref counting is off so there is a kernel panic when you run
> `atalkd`.  See https://bugzilla.kernel.org/show_bug.cgi?id=79441
> This fix is similar to 0ae89beb283a ('can: add destructor for self
> generated skbs')
>  should
> Reported-by: Ed Martin <edman007@edman007.com>
> Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>
> ---
>  net/appletalk/ddp.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
> index 01a1082..3d8ab34 100644
> --- a/net/appletalk/ddp.c
> +++ b/net/appletalk/ddp.c
> @@ -1399,6 +1399,11 @@ drop:
>  	return NET_RX_DROP;
>  }
>  
> +static inline void atalk_skb_destructor(struct sk_buff *skb)
> +{
> +	sock_put(skb->sk);
> +}
> +
>  /**
>   *	atalk_rcv - Receive a packet (in skb) from device dev
>   *	@skb - packet received
> @@ -1489,6 +1494,8 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
>  		goto drop;
>  
>  	/* Queue packet (standard) */
> +	sock_hold(sock);
> +	skb->destructor = atalk_skb_destructor;
>  	skb->sk = sock;

This part is not needed : sock_queue_rcv_skb() already does the right
thing : It calls skb_set_owner_r(skb, sk);

You should therefore remove the "skb->sk = sock;" line

>  
>  	if (sock_queue_rcv_skb(sock, skb) < 0)
> @@ -1644,6 +1651,8 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
>  	if (!skb)
>  		goto out;
>  
> +	sock_hold(sk);
> +	skb->destructor = atalk_skb_destructor;
>  	skb->sk = sk;
>  	skb_reserve(skb, ddp_dl->header_length);
>  	skb_reserve(skb, dev->hard_header_len);
