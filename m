From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net PATCH v3 2/3] net: netprio: fd passed in SCM_RIGHTS
 datagram not set correctly
Date: Wed, 15 Aug 2012 06:53:40 -0400
Message-ID: <20120815105340.GB23811@hmsreliant.think-freely.org>
References: <20120814223424.3551.21608.stgit@jf-dev1-dcblab>
 <20120814223430.3551.88909.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org, joe@perches.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120814223430.3551.88909.stgit@jf-dev1-dcblab>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2012 at 03:34:30PM -0700, John Fastabend wrote:
> A socket fd passed in a SCM_RIGHTS datagram was not getting
> updated with the new tasks cgrp prioidx. This leaves IO on
> the socket tagged with the old tasks priority.
> 
> To fix this add a check in the scm recvmsg path to update the
> sock cgrp prioidx with the new tasks value.
> 
> Thanks to Al Viro for catching this.
> 
> CC: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  net/core/scm.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/scm.c b/net/core/scm.c
> index 8f6ccfd..040cebe 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
> @@ -265,6 +265,7 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
>  	for (i=0, cmfptr=(__force int __user *)CMSG_DATA(cm); i<fdmax;
>  	     i++, cmfptr++)
>  	{
> +		struct socket *sock;
>  		int new_fd;
>  		err = security_file_receive(fp[i]);
>  		if (err)
> @@ -281,6 +282,9 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
>  		}
>  		/* Bump the usage count and install the file. */
>  		get_file(fp[i]);
> +		sock = sock_from_file(fp[i], &err);
> +		if (sock)
> +			sock_update_netprioidx(sock->sk, current);
>  		fd_install(new_fd, fp[i]);
>  	}
>  
> 
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
