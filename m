From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: icmp: Add protection from concurrent users in the
 function icmpv6_echo_reply
Date: Tue, 5 Apr 2016 23:36:28 +0200
Message-ID: <57042FDC.6020809@stressinduktion.org>
References: <1459891676-20836-1-git-send-email-bastienphilbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bastien Philbert <bastienphilbert@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:43471 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760156AbcDEVgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 17:36:33 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 8E63721687
	for <netdev@vger.kernel.org>; Tue,  5 Apr 2016 17:36:32 -0400 (EDT)
In-Reply-To: <1459891676-20836-1-git-send-email-bastienphilbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.04.2016 23:27, Bastien Philbert wrote:
> This adds protection from concurrenct users in the function
> icmpv6_echo_reply around the call to the function __in6_dev_get
> by locking/unlocking around this call with calls to the functions
> rtnl_lock and rtnl_unlock to protect against concurrent users
> when calling this function in icmpv6_echo_reply as stated in the
> comments for locking requirements for the function, __in6_dev_get.
>
> Signed-off-by: Bastien Philbert <bastienphilbert@gmail.com>
> ---
>   net/ipv6/icmp.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 0a37ddc..798434f 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -607,7 +607,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
>
>   	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
>
> +	rtnl_lock();
>   	idev = __in6_dev_get(skb->dev);
> +	rtnl_unlock();
>
>   	msg.skb = skb;
>   	msg.offset = 0;
>

We can't hold rtnl_lock in bh context. Have you seen a rcu verifier 
report? I am sure we hold rcu read lock at this point.

Bye,
Hannes
