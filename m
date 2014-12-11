From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] Fix race condition between vxlan_sock_add and
 vxlan_sock_release
Date: Thu, 11 Dec 2014 14:57:40 -0500 (EST)
Message-ID: <20141211.145740.2133438308870305336.davem@davemloft.net>
References: <125fcb71bfb239711f03d3344b4275b304db6bb8.1418298054.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758765AbaLKT5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 14:57:43 -0500
In-Reply-To: <125fcb71bfb239711f03d3344b4275b304db6bb8.1418298054.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Thu, 11 Dec 2014 10:02:22 -0200

> Currently, when trying to reuse a socket, vxlan_sock_add will grab
> vn->sock_lock, locate a reusable socket, inc refcount and release
> vn->sock_lock.
> 
> But vxlan_sock_release() will first decrement refcount, and then grab
> that lock. refcnt operations are atomic but as currently we have
> deferred works which hold vs->refcnt each, this might happen, leading to
> a use after free (specially after vxlan_igmp_leave):
> 
>   CPU 1                            CPU 2
> 
> deferred work                    vxlan_sock_add
>   ...                              ...
>                                    spin_lock(&vn->sock_lock)
>                                    vs = vxlan_find_sock();
>   vxlan_sock_release
>     dec vs->refcnt, reaches 0
>     spin_lock(&vn->sock_lock)
>                                    vxlan_sock_hold(vs), refcnt=1
>                                    spin_unlock(&vn->sock_lock)
>     hlist_del_rcu(&vs->hlist);
>     vxlan_notify_del_rx_port(vs)
>     spin_unlock(&vn->sock_lock)
> 
> 
> So when we look for a reusable socket, we check if it wasn't freed
> already before reusing it.
> 
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Fixes: 7c47cedf43a8b3 ("vxlan: move IGMP join/leave to work queue")

Applied and queued up for -stable, thanks.
