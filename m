From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] inetpeer: add namespace support for
 inetpeer
Date: Tue, 05 Jun 2012 10:57:06 +0200
Message-ID: <1338886626.2760.2109.camel@edumazet-glaptop>
References: <1338882737-11914-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: serge.hallyn@canonical.com, ebiederm@xmission.com,
	herbert@gondor.apana.org.au, steffen.klassert@secunet.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59079 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758023Ab2FEI5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 04:57:12 -0400
Received: by bkcji2 with SMTP id ji2so4389285bkc.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 01:57:10 -0700 (PDT)
In-Reply-To: <1338882737-11914-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 15:52 +0800, Gao feng wrote:

> +static void __net_exit inetpeer_net_exit(struct net *net)
> +{
> +	inetpeer_invalidate_tree(net, AF_INET);
> +	kfree(net->ipv4.peers);
> +
> +	inetpeer_invalidate_tree(net, AF_INET6);
> +	kfree(net->ipv6.peers);
> +}
> +

Are we 1000% sure no code ever run in inetpeer land after this call ?

I would add
	net->ipv4.peers = NULL;
	net->ipv6.peers = NULL;

to catch NULL deref instead of strange errors, just in case.

By the way, I think we have a bug in inetpeer_gc_worker()

Steffen ?

We have no rcu grace period to make sure the following is safe :

if (!atomic_read(&p->refcnt)) {
	list_del(&p->gc_list);
	kmem_cache_free(peer_cachep, p);
}

I'll post a fix like :

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index d4d61b6..07731b5 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -137,7 +137,7 @@ static void inetpeer_gc_worker(struct work_struct *work)
 
 		n = list_entry(p->gc_list.next, struct inet_peer, gc_list);
 
-		if (!atomic_read(&p->refcnt)) {
+		if (atomic_cmpxchg(&p->refcnt, 0, -1) == 0) {
 			list_del(&p->gc_list);
 			kmem_cache_free(peer_cachep, p);
 		}
