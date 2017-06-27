From: David Miller <davem@davemloft.net>
Subject: Re: RFC: sk leak in sock_graft?
Date: Tue, 27 Jun 2017 15:38:16 -0400 (EDT)
Message-ID: <20170627.153816.46774843898605825.davem@davemloft.net>
References: <20170624130827.GD6901@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44638 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbdF0TiS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 15:38:18 -0400
In-Reply-To: <20170624130827.GD6901@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sat, 24 Jun 2017 09:08:27 -0400

> We're seeing a memleak when we run an infinite loop that 
> loads/unloads rds-tcp, and runs some traffic between each 
> load/unload.
> 
> Analysis shows that this is happening for the following reason:
> 
> inet_accept -> sock_graft does
> 	parent->sk = sk
> but if the parent->sk was previously pointing at some other
> struct sock "old_sk" (happens in the case of rds_tcp_accept_one()
> which has historically called sock_create_kern() to set up
> the new_sock), we need to sock_put(old_sk), else we'd leak it.
> 
> In general, sock_graft() is cutting loose the parent->sk,
> so it looks like it needs to release its refcnt on it?
> 
> Patch below takes care of the leak in our case, but I could use
> some input on other locking considerations, and if this is ok
> with other modules that use sock_graft()

It could simply be the case that rds-tcp is the first setup that
created that situation where there is a parent->sk already.

In all of the normal accept*() code paths, a plain struct socket
is allocated and nothing sets newsock->sk to anything before that
sock_graft() call.

Why does rds-tcp need to call sock_graft() without those invariants
met?

Thanks.
