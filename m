From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH] scm: remove use CMSG{_COMPAT}_ALIGN(sizeof(struct
 {compat_}cmsghdr))
Date: Wed, 4 Jan 2017 23:45:30 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15A52EB0@cnshjmbx04>
References: <1483447337-4976-1-git-send-email-cugyly@163.com>
 <20170104.132452.646592152519338774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "cugyly@163.com" <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:58796 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751247AbdADXp4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 18:45:56 -0500
In-Reply-To: <20170104.132452.646592152519338774.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, January 05, 2017 2:25 AM
> To: cugyly@163.com
> Cc: netdev@vger.kernel.org; YUAN Linyu
> Subject: Re: [PATCH] scm: remove use CMSG{_COMPAT}_ALIGN(sizeof(struct
> {compat_}cmsghdr))
> 
> From: yuan linyu <cugyly@163.com>
> Date: Tue,  3 Jan 2017 20:42:17 +0800
> 
> > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> >
> > sizeof(struct cmsghdr) and sizeof(struct compat_cmsghdr) already aligned.
> > remove use CMSG_ALIGN(sizeof(struct cmsghdr)) and
> > CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr)) keep code
> consistent.
> >
> > Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> Applied, and I added the following commit which will make sure our
> analysis is accurate.
> 
> ====================
> [PATCH] net: Assert at build time the assumptions we make about the CMSG
> header.
> 
> It must always be the case that CMSG_ALIGN(sizeof(hdr)) == sizeof(hdr).
> 
> Otherwise there are missing adjustments in the various calculations
> that parse and build these things.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/compat.c | 3 +++
>  net/socket.c | 2 ++
>  2 files changed, 5 insertions(+)
> 
> diff --git a/net/compat.c b/net/compat.c
> index 4e27dd1..ba3ac72 100644
> --- a/net/compat.c
> +++ b/net/compat.c
> @@ -130,6 +130,9 @@ int cmsghdr_from_user_compat_to_kern(struct
> msghdr *kmsg, struct sock *sk,
>  	__kernel_size_t kcmlen, tmp;
>  	int err = -EFAULT;
> 
> +	BUILD_BUG_ON(sizeof(struct compat_cmsghdr) !=
> +		     CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr)));
> +
>  	kcmlen = 0;
>  	kcmsg_base = kcmsg = (struct cmsghdr *)stackbuf;
>  	ucmsg = CMSG_COMPAT_FIRSTHDR(kmsg);
> diff --git a/net/socket.c b/net/socket.c
> index 8487bf1..5f3b5a2 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1948,6 +1948,8 @@ static int ___sys_sendmsg(struct socket *sock,
> struct user_msghdr __user *msg,
>  		ctl_buf = msg_sys->msg_control;
>  		ctl_len = msg_sys->msg_controllen;
>  	} else if (ctl_len) {
> +		BUILD_BUG_ON(sizeof(struct cmsghdr) !=
> +			     CMSG_ALIGN(sizeof(struct cmsghdr)));
>  		if (ctl_len > sizeof(ctl)) {
>  			ctl_buf = sock_kmalloc(sock->sk, ctl_len, GFP_KERNEL);
>  			if (ctl_buf == NULL)
> --
> 2.4.11
