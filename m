From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/3] ipv6: use newly introduced __ipv6_addr_needs_scope_id and ipv6_iface_scope_id
Date: Wed, 13 Feb 2013 01:13:57 +0100
Message-ID: <20130213001357.GB1096@order.stressinduktion.org>
References: <20130212221634.GA7212@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60252 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477Ab3BMAN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 19:13:58 -0500
Content-Disposition: inline
In-Reply-To: <20130212221634.GA7212@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2013 at 11:16:34PM +0100, Hannes Frederic Sowa wrote:
> This patch requires multicast interface-scoped addresses to supply a
> sin6_scope_id. Because the sin6_scope_id is now also correctly used
> in case of interface-scoped multicast traffic this enables one to use
> interface scoped addresses over interfaces which are not targeted by the
> default multicast route (the route has to be put there manually, though).
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/af_inet6.c              |  6 +++---
>  net/ipv6/datagram.c              | 18 ++++++++++--------
>  net/ipv6/icmp.c                  |  2 +-
>  net/ipv6/inet6_connection_sock.c |  6 ++----
>  net/ipv6/raw.c                   |  9 ++++-----
>  net/ipv6/udp.c                   | 14 ++++++++------
>  6 files changed, 28 insertions(+), 27 deletions(-)
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 6b793bf..f56277f 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -323,7 +323,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  			struct net_device *dev = NULL;
>  
>  			rcu_read_lock();
> -			if (addr_type & IPV6_ADDR_LINKLOCAL) {
> +			if (__ipv6_addr_needs_scope_id(addr_type)) {
>  				if (addr_len >= sizeof(struct sockaddr_in6) &&
>  				    addr->sin6_scope_id) {
>  					/* Override any existing binding, if another one

By trying to setup the multicast interface scoped routes by default I
just found a bug in this patch essentially breaking ipv6 multicast. I
overlooked that ipv6_addr_type strips off the scopes, thus my check if
a multicast address needs a scope_id always returns true. I'll check
if I can convert the ipv6_addr_type calls to __ipv6_addr_type and will
reroll the patch.  Sorry, my tests were too focused on interface/local
multicast. :(
