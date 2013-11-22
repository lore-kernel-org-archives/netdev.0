From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: rework recvmsg handler msg_name and msg_namelen logic
Date: Fri, 22 Nov 2013 07:45:49 +0100
Message-ID: <20131122064549.GA15822@order.stressinduktion.org>
References: <20131121003828.GA32587@order.stressinduktion.org> <528E1E2E.20905@gmail.com> <1385046014.10637.44.camel@edumazet-glaptop2.roam.corp.google.com> <20131121.125707.653753874005080724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58662 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab3KVGpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 01:45:51 -0500
Content-Disposition: inline
In-Reply-To: <20131121.125707.653753874005080724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 21, 2013 at 12:57:07PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 21 Nov 2013 07:00:14 -0800
> 
> > So a protocol should use BUILD_BUG_ON() to make sure sockaddr_storage is
> > big enough.
> 
> Hannes mentioned trying to do this, somehow, automatically.  Best I could
> come up with is something like:
> 
> #define DECLARE_RECVMSG_HANDLER(name, ..., sockaddr_type) \
> static ... __name(...); \
> static ... name(...)	\
> {	\
> 	BUILD_BUG_ON(sizeof(sockaddr_type) > sizeof(sockaddr_storage); \
> 	__name(...); \
> } \
> static ... __name(...)
> 
> And then the protocols go:
> 
> DECLARE_RECVMSG_HANDLER(udp_recvmsg, ..., struct sockaddr_in)
> {
> 	struct inet_sock *inet = inet_sk(sk);
> 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
>  ...
> 
> You get the idea.
> 
> Slightly convoluted, and we can do something special with types or the
> prot ops member name to enforce usage of the macro.

Actually we already have a simpler solution in the tree:

#define __sockaddr_check_size(size)     \
        BUILD_BUG_ON(((size) > sizeof(struct __kernel_sockaddr_storage)))

and

#define DECLARE_SOCKADDR(type, dst, src)        \
        type dst = ({ __sockaddr_check_size(sizeof(*dst)); (type) src; })

Unfortunately I missed it before (it only gets used in the getname functions).
So, some checks are already in place (af_packet, af_inet, llcp_sock, af_unix
and af_netlink).

I still want to explore my idea regarding coccinelle or sparse. Checking
these with sparse should be relatively straightforward. We would just
have to lift the msg_name pointer into its own address_space universe
and add a __force to the cast in DECLARE_SOCKADDR. But because sparse
errors are already high in numbers I fear it will be simply overlooked.

I'll want to test if a coccicheck is reasonable, too.

Will cook something up soon.

Greetings,

  Hannes
