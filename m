From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Subject: Re: [PATCHv2] ipv4: Do not cache routing failures due to disabled
 forwarding.
Date: Tue, 16 Sep 2014 21:52:22 +0200
Message-ID: <541894F6.3090903@green-communications.fr>
References: <54143FB2.9000600@green-communications.fr>	<1410776893-5284-1-git-send-email-nicolas.cavallari@green-communications.fr> <20140916.145435.714034191389495557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.tech.numericable.fr ([82.216.111.39]:41106 "EHLO
	smtp3.tech.numericable.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755026AbaIPTw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 15:52:26 -0400
In-Reply-To: <20140916.145435.714034191389495557.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/09/2014 20:54, David Miller wrote:
> From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
> Date: Mon, 15 Sep 2014 12:28:13 +0200
> 
>> If we cache them, the kernel will reuse them, independently of
>> whether forwarding is enabled or not.  Which means that if forwarding is
>> disabled on the input interface where the first routing request comes
>> from, then that unreachable result will be cached and reused for
>> other interfaces, even if forwarding is enabled on them.
>>
>> This can be verified with two interfaces A and B and an output interface
>> C, where B has forwarding enabled, but not A and trying
>> ip route get $dst iif A from $src && ip route get $dst iif B from $src
>>
>> Signed-off-by: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
>> ---
>> v2: simplify patch using julian anastasov's suggestion.
> 
> This also disables caching for the cases of a simple fib lookup failure.

Caching is already not done on a fib lookup failure. On which fib_info
would you cache anyway ? res.fi is already NULL in this case.

> Handle cached route invalidation the way it's meant to be, by bumping
> the rt_genid.
>
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 214882e..aa4e63c 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1965,6 +1965,8 @@ static void inet_forward_change(struct net *net)
>  		}
>  		rcu_read_unlock();
>  	}
> +
> +	rt_cache_flush(net);
>  }
>  
>  static int devinet_conf_ifindex(struct net *net, struct ipv4_devconf *cnf)

This doesn't solve the problem. Flushing the cache only changes how the
bug manifests:

ip route flush cache
ip route get 10.0.0.1 from 10.0.0.2 iif A
# unreachable (because forwarding on A is disabled). This is cached.
ip route get 10.0.0.1 from 10.0.0.2 iif B
# unreachable (at first fib_lookup finds it reachable and forwarding on
B is enabled. And then there is a valid cache entry, which is reused
blindly even if it says "unreachable").

ip route flush cache
ip route get 10.0.0.1 from 10.0.0.2 iif B
# reachable (because forwarding on B is enabled).  This is cached
ip route get 10.0.0.1 from 10.0.0.2 iif A
# reachable (forwarding on A is disabled, so it is unreachable
initially.  But there is a valid cache entry, which says "reachable",
which is reused)
