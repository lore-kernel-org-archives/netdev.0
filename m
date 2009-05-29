From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Multicast socket option
Date: Fri, 29 May 2009 06:35:56 -0400
Message-ID: <20090529103556.GA4160@hmsreliant.think-freely.org>
References: <4A1EC33E.1080201@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Christoph Lameter <cl@linux.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nivedita Singhvi <niv@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53014 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274AbZE2KgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 06:36:08 -0400
Content-Disposition: inline
In-Reply-To: <4A1EC33E.1080201@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2009 at 10:00:46AM -0700, Nivedita Singhvi wrote:
> After some discussion offline with Christoph Lameter and David Stevens  
> regarding multicast behaviour in Linux, I'm submitting a slightly
> modified patch from the one Christoph submitted earlier.
>
> This patch provides a new socket option IP_MULTICAST_ALL.
>
> In this case, default behaviour is _unchanged_ from the current
> Linux standard. The socket option is set by default to provide original 
> behaviour. Sockets wishing to receive data only from multicast groups 
> they join explicitly will need to clear this socket option. 
>
>
> Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>
> Signed-off-by: Christoph Lameter<cl@linux.com>
> Acked-by: David Stevens <dlstevens@us.ibm.com>
>
>
> diff -urN linux-2.6.29.2/include/linux/in.h linux-2.6.29.2.new/include/linux/in.h
> --- linux-2.6.29.2/include/linux/in.h	2009-04-27 13:37:11.000000000 -0400
> +++ linux-2.6.29.2.new/include/linux/in.h	2009-05-18 16:22:06.000000000 -0400
> @@ -107,6 +107,7 @@
> #define MCAST_JOIN_SOURCE_GROUP		46
> #define MCAST_LEAVE_SOURCE_GROUP	47
> #define MCAST_MSFILTER			48
> +#define IP_MULTICAST_ALL		49
>
> #define MCAST_EXCLUDE	0
> #define MCAST_INCLUDE	1
> diff -urN linux-2.6.29.2/include/net/inet_sock.h linux-2.6.29.2.new/include/net/inet_sock.h
> --- linux-2.6.29.2/include/net/inet_sock.h	2009-04-27 13:37:11.000000000 -0400
> +++ linux-2.6.29.2.new/include/net/inet_sock.h	2009-05-18 16:22:06.000000000 -0400
> @@ -130,7 +130,8 @@
> 				freebind:1,
> 				hdrincl:1,
> 				mc_loop:1,
> -				transparent:1;
> +				transparent:1,
> +				mc_all:1;
> 	int			mc_index;
> 	__be32			mc_addr;
> 	struct ip_mc_socklist	*mc_list;
> diff -urN linux-2.6.29.2/net/ipv4/af_inet.c linux-2.6.29.2.new/net/ipv4/af_inet.c
> --- linux-2.6.29.2/net/ipv4/af_inet.c	2009-04-27 13:37:11.000000000 -0400
> +++ linux-2.6.29.2.new/net/ipv4/af_inet.c	2009-05-18 16:22:06.000000000 -0400
> @@ -376,6 +376,7 @@
> 	inet->uc_ttl	= -1;
> 	inet->mc_loop	= 1;
> 	inet->mc_ttl	= 1;
> +	inet->mc_all	= 1;
> 	inet->mc_index	= 0;
> 	inet->mc_list	= NULL;
>
> diff -urN linux-2.6.29.2/net/ipv4/igmp.c linux-2.6.29.2.new/net/ipv4/igmp.c
> --- linux-2.6.29.2/net/ipv4/igmp.c	2009-04-27 13:37:11.000000000 -0400
> +++ linux-2.6.29.2.new/net/ipv4/igmp.c	2009-05-18 16:22:33.000000000 -0400
> @@ -2196,7 +2196,7 @@
> 			break;
> 	}
> 	if (!pmc)
> -		return 1;
> +		return inet->mc_all;

This change also filters out broadcasts sent to sockets listening on a given
port.  Is that what you want?

Neil

>
