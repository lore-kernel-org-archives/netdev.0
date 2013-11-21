From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: rework recvmsg handler msg_name and msg_namelen
 logic
Date: Wed, 20 Nov 2013 17:02:40 -0800
Message-ID: <1384995760.2164.33.camel@joe-AO722>
References: <20131121003828.GA32587@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0018.hostedemail.com ([216.40.44.18]:41566 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753481Ab3KUBCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 20:02:44 -0500
In-Reply-To: <20131121003828.GA32587@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 01:38 +0100, Hannes Frederic Sowa wrote:
> This patch now always passes msg->msg_namelen as 0. recvmsg handlers must
> set msg_namelen to the proper size <= sizeof(struct sockaddr_storage)
> to return msg_name to the user.
[]
> This change does not alter the user visible error logic as we ignore
> msg_namelen as long as msg_name is NULL.
> 
> Also remove two unnecessary curly brackets in ___sys_recvmsg and change
> comments to netdev style.

Perhaps take the opportunity to remove the unnecessary casts of
struct msghdr.msg_name as it's a void *.

And there's one other oddity about setting a known NULL to NULL.

Maybe fix in a follow-on patch?

> diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
[]
> @@ -135,9 +134,10 @@ mISDN_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
[]
> +	if (msg->msg_name) {
> +		struct sockaddr_mISDN *maddr =
> +			(struct sockaddr_mISDN *)msg->msg_name;

		struct sockaddr_mISDN *maddr = msg->msg_name;

> diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
[]
> @@ -1764,14 +1763,14 @@ static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
[]
> +	if (!err && msg->msg_name) {
> +		struct sockaddr_at *sat =
> +			(struct sockaddr_at *)msg->msg_name;

> diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
[]
> @@ -1636,11 +1636,12 @@ static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
[]
> +		struct sockaddr_ax25 *sax =
> +			(struct sockaddr_ax25 *)msg->msg_name;

> diff --git a/net/core/iovec.c b/net/core/iovec.c
[]
> @@ -48,7 +48,7 @@ int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr_storage *a
>  			if (err < 0)
>  				return err;
>  		}
> -		m->msg_name = address;
> +		m->msg_name = (m->msg_name) ? address : NULL;

It's pretty odd I think to set a known NULL to NULL;

> diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
[]
> @@ -1252,8 +1251,11 @@ static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
[]
> +		srose = (struct sockaddr_rose *)msg->msg_name;
