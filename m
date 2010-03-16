From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1/1] NET: netpoll, fix potential NULL ptr dereference
Date: Tue, 16 Mar 2010 12:12:07 -0500
Message-ID: <1268759527.25503.2980.camel@calx>
References: <1268753394-17765-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Daniel Borkmann <danborkmann@googlemail.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268753394-17765-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-03-16 at 16:29 +0100, Jiri Slaby wrote:
> Stanse found that one error path in netpoll_setup dereferences npinfo
> even though it is NULL. Avoid that by adding new label and go to that
> instead.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Daniel Borkmann <danborkmann@googlemail.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  net/core/netpoll.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 7aa6972..d4ec38f 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -735,7 +735,7 @@ int netpoll_setup(struct netpoll *np)
>  		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
>  		if (!npinfo) {
>  			err = -ENOMEM;
> -			goto release;
> +			goto put;
>  		}
>  
>  		npinfo->rx_flags = 0;
> @@ -845,7 +845,7 @@ int netpoll_setup(struct netpoll *np)
>  
>  		kfree(npinfo);
>  	}
> -
> +put:
>  	dev_put(ndev);
>  	return err;
>  }

I don't get it. The source of the branch tests for !ndev->npinfo and the
original destination of the branch also tests for !ndev->npinfo. I don't
see how it gets dereferenced.

This looks like it just patches over a false positive in your tool
(which isn't correlating the validity of npinfo with ndev->npinfo)
without actually improving the code. However, it seems that we can drop
the second check at release if we add your new exit point.

-- 
http://selenic.com : development and support for Mercurial and Linux
