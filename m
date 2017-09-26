From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] l2tp: fix race condition in l2tp_tunnel_delete
Date: Tue, 26 Sep 2017 10:34:41 -0700 (PDT)
Message-ID: <20170926.103441.1994262467184186990.davem@davemloft.net>
References: <d6011f741f7ea38a61006b9f2cde8e544b4d206b.1506432922.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, g.nault@alphalink.fr, lucien.xin@gmail.com,
        tparkin@katalix.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60922 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964826AbdIZRem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 13:34:42 -0400
In-Reply-To: <d6011f741f7ea38a61006b9f2cde8e544b4d206b.1506432922.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 26 Sep 2017 16:16:43 +0200

> If we try to delete the same tunnel twice, the first delete operation
> does a lookup (l2tp_tunnel_get), finds the tunnel, calls
> l2tp_tunnel_delete, which queues it for deletion by
> l2tp_tunnel_del_work.
> 
> The second delete operation also finds the tunnel and calls
> l2tp_tunnel_delete. If the workqueue has already fired and started
> running l2tp_tunnel_del_work, then l2tp_tunnel_delete will queue the
> same tunnel a second time, and try to free the socket again.
> 
> Add a dead flag to prevent firing the workqueue twice. Then we can
> remove the check of queue_work's result that was meant to prevent that
> race but doesn't.
> 
> Reproducer:
> 
>     ip l2tp add tunnel tunnel_id 3000 peer_tunnel_id 4000 local 192.168.0.2 remote 192.168.0.1 encap udp udp_sport 5000 udp_dport 6000
>     ip l2tp add session name l2tp1 tunnel_id 3000 session_id 1000 peer_session_id 2000
>     ip link set l2tp1 up
>     ip l2tp del tunnel tunnel_id 3000
>     ip l2tp del tunnel tunnel_id 3000
> 
> Fixes: f8ccac0e4493 ("l2tp: put tunnel socket release on a workqueue")
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
