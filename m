From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] netfilter: take care of timewait sockets
Date: Tue, 04 Sep 2012 09:55:25 +0200
Message-ID: <1346745325.13121.4.camel@edumazet-glaptop>
References: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>
	 <20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>
	 <20120902132834.GB7456@breakpoint.cc>
	 <1346626385.2563.44.camel@edumazet-glaptop>
	 <1346629684.2563.78.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sami Farin <hvtaifwkbgefbaei@gmail.com>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35520 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab2IDHzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 03:55:32 -0400
Received: by bkwj10 with SMTP id j10so2480160bkw.19
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2012 00:55:30 -0700 (PDT)
In-Reply-To: <1346629684.2563.78.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-03 at 01:48 +0200, Eric Dumazet wrote:
> Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
> full blown socket.
> 
> But with TCP early demux, we can have skb->sk pointing to a timewait
> socket.
> 
> Same fix is needed in netfnetlink_log
> 
> Diagnosed-by: Florian Westphal <fw@strlen.de>
> Reported-by: Sami Farin <hvtaifwkbgefbaei@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/netfilter/nfnetlink_log.c |   14 +++++++------
>  net/netfilter/xt_LOG.c        |   33 ++++++++++++++++----------------
>  2 files changed, 25 insertions(+), 22 deletions(-)
> 
> diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
> index 14e2f39..5cfb5be 100644
> --- a/net/netfilter/nfnetlink_log.c
> +++ b/net/netfilter/nfnetlink_log.c
> @@ -381,6 +381,7 @@ __build_packet_message(struct nfulnl_instance *inst,
>  	struct nlmsghdr *nlh;
>  	struct nfgenmsg *nfmsg;
>  	sk_buff_data_t old_tail = inst->skb->tail;
> +	struct sock *sk;
>  
>  	nlh = nlmsg_put(inst->skb, 0, 0,
>  			NFNL_SUBSYS_ULOG << 8 | NFULNL_MSG_PACKET,
> @@ -499,18 +500,19 @@ __build_packet_message(struct nfulnl_instance *inst,
>  	}
>  
>  	/* UID */
> -	if (skb->sk) {
> -		read_lock_bh(&skb->sk->sk_callback_lock);
> -		if (skb->sk->sk_socket && skb->sk->sk_socket->file) {
> -			struct file *file = skb->sk->sk_socket->file;
> +	sk = skb->sk;
> +	if (sk && sk->sk_state != TCP_TIME_WAIT) {
> +		read_lock_bh(&sk->sk_callback_lock);
> +		if (sk->sk_socket && sk->sk_socket->file) {
> +			struct file *file = sk->sk_socket->file;
>  			__be32 uid = htonl(file->f_cred->fsuid);
>  			__be32 gid = htonl(file->f_cred->fsgid);
> -			read_unlock_bh(&skb->sk->sk_callback_lock);
> +			read_unlock_bh(&sk->sk_callback_lock);
>  			if (nla_put_be32(inst->skb, NFULA_UID, uid) ||
>  			    nla_put_be32(inst->skb, NFULA_GID, gid))
>  				goto nla_put_failure;
>  		} else
> -			read_unlock_bh(&skb->sk->sk_callback_lock);
> +			read_unlock_bh(&sk->sk_callback_lock);
>  	}
>  
>  	/* local sequence number */
> diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
> index ff5f75f..2a4f969 100644
> --- a/net/netfilter/xt_LOG.c
> +++ b/net/netfilter/xt_LOG.c
> @@ -145,6 +145,19 @@ static int dump_tcp_header(struct sbuff *m, const struct sk_buff *skb,
>  	return 0;
>  }
>  
> +static void dump_sk_uid_gid(struct sbuff *m, struct sock *sk)
> +{
> +	if (!sk || sk->sk_state == TCP_TIME_WAIT)
> +		return;
> +
> +	read_lock_bh(&sk->sk_callback_lock);
> +	if (sk->sk_socket && sk->sk_socket->file)
> +		sb_add(m, "UID=%u GID=%u ",
> +			sk->sk_socket->file->f_cred->fsuid,
> +			sk->sk_socket->file->f_cred->fsgid);
> +	read_unlock_bh(&sk->sk_callback_lock);
> +}
> +
>  /* One level of recursion won't kill us */
>  static void dump_ipv4_packet(struct sbuff *m,
>  			const struct nf_loginfo *info,
> @@ -361,14 +374,8 @@ static void dump_ipv4_packet(struct sbuff *m,
>  	}
>  
>  	/* Max length: 15 "UID=4294967295 " */
> -	if ((logflags & XT_LOG_UID) && !iphoff && skb->sk) {
> -		read_lock_bh(&skb->sk->sk_callback_lock);
> -		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
> -			sb_add(m, "UID=%u GID=%u ",
> -				skb->sk->sk_socket->file->f_cred->fsuid,
> -				skb->sk->sk_socket->file->f_cred->fsgid);
> -		read_unlock_bh(&skb->sk->sk_callback_lock);
> -	}
> +	if ((logflags & XT_LOG_UID) && !iphoff)
> +		dump_sk_uid_gid(m, skb->sk);
>  
>  	/* Max length: 16 "MARK=0xFFFFFFFF " */
>  	if (!iphoff && skb->mark)
> @@ -717,14 +724,8 @@ static void dump_ipv6_packet(struct sbuff *m,
>  	}
>  
>  	/* Max length: 15 "UID=4294967295 " */
> -	if ((logflags & XT_LOG_UID) && recurse && skb->sk) {
> -		read_lock_bh(&skb->sk->sk_callback_lock);
> -		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
> -			sb_add(m, "UID=%u GID=%u ",
> -				skb->sk->sk_socket->file->f_cred->fsuid,
> -				skb->sk->sk_socket->file->f_cred->fsgid);
> -		read_unlock_bh(&skb->sk->sk_callback_lock);
> -	}
> +	if ((logflags & XT_LOG_UID) && recurse)
> +		dump_sk_uid_gid(m, skb->sk);
>  
>  	/* Max length: 16 "MARK=0xFFFFFFFF " */
>  	if (!recurse && skb->mark)
> 

Hi David

This patch was marked "Not applicable" in Patchwork
( http://patchwork.ozlabs.org/patch/181275/ )

It seems a mistake, since it should be applied ?

Tell me if I should resend it

Thanks
