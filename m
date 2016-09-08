From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] ipv4: accept u8 in IP_TOS ancillary data
Date: Thu, 8 Sep 2016 11:15:19 +0200
Message-ID: <20160908111519.62af94bf@redhat.com>
References: <1473310376.15733.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Francesco Fusco <fusco@ntop.org>,
        Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <maze@google.com>,
        brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60068 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933325AbcIHJPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 05:15:25 -0400
In-Reply-To: <1473310376.15733.26.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 07 Sep 2016 21:52:56 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit f02db315b8d8 ("ipv4: IP_TOS and IP_TTL can be specified as
> ancillary data") Francesco added IP_TOS values specified as integer.
> 
> However, kernel sends to userspace (at recvmsg() time) an IP_TOS value
> in a single byte, when IP_RECVTOS is set on the socket.
> 
> It can be very useful to reflect all ancillary options as given by the
> kernel in a subsequent sendmsg(), instead of aborting the sendmsg() with
> EINVAL after Francesco patch.
> 
> So this patch extends IP_TOS ancillary to accept an u8, so that an UDP
> server can simply reuse same ancillary block without having to mangle
> it.
> 
> Jesper can then augment
> https://github.com/netoptimizer/network-testing/blob/master/src/udp_example02.c
> to add TOS reflection ;)

This is actually your old program ;-)
Do I need to change anything, as I'm just bouncing the packet back with sendmsg() ?


> Fixes: f02db315b8d8 ("ipv4: IP_TOS and IP_TTL can be specified as ancillary data")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Francesco Fusco <ffusco@redhat.com> 
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>

Looks like a good fix,

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

> ---
>  net/ipv4/ip_sockglue.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index 71a52f4d4cffba2db9353f43dc817689bf4fab10..af4919792b6a812041dcb18ff30aa8b27482c7a2 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -284,9 +284,12 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
>  			ipc->ttl = val;
>  			break;
>  		case IP_TOS:
> -			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int)))
> +			if (cmsg->cmsg_len == CMSG_LEN(sizeof(int)))
> +				val = *(int *)CMSG_DATA(cmsg);
> +			else if (cmsg->cmsg_len == CMSG_LEN(sizeof(u8)))
> +				val = *(u8 *)CMSG_DATA(cmsg);
> +			else
>  				return -EINVAL;
> -			val = *(int *)CMSG_DATA(cmsg);
>  			if (val < 0 || val > 255)
>  				return -EINVAL;
>  			ipc->tos = val;
> 
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
