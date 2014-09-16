From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] ipv4: Do not cache routing failures due to disabled
 forwarding.
Date: Tue, 16 Sep 2014 14:54:35 -0400 (EDT)
Message-ID: <20140916.145435.714034191389495557.davem@davemloft.net>
References: <54143FB2.9000600@green-communications.fr>
	<1410776893-5284-1-git-send-email-nicolas.cavallari@green-communications.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: nicolas.cavallari@green-communications.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755137AbaIPSyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 14:54:40 -0400
In-Reply-To: <1410776893-5284-1-git-send-email-nicolas.cavallari@green-communications.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Date: Mon, 15 Sep 2014 12:28:13 +0200

> If we cache them, the kernel will reuse them, independently of
> whether forwarding is enabled or not.  Which means that if forwarding is
> disabled on the input interface where the first routing request comes
> from, then that unreachable result will be cached and reused for
> other interfaces, even if forwarding is enabled on them.
> 
> This can be verified with two interfaces A and B and an output interface
> C, where B has forwarding enabled, but not A and trying
> ip route get $dst iif A from $src && ip route get $dst iif B from $src
> 
> Signed-off-by: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
> ---
> v2: simplify patch using julian anastasov's suggestion.

This also disables caching for the cases of a simple fib lookup failure.

Handle cached route invalidation the way it's meant to be, by bumping
the rt_genid.

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 214882e..aa4e63c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1965,6 +1965,8 @@ static void inet_forward_change(struct net *net)
 		}
 		rcu_read_unlock();
 	}
+
+	rt_cache_flush(net);
 }
 
 static int devinet_conf_ifindex(struct net *net, struct ipv4_devconf *cnf)
