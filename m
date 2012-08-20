From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute: Fix errno propagation from rtnl_talk
Date: Mon, 20 Aug 2012 12:55:22 -0700
Message-ID: <20120820125522.2e5eb519@nehalam.linuxnetplumber.net>
References: <5031F088.1030404@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51457 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326Ab2HTTzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 15:55:40 -0400
In-Reply-To: <5031F088.1030404@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Aug 2012 12:08:40 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> Callers of rtnl_talk check errno value for their needs. In particular, the addrs
> and routes restoring code validly reports success if the EEXISTS is in there.
> 
> However, the errno value can be sometimes screwed up by the perror call. Thus
> we should only set it _after_ the message was emitted.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> ---
> 
> diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> index 878911e..8e8c8b9 100644
> --- a/lib/libnetlink.c
> +++ b/lib/libnetlink.c
> @@ -360,13 +360,14 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
>  				if (l < sizeof(struct nlmsgerr)) {
>  					fprintf(stderr, "ERROR truncated\n");
>  				} else {
> -					errno = -err->error;
> -					if (errno == 0) {
> +					if (!err->error) {
>  						if (answer)
>  							memcpy(answer, h, h->nlmsg_len);
>  						return 0;
>  					}
> -					perror("RTNETLINK answers");
> +
> +					fprintf(stderr, "RTNETLINK answers: %s\n", strerror(-err->error));
> +					errno = -err->error;
>  				}
>  				return -1;
>  			}

Applied
