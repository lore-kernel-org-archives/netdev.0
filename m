From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [patch v2] net: heap overflow in __audit_sockaddr()
Date: Wed, 27 Nov 2013 11:32:18 +0000
Message-ID: <20131127113218.GB1612@dcvr.yhbt.net>
References: <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com>
 <20131002212720.GA30492@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	security@kernel.org,
	=?utf-8?B?SsO8cmk=?= Aedla <juri.aedla@gmail.com>,
	stable@kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dcvr.yhbt.net ([64.71.152.64]:56051 "EHLO dcvr.yhbt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533Ab3K0Lmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Nov 2013 06:42:49 -0500
Content-Disposition: inline
In-Reply-To: <20131002212720.GA30492@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> wrote:
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1964,6 +1964,16 @@ struct used_address {
>  	unsigned int name_len;
>  };
>  
> +static int copy_msghdr_from_user(struct msghdr *kmsg,
> +				 struct msghdr __user *umsg)
> +{
> +	if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
> +		return -EFAULT;
> +	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
> +		return -EINVAL;
> +	return 0;

Crap, this seems to break Ruby trunk :x
https://bugs.ruby-lang.org/issues/9124

I'm inclined to think Ruby is wrong to use a gigantic buffer, but this
may also break some other existing userspace code.  I'm not sure what
the best option since breaking userspace (even buggy userspace?) is not
taken lightly.

Is there a different way to fix this in the kernel?

Note: this doesn't affect a stable release of Ruby, yet.

(Not a Ruby developer myself, just occasional contributor).
