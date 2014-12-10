From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Fix race condition between vxlan_sock_add and
 vxlan_sock_release
Date: Wed, 10 Dec 2014 13:11:33 -0500 (EST)
Message-ID: <20141210.131133.729833991671277249.davem@davemloft.net>
References: <e76bb0b4377c56583148323ada9b479e4628e35e.1418135271.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932497AbaLJSLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 13:11:38 -0500
In-Reply-To: <e76bb0b4377c56583148323ada9b479e4628e35e.1418135271.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Tue,  9 Dec 2014 12:28:28 -0200

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

Just make vxlan_sock_add() do atomic_add_unless(x, 1, 0), that way
if vxlan_sock_add() sees the count at zero it can just act as if
no such reusable socket exists.
