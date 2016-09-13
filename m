From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] sctp: hold the transport before using it in
 sctp_hash_cmp
Date: Tue, 13 Sep 2016 11:45:35 -0400 (EDT)
Message-ID: <20160913.114535.186471066793791952.davem@davemloft.net>
References: <8e671aa0baca387f230bf8f6fc5ecbbb091866f6.1473520283.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40314 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754132AbcIMPpg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:45:36 -0400
In-Reply-To: <8e671aa0baca387f230bf8f6fc5ecbbb091866f6.1473520283.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 10 Sep 2016 23:11:23 +0800

> Since commit 4f0087812648 ("sctp: apply rhashtable api to send/recv
> path"), sctp uses transport rhashtable with .obj_cmpfn sctp_hash_cmp,
> in which it compares the members of the transport with the rhashtable
> args to check if it's the right transport.
> 
> But sctp uses the transport without holding it in sctp_hash_cmp, it can
> cause a use-after-free panic. As after it gets transport from hashtable,
> another CPU may close the sk and free the asoc. In sctp_association_free,
> it frees all the transports, meanwhile, the assoc's refcnt may be reduced
> to 0, assoc can be destroyed by sctp_association_destroy.
> 
> So after that, transport->assoc is actually an unavailable memory address
> in sctp_hash_cmp. Although sctp_hash_cmp is under rcu_read_lock, it still
> can not avoid this, as assoc is not freed by RCU.
> 
> This patch is to hold the transport before checking it's members with
> sctp_transport_hold, in which it checks the refcnt first, holds it if
> it's not 0.
> 
> Fixes: 4f0087812648 ("sctp: apply rhashtable api to send/recv path")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.
