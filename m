From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sat, 29 Jan 2005 01:21:28 +0100
Message-ID: <20050129002128.GX31837@postel.suug.ch>
References: <20050128230327.GV31837@postel.suug.ch> <E1CufRB-0000zf-00@gondolin.me.apana.org.au> <20050128234828.GA24868@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20050128234828.GA24868@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Alexey Kuznetsov <20050128234828.GA24868@yakov.inr.ac.ru> 2005-01-29 02:48
> > > -#define NLMSG_GOODSIZE (PAGE_SIZE - ((sizeof(struct sk_buff)+0xF)&~0xF))
> 
> 
> ... which reminded me about an old stale patchlet:
> 
> 
> Comment: improper size calculation for collapsed skb size.
>          Noticed by Denis V. Lunev <den@asplinux.ru>
> 
> ===== net/ipv4/tcp_input.c 1.89 vs edited =====
> --- 1.89/net/ipv4/tcp_input.c	Tue Jan 18 01:09:33 2005
> +++ edited/net/ipv4/tcp_input.c	Thu Jan 27 19:41:07 2005
> @@ -3760,8 +3760,8 @@
>  	while (before(start, end)) {
>  		struct sk_buff *nskb;
>  		int header = skb_headroom(skb);
> -		int copy = (PAGE_SIZE - sizeof(struct sk_buff) -
> -			    sizeof(struct skb_shared_info) - header - 31)&~15;
> +		int copy = (PAGE_SIZE - sizeof(struct skb_shared_info)
> +			    - header - 31)&~15;

Indeed, it can still exceed PAGE_SIZE in alloc_skb because of the SMP_CACHE_BYTES
alignment though. Can someone enlighten me about the magic 31 in there? I don't get
it from the context. The patch below should do a little bit better

--- linux-2.6.11-rc2-bk4.orig/net/ipv4/tcp_input.c	2005-01-26 18:19:42.000000000 +0100
+++ linux-2.6.11-rc2-bk4/net/ipv4/tcp_input.c	2005-01-29 01:12:30.000000000 +0100
@@ -3760,8 +3760,7 @@
 	while (before(start, end)) {
 		struct sk_buff *nskb;
 		int header = skb_headroom(skb);
-		int copy = (PAGE_SIZE - sizeof(struct sk_buff) -
-			    sizeof(struct skb_shared_info) - header - 31)&~15;
+		int copy = SKB_MAX_ORDER(header + 31, 0);
 
 		/* Too big header? This can happen with IPv6. */
 		if (copy < 0)
