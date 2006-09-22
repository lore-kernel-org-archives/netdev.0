From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 5/9] network namespaces: async socket operations
Date: Fri, 22 Sep 2006 17:33:56 +0200
Message-ID: <45140264.3020007@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru> <20060815184845.A2882@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:25131 "EHLO
	mtagate1.de.ibm.com") by vger.kernel.org with ESMTP id S932602AbWIVPd5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 11:33:57 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id k8MFXspU102686
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 15:33:54 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8MFZjDT3174608
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 17:35:45 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8MFXrVN000433
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 17:33:54 +0200
To: Andrey Savochkin <saw@sw.ru>
In-Reply-To: <20060815184845.A2882@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Savochkin wrote:
> Non-trivial part of socket namespaces: asynchronous events
> should be run in proper context.
> 
> Signed-off-by: Andrey Savochkin <saw@swsoft.com>
> ---
>  af_inet.c            |   10 ++++++++++
>  inet_timewait_sock.c |    8 ++++++++
>  tcp_timer.c          |    9 +++++++++
>  3 files changed, 27 insertions(+)
> 
> --- ./net/ipv4/af_inet.c.venssock-asyn	Mon Aug 14 17:04:07 2006
> +++ ./net/ipv4/af_inet.c	Tue Aug 15 13:45:44 2006
> @@ -366,10 +366,17 @@ out_rcu_unlock:
>  int inet_release(struct socket *sock)
>  {
>  	struct sock *sk = sock->sk;
> +	struct net_namespace *ns, *orig_net_ns;
>  
>  	if (sk) {
>  		long timeout;
>  
> +		/* Need to change context here since protocol ->close
> +		 * operation may send packets.
> +		 */
> +		ns = get_net_ns(sk->sk_net_ns);
> +		push_net_ns(ns, orig_net_ns);
> +

Is it not a race condition here ? What happens if you have a packet 
incoming during the namespace context switching ?

IHMO doing namespace switching is something dangerous, you can probably 
handle that with locks but it will be difficult and will decrease all 
network performance.

In an other hand, I don't see how you can handle the 
"sk->sk_prot->close" after ...

    -- Cheers
